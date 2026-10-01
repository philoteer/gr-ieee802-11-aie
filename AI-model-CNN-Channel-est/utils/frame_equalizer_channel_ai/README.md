# frame_equalizer_channel_ai(1)

## NAME

frame_equalizer_channel_ai — generate channel-estimation data, train and export
quantized CNN weights, then evaluate the exported model and select an LS gate.

## SYNOPSIS

Run these commands from `stage42/`. The three entry points are independent:

```text
python3 utils/frame_equalizer_channel_ai/dataset_generator/generate_dataset.py [options]
python3 utils/frame_equalizer_channel_ai/training/cli.py {train,export} [options]
python3 utils/frame_equalizer_channel_ai/verification/cli.py {gate,evaluate} [options]
```

Use `<program> <command> --help` for the full list of options (or `<program>
--help` for the dataset generator).

## EXAMPLE

Generate both synthetic and GNU Radio splits, train with the same dataset, pick
the gate on the validation split, re-export the weights with that gate, and
evaluate on the held-out test split:

```bash
python3 utils/frame_equalizer_channel_ai/dataset_generator/generate_dataset.py --dataset both
python3 utils/frame_equalizer_channel_ai/training/cli.py train --dataset both
python3 utils/frame_equalizer_channel_ai/verification/cli.py gate --dataset both
# Replace the example value with gate_snr_ratio_x16 from the preceding JSON output.
GATE=20191
python3 utils/frame_equalizer_channel_ai/training/cli.py export --gate-snr-ratio-x16 "$GATE"
python3 utils/frame_equalizer_channel_ai/verification/cli.py evaluate --dataset both --checkpoint utils/frame_equalizer_channel_ai/training/artifacts/channel_estimator.pt
```

For an original-only run, omit `--dataset both` throughout. Gate
selection does not modify the weights: the second export embeds the selected
threshold in the NPZ, JSON, and C++ header. The initial training export uses
an effectively disabled gate. Export writes the deployed header to
`kernel/channel_estimator/model/frame_equalizer_channel_ai_weights.h` by
default; rebuilding the kernel is required to deploy new weights.

## INPUTS AND OUTPUTS

The room and bus real-symbol collections are fixed SigMF splits under
`data/datasets/channel_estimator/{20260927_room,20260928_bus}/by_frame/` and
`by_channel/`, each with `train/`, `val/`, `test/` and a checksummed manifest.
The unsplit originals are archived at
`data/datasets/channel_estimator_sources_archive/`; see `data/README.md` for
the split policy and regeneration command. Convert only the saved partitions:

```bash
python3 utils/frame_equalizer_channel_ai/dataset_generator/convert_sigmf.py --recordings data/datasets/channel_estimator/20260927_room --split-mode by_frame
python3 utils/frame_equalizer_channel_ai/dataset_generator/convert_sigmf.py --recordings data/datasets/channel_estimator/20260928_bus --split-mode by_channel
python3 utils/frame_equalizer_channel_ai/training/updater.py --recordings data/datasets/channel_estimator/20260927_room --split-mode by_frame
python3 utils/frame_equalizer_channel_ai/verification/updater.py --recordings data/datasets/channel_estimator/20260927_room --split-mode by_frame --split test
```

The converter writes `train.npz`, `validation.npz`, and `test.npz`; its split
source is always the saved SigMF version. Updater training uses saved train/val
for fitting and gate selection; verification defaults to saved test.

The dataset generator writes `train.npz`, `validation.npz`, and `test.npz` under
`data/datasets/channel_estimator/synthetic_original/` and/or
`data/datasets/channel_estimator/synthetic_gnuradio/`, with a manifest for each
source. `--dataset both` combines the matching splits when training or
verifying. The default generation sizes are 12,000 training, 2,000 validation,
and 3,000 test samples total. Use the same `--dataset-dir` with all three
programs if storing splits elsewhere. To convert a recorded GNU Radio archive,
use `generate_dataset.py --convert RAW_NPZ --output PATH`, then place the
converted split at `DATASET_DIR/SOURCE/SPLIT.npz`.

Training writes `training/artifacts/channel_estimator.pt` (checkpoint),
`channel_estimator_report.json` (settings and loss), and
`channel_estimator_weights.npz`/`.json` (exported integer weights and gate).
Verification consumes the NPZ; it does not require the training checkpoint for
`gate` or ordinary `evaluate`. `gate` defaults to the validation split;
`evaluate` defaults to the test split and reports LS, ungated quantized, and
gated NMSE/EVM plus per-SNR results. Pass `--checkpoint` to `evaluate` on the
full test split to check its digest against the training checkpoint. Use
`--report PATH` to save verification output as JSON.

## TESTS

```bash
python3 -m pytest -q utils/frame_equalizer_channel_ai
```
