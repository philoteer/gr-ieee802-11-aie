#!/usr/bin/env python3
"""Convert GNU Radio probe-rate logs to one CSV per input log."""

import argparse
import csv
import math
from pathlib import Path
import re


SCRIPT_DIR = Path(__file__).resolve().parent
NUMBER = r"[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?"
RATE = re.compile(rf"\((rate_avg|rate_now)\s+\.\s+({NUMBER})\s*\)")
HEADER = (
    "reading",
    "rate_avg_samples_s",
    "rate_now_samples_s",
    "rate_avg_MSamples_s",
    "rate_now_MSamples_s",
)


def read_log(path):
    """Return ordered rate pairs, ignoring startup and debug-banner lines.

    Each rate-message line must contain exactly one finite, nonnegative value
    for each of rate_avg and rate_now. Report malformed messages with their
    source line number instead of silently dropping measurements.
    """
    readings = []
    with path.open(encoding="utf-8") as stream:
        for line_number, line in enumerate(stream, 1):
            if "rate_avg" not in line and "rate_now" not in line:
                continue
            matches = RATE.findall(line)
            rates = {key: float(value) for key, value in matches}
            if (
                len(matches) != 2
                or set(rates) != {"rate_avg", "rate_now"}
                or any(not math.isfinite(value) or value < 0 for value in rates.values())
            ):
                raise ValueError(f"{path}:{line_number}: invalid rate message")
            readings.append((rates["rate_avg"], rates["rate_now"]))
    if not readings:
        raise ValueError(f"{path}: no rate messages found")
    return readings


def convert_logs(input_dir, output_dir):
    """Parse all .log files before writing matching .csv files."""
    paths = sorted(input_dir.glob("*.log"))
    if not paths:
        raise ValueError(f"No .log files found in {input_dir}")
    parsed = [(path, read_log(path)) for path in paths]
    output_dir.mkdir(parents=True, exist_ok=True)
    for path, readings in parsed:
        destination = output_dir / path.with_suffix(".csv").name
        with destination.open("w", newline="", encoding="utf-8") as stream:
            writer = csv.writer(stream)
            writer.writerow(HEADER)
            for index, (average, current) in enumerate(readings, 1):
                writer.writerow((index, average, current, average / 1e6, current / 1e6))
        print(f"{path.name} -> {destination} ({len(readings)} readings)")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--input-dir", type=Path, default=SCRIPT_DIR / "magsq_avg_cf",
        help="Directory containing .log files (default: %(default)s).",
    )
    parser.add_argument(
        "--output-dir", type=Path,
        help="CSV destination (default: the input directory).",
    )
    args = parser.parse_args()
    try:
        convert_logs(args.input_dir, args.output_dir or args.input_dir)
    except (OSError, ValueError) as error:
        parser.exit(1, f"error: {error}\n")


if __name__ == "__main__":
    main()
