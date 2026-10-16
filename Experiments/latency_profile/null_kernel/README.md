# Standalone real NPU null kernel

This minimal NPU1 / XDNA1 kernel runs on one AIE compute tile and preserves the
existing PHY block's buffer ABI:

* 16384 packed cint16 input samples (65536 bytes), consumed through device DMA
  and FIFO acquisition; their values are ignored.
* 16384 output bytes, all written to zero on the NPU.
* Sixteen 8968-byte metadata records, fully written on the NPU. Each reports
  `output_length=1024` and `tag_count=0`; no frame/CSI tags are fabricated.
* The frequency-RTP instruction markers expected by the PHY host block.
  Frequency updates do not affect the dummy computation.

All three DMA streams complete before a command finishes. This is a real AIE
kernel and xclbin, not a host bypass. It is independent of the profiling code.

## Build and test

From the repository root, using the existing MLIR-AIE and Vitis AIE tools:

```bash
make -C Experiments/latency_profile/null_kernel -j2
make -C Experiments/latency_profile/null_kernel test
```

Artifacts are `build/final.xclbin` and `build/insts.bin` in this directory.
The standalone hardware test repeats execution three times with varying input
and sentinel-filled output buffers, verifying every output and metadata word.

The artifacts can be supplied to the existing PHY block's xclbin and instruction
path parameters, with `VECTOR_SIZE=16384`, `N_TILES=16`, no runtime weights, and
kernel name `MLIR_AIE`. Here, 16 is the number of logical 1024-sample transfers,
not the number of physical compute cores.

The dummy output contains no valid packets. It always produces a full output
vector, which differs from real PHY output rates and can change downstream
backpressure. The one-core topology and buffer-clearing cost make this an
overhead baseline, not an exact quantity to subtract to recover PHY compute time.
