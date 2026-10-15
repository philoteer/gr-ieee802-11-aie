#!/usr/bin/env python3
"""Train CNNs using the existing frame-split and channel-split datasets.

This wrapper does not create or change dataset partitions. It converts the
saved room/bus SigMF train/validation/test partitions to trainer-ready NPZ
files, then invokes the existing training CLI once per split policy. Each run
exports separate NPU and GNU Radio weights, checkpoints, and training reports.
"""

from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[3]
PACKAGE = ROOT / "utils/frame_equalizer_channel_ai"


def main():
    # These select existing partition directories, not new splitting operations.
    for mode in ("by_frame", "by_channel"):
        names = []
        for collection in ("20260927_room", "20260928_bus"):
            name = f"{collection}_{mode}"
            names.append(name)
            # Convert the saved partitions to NPZ without reassigning frames
            # or channels. Existing converted NPZ files are regenerated.
            subprocess.run([
                sys.executable, str(PACKAGE / "dataset_generator/convert_sigmf.py"),
                "--recordings", str(ROOT / "data/datasets/channel_estimator" / collection),
                "--split-mode", mode, "--dataset-dir", str(ROOT / "data/datasets/channel_estimator"),
                "--dataset-name", name,
            ], check=True)
        # Combine room and bus data within each matching partition: training
        # fits weights, validation selects the epoch/gates, and test reports
        # held-out metrics. Keep all outputs separate for each split policy.
        artifacts = PACKAGE / "training/artifacts" / mode
        subprocess.run([
            sys.executable, str(PACKAGE / "training/cli.py"), "train",
            "--dataset", ",".join(names),
            "--checkpoint", str(artifacts / "channel_estimator.pt"),
            "--report", str(artifacts / "channel_estimator_report.json"),
            "--artifact-prefix", str(artifacts / "channel_estimator_weights"),
            "--header", str(ROOT / f"kernel/channel_estimator/model/frame_equalizer_channel_ai_weights_{mode}.h"),
            "--cpu-header", str(ROOT.parent / f"gr-ieee802-11-modified/lib/equalizer/model/channel_cnn_weights_{mode}.h"),
        ], check=True)


if __name__ == "__main__":
    main()
