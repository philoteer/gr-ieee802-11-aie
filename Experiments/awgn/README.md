# Stress-test capture: SNR gates and AWGN copy

The original `AI-model-CNN-Channel-est/data/raw_capture/stress_test.sigmf-data`
**does trigger the high-SNR bypass gates**. When gated, the CNN leaves the LS
estimate in place and the MLP skips its learned update.

## Measurement

The script uses GNU Radio's `ieee802_11.sync_short` and `sync_long`, including
carrier-offset correction, and extracts the first two 64-sample long training
symbols at each `wifi_start` tag. After FFT, it uses the same 52 occupied bins and
metric as `gr-ieee802-11-modified/lib/equalizer/channel_ai_model.cc`:

```text
ratio_x16 = 16 * sum(|LTS1 + LTS2|²) / sum(|LTS1 - LTS2|²)
SNR_dB = 10 * log10(ratio_x16 / 32)
bypass if ratio_x16 >= model threshold
```

Thresholds are read from the checked-in CPU and AIE weight headers. These are
floating-point measurements compared with each threshold; they are not a
bit-exact execution of the AIE fixed-point synchronization/FFT pipeline.

Default analysis samples twelve 0.1-second windows uniformly spread over the
127.82334-second recording. These are detected training pairs, not necessarily
CRC-valid decoded packets; bypass percentages describe these windows.

| Model | Gate (dB) | Original bypass | 15 dB copy bypass |
| --- | ---: | ---: | ---: |
| CPU by-frame CNN | 30.0 | 73.85% | 0% |
| CPU by-frame MLP | 26.5 | 88.39% | 0% |
| AIE by-frame CNN | 31.0 | 70.48% | 0% |
| AIE by-frame MLP | 26.0 | 90.23% | 0% |
| CPU by-channel CNN | effectively disabled | 0% | 0% |
| CPU by-channel MLP | 31.0 | 70.48% | 0% |
| AIE by-channel CNN | 31.0 | 70.48% | 0% |
| AIE by-channel MLP | 31.0 | 70.48% | 0% |

| Metric | Original | AWGN copy |
| --- | ---: | ---: |
| Detected training pairs | 6,244 | 6,221 |
| SNR 5th percentile | 24.84 dB | 13.14 dB |
| SNR median | 34.14 dB | 15.06 dB |
| SNR 95th percentile | 39.24 dB | 16.88 dB |

The original analysis is saved in `stress_test_gate_report.json`. The generated
copy's full before/after report is saved alongside its data.

## Usage

Requires Python 3, NumPy, GNU Radio, and the installed `ieee802_11` module.
Run from the repository root:

```bash
# Inspect the original without creating IQ data.
python3 Experiments/awgn/stress_test_awgn.py --analyze-only

# Generate the full 15 dB copy (already generated in this workspace).
python3 Experiments/awgn/stress_test_awgn.py

# Select another target and a fresh output name.
python3 Experiments/awgn/stress_test_awgn.py --snr-db 20 \
  --output Experiments/awgn/data/stress_test_awgn_20db.sigmf-data

# Inspect an existing generated copy.
python3 Experiments/awgn/stress_test_awgn.py --analyze-only \
  --source Experiments/awgn/data/stress_test_awgn_15db.sigmf-data
```

Existing output files are protected against overwriting. Default generated files:

```text
Experiments/awgn/data/stress_test_awgn_15db.sigmf-data
Experiments/awgn/data/stress_test_awgn_15db.sigmf-meta
Experiments/awgn/data/stress_test_awgn_15db.awgn.json
```

The copy retains all 2,556,466,800 complex samples (10,225,867,200 bytes), the
20 MHz sample rate, capture positions, and int16 little-endian interleaved IQ
format. The metadata dataset filename and description are updated; an old
checksum, if present, is removed. Generated data and its sidecars are gitignored.

## Noise calibration

Noise is added to the entire recording, including gaps, at a constant variance.
The target is the **median occupied-subcarrier SNR**, so individual packet SNRs
still vary. For each detected LTS pair, the script estimates signal and existing
noise power from the sum and difference, subtracts existing noise from the target
noise budget, and takes the median required added power. It does not use
whole-recording average power, which would be biased downward by idle gaps.

Independent Gaussian noise is added to I and Q with default seed `20261017`.
Processing is chunked to limit memory use; values are rounded and saturated to
int16. The generated 15 dB copy used component standard deviation 1430.743 int16
units and clipped 0.000466% of components. The JSON report records calibration,
seed, clipping, and before/after gate statistics. Detection counts can decrease
after noise injection; decoding performance is not measured by this script.
