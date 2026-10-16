# MLP latency capture pair

The saved `Experiments/xclbin_default/MLP_BY_FRAME` and `MLP_BY_CHANNEL` builds
use `EQUALIZER_ALGORITHM=CNN`, `CNN_DATA_UPDATER=MLP`, and `ENGINE=CLASSIC`.
The gated MLP here is the channel updater, not the optional neural demapper.

## What "gating triggered" means

In `AI-model-CNN-Channel-est/kernel/channel_estimator/cnn_data_updater/mlp.h`:

```cpp
if (snr_ratio_x16 >= frame_equalizer_channel_updater_mlp::kGateSnrRatioX16)
    return;
```

Thus **gate taken = MLP skipped**; **gate not taken = MLP inference runs** on
eligible symbols. The LTS-derived SNR is constant over a frame, so the gate has
the same decision on that frame's SIGNAL/payload updater calls.

| Weight selection | Native gate threshold | NPU-reported SNR threshold |
| --- | ---: | ---: |
| BY_FRAME | 12739 | approximately 26 dB |
| BY_CHANNEL | 40286 | approximately 31 dB |

The host block reports `10*log10(snr_ratio_x16 / 32)`, including the LTS
sum/difference factor of two. Using a divisor of 16 would misplace the threshold
by 3 dB. The saved compiled MLP listings also contain the corresponding unsigned
comparisons against 12738/40285, implementing the same greater-or-equal tests.

## Measured on the actual NPU kernels

Both recordings contain **2000 frames, 200108081 complex samples, 10.00540405 s**,
at 20 MSamples/s with 5 ms frame-start spacing. Payload IDs, frame timing, BPSK
1/2 modulation, transmit scale 0.2, and noise seed 1 are the same. The new capture
increases only Gaussian noise standard deviation per I/Q from 0.003 to 0.015.

| Capture | NPU SNR min / median / max | BY_FRAME: skip / run | BY_CHANNEL: skip / run |
| --- | --- | ---: | ---: |
| `wifi_latency.sigmf` (existing) | 29.92 / 34.10 / 36.87 dB | 2000 / 0 | 1995 / 5 |
| `wifi_latency_mlp_active.sigmf` (new) | 16.05 / 20.13 / 22.89 dB | 0 / 2000 | 0 / 2000 |

Every frame was detected and **2000/2000 CRC-valid payloads and MAC sequence
numbers matched** for each of the four capture/kernel combinations.

The existing recording is a pure MLP-bypass case for **BY_FRAME**, but is a
slightly mixed case for BY_CHANNEL. Use the same BY_FRAME kernel for both
recordings for an all-skipped versus all-running MLP comparison. The new capture
is an all-running case for either weight selection.

There is also a separate initial CNN-estimator gate at approximately 31 dB.
It skips CNN inference on 1995/2000 frames of the existing capture and 0/2000 of
the new capture. Consequently the latency difference reflects the complete
gated **CNN + MLP** pipeline, not an isolated MLP-instruction cost.

## Regenerate the complementary capture

From `Experiments/latency`:

```bash
grcc wifi_tx_sigmf.grc
/usr/bin/python3 -u wifi_tx_sigmf.py \
  --output-base wifi_latency_mlp_active --noise-std 0.015
```

The saved GRC generator now exposes `--noise-std` and `--output-base` as well as
`--frame-count`. Its defaults still generate the original high-SNR recording.
The original recording was preserved when creating the new one. Each data file
is approximately 1.60 GB and has matching SigMF annotations and a SHA-512 hash.

## Recheck gate decisions

```bash
/usr/bin/python3 check_mlp_gate.py \
  --report wifi_latency_mlp_by_frame_gate.json
/usr/bin/python3 check_mlp_gate.py \
  --kernel-dir ../xclbin_default/MLP_BY_CHANNEL \
  --report wifi_latency_mlp_by_channel_gate.json
/usr/bin/python3 check_mlp_gate.py --capture-base wifi_latency_mlp_active \
  --report wifi_latency_mlp_active_by_frame_gate.json
/usr/bin/python3 check_mlp_gate.py --capture-base wifi_latency_mlp_active \
  --kernel-dir ../xclbin_default/MLP_BY_CHANNEL \
  --report wifi_latency_mlp_active_by_channel_gate.json
```

The checker verifies the capture hash, loads the selected MLP kernel, and reads
the native SNR tag on every first payload vector **before CRC decoding**, so
failed packets would not silently disappear from the gating statistics. It
applies the kernel's unchanged gate predicate to those NPU SNR values and
separately verifies all decoded identities. These are inferred branch decisions
from the actual gate input, not new branch counters or a forced gate setting.
Reports include kernel/capture hashes and build mode. Replay is unthrottled for
this correctness check; the script does not measure latency.

## Select the MLP kernel for latency measurements

`NPU/receiver.grc` currently selects an LS kernel with batch 8192/8 tiles. For
the saved MLP builds checked above, configure its PHY block with:

| Setting | Value (relative to `Experiments/latency/NPU`) |
| --- | --- |
| xclbin | `../../xclbin_default/MLP_BY_FRAME/final.xclbin` |
| instructions | `../../xclbin_default/MLP_BY_FRAME/insts.bin` |
| VECTOR_SIZE | 16384 |
| N_TILES | 16 |
| slots | 2 |
| weights path | empty (weights are compiled into these kernels) |
| input `file_path`, bypass case | `"../wifi_latency.sigmf"` |
| input `file_path`, active case | `"../wifi_latency_mlp_active.sigmf"` |

Keep the same MLP kernel and replay settings for both input recordings. Swapping
only the input measures the naturally selected gating paths. The current LS
selection itself has no MLP gate; it was not changed by the dataset generation.
