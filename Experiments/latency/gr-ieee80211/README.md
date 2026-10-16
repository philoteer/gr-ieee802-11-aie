# GR-WiFi native-timestamp latency

`s80211.grc` uses a locally built `gnuradio.ieee80211` receiver from
`gr-ieee80211/`, a native boundary-tag side tap, and a message-only epy reporter.
Python does not process or copy IQ. The recording and replay rate match the
other latency experiments: `../wifi_latency.sigmf-{data,meta}`, 20 MSamples/s,
with at most 1024 samples released per throttle callback.

## Build and run

From `Experiments/latency/gr-ieee80211` in bash:

```bash
cmake -S gr-ieee80211 -B gr-ieee80211/build-local \
  -DCMAKE_INSTALL_PREFIX="$PWD/gr-ieee80211/local" \
  -DPYTHON_EXECUTABLE=/usr/bin/python3 -DENABLE_DOXYGEN=OFF
cmake --build gr-ieee80211/build-local -j 4
cmake --install gr-ieee80211/build-local

source ./local-env.sh
grcc -o . s80211.grc
/usr/bin/python3 -u wifi_rx.py
```

The local build is already installed on this host. Source `local-env.sh` in new
shells to select the edited GR-WiFi library and GRC definitions. This does not
select a local `gr-mlir_aie`; the installed SigMF injector is used unchanged.
Check the import with:

```bash
/usr/bin/python3 -c 'from gnuradio import ieee80211; print(ieee80211.__file__)'
```

It should resolve under `gr-ieee80211/local/`. Alternatively, start
`gnuradio-companion s80211.grc` from the configured shell. Run from this directory
for relative data paths. The existing `presiso` hierarchical block must be
available in the GRC hierarchy path, as it was for the original receiver.

## Measurement and matching

The native SigMF injector timestamps annotated input boundaries with
`CLOCK_MONOTONIC`. `ieee80211.latency_tag_monitor` forwards the original boundary
dictionaries to the reporter from a side tap. It never substitutes delivery time
and no latency tags need to survive the PHY processing chain.

The local `demod` block stamps `phy_equalized_ns` when the frame's final OFDM
symbol has been equalized, soft-demapped, and deinterleaved into output LLRs.
This is before the separate payload Viterbi decoder. The stream tag is placed at
the start of that final symbol's LLRs because the decoder can finish without
consuming the symbol's padding bits. `decode` collects it while consuming the
packet and carries it unchanged into each decoded PDU. NDP channel reports are
not packet-completion events. Missing native equalizer metadata is rejected
rather than replaced with Python callback time.

GR-WiFi's output layout is:

```text
format (1 byte) | PSDU length (2, little-endian) | MAC + FCS | MCS (1 byte)
```

The reporter verifies the envelope length and FCS, removes the envelope/FCS, and
matches the complete payload and MAC sequence against the annotation's JSON
`core:comment`. This recording uses a 24-byte MAC header and unique ASCII
payloads. Missing or reordered packets cannot shift identities. The first
completion wins for duplicates, and either decoded or boundary messages can
arrive first.

Each frame prints native **start-to-equalized**, **end-to-equalized**, and running
mean start-to-equalized latency. Payload decoding and CRC checking identify the
frame but do not determine the measurement endpoint. The final summary includes matching, duplicate,
unmatched, malformed-output, and missing-frame information. The copied energy
logger and UDP output are disabled for this measurement flowgraph.

## Verification and accuracy

```bash
source ./local-env.sh
/usr/bin/python3 gr-ieee80211/tests/test_latency.py
/usr/bin/python3 gr-ieee80211/tests/check_accuracy.py --runs 30
```

The regression tests load the embedded source directly from `s80211.grc` and
check native timestamp preservation, reordered/dropped/duplicate packets,
sequence mismatches, envelope/FCS rejection, ignored channel reports, late
Python delivery, and missing native metadata. The native decoder regression verifies that an
endpoint tag arriving after header metadata is forwarded exactly, without a
new completion timestamp at decoder output.

The accuracy check temporarily compiles a Linux/GNU Radio 3.10 ABI-specific
`LD_PRELOAD` probe. It independently captures original ingress tag timestamps,
final demodulator endpoint-tag emission, and decoder publication. Configurations run in
shuffled order, with the same edited decoder and probe. Normal runs do not load
this probe; no system installation is modified. The probe expects generated
capture IDs below 4096.

The receiver retains its original `noutput_items + 160` decoder forecast.
Previously published numerical results used a forecast modification that has
been reverted and are not results for the current experimental configuration.
The accuracy check requires every annotated frame to decode; receiver-side
missing packets cause a check failure rather than a substituted measurement.

Input timestamps are still per injector scheduler buffer, not per antenna
sample. A throttle burst of 1024 samples represents 51.2 µs at 20 MSamples/s,
and downstream buffers can merge bursts. Native endpoint-tag agreement therefore
does not establish microsecond absolute RF latency accuracy. OS scheduling and
receiver buffering remain part of the host-side estimate. The annotation also
includes a final windowing tail, so end-to-equalized can in principle be negative.

The endpoint now follows the NPU and `gr-ieee802-11` experiments: post-equalizer/
demodulator output, before payload Viterbi decoding and CRC checking. GR-WiFi
produces soft/deinterleaved LLRs here, while the other equalizers produce hard
decisions. CPU endpoints are per frame; NPU completion remains chunk-granular.
See `../README.md` for the common definition and remaining differences.
