#!/usr/bin/env python3
"""Summarize CPU and NVIDIA GPU measurements from s80211.grc."""

import argparse
import csv
from pathlib import Path


DEFAULT_CSV = Path("/home/piloteer/바탕화면/WiFi_Paper_Data/SUB/tmp_out/gr_ieee80211_energy.csv")


def summarize(path):
    with Path(path).open(newline="") as stream:
        rows = list(csv.DictReader(stream))
    if len(rows) < 2 or rows[0]["phase"] != "start":
        raise ValueError("CSV needs a start reading and at least one later reading")
    duration = float(rows[-1]["elapsed_s"]) - float(rows[0]["elapsed_s"])
    if duration <= 0:
        raise ValueError("Run duration must be positive")
    for previous, current in zip(rows, rows[1:]):
        dt = float(current["elapsed_s"]) - float(previous["elapsed_s"])
        if dt <= 0:
            raise ValueError("CSV timestamps must be strictly increasing")
        for sensor in ("cpu", "gpu"):
            if float(current[f"{sensor}_energy_j"]) < float(previous[f"{sensor}_energy_j"]):
                raise ValueError(f"Cumulative {sensor.upper()} energy must not decrease")
        if current["gpu_uuid"] != previous["gpu_uuid"]:
            raise ValueError("GPU identity changed during the recording")
    return {
        "complete": rows[-1]["phase"] == "end",
        "readings": len(rows),
        "domain": rows[0]["rapl_domain"],
        "duration_s": duration,
        "samples": int(rows[-1]["samples_processed"]),
        "cpu_j": float(rows[-1]["cpu_energy_j"]) - float(rows[0]["cpu_energy_j"]),
        "gpu_j": float(rows[-1]["gpu_energy_j"]) - float(rows[0]["gpu_energy_j"]),
        "gpu_name": rows[0]["gpu_name"],
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
    print(f"Recording: {'finalized' if result['complete'] else 'partial (no end reading)'}; "
          f"{result['readings']} readings")
    print(f"Elapsed: {seconds:.3f} s")
    print(f"Processed: {result['samples']:,} complex IQ samples")
    print(f"Throughput: {result['samples'] / seconds / 1e6:.3f} MSamples/s")
    for label, joules in (
        (f"CPU/package ({result['domain']})", result["cpu_j"]),
        (f"GPU/board ({result['gpu_name']}; estimated energy)", result["gpu_j"]),
        ("CPU + GPU", result["cpu_j"] + result["gpu_j"]),
    ):
        print(f"{label}: {joules:.3f} J ({joules / 3600:.6f} Wh); "
              f"average {joules / seconds:.3f} W")
        if result["samples"]:
            print(f"  Energy per million samples: {joules / result['samples'] * 1e6:.3f} J")
    print("GPU energy integrates NVML board power; CPU + GPU excludes other system components.")


if __name__ == "__main__":
    main()
