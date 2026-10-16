#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Check real NPU execution and complete output/metadata writes on repeated runs."""

from pathlib import Path

import aie.iron as iron
import numpy as np
from aie.utils import DefaultNPURuntime, NPUKernel

from aie2 import METADATA_WORDS, N_TILES, TILE_SIZE, VECTOR_SIZE


def main():
    directory = Path(__file__).resolve().parent
    kernel = NPUKernel(str(directory / "build/final.xclbin"),
                       str(directory / "build/insts.bin"), kernel_name="MLIR_AIE")
    handle = DefaultNPURuntime.load(kernel)
    expected_metadata = np.zeros(N_TILES * METADATA_WORDS, dtype=np.int32)
    expected_metadata[::METADATA_WORDS] = TILE_SIZE
    rng = np.random.default_rng(42)
    for _ in range(3):
        data = iron.tensor(rng.integers(-32768, 32768, VECTOR_SIZE, dtype=np.int32),
                           dtype=np.int32)
        output = iron.tensor(np.full(VECTOR_SIZE, 42, dtype=np.int8), dtype=np.int8)
        metadata = iron.tensor(np.full(N_TILES * METADATA_WORDS, -123, dtype=np.int32),
                               dtype=np.int32)
        DefaultNPURuntime.run(handle, [data, output, metadata])
        np.testing.assert_array_equal(output.numpy(), np.zeros(VECTOR_SIZE, dtype=np.int8))
        np.testing.assert_array_equal(metadata.numpy(), expected_metadata)
    print("PASS: three real NPU runs wrote all dummy bytes and valid no-tag metadata")


if __name__ == "__main__":
    main()
