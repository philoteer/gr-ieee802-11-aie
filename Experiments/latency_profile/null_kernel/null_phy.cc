// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
#include <aie_api/aie.hpp>
#include <stdint.h>

#include "frame_equalizer_metadata.h"

extern "C" void null_phy(const int32_t* __restrict input,
                         int8_t* __restrict output,
                         int32_t* __restrict metadata,
                         const int32_t* __restrict frequency,
                         const int32_t tile_size,
                         const int32_t metadata_words)
{
    // DMA/FIFO acquisition consumes the input. No PHY computation or input copy.
    (void)input;
    (void)frequency;
    static_assert(sizeof(frame_equalizer_tile_metadata) == 8968,
                  "null kernel metadata ABI must match the host PHY block");

    const auto zero_bytes = aie::zeros<int8_t, 32>();
    for (int32_t i = 0; i < tile_size; i += 32)
        aie::store_v(output + i, zero_bytes);

    const auto zero_words = aie::zeros<int32_t, 16>();
    int32_t i = 0;
    for (; i + 16 <= metadata_words; i += 16)
        aie::store_v(metadata + i, zero_words);
    for (; i < metadata_words; ++i)
        metadata[i] = 0;

    // Output is a full tile of dummy bytes with no frame/CSI tags. Clearing the
    // entire metadata object avoids stale records across slot reuse.
    metadata[0] = tile_size;
}
