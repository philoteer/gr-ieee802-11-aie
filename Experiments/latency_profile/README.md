# NPU latency profilers

Two receiver flowgraphs use the room capture and the existing
`Experiments/xclbin_default/LS` artifacts (16 tiles, 16384 IQ samples per NPU
vector, two XRT slots):

* **`NPU_inter_kernel.grc`** exports GNU Radio work-time counters for the file
  source, short-to-complex conversion, SigMF tag injector, complex-to-cint16
  conversion, and `mlir_aie_80211_phy`, inclusive.
* **`NPU_intra_kernel.grc`** records host-side phases inside the locally modified
  `mlir_aie_80211_phy` block.

The downstream stream-to-vector / MAC decoder / PCAP chain remains connected so
the receiver runs normally. Its latency is outside these reports.

## Build and run

From the repository root:

```bash
bash Experiments/latency_profile/build-local.sh

grcc -o Experiments/latency_profile \
  Experiments/latency_profile/NPU_inter_kernel.grc \
  Experiments/latency_profile/NPU_intra_kernel.grc

bash Experiments/latency_profile/run-profile.sh /usr/bin/python3 -u \
  Experiments/latency_profile/npu_inter_kernel.py --num-samples 1048576

bash Experiments/latency_profile/run-profile.sh /usr/bin/python3 -u \
  Experiments/latency_profile/npu_intra_kernel.py --num-samples 1048576
```

`--num-samples` counts **complex IQ samples**, not int16 components. Omit it or
use zero to process the entire capture. Use a multiple of 16384; an incomplete
final vector cannot be processed by the PHY. The room capture is large, so a
bounded sample count is useful for initial runs. Ctrl-C or SIGTERM stops the
graph, waits for its threads, and exports the completed measurements.

Generate the Python files beside these `.grc` files: dataset, artifact and launch
paths are relative to that location. Change `file_path` / `kernel_dir` in GRC to
select another capture or compatible kernel build.

For GNU Radio Companion:

```bash
source Experiments/latency_profile/local-env.sh
gnuradio-companion Experiments/latency_profile/NPU_intra_kernel.grc
```

Both graphs' Execute commands use `run-profile.sh`. It selects the private local
Python package and shared library and enables GNU Radio performance counters.
The modified block is built in `gr-mlir_aie-profile/gr-mlir_aie/build-profile`
and installed in that module's `local/` directory. This also avoids the copied
`build/` directory's stale CMake cache. No system installation is needed.
`PROFILE_BUILD_JOBS` controls build parallelism (default 2).

## Output

By default:

```text
results/inter/inter_blocks.csv
results/inter/decoded.pcap
results/intra/intra_raw.csv
results/intra/intra_summary.csv
results/intra/decoded.pcap
```

Set `PROFILE_OUTPUT_DIR=/absolute/path` before launching to change the `results`
root. Each mode overwrites its previous reports and PCAP. Build outputs,
generated Python and default results are git-ignored.

### Inter-block measurements

`inter_blocks.csv` has one row per measured block:

* `total_work_ns`: accumulated wall time inside scheduler calls to
  `general_work()` (including `work()` for synchronous blocks).
* `gr_work_time_avg_ns`, `gr_work_time_stddev_ns`: GNU Radio's native counter
  statistics, converted to nanoseconds. These retain the runtime's native
  floating-point precision and initialization behavior. In GNU Radio 3.10.9.2,
  the running-average initialization discards the first observation when the
  second arrives; these are **not exact offline sample statistics**. A call
  count is deliberately not inferred by dividing total by average.
* `input_items`, `output_items`: actual stream-item counts in each block's own
  units. The source emits interleaved int16 I/Q components; the PHY emits bytes.
* `processed_iq_samples`: converts upstream int16 component counts to complex
  sample counts, making costs comparable across the chain.
* `work_ns_per_iq_sample`, `work_us_per_16384_samples`: accumulated work divided
  by processed IQ samples, with the latter normalized to one NPU vector.
  These are amortized processing costs, not individual-sample transit times.

The profiler explicitly selects `CLOCK_MONOTONIC` in the local binding before
starting scheduler threads. The preference alone does not switch the timer on
this host's GNU Radio runtime. Thus XRT waiting is included rather than hidden
by thread CPU-time accounting.

Counters exclude constructor/kernel-load time, forecast calls, tag propagation
performed by the scheduler after work returns, and scheduler/buffer waiting
outside work. EOF/zero-output work calls are included. The original virtual
source/sink are wiring aliases, so there are no work calls to time for them.
Different blocks can process different batch sizes and run concurrently:
**do not add their per-call averages and interpret that as packet latency**.

### Intra-block measurements

`intra_raw.csv` is long-form CSV with `scope`, `work_id`, `chunk_index`, absolute
complex-sample `input_offset`, `input_items`, `output_items`, `stage`, and
`duration_ns`. Each chunk has eight stage records; item counts are repeated on
those rows and should only be counted once per chunk. Chunk indices restart
inside each work call. The summary groups by `(scope, stage)` and provides exact
count, integer total, mean, population standard deviation, minimum and maximum.

| Scope | Stage | Timed region |
|---|---|---|
| chunk | `input_copy` | GNU Radio input to mapped input BO memcpy |
| chunk | `input_sync` | Input BO sync to device |
| chunk | `run_start` | XRT `run.start()` |
| chunk | `run_wait` | Host time spent in `run.wait()` |
| chunk | `output_sync` | Output BO sync from device |
| chunk | `metadata_sync` | Metadata BO sync from device |
| chunk | `output_unpack` | Output copying and GNU Radio tag construction |
| chunk | `submit_to_wait_complete` | From entering `run.start()` to return from the matching `run.wait()` |
| work | `prepare` | Input/tag/frequency handling, RTP updates, profiling-record allocation and setup |
| work | `pipeline` | All launches, waits, syncs and output unpacking for this work call |
| work | `finalize` | Final frequency-state update and input consumption |
| work | `work_total` | Prepare + pipeline + finalize |

These explicitly use `clock_gettime(CLOCK_MONOTONIC, ...)`, matching the
timestamp clock in `Experiments/latency/`. With multiple slots, submission residence
times overlap; `run_wait` measures only the remaining host wait when that slot
is retired. Neither is pure device compute time. Likewise, `work_total` contains
`pipeline`, which contains the individual chunk phases: **do not sum nested or
overlapping metrics**. GNU Radio's default buffers usually allow only one NPU
vector per work call in these graphs; two configured slots alone do not force
multi-vector scheduling. Work rows' `input_items / 16384` give actual batch size.

Profiling starts after construction, so kernel load, BO allocation and initial
weights transfer are excluded. Timer/recording overhead perturbs execution.
Buffered CSV formatting/writing happens after the timed work region and is
excluded from `work_total`, but still delays the next work call. Runs are not
warm-up filtered; use `work_id` to filter raw records if needed. Profiling is
disabled unless `start_profiling(path)` is called before `start()`; call
`stop_profiling()` after `wait()` to flush and close it.

**This is instrumentation inside the host GNU Radio block. It does not measure
individual autocorrelation, sync, FFT or equalizer AIE kernels inside the
xclbin.** Those require device-side trace/cycle instrumentation and a compatible
rebuilt xclbin; the supplied binaries are used as-is.

## Validation

```bash
# Hardware-free: real scheduler wall-clock accounting and CSV statistics.
bash Experiments/latency_profile/run-profile.sh /usr/bin/python3 \
  Experiments/latency_profile/test_profiler.py

# Also run an NPU output-equivalence and multi-slot timing/accounting check.
# Requires the generated npu_intra_kernel.py above.
PROFILE_TEST_HARDWARE=1 bash Experiments/latency_profile/run-profile.sh \
  /usr/bin/python3 Experiments/latency_profile/test_profiler.py
```

The hardware check processes 64 vectors, requests four-vector work batches to
exercise two-slot reuse, compares PHY output bytes with profiling disabled and
enabled, checks contiguous sample offsets and item counts, and verifies
`prepare + pipeline + finalize == work_total` for every measured work call.
