#!/usr/bin/env python3
"""Measure estimator gating and calibrate AWGN for a ci16_le SigMF capture.

Requires NumPy and the installed GNU Radio ieee802_11 module. Calibration uses
short windows spread over the recording and the receiver's short/long sync.
SNR is the estimator's occupied-subcarrier LTS sum/difference metric, not power
averaged over packet gaps. This script only reads IQ data; its JSON report can
be passed to add_awgn.py to create a noisy copy.
"""

import argparse
import json
import math
from pathlib import Path
import re

import numpy as np


ROOT = Path(__file__).resolve().parents[2]
DEFAULT_SOURCE = ROOT / "AI-model-CNN-Channel-est/data/raw_capture/stress_test.sigmf-data"
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


def analyze_capture(source, windows=12, window_seconds=0.1, snr_db=15):
    """Return SNR/gate statistics and the noise budget for a target median SNR."""
    if (not math.isfinite(snr_db) or not math.isfinite(window_seconds)
            or windows < 1 or window_seconds <= 0):
        raise ValueError("SNR must be finite; window count and duration must be positive")
    source = source.resolve()
    metadata = json.loads(source.with_suffix(".sigmf-meta").read_text())
    fields = metadata["global"]
    if fields["core:datatype"] != "ci16_le" or fields.get("core:num_channels", 1) != 1:
        raise ValueError("Expected a single-channel ci16_le SigMF dataset")
    if source.stat().st_size == 0 or source.stat().st_size % 4:
        raise ValueError("Input must contain whole interleaved int16 I/Q samples")
    rate = float(fields["core:sample_rate"])
    if not math.isfinite(rate) or rate <= 0 or round(rate * window_seconds) < 640:
        raise ValueError("Invalid sample rate or analysis window too short")
    measurements, sampling = analyze(source, rate, windows, window_seconds)
    # Subtract existing noise before taking the median per-packet noise budget.
    target = 10 ** (snr_db / 10)
    noise_power = float(np.median(measurements[:, 1] / target - measurements[:, 2]))
    return {"source": str(source), "sampling": sampling,
            "before": summarize(measurements, gate_thresholds()),
            "calibration": {"target_snr_db": snr_db,
                            "complex_noise_power_int16_units": noise_power}}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, default=DEFAULT_SOURCE)
    parser.add_argument("--snr-db", type=float, default=15,
                        help="target median occupied-carrier SNR (default: 15 dB)")
    parser.add_argument("--windows", type=int, default=12)
    parser.add_argument("--window-seconds", type=float, default=0.1)
    parser.add_argument("--report", type=Path, help="JSON report destination")
    args = parser.parse_args()
    try:
        report = analyze_capture(args.source, args.windows, args.window_seconds, args.snr_db)
    except ValueError as error:
        parser.error(str(error))
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
