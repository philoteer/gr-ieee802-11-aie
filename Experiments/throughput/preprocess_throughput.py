#!/usr/bin/env python3
"""Prepare dataset-grouped throughput and channel-marker CSVs for XY plotting."""

import argparse
import csv
from itertools import zip_longest
import json
import math
from pathlib import Path
import re


ENERGY_DIR = Path(__file__).resolve().parent
CAPTURE_DIR = ENERGY_DIR.parents[1] / "AI-model-CNN-Channel-est/data/raw_capture"


def dataset_name(stem):
    """Normalize measurement prefixes and the existing capture-name aliases."""
    name = re.sub(r"^(?:desktop_|cu_)", "", stem)
    name = re.sub(r"_\d{8}$", "", name)
    return "stress_test" if name == "stresstest" else name


def read_capture(path):
    with path.open() as stream:
        metadata = json.load(stream)
    rate = float(metadata["global"]["core:sample_rate"])
    if not math.isfinite(rate) or rate <= 0:
        raise ValueError(f"{path}: sample rate must be finite and positive")
    changes = []
    previous_start = -1
    previous_frequency = None
    for capture in metadata["captures"]:
        start = int(capture["core:sample_start"])
        frequency = float(capture["core:frequency"])
        if start <= previous_start or not math.isfinite(frequency):
            raise ValueError(f"{path}: invalid capture position or frequency")
        # The initial tuning is not a channel change. Ignore repeated tuning
        # entries with the same frequency (allowing sub-Hz hardware rounding).
        if previous_frequency is not None and not math.isclose(
                frequency, previous_frequency, rel_tol=0, abs_tol=1):
            changes.append((start, start / rate,
                            previous_frequency / 1e6, frequency / 1e6))
        previous_start, previous_frequency = start, frequency
    if previous_start < 0:
        raise ValueError(f"{path}: no captures")
    return rate, changes


def read_throughput(path, rate):
    """Return (recording-time midpoint, interval MSamples/s) pairs."""
    with path.open(newline="") as stream:
        rows = list(csv.DictReader(stream))
    if len(rows) < 2 or rows[0]["phase"] != "start":
        raise ValueError(f"{path}: expected a start row and later readings")
    points = []
    previous_time = None
    previous_samples = None
    for line, row in enumerate(rows, 2):
        elapsed = float(row["elapsed_s"])
        samples = int(row["samples_processed"])
        if not math.isfinite(elapsed) or elapsed < 0 or samples < 0:
            raise ValueError(f"{path}:{line}: invalid time or sample count")
        if previous_time is not None:
            dt, count = elapsed - previous_time, samples - previous_samples
            if dt <= 0 or count < 0:
                raise ValueError(f"{path}:{line}: time must increase and counts must not decrease")
            points.append(((previous_samples + samples) / (2 * rate),
                           count / dt / 1e6))
        previous_time, previous_samples = elapsed, samples
    return points, previous_samples, rows[-1]["phase"] == "end"


def write_csv(path, header, rows):
    with path.open("w", newline="") as stream:
        writer = csv.writer(stream)
        writer.writerow(header)
        writer.writerows(rows)


def prepare(energy_dir, capture_dir, output_dir):
    captures = {}
    for path in sorted(capture_dir.glob("*.sigmf-meta")):
        name = dataset_name(path.stem)
        if name in captures:
            raise ValueError(f"Ambiguous metadata for dataset {name}")
        captures[name] = path
    grouped = {}
    for path in sorted(energy_dir.glob("*/*/*.csv")):
        name = dataset_name(path.stem)
        if name not in captures:
            raise ValueError(f"{path}: no matching metadata in {capture_dir}")
        grouped.setdefault(name, []).append(path)
    if not grouped:
        raise ValueError(f"No measurement CSVs found in {energy_dir}/*/*/*.csv")

    # Parse all inputs before creating output, so malformed logs fail early.
    prepared = []
    for name, paths in sorted(grouped.items()):
        rate, changes = read_capture(captures[name])
        runs = []
        for path in paths:
            points, samples, complete = read_throughput(path, rate)
            label = "/".join(path.relative_to(energy_dir).parts[:2])
            runs.append((label, points, samples))
            if not complete:
                print(f"Note: {path}: partial log (no end row)")
        prepared.append((name, changes, runs))

    output_dir.mkdir(parents=True, exist_ok=True)
    for name, changes, runs in prepared:
        max_samples = max(run[2] for run in runs)
        visible_changes = [change for change in changes if change[0] <= max_samples]
        top = max(y for _, points, _ in runs for _, y in points) * 1.05
        marker_points = []
        for _, seconds, _, _ in visible_changes:
            marker_points.extend([(seconds, 0), (seconds, top), ("", "")])
        header = []
        columns = []
        for label, points, _ in runs:
            header.extend([f"{label}:recording_s", f"{label}:throughput_MSamples_s"])
            columns.append(points)
        header.extend(["channel_change:recording_s", "channel_change:marker_MSamples_s"])
        columns.append(marker_points)
        rows = ([value for pair in row for value in pair]
                for row in zip_longest(*columns, fillvalue=("", "")))
        destination = output_dir / f"{name}_throughput.csv"
        write_csv(destination, header, rows)
        write_csv(output_dir / f"{name}_channel_changes.csv",
                  ["sample_start", "recording_s", "from_frequency_MHz", "to_frequency_MHz"],
                  changes)
        print(f"{destination}: {len(runs)} runs, {len(visible_changes)} visible channel changes")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--energy-dir", type=Path, default=ENERGY_DIR,
                        help="root containing */*/*.csv measurement logs")
    parser.add_argument("--capture-dir", type=Path, default=CAPTURE_DIR,
                        help="directory containing the raw capture .sigmf-meta files")
    parser.add_argument("--output-dir", type=Path, default=ENERGY_DIR / "throughput_csv",
                        help="destination for generated CSVs (default: %(default)s)")
    args = parser.parse_args()
    try:
        prepare(args.energy_dir, args.capture_dir, args.output_dir)
    except (OSError, ValueError, KeyError, TypeError) as error:
        parser.exit(1, f"Cannot preprocess throughput: {error}\n")


if __name__ == "__main__":
    main()
