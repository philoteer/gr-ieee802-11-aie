#!/usr/bin/env python3
"""Measure estimator gating and make a reproducible, noisy ci16_le SigMF copy.

Requires NumPy and the installed GNU Radio ieee802_11 module. Calibration uses
short windows spread over the recording and the receiver's short/long sync.
SNR is the estimator's occupied-subcarrier LTS sum/difference metric, not power
averaged over packet gaps. Run --analyze-only to inspect a capture without copying.
"""

import argparse
import copy
import json
import math
from pathlib import Path
import re

import numpy as np


ROOT = Path(__file__).resolve().parents[2]
DEFAULT_SOURCE = ROOT / "AI-model-CNN-Channel-est/data/raw_capture/stress_test.sigmf-data"
DEFAULT_OUTPUT = Path(__file__).resolve().parent / "data/stress_test_awgn_15db.sigmf-data"
OCCUPIED = np.r_[6:32, 33:59]


def gate_thresholds():
    """Read the actual checked-in CPU and AIE model thresholds."""
    result = {}
    for split in ("by_frame", "by_channel"):
        for kind, name in (("CNN", "channel_cnn"), ("MLP", "channel_updater_mlp")):
            path = ROOT / f"gr-ieee802-11-modified/lib/equalizer/model/{name}_weights_{split}.h"
            result[f"CPU {split} {kind}"] = int(re.search(
                r"kGateSnrRatioX16\s*=\s*(\d+)", path.read_text())[1])
        for kind, name, constant in (
                ("CNN", "frame_equalizer_channel_ai", "kLsGateSnrRatioX16"),
                ("MLP", "frame_equalizer_channel_updater_mlp", "kGateSnrRatioX16")):
            path = ROOT / f"AI-model-CNN-Channel-est/kernel/channel_estimator/model/{name}_weights_{split}.h"
            result[f"AIE {split} {kind}"] = int(re.search(
                rf"{constant}\s*=\s*(\d+)", path.read_text())[1])
    return result


def training_measurements(samples):
    """Return (ratio_x16, signal_bin_power/64, noise_bin_power/64) per LTS pair.

    FFTs are unnormalized. Dividing per-bin powers by 64 puts white-noise
    power in time-domain IQ units. The known LTS signs cancel in both norms.
    Synchronization includes coarse and fine carrier-offset correction.
    """
    from gnuradio import blocks, gr
    import ieee802_11
    import pmt

    class TrainingSink(gr.sync_block):
        def __init__(self):
            gr.sync_block.__init__(self, "LTS measurements", [(np.complex64, 64)], [])
            self.first = None
            self.second_offset = None
            self.rows = []

        def work(self, inputs, outputs):
            vectors = inputs[0]
            base = self.nitems_read(0)
            starts = {tag.offset for tag in self.get_tags_in_window(
                0, 0, len(vectors), pmt.intern("wifi_start"))}
            for index, vector in enumerate(vectors):
                offset = base + index
                if offset in starts:
                    self.first = np.fft.fftshift(np.fft.fft(vector))[OCCUPIED]
                    self.second_offset = offset + 1
                elif offset == self.second_offset:
                    second = np.fft.fftshift(np.fft.fft(vector))[OCCUPIED]
                    plus = float(np.sum(np.abs(self.first + second) ** 2))
                    minus = float(np.sum(np.abs(self.first - second) ** 2))
                    ratio = 16 * plus / minus if minus else float("inf")
                    signal = max(0.0, (plus - minus) / (4 * 52 * 64))
                    noise = minus / (2 * 52 * 64)
                    self.rows.append((ratio, signal, noise))
                    self.second_offset = None
            return len(vectors)

    graph = gr.top_block()
    source = blocks.vector_source_c(samples, False)
    delay16 = blocks.delay(gr.sizeof_gr_complex, 16)
    conjugate = blocks.conjugate_cc()
    product = blocks.multiply_cc()
    correlation = blocks.moving_average_cc(48, 1, 4000)
    magnitude = blocks.complex_to_mag()
    power = blocks.complex_to_mag_squared()
    average = blocks.moving_average_ff(64, 1, 4000)
    divide = blocks.divide_ff()
    short = ieee802_11.sync_short(0.56, 2, False, False)
    delay320 = blocks.delay(gr.sizeof_gr_complex, 320)
    long = ieee802_11.sync_long(320, False, False)
    vectors = blocks.stream_to_vector(gr.sizeof_gr_complex, 64)
    sink = TrainingSink()
    graph.connect(source, delay16, conjugate, (product, 1))
    graph.connect(source, (product, 0))
    graph.connect(product, correlation, magnitude, (divide, 0))
    graph.connect(source, power, average, (divide, 1))
    graph.connect(delay16, (short, 0))
    graph.connect(correlation, (short, 1))
    graph.connect(divide, (short, 2))
    graph.connect(short, (long, 0))
    graph.connect(short, delay320, (long, 1))
    graph.connect(long, vectors, sink)
    graph.run()
    return np.asarray(sink.rows, dtype=np.float64).reshape(-1, 3)


def analyze(path, sample_rate, windows, window_seconds):
    data = np.memmap(path, dtype="<i2", mode="r").reshape(-1, 2)
    length = min(len(data), round(sample_rate * window_seconds))
    starts = np.unique(np.linspace(0, len(data) - length, windows, dtype=np.int64))
    rows = []
    for start in starts:
        iq = data[start:start + length].astype(np.float32)
        samples = iq[:, 0] + 1j * iq[:, 1]
        rows.append(training_measurements(samples))
    measurements = np.concatenate(rows)
    if not len(measurements):
        raise ValueError("No training-symbol pairs detected in analysis windows")
    return measurements, {"window_starts": starts.tolist(), "window_samples": length}


def summarize(measurements, gates):
    ratios = measurements[:, 0]
    snr = 10 * np.log10(np.maximum(ratios, np.finfo(float).tiny) / 32)
    return {
        "detected_lts_pairs": len(ratios),
        "snr_db_percentiles": dict(zip(("p05", "p50", "p95"),
                                       np.percentile(snr, [5, 50, 95]).tolist())),
        "gates": {name: {"ratio_x16": gate,
                         "threshold_db": 10 * math.log10(gate / 32),
                         "bypassed_pairs": int(np.count_nonzero(ratios >= gate)),
                         "bypassed_percent": float(100 * np.mean(ratios >= gate))}
                  for name, gate in gates.items()},
    }


def noisy_copy(source, output, noise_power, seed, chunk_samples):
    """Stream interleaved int16 IQ, add independent real/imag AWGN, round, saturate."""
    rng = np.random.default_rng(seed)
    sigma = math.sqrt(noise_power / 2)
    clipped = 0
    samples = 0
    with source.open("rb") as reader, output.open("xb") as writer:
        while True:
            iq = np.fromfile(reader, dtype="<i2", count=2 * chunk_samples)
            if not len(iq):
                break
            values = iq.astype(np.float64)
            values += rng.normal(0, sigma, len(iq))
            np.rint(values, out=values)
            clipped += int(np.count_nonzero((values < -32768) | (values > 32767)))
            np.clip(values, -32768, 32767, out=values)
            values.astype("<i2").tofile(writer)
            samples += len(iq) // 2
    return {"samples": samples, "clipped_components": clipped,
            "clipped_component_fraction": clipped / (2 * samples)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, default=DEFAULT_SOURCE)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--snr-db", type=float, default=15,
                        help="target median occupied-carrier SNR (default: 15 dB)")
    parser.add_argument("--seed", type=int, default=20261017)
    parser.add_argument("--windows", type=int, default=12)
    parser.add_argument("--window-seconds", type=float, default=0.1)
    parser.add_argument("--chunk-samples", type=int, default=1048576)
    parser.add_argument("--analyze-only", action="store_true")
    parser.add_argument("--report", type=Path, help="analysis-only JSON report destination")
    args = parser.parse_args()
    if (not math.isfinite(args.snr_db) or not math.isfinite(args.window_seconds)
            or args.windows < 1 or args.window_seconds <= 0 or args.chunk_samples < 1):
        parser.error("SNR must be finite; window count, duration and chunk size must be positive")
    source = args.source.resolve()
    metadata = json.loads(source.with_suffix(".sigmf-meta").read_text())
    global_fields = metadata["global"]
    if global_fields["core:datatype"] != "ci16_le" or global_fields.get("core:num_channels", 1) != 1:
        parser.error("Expected a single-channel ci16_le SigMF dataset")
    if source.stat().st_size == 0 or source.stat().st_size % 4:
        parser.error("Input must contain whole interleaved int16 I/Q samples")
    rate = float(global_fields["core:sample_rate"])
    if not math.isfinite(rate) or rate <= 0 or round(rate * args.window_seconds) < 640:
        parser.error("Invalid sample rate or analysis window too short")
    gates = gate_thresholds()
    measurements, sampling = analyze(source, rate, args.windows, args.window_seconds)
    report = {"source": str(source), "sampling": sampling,
              "before": summarize(measurements, gates)}
    if args.analyze_only:
        if args.report:
            args.report.parent.mkdir(parents=True, exist_ok=True)
            args.report.write_text(json.dumps(report, indent=2) + "\n")
        print(json.dumps(report, indent=2))
        return

    # Solve per packet for the extra white-noise power, then use the median.
    # This subtracts measured existing noise and avoids the idle-gap power bias.
    target = 10 ** (args.snr_db / 10)
    noise_power = float(np.median(measurements[:, 1] / target - measurements[:, 2]))
    if not math.isfinite(noise_power) or noise_power <= 0:
        parser.error("Target is not below measured SNR; AWGN cannot increase SNR")
    output = args.output.resolve()
    meta_output = output.with_suffix(".sigmf-meta")
    report_output = output.with_suffix(".awgn.json")
    if output.suffix != ".sigmf-data":
        parser.error("Output must have .sigmf-data suffix")
    if any(path.exists() for path in (output, meta_output, report_output)):
        parser.error("Output data, metadata or report already exists; choose a new output")
    output.parent.mkdir(parents=True, exist_ok=True)
    print(f"Writing {source.stat().st_size:,} bytes to {output}", flush=True)
    report["injection"] = {"target_snr_db": args.snr_db, "seed": args.seed,
                           "complex_noise_power_int16_units": noise_power,
                           "component_sigma_int16_units": math.sqrt(noise_power / 2),
                           "chunk_samples": args.chunk_samples,
                           **noisy_copy(source, output, noise_power, args.seed, args.chunk_samples)}
    result = copy.deepcopy(metadata)
    result["global"].pop("core:sha512", None)
    result["global"]["core:dataset"] = output.name
    result["global"]["core:description"] = (
        global_fields.get("core:description", "")
        + f"; AWGN added, target median LTS SNR {args.snr_db:g} dB, seed {args.seed}; "
        + f"see {report_output.name}")
    meta_output.write_text(json.dumps(result, indent=2) + "\n")
    after, _ = analyze(output, rate, args.windows, args.window_seconds)
    report["after"] = summarize(after, gates)
    report["output"] = str(output)
    report_output.write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
