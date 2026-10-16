#!/usr/bin/env python3
"""Prepare dataset-grouped throughput and channel-marker CSVs for XY plotting.

Measurement logs provide elapsed processing time and cumulative IQ sample counts.
SigMF metadata supplies the capture sample rate and channel-change positions.
Output series share a recording-time coordinate system so implementations with
different processing speeds can be compared against the same channel boundaries.

Example:
    Run from the repository root::

        python3 Experiments/throughput/preprocess_throughput.py
"""

import argparse
import csv
from itertools import zip_longest
import json
import math
from pathlib import Path
import re


SCRIPT_DIR = Path(__file__).resolve().parent
ENERGY_DIR = SCRIPT_DIR.parent / "energy"
CAPTURE_DIR = SCRIPT_DIR.parents[1] / "AI-model-CNN-Channel-est/data/raw_capture"


def dataset_name(stem):
    """Normalize a measurement or capture filename stem to its dataset name.

    Args:
        stem (str): Filename without its extension. Supported aliases include
            desktop_/cu_ prefixes, trailing _YYYYMMDD dates, and stresstest.

    Returns:
        str: Canonical dataset name used to match logs with capture metadata.
    """
    name = re.sub(r"^(?:desktop_|cu_)", "", stem)
    name = re.sub(r"_\d{8}$", "", name)
    return "stress_test" if name == "stresstest" else name


def read_capture(path):
    """Read a capture's sample rate and successive frequency changes.

    Args:
        path (Path): SigMF metadata file to read.

    Returns:
        tuple: Sample rate in complex IQ samples per second and a list of
        (sample_start, recording_s, from_frequency_MHz, to_frequency_MHz)
        tuples. Initial tuning and frequency differences within 1 Hz are omitted.

    Raises:
        OSError: If the metadata file cannot be read.
        ValueError: If JSON or numeric values are invalid, the sample rate is
            nonpositive, capture positions are not strictly increasing and
            nonnegative, frequencies are nonfinite, or captures are absent.
        KeyError: If a required SigMF field is missing.
        TypeError: If metadata values have incompatible types.
    """
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
    """Calculate interval throughput at recording-time midpoints.

    Args:
        path (Path): Measurement CSV containing phase, elapsed_s, and
            samples_processed columns.
        rate (float): Positive capture sample rate in complex IQ samples per
            second, as validated by read_capture().

    Returns:
        tuple: A list of (recording_s, throughput_MSamples_s) pairs, the final
        cumulative sample count, and a boolean indicating a final end row.
        Zero-progress intervals are retained with zero throughput.

    Raises:
        OSError: If the measurement file cannot be read.
        ValueError: If the log lacks a start row and later reading, numeric
            values are invalid or negative, elapsed time does not increase,
            or the cumulative sample count decreases.
        KeyError: If a required CSV column is missing.
        TypeError: If a required CSV value is missing or has an incompatible type.
    """
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
            # Sample-space midpoints align runs without resampling their data.
            points.append(((previous_samples + samples) / (2 * rate),
                           count / dt / 1e6))
        previous_time, previous_samples = elapsed, samples
    return points, previous_samples, rows[-1]["phase"] == "end"


def write_csv(path, header, rows):
    """Write a header and data rows, replacing any existing destination file.

    Args:
        path (Path): Destination file whose parent directory already exists.
        header (Iterable[str]): CSV column names.
        rows (Iterable[Iterable]): Data rows; empty strings produce blank cells.

    Raises:
        OSError: If the destination cannot be opened or written.
        csv.Error: If the CSV writer cannot serialize a row.
    """
    with path.open("w", newline="") as stream:
        writer = csv.writer(stream)
        writer.writerow(header)
        writer.writerows(rows)


def prepare(energy_dir, capture_dir, output_dir):
    """Group measurement logs and export throughput and channel-change CSVs.

    All inputs are parsed before output files are created. Each dataset receives
    adjacent X/Y pairs for its runs and a vertical-marker series, plus a separate
    table of all channel changes. Progress and partial-log notes go to stdout.

    Args:
        energy_dir (Path): Root containing measurement logs at */*/*.csv.
        capture_dir (Path): Directory containing matching .sigmf-meta files.
        output_dir (Path): Destination directory, created if necessary. Existing
            generated files for the same datasets are overwritten.

    Raises:
        OSError: If an input cannot be read or an output cannot be written.
        ValueError: If metadata matches are missing or ambiguous, no logs are
            found, or a capture or measurement log fails validation.
        KeyError: If an input lacks a required field or column.
        TypeError: If an input contains values with incompatible types.
        csv.Error: If CSV input or output cannot be processed.
    """
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
            # Include the results directory to distinguish NPU model variants.
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
            # Empty pairs separate vertical lines in spreadsheet XY charts.
            marker_points.extend([(seconds, 0), (seconds, top), ("", "")])
        header = []
        columns = []
        for label, points, _ in runs:
            header.extend([f"{label}:recording_s", f"{label}:throughput_MSamples_s"])
            columns.append(points)
        header.extend(["channel_change:recording_s", "channel_change:marker_MSamples_s"])
        columns.append(marker_points)
        # Preserve each run's own X coordinates and pad shorter series with gaps.
        rows = ([value for pair in row for value in pair]
                for row in zip_longest(*columns, fillvalue=("", "")))
        destination = output_dir / f"{name}_throughput.csv"
        write_csv(destination, header, rows)
        write_csv(output_dir / f"{name}_channel_changes.csv",
                  ["sample_start", "recording_s", "from_frequency_MHz", "to_frequency_MHz"],
                  changes)
        print(f"{destination}: {len(runs)} runs, {len(visible_changes)} visible channel changes")


def main():
    """Parse command-line paths and run preprocessing.

    Default paths are relative to this script rather than the working directory.
    Input and filesystem errors handled here are reported through argparse.

    Raises:
        SystemExit: If argument parsing requests an exit or preprocessing fails
            with a handled error (status 1).
    """
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--energy-dir", type=Path, default=ENERGY_DIR,
                        help="root containing */*/*.csv measurement logs")
    parser.add_argument("--capture-dir", type=Path, default=CAPTURE_DIR,
                        help="directory containing the raw capture .sigmf-meta files")
    parser.add_argument("--output-dir", type=Path, default=SCRIPT_DIR / "throughput_csv",
                        help="destination for generated CSVs (default: %(default)s)")
    args = parser.parse_args()
    try:
        prepare(args.energy_dir, args.capture_dir, args.output_dir)
    except (OSError, ValueError, KeyError, TypeError) as error:
        parser.exit(1, f"Cannot preprocess throughput: {error}\n")


if __name__ == "__main__":
    main()
