#!/usr/bin/env python3
"""Run capture analysis, AWGN injection, and output analysis together.

The standalone tools are analyze_capture.py and add_awgn.py. This wrapper
retains the original CLI, including --analyze-only and all default paths.
"""

import argparse
import json
from pathlib import Path

from add_awgn import DEFAULT_OUTPUT, inject_awgn
from analyze_capture import DEFAULT_SOURCE, analyze_capture


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
    try:
        if args.seed < 0 or args.chunk_samples < 1:
            raise ValueError("Seed must be nonnegative and chunk size must be positive")
        report = analyze_capture(args.source, args.windows, args.window_seconds, args.snr_db)
        if args.analyze_only:
            if args.report:
                args.report.parent.mkdir(parents=True, exist_ok=True)
                args.report.write_text(json.dumps(report, indent=2) + "\n")
        else:
            calibration = report.pop("calibration")
            report.update(inject_awgn(
                args.source, args.output, calibration["complex_noise_power_int16_units"],
                args.seed, args.chunk_samples, args.snr_db))
            after = analyze_capture(args.output, args.windows, args.window_seconds, args.snr_db)
            report["after"] = after["before"]
            args.output.with_suffix(".awgn.json").write_text(json.dumps(report, indent=2) + "\n")
    except ValueError as error:
        parser.error(str(error))
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
