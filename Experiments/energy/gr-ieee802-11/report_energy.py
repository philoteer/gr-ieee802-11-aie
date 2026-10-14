#!/usr/bin/env python3
"""Summarize CSV measurements from original.grc's embedded energy logger."""

import argparse
import csv
from pathlib import Path


DEFAULT_CSV = (Path(__file__).resolve().parents[3]
               / "AI-model-CNN-Channel-est/data/tmp_out/original_energy.csv")


def summarize(path):
    with Path(path).open(newline="") as stream:
        rows = list(csv.DictReader(stream))
    if len(rows) < 2 or rows[0]["phase"] != "start":
        raise ValueError("CSV needs a start reading and at least one later reading")
    duration = float(rows[-1]["elapsed_s"]) - float(rows[0]["elapsed_s"])
    if duration <= 0:
        raise ValueError("Run duration must be positive")
    system_j = 0.0
    battery_seconds = 0.0
    for previous, current in zip(rows, rows[1:]):
        dt = float(current["elapsed_s"]) - float(previous["elapsed_s"])
        if dt <= 0:
            raise ValueError("CSV timestamps must be strictly increasing")
        if float(current["soc_energy_j"]) < float(previous["soc_energy_j"]):
            raise ValueError("Cumulative RAPL energy must not decrease")
        # Do not interpolate across a plug/unplug transition or a missing reading.
        if all(row["ac_online"] == "0"
               and row["battery_status"] == "Discharging"
               and row["system_power_w"] != "" for row in (previous, current)):
            system_j += dt * (float(previous["system_power_w"])
                              + float(current["system_power_w"])) / 2
            battery_seconds += dt
    return {
        "complete": rows[-1]["phase"] == "end",
        "readings": len(rows),
        "domain": rows[0]["rapl_domain"],
        "duration_s": duration,
        "samples": int(rows[-1]["samples_processed"]),
        "soc_j": float(rows[-1]["soc_energy_j"]) - float(rows[0]["soc_energy_j"]),
        "system_j": system_j,
        "battery_seconds": battery_seconds,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("csv", nargs="?", type=Path, default=DEFAULT_CSV)
    args = parser.parse_args()
    try:
        result = summarize(args.csv)
    except (OSError, ValueError, KeyError) as error:
        parser.exit(1, f"Cannot summarize {args.csv}: {error}\n")
    seconds = result["duration_s"]
    print(f"CSV: {args.csv}")
    print(f"Run: {'complete' if result['complete'] else 'partial (no end reading)'}; "
          f"{result['readings']} readings")
    print(f"Elapsed: {seconds:.3f} s")
    print(f"Processed: {result['samples']:,} complex IQ samples")
    print(f"Throughput: {result['samples'] / seconds / 1e6:.3f} MSamples/s")
    print(f"SoC/package ({result['domain']}): {result['soc_j']:.3f} J "
          f"({result['soc_j'] / 3600:.6f} Wh); "
          f"average {result['soc_j'] / seconds:.3f} W")
    if result["samples"]:
        print(f"SoC/package energy per million samples: "
              f"{result['soc_j'] / result['samples'] * 1e6:.3f} J")
    coverage = result["battery_seconds"]
    if coverage:
        print(f"System (battery discharge): {result['system_j']:.3f} J "
              f"({result['system_j'] / 3600:.6f} Wh); "
              f"average {result['system_j'] / coverage:.3f} W")
        print(f"System measurement coverage: {coverage:.3f} s "
              f"({100 * coverage / seconds:.2f}% of run)")
        if coverage < seconds - 1e-6:
            print("System energy covers unplugged intervals only, not the entire run.")
    else:
        print("System energy: unavailable (no measured unplugged intervals)")


if __name__ == "__main__":
    main()
