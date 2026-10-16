"""Export GNU Radio work-time counters and host-side NPU stage measurements."""

import atexit
import csv
import math
from collections import defaultdict
from pathlib import Path

from gnuradio import gr


# Virtual source/sink blocks are wiring aliases and have no work function.
CHAIN = (
    "blocks_file_source_0",
    "blocks_interleaved_short_to_complex_0",
    "mlir_aie_sigmf_tag_injector_0",
    "mlir_aie_complex64_to_cint16_0",
    "mlir_aie_mlir_aie_80211_phy_0",
)


def export_inter(tb, path):
    """Read after wait(): wall time inside work(), excluding scheduler queues."""
    ticks_per_ns = gr.high_res_timer_tps() / 1e9
    fields = ("block", "input_items", "output_items", "processed_iq_samples",
              "total_work_ns", "gr_work_time_avg_ns", "gr_work_time_stddev_ns",
              "work_ns_per_iq_sample", "work_us_per_16384_samples")
    rows = []
    for name in CHAIN:
        block = getattr(tb, name)
        total = block.pc_work_time_total() / ticks_per_ns
        mean = block.pc_work_time_avg() / ticks_per_ns
        variance = block.pc_work_time_var() / ticks_per_ns**2
        if total <= 0 or mean <= 0:
            raise RuntimeError(f"No performance counters for {name}; run through run-profile.sh")
        consumed = block.nitems_read(0) if name != CHAIN[0] else 0
        produced = block.nitems_written(0)
        samples = produced / 2 if name == CHAIN[0] else (
            consumed / 2 if name == CHAIN[1] else consumed)
        rows.append(dict(zip(fields, (
            name, consumed, produced, samples, total, mean,
            math.sqrt(max(0, variance)), total / samples if samples else "",
            total / samples * 16384 / 1000 if samples else "",
        ))))
    with Path(path).open("w", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)
    for row in rows:
        print(f"{row['block']}: GR avg work {row['gr_work_time_avg_ns'] / 1e3:.3f} us, "
              f"total {row['total_work_ns'] / 1e6:.3f} ms, "
              f"{row['work_us_per_16384_samples']:.3f} us / 16384 IQ samples")


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

    def __init__(self, tb, mode, output_dir):
        self.tb = tb
        self.mode = mode
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.finished = False
        phy = tb.mlir_aie_mlir_aie_80211_phy_0
        if not hasattr(phy, "use_monotonic_performance_clock"):
            raise RuntimeError("Build with build-local.sh and launch with run-profile.sh "
                               "to load the local profiling module")
        phy.use_monotonic_performance_clock()
        if mode == "inter":
            prefs = gr.prefs()
            if not prefs.get_bool("PerfCounters", "on", False) or prefs.get_string(
                    "PerfCounters", "clock", "thread") != "monotonic":
                raise RuntimeError("Use run-profile.sh (monotonic performance counters required)")
        elif mode == "intra":
            phy.start_profiling(str(self.output_dir / "intra_raw.csv"))
        else:
            raise ValueError(f"Unknown profile mode: {mode}")
        atexit.register(self.finish)

    def finish(self):
        if self.finished:
            return
        self.finished = True
        self.tb.stop()
        self.tb.wait()
        if self.mode == "inter":
            export_inter(self.tb, self.output_dir / "inter_blocks.csv")
        else:
            self.tb.mlir_aie_mlir_aie_80211_phy_0.stop_profiling()
            summarize_intra(self.output_dir / "intra_raw.csv",
                            self.output_dir / "intra_summary.csv")
        print(f"Profile saved in {self.output_dir}")
