#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Minimal NPU1 kernel with the 16 x 1024-sample PHY host ABI."""

import numpy as np

from aie.iron import Buffer, Kernel, ObjectFifo, Program, Runtime, Worker
from aie.iron.controlflow import range_
from aie.iron.device import NPU1Col1
from aie.iron.placers import SequentialPlacer

TILE_SIZE = 1024
N_TILES = 16  # Logical transfers per invocation, not physical compute cores.
VECTOR_SIZE = TILE_SIZE * N_TILES
METADATA_WORDS = 8968 // 4  # sizeof(frame_equalizer_tile_metadata) / sizeof(int32_t)


def build_program():
    input_tile = np.ndarray[(TILE_SIZE,), np.dtype[np.int32]]
    output_tile = np.ndarray[(TILE_SIZE,), np.dtype[np.int8]]
    metadata_tile = np.ndarray[(METADATA_WORDS,), np.dtype[np.int32]]
    input_tensor = np.ndarray[(VECTOR_SIZE,), np.dtype[np.int32]]
    output_tensor = np.ndarray[(VECTOR_SIZE,), np.dtype[np.int8]]
    metadata_tensor = np.ndarray[(N_TILES * METADATA_WORDS,), np.dtype[np.int32]]
    frequency_type = np.ndarray[(2,), np.dtype[np.int32]]

    input_fifo = ObjectFifo(input_tile, name="null_input")
    output_fifo = ObjectFifo(output_tile, name="null_output")
    metadata_fifo = ObjectFifo(metadata_tile, name="null_metadata")
    frequency = Buffer(frequency_type, name="center_frequency", use_write_rtp=True)
    kernel = Kernel("null_phy", "null_phy.o",
                    [input_tile, output_tile, metadata_tile, frequency_type,
                     np.int32, np.int32])

    def core(inputs, outputs, metadata, frequency, null_phy):
        for _ in range_(N_TILES):
            # Acquiring input is intentional even though its values are ignored:
            # every input DMA transfer must complete before the object is released.
            data = inputs.acquire(1)
            dummy = outputs.acquire(1)
            tags = metadata.acquire(1)
            null_phy(data, dummy, tags, frequency, TILE_SIZE, METADATA_WORDS)
            inputs.release(1)
            outputs.release(1)
            metadata.release(1)

    worker = Worker(core, [input_fifo.cons(), output_fifo.prod(),
                           metadata_fifo.prod(), frequency, kernel])

    def write_frequency_rtp(buffer):
        # Preserve the unique instruction markers patched by the PHY host block.
        # The dummy computation does not depend on the frequency value.
        buffer[0] = 0x13579BDF
        buffer[1] = 0x2468ACE0

    runtime = Runtime()
    with runtime.sequence(input_tensor, output_tensor, metadata_tensor) as (src, dst, meta):
        runtime.inline_ops(write_frequency_rtp, [frequency])
        runtime.start(worker)
        group = runtime.task_group()
        runtime.fill(input_fifo.prod(), src, task_group=group, wait=True)
        runtime.drain(output_fifo.cons(), dst, task_group=group, wait=True)
        runtime.drain(metadata_fifo.cons(), meta, task_group=group, wait=True)
        # Start all three streams before waiting, then wait for ALL transfers.
        runtime.finish_task_group(group)

    return Program(NPU1Col1(), runtime).resolve_program(SequentialPlacer())


if __name__ == "__main__":
    print(build_program())
