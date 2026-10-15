# NPU energy experiment

## Local PCAP connector build

`NPU.grc` uses the corrected `gr-foo-fixed` library in the sibling workspace:

```text
xdna_phy/
├── gr-foo-fixed/build/lib/
└── gr-ieee802-11-aie/Experiments/energy/NPU/NPU.grc
```

Build it from `xdna_phy/gr-foo-fixed`:

```sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DENABLE_PYTHON=OFF -DENABLE_DOXYGEN=OFF
cmake --build build -j2
```

The installed `foo` Python bindings are reused. The flowgraph's **Run Command**
prepends the local build's `lib` directory to `LD_LIBRARY_PATH` before starting
Python, so GRC's Execute button loads the corrected C++ library.

When running the generated script directly from the project root, use:

```sh
LD_LIBRARY_PATH="$(realpath ../gr-foo-fixed/build/lib)${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" \
    python3 -u Experiments/energy/NPU/wifi_rx.py
```

## Why the local connector is needed

The installed connector polls its GNU Radio message input manually, without a
registered message handler. When the queue exceeds `DEFAULT/max_messages`
(8,192 on this machine), the thread-per-block scheduler removes queued messages
and logs:

```text
tpb_thread_body :warning: asynchronous message buffer overflowing, dropping message
```

Those messages are decoded packets destined for the PCAP file, so this is real
packet loss. Raising the queue limit only postpones it.

The local connector registers a handler, retains incoming PDUs in order, and
batches PCAP records into its byte-stream output. EOF is processed after pending
records have been emitted. A queued burst of 8,210 packets reproduced 10 losses
with the installed library; the local build preserved all 8,210 in order without
overflow warnings.
