#pragma once

#include <Eigen/Core>
#include <complex>

namespace gr {
namespace ieee802_11 {
namespace equalizer {

class channel_ai_model
{
public:
    EIGEN_MAKE_ALIGNED_OPERATOR_NEW
    using complex = std::complex<float>;
    channel_ai_model();
    void refine(const complex* first, const complex* second, double ratio_x16,
                complex* channel);
    void update(const complex* baseline, const complex* pilots, double ratio_x16,
                complex* channel);
    static bool occupied(int bin) { return bin >= 6 && bin <= 58 && bin != 32; }
    static double snr_ratio(const complex* first, const complex* second);
    static float snr_feature(double ratio_x16);

private:
    Eigen::Matrix<float, 6, 70, Eigen::RowMajor> d_input;
    Eigen::Matrix<float, 12, 70, Eigen::RowMajor> d_hidden0;
    Eigen::Matrix<float, 12, 70, Eigen::RowMajor> d_hidden1;
    Eigen::Matrix<float, 2, 70, Eigen::RowMajor> d_residual;
    Eigen::Matrix<float, 61, 1> d_features;
    Eigen::Matrix<float, 16, 1> d_hidden;
    Eigen::Matrix<float, 26, 1> d_output;
};

}
}
}
