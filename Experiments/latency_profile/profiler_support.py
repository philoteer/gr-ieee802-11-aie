"""Export host-side NPU stage measurements."""

import atexit
import csv
import math
from collections import defaultdict
from pathlib import Path


def summarize_intra(raw_path, summary_path):
    # Online moments keep memory bounded even for very large captures.
    groups = defaultdict(lambda: [0, 0.0, 0.0, math.inf, 0, 0])
    with Path(raw_path).open(newline="") as stream:
        for row in csv.DictReader(stream):
            value = int(row["duration_ns"])
            key = row["scope"], row["stage"]
            acc = groups[key]
            acc[0] += 1
            delta = value - acc[1]
            acc[1] += delta / acc[0]
            acc[2] += delta * (value - acc[1])
            acc[3] = min(acc[3], value)
            acc[4] = max(acc[4], value)
            acc[5] += value
    if not groups:
        raise RuntimeError(f"No NPU chunks were profiled in {raw_path}")
    with Path(summary_path).open("w", newline="") as stream:
        writer = csv.writer(stream)
        writer.writerow(("scope", "stage", "count", "total_ns", "mean_ns",
                         "stddev_ns", "min_ns", "max_ns"))
        for (scope, stage), (count, mean, m2, low, high, total) in groups.items():
            writer.writerow((scope, stage, count, total, mean,
                             math.sqrt(max(0, m2 / count)), low, high))
            print(f"{scope}/{stage}: {mean / 1e3:.3f} us (n={count})")


class ProfileSession:
    """GRC main snippets call finish at EOF; atexit also covers Ctrl-C/SIGTERM."""

    def __init__(self, tb, output_dir):
        self.tb = tb
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.finished = False
        phy = tb.mlir_aie_mlir_aie_80211_phy_0
        if not hasattr(phy, "start_profiling"):
            raise RuntimeError("Build with build-local.sh and launch with run-profile.sh "
                               "to load the local profiling module")
        phy.start_profiling(str(self.output_dir / "intra_raw.csv"))
        atexit.register(self.finish)

    def finish(self):
        if self.finished:
            return
        self.finished = True
        self.tb.stop()
        self.tb.wait()
        self.tb.mlir_aie_mlir_aie_80211_phy_0.stop_profiling()
        summarize_intra(self.output_dir / "intra_raw.csv",
                        self.output_dir / "intra_summary.csv")
        print(f"Profile saved in {self.output_dir}")
