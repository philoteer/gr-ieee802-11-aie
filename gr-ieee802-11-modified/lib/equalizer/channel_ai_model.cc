#include "channel_ai_model.h"
#include "model/channel_cnn_weights_by_frame.h"
#include "model/channel_updater_mlp_weights.h"
#include <algorithm>
#include <cmath>
#include <cstdint>
#include <limits>

namespace channel_model {
#include "model/channel_cnn_weights_by_channel.h"
}

namespace gr {
namespace ieee802_11 {
namespace equalizer {
namespace {

constexpr float q15_max = 32767.0f / 32768.0f;
constexpr int pilot_bins[] = {11, 25, 39, 53};
static_assert(sizeof(channel_cnn_weights::kW1) / sizeof(float) == 12 * 6 * 7,
              "CNN first-layer shape mismatch");
static_assert(sizeof(channel_cnn_weights::kW2) / sizeof(float) == 12 * 12 * 5,
              "CNN second-layer shape mismatch");
static_assert(sizeof(channel_cnn_weights::kW3) / sizeof(float) == 2 * 12 * 3,
              "CNN output-layer shape mismatch");
static_assert(sizeof(channel_updater_weights::kW1) / sizeof(float) == 4 * 16 * 61,
              "MLP first-layer shape mismatch");
static_assert(sizeof(channel_updater_weights::kW2) / sizeof(float) == 4 * 26 * 16,
              "MLP output-layer shape mismatch");

double component_max(channel_ai_model::complex value)
{
    return std::max(std::abs(double(value.real())), std::abs(double(value.imag())));
}

double normalization_scale(double maximum)
{
    if (!(maximum > 0) || !std::isfinite(maximum))
        return 1;
    int exponent;
    std::frexp(maximum, &exponent);
    return std::ldexp(1.0, exponent);
}

template <int Inputs, int Outputs, int Taps, bool Relu>
void convolution(const Eigen::Matrix<float, Inputs, 70, Eigen::RowMajor>& input,
                 Eigen::Matrix<float, Outputs, 70, Eigen::RowMajor>& output,
                 const float* weights)
{
    for (int out = 0; out < Outputs; ++out) {
        Eigen::Map<Eigen::Array<float, 1, 64>> values(output.data() + out * 70 + 3);
        values.setZero();
        for (int in = 0; in < Inputs; ++in) {
            for (int tap = 0; tap < Taps; ++tap) {
                const Eigen::Map<const Eigen::Array<float, 1, 64>> source(
                    input.data() + in * 70 + 3 + tap - Taps / 2);
                values += source * weights[(out * Inputs + in) * Taps + tap];
            }
        }
        if (Relu)
            values = values.max(0.0f);
    }
}

}

channel_ai_model::channel_ai_model(weights model)
{
    d_w1 = channel_cnn_weights::kW1;
    d_w2 = channel_cnn_weights::kW2;
    d_w3 = channel_cnn_weights::kW3;
    d_gate = channel_cnn_weights::kGateSnrRatioX16;
    if (model == weights::by_channel) {
        d_w1 = channel_model::channel_cnn_weights::kW1;
        d_w2 = channel_model::channel_cnn_weights::kW2;
        d_w3 = channel_model::channel_cnn_weights::kW3;
        d_gate = channel_model::channel_cnn_weights::kGateSnrRatioX16;
    }
    d_input.setZero();
    d_hidden0.setZero();
    d_hidden1.setZero();
    d_residual.setZero();
}

double channel_ai_model::snr_ratio(const complex* first, const complex* second)
{
    double signal = 0;
    double noise = 0;
    for (int bin = 6; bin <= 58; ++bin) {
        if (!occupied(bin))
            continue;
        const std::complex<double> a(first[bin]), b(second[bin]);
        signal += std::norm(a + b);
        noise += std::norm(a - b);
    }
    if (signal == 0)
        return 0;
    return noise == 0 ? std::numeric_limits<double>::infinity() : 16 * signal / noise;
}

float channel_ai_model::snr_feature(double ratio_x16)
{
    if (!(ratio_x16 > 32))
        return 0;
    if (ratio_x16 >= 320000)
        return q15_max;
    const auto ratio = static_cast<std::uint64_t>(ratio_x16);
    int exponent = 0;
    for (auto remaining = ratio; remaining >>= 1;)
        ++exponent;
    const auto mantissa = exponent >= 8 ? ratio >> (exponent - 8)
                                        : ratio << (8 - exponent);
    const auto logarithm = exponent * 256 + mantissa - 256 - 5 * 256;
    return float(std::min<std::uint64_t>(32767, logarithm * 32767 / 3402)) / 32768.0f;
}

void channel_ai_model::refine(const complex* first, const complex* second,
                              double ratio_x16, complex* channel)
{
    if (!(ratio_x16 < d_gate))
        return;
    double maximum = 0;
    for (int bin = 6; bin <= 58; ++bin) {
        if (occupied(bin))
            maximum = std::max(maximum, std::max(component_max(first[bin]),
                                                component_max(second[bin])));
    }
    const double scale = normalization_scale(maximum);
    if (maximum == 0)
        return;
    for (int bin = 0; bin < 64; ++bin) {
        const bool active = occupied(bin);
        if(active){
            d_input(0, bin + 3) = first[bin].real() / scale;
            d_input(1, bin + 3) = first[bin].imag() / scale;
            d_input(2, bin + 3) = second[bin].real() / scale;
            d_input(3, bin + 3) = second[bin].imag() / scale;
            d_input(4, bin + 3) = q15_max;
        }
        else{
            d_input(0, bin + 3) = 0;
            d_input(1, bin + 3) = 0;
            d_input(2, bin + 3) = 0;
            d_input(3, bin + 3) = 0;
            d_input(4, bin + 3) = 0;
        }
        d_input(5, bin + 3) = snr_feature(ratio_x16);
    }
    convolution<6, 12, 7, true>(d_input, d_hidden0, d_w1);
    convolution<12, 12, 5, true>(d_hidden0, d_hidden1, d_w2);
    convolution<12, 2, 3, false>(d_hidden1, d_residual, d_w3);
    for (int bin = 0; bin < 64; ++bin) {
        if (occupied(bin))
            channel[bin] += complex(d_residual(0, bin + 3) * scale,
                                    d_residual(1, bin + 3) * scale);
        else
            channel[bin] = 0;
    }
}

void channel_ai_model::update(const complex* baseline, const complex* pilots,
                              double ratio_x16, complex* channel)
{
    std::copy(baseline, baseline + 64, channel);
    if (!(ratio_x16 < channel_updater_weights::kGateSnrRatioX16))
        return;
    double maximum = 0;
    for (int bin = 6; bin <= 58; ++bin) {
        if (occupied(bin))
            maximum = std::max(maximum, component_max(baseline[bin]));
    }
    for (int pilot = 0; pilot < 4; ++pilot)
        maximum = std::max(maximum, component_max(pilots[pilot]));
    const double scale = normalization_scale(maximum);
    for (int pilot = 0; pilot < 4; ++pilot) {
        const complex delta = pilots[pilot] - baseline[pilot_bins[pilot]];
        d_features(52 + 2 * pilot) = std::max(-1.0, std::min(double(q15_max), delta.real() / scale));
        d_features(53 + 2 * pilot) = std::max(-1.0, std::min(double(q15_max), delta.imag() / scale));
    }
    d_features(60) = snr_feature(ratio_x16);
    for (int group = 0; group < 4; ++group) {
        const int half_start = group < 2 ? 6 : 33;
        for (int bin = 0; bin < 26; ++bin) {
            d_features(2 * bin) = baseline[half_start + bin].real() / scale;
            d_features(2 * bin + 1) = baseline[half_start + bin].imag() / scale;
        }
        using First = Eigen::Matrix<float, 16, 61, Eigen::RowMajor>;
        using Second = Eigen::Matrix<float, 26, 16, Eigen::RowMajor>;
        const Eigen::Map<const First> w1(channel_updater_weights::kW1 + group * 16 * 61);
        const Eigen::Map<const Second> w2(channel_updater_weights::kW2 + group * 26 * 16);
        d_hidden.noalias() = w1 * d_features;
        d_hidden = d_hidden.cwiseMax(0.0f).cwiseMin(q15_max);
        d_output.noalias() = w2 * d_hidden;
        d_output = d_output.cwiseMax(-1.0f).cwiseMin(q15_max);
        const int start = half_start + (group % 2) * 13;
        for (int bin = 0; bin < 13; ++bin)
            channel[start + bin] += complex(d_output(2 * bin) * scale,
                                            d_output(2 * bin + 1) * scale);
    }
}

}
}
}
