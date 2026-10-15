"""Compare native publication with reported timestamps and observer bypass.

Run after sourcing ./local-env.sh from the receiver experiment directory.
The parent builds a temporary Linux/GNU Radio 3.10 ABI probe and starts a fresh
child with LD_PRELOAD. Production flowgraphs never load this probe.
"""
import argparse
import ctypes
import gc
import json
import os
from pathlib import Path
import random
import shlex
import subprocess
import sys
import tempfile
import time

import numpy as np
import pmt


ROOT = Path(__file__).resolve().parents[2]


def child(args):
    """Run shuffled configurations and check every frame's native timestamps."""
    sys.path.insert(0, str(ROOT))
    import ieee802_11
    import wifi_rx

    expected_prefix = ROOT / "gr-ieee802-11-latency" / "local"
    assert Path(ieee802_11.__file__).is_relative_to(expected_prefix), ieee802_11.__file__
    meta = json.loads((ROOT.parent / "wifi_latency.sigmf-meta").read_text())
    labels = [a["core:label"] for a in meta["annotations"]
              if a.get("core:label", "").startswith("wifi-frame-")]
    probe = ctypes.CDLL(args.probe)
    probe.latency_probe_get.argtypes = [ctypes.c_uint, ctypes.c_uint]
    probe.latency_probe_get.restype = ctypes.c_uint64
    samples = {}
    run_means = {}
    real_print = print
    for repeat in range(args.runs):
        modes = ["report_print", "report_quiet", "report_delayed_2ms", "native_only"]
        random.Random(repeat).shuffle(modes)
        for mode in modes:
            wifi_rx.epy_block_latency.print = real_print if mode == "report_print" else lambda *a, **k: None
            tb = wifi_rx.wifi_rx()
            observer = tb.epy_block_latency
            if mode == "native_only":
                monitor = tb.ieee802_11_latency_tag_monitor_0
                tb.disconnect((tb.mlir_aie_sigmf_tag_injector_0, 0), (monitor, 0))
                tb.msg_disconnect((monitor, "events"), (observer, "boundaries"))
                tb.msg_disconnect((tb.ieee802_11_decode_mac_0, "out"), (observer, "decoded"))
            elif mode == "report_delayed_2ms":
                original = observer.handle_decoded

                def delayed(message, handler=original):
                    time.sleep(0.002)
                    handler(message)

                observer.delayed = delayed
                observer.set_msg_handler(pmt.intern("decoded"), delayed)
            probe.latency_probe_reset()
            tb.start()
            tb.wait()
            rows = []
            for label in labels:
                index = int(label.removeprefix("wifi-frame-"))
                start, end, published, completed = [probe.latency_probe_get(index, k) for k in range(4)]
                assert start and end and published and completed, (mode, label)
                assert published >= completed >= start, (mode, label)
                row = {"native_us": (completed - start) / 1000,
                       "timestamp_to_publish_us": (published - completed) / 1000}
                if mode != "native_only":
                    state = observer.frames[label]
                    assert state["reported"]
                    assert (state["start"], state["end"], state["done"]) == (start, end, completed)
                    row["delivery_us"] = (state["observed"] - published) / 1000
                    # Independent publication-time estimate minus actual report.
                    row["report_vs_publish_us"] = ((published - start) - (state["done"] - state["start"])) / 1000
                    if mode == "report_delayed_2ms":
                        assert row["delivery_us"] >= 2000
                rows.append(row)
            if mode != "native_only":
                assert observer.count == len(labels) and observer.unmatched == 0
            samples.setdefault(mode, []).extend(rows)
            run_means.setdefault(mode, []).append(float(np.mean([r["native_us"] for r in rows])))
            del tb, observer
            gc.collect()

    summary = {"runs_per_configuration": args.runs, "receiver_module": ieee802_11.__file__}
    for mode, rows in samples.items():
        stats = {"frames": len(rows)}
        for field in rows[0]:
            values = [row[field] for row in rows]
            stats[field] = {"mean": float(np.mean(values)),
                            "p50": float(np.percentile(values, 50)),
                            "p95": float(np.percentile(values, 95)),
                            "max": float(np.max(values))}
        stats["native_run_mean_us"] = {"mean": float(np.mean(run_means[mode])),
                                       "stddev": float(np.std(run_means[mode]))}
        summary[mode] = stats
    print("RESULT " + json.dumps(summary, sort_keys=True), flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runs", type=int, default=30)
    parser.add_argument("--probe", help=argparse.SUPPRESS)
    args = parser.parse_args()
    if args.runs < 1:
        parser.error("--runs must be positive")
    if args.probe:
        child(args)
        return
    with tempfile.TemporaryDirectory(prefix="ieee80211-latency-") as temp:
        probe = Path(temp) / "accuracy_probe.so"
        flags = shlex.split(subprocess.check_output(
            ["pkg-config", "--cflags", "--libs", "gnuradio-runtime"], text=True))
        subprocess.run(["g++", "-std=c++17", "-O2", "-fPIC", "-shared",
                        str(Path(__file__).with_name("accuracy_probe.cc")),
                        "-o", str(probe), "-Wl,--no-as-needed", *flags,
                        "-lfmt", "-lspdlog", "-ldl", "-pthread"], check=True)
        preload = str(probe) + (":" + os.environ["LD_PRELOAD"] if os.environ.get("LD_PRELOAD") else "")
        result = subprocess.run([sys.executable, str(Path(__file__).resolve()),
                                 "--runs", str(args.runs), "--probe", str(probe)],
                                cwd=ROOT, env=dict(os.environ, LD_PRELOAD=preload),
                                capture_output=True, text=True)
        if result.returncode:
            sys.stdout.write(result.stdout)
            sys.stderr.write(result.stderr)
            raise SystemExit(result.returncode)
        line = next(line for line in result.stdout.splitlines() if line.startswith("RESULT "))
        print(json.dumps(json.loads(line.removeprefix("RESULT ")), indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
