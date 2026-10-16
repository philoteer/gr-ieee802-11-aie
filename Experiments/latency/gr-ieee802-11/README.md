# Native-timestamp receiver latency

The receiver changes are confined to `gr-ieee802-11-latency/` and installed
under its `local/` prefix. `original.grc` uses those blocks and a **message-only
embedded Python reporter**. No Python block processes or copies the IQ stream.

## Build and run

From `Experiments/latency/gr-ieee802-11`:

```bash
cmake -S gr-ieee802-11-latency -B gr-ieee802-11-latency/build-local \
  -DCMAKE_INSTALL_PREFIX="$PWD/gr-ieee802-11-latency/local" \
  -DPYTHON_EXECUTABLE=/usr/bin/python3 -DENABLE_DOXYGEN=OFF
cmake --build gr-ieee802-11-latency/build-local -j 4
cmake --install gr-ieee802-11-latency/build-local

source ./local-env.sh
grcc -o . original.grc
/usr/bin/python3 -u wifi_rx.py
```

The local build is already installed on this host. Source `local-env.sh` in each
new shell; it now selects the **modified `ieee802_11` library and GRC definitions**.
It does not select a local `gr-mlir_aie` or require an NPU. The installed SigMF
tag injector is used unchanged. Confirm the receiver import with:

```bash
/usr/bin/python3 -c 'import ieee802_11; print(ieee802_11.__file__)'
```

The path should be inside `gr-ieee802-11-latency/local/`. Alternatively, launch
`gnuradio-companion original.grc` from the configured shell. Run from this
directory so the relative `../wifi_latency.sigmf-{data,meta}` paths resolve.
The flowgraph exits on file EOF and prints a matching summary.

## Timestamp placement

1. File IQ is throttled to 20 MSamples/s, with a 1024-sample release limit.
2. The existing native SigMF injector stamps annotated `frame_start` and
   `frame_end` boundaries using `CLOCK_MONOTONIC` at scheduler callback entry.
3. IQ goes directly to the conventional receiver. A native `latency_tag_monitor`
   **side tap** forwards boundary dictionaries to Python, preserving their
   original timestamps. The tap's scheduling does not retimestamp the events.
4. The local `frame_equalizer` stamps `phy_equalized_ns` after producing the
   frame's final equalized/hard-demapped output symbol. This is a stream tag on
   the final 48-byte vector, before payload deinterleaving/Viterbi/CRC.
5. `decode_mac` collects that final-vector tag and carries it unchanged into the
   decoded PDU. Python uses the decoded payload and MAC sequence only to identify
   the annotated frame, then subtracts the earlier native timestamps.

The capture uses unique ASCII payloads, 24-byte MAC headers, and a decoder that
removes the FCS. Dropped frames do not shift matching. Either message input may
arrive first; duplicates and unmatched outputs are counted. Native completion
metadata is mandatory: the reporter never falls back to Python arrival time.
`frames[label]["observed"]` retains Python arrival time for diagnostics only.

- **start-to-equalized:** native input-start to final equalized symbol completion.
- **end-to-equalized:** native input-end to the same completion timestamp.
- **mean:** running mean of start-to-equalized over matched frames.

Payload decoding, CRC checking, Python delivery, matching, and printing are
excluded from these intervals. Decoding still determines which frames can be
identified, so only CRC-valid matched frames produce samples. Downstream work
can still contend for CPU resources; the observer effect is checked below.

## Accuracy checks

```bash
source ./local-env.sh
/usr/bin/python3 gr-ieee802-11-latency/tests/test_latency.py
/usr/bin/python3 gr-ieee802-11-latency/tests/check_accuracy.py --runs 30
```

Regression tests check unchanged forwarding of native timestamps, reversed
message delivery, lost/duplicate packets, sequence mismatch, much later Python
observation, and rejection of PDUs without equalizer timestamps. A native decoder
regression test checks that a tag arriving on the final vector, rather than the
frame-header vector, is preserved exactly and not replaced with decoder time.
The tests load the epy source directly from `original.grc`.

The accuracy check compiles a temporary, Linux/GNU Radio 3.10 ABI-specific native
probe. It independently observes ingress tags, emission of the final equalizer
tag, and decoder PDU publication using `LD_PRELOAD`. No global installation is changed, and the probe
is not used by normal runs. It expects the generated latency capture with
numeric frame IDs below 4096. The probe buffers timestamps without per-event
printing or file I/O. Configurations run in shuffled order using the same local
decoder and the same probe.

Verification on this host: **30 replays × 20 frames = 600 frames per configuration**.

| Configuration | Mean native start-to-equalized | Python delivery after decoded PDU, mean |
| --- | ---: | ---: |
| Reporter printing | 0.7057 ms | 32.3 µs |
| Reporter, printing disabled | 0.7124 ms | 31.2 µs |
| Reporter deliberately delayed by 2 ms | 0.7292 ms | 2089.8 µs |
| Native baseline: side tap and Python reporter disconnected | 0.6892 ms | — |

All frames matched, and input/completion timestamps agreed exactly with the
independently captured native values. The completion field preceded the probe's
observation of the final equalizer tag by **0.90 µs mean, 1.43 µs p95** in the
printing configuration. Decoder publication followed equalization by a further
**71.2 µs on average**, which is now excluded from the reported latency. Even a
deliberately late Python callback retained the original equalizer timestamp.

The printing configuration's mean differed from the observer-free baseline by
**16.5 µs**; per-replay mean standard deviations were about **26–34 µs** for the
baseline and normal reporting configurations. This suggests small remaining
observer interference in this test, not a guaranteed bound for other loads.

### Remaining limits

The equalizer-tag agreement validates **native host-side timestamping**,
not a claim of microsecond absolute RF latency accuracy. The input clock is still
taken once per injector scheduler buffer. The throttle releases bursts of up to
1024 samples (51.2 µs at 20 MSamples/s); downstream callbacks can merge bursts.
These timestamps therefore approximate arrival at the receiver, not individual
sample arrival at an antenna. OS scheduling and buffering remain part of the
measured receiver latency. The annotation includes a final windowing tail, so an
early equalizer completion can produce a negative end-to-equalized estimate.

The endpoint now follows the NPU experiment: completion of equalization/demapping,
before payload Viterbi decoding and CRC checking. CPU timestamps are frame/final-
symbol granular; the NPU timestamp is completion of the chunk containing the
annotated frame end and includes batching effects. See `../README.md` for the
common endpoint definition and remaining granularity differences.
