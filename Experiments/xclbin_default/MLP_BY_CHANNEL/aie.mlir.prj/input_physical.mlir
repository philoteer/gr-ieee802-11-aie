module {
  aie.device(npu1) {
    %tile_0_2 = aie.tile(0, 2) {controller_id = #aie.packet_info<pkt_type = 0, pkt_id = 27>}
    %tile_0_3 = aie.tile(0, 3) {controller_id = #aie.packet_info<pkt_type = 0, pkt_id = 29>}
    %tile_0_4 = aie.tile(0, 4) {controller_id = #aie.packet_info<pkt_type = 0, pkt_id = 30>}
    %tile_0_5 = aie.tile(0, 5) {controller_id = #aie.packet_info<pkt_type = 0, pkt_id = 31>}
    %tile_1_2 = aie.tile(1, 2) {controller_id = #aie.packet_info<pkt_type = 0, pkt_id = 27>}
    %tile_1_3 = aie.tile(1, 3) {controller_id = #aie.packet_info<pkt_type = 0, pkt_id = 29>}
    %tile_1_4 = aie.tile(1, 4) {controller_id = #aie.packet_info<pkt_type = 0, pkt_id = 30>}
    %tile_1_5 = aie.tile(1, 5) {controller_id = #aie.packet_info<pkt_type = 0, pkt_id = 31>}
    %tile_2_2 = aie.tile(2, 2) {controller_id = #aie.packet_info<pkt_type = 0, pkt_id = 27>}
    %shim_noc_tile_2_0 = aie.tile(2, 0) {controller_id = #aie.packet_info<pkt_type = 0, pkt_id = 15>}
    %shim_noc_tile_0_0 = aie.tile(0, 0) {controller_id = #aie.packet_info<pkt_type = 0, pkt_id = 15>}
    %mem_tile_0_1 = aie.tile(0, 1) {controller_id = #aie.packet_info<pkt_type = 0, pkt_id = 26>}
    %threshold_met_buff_0 = aie.buffer(%tile_0_4) {address = 32768 : i32, mem_bank = 2 : i32, sym_name = "threshold_met_buff_0"} : memref<1024xi8> 
    %threshold_met_buff_1 = aie.buffer(%tile_0_4) {address = 49152 : i32, mem_bank = 3 : i32, sym_name = "threshold_met_buff_1"} : memref<1024xi8> 
    %threshold_met_prod_lock_0 = aie.lock(%tile_0_4, 2) {init = 2 : i32, sym_name = "threshold_met_prod_lock_0"}
    %threshold_met_cons_lock_0 = aie.lock(%tile_0_4, 3) {init = 0 : i32, sym_name = "threshold_met_cons_lock_0"}
    %sync_short_out_meta_cons_buff_0 = aie.buffer(%tile_1_2) {address = 7424 : i32, mem_bank = 0 : i32, sym_name = "sync_short_out_meta_cons_buff_0"} : memref<16xi32> 
    %sync_short_out_meta_cons_buff_1 = aie.buffer(%tile_1_2) {address = 21760 : i32, mem_bank = 1 : i32, sym_name = "sync_short_out_meta_cons_buff_1"} : memref<16xi32> 
    %sync_short_out_meta_cons_prod_lock_0 = aie.lock(%tile_1_2, 6) {init = 2 : i32, sym_name = "sync_short_out_meta_cons_prod_lock_0"}
    %sync_short_out_meta_cons_cons_lock_0 = aie.lock(%tile_1_2, 7) {init = 0 : i32, sym_name = "sync_short_out_meta_cons_cons_lock_0"}
    %sync_short_out_meta_buff_0 = aie.buffer(%tile_0_5) {address = 38144 : i32, mem_bank = 2 : i32, sym_name = "sync_short_out_meta_buff_0"} : memref<16xi32> 
    %sync_short_out_meta_buff_1 = aie.buffer(%tile_0_5) {address = 54528 : i32, mem_bank = 3 : i32, sym_name = "sync_short_out_meta_buff_1"} : memref<16xi32> 
    %sync_short_out_meta_prod_lock_0 = aie.lock(%tile_0_5, 6) {init = 2 : i32, sym_name = "sync_short_out_meta_prod_lock_0"}
    %sync_short_out_meta_cons_lock_0 = aie.lock(%tile_0_5, 7) {init = 0 : i32, sym_name = "sync_short_out_meta_cons_lock_0"}
    %sync_short_out_cons_buff_0 = aie.buffer(%tile_1_2) {address = 2048 : i32, mem_bank = 0 : i32, sym_name = "sync_short_out_cons_buff_0"} : memref<2688xi16> 
    %sync_short_out_cons_buff_1 = aie.buffer(%tile_1_2) {address = 16384 : i32, mem_bank = 1 : i32, sym_name = "sync_short_out_cons_buff_1"} : memref<2688xi16> 
    %sync_short_out_cons_prod_lock_0 = aie.lock(%tile_1_2, 4) {init = 2 : i32, sym_name = "sync_short_out_cons_prod_lock_0"}
    %sync_short_out_cons_cons_lock_0 = aie.lock(%tile_1_2, 5) {init = 0 : i32, sym_name = "sync_short_out_cons_cons_lock_0"}
    %sync_short_out_buff_0 = aie.buffer(%tile_0_5) {address = 32768 : i32, mem_bank = 2 : i32, sym_name = "sync_short_out_buff_0"} : memref<2688xi16> 
    %sync_short_out_buff_1 = aie.buffer(%tile_0_5) {address = 49152 : i32, mem_bank = 3 : i32, sym_name = "sync_short_out_buff_1"} : memref<2688xi16> 
    %sync_short_out_prod_lock_0 = aie.lock(%tile_0_5, 4) {init = 2 : i32, sym_name = "sync_short_out_prod_lock_0"}
    %sync_short_out_cons_lock_0 = aie.lock(%tile_0_5, 5) {init = 0 : i32, sym_name = "sync_short_out_cons_lock_0"}
    %sync_long_out_meta_buff_0 = aie.buffer(%tile_1_2) {address = 36864 : i32, mem_bank = 2 : i32, sym_name = "sync_long_out_meta_buff_0"} : memref<16xi32> 
    %sync_long_out_meta_buff_1 = aie.buffer(%tile_1_2) {address = 53248 : i32, mem_bank = 3 : i32, sym_name = "sync_long_out_meta_buff_1"} : memref<16xi32> 
    %sync_long_out_meta_prod_lock_0 = aie.lock(%tile_1_2, 2) {init = 2 : i32, sym_name = "sync_long_out_meta_prod_lock_0"}
    %sync_long_out_meta_cons_lock_0 = aie.lock(%tile_1_2, 3) {init = 0 : i32, sym_name = "sync_long_out_meta_cons_lock_0"}
    %sync_long_out_buff_0 = aie.buffer(%tile_1_2) {address = 32768 : i32, mem_bank = 2 : i32, sym_name = "sync_long_out_buff_0"} : memref<2048xi16> 
    %sync_long_out_buff_1 = aie.buffer(%tile_1_2) {address = 49152 : i32, mem_bank = 3 : i32, sym_name = "sync_long_out_buff_1"} : memref<2048xi16> 
    %sync_long_out_prod_lock_0 = aie.lock(%tile_1_2, 0) {init = 2 : i32, sym_name = "sync_long_out_prod_lock_0"}
    %sync_long_out_cons_lock_0 = aie.lock(%tile_1_2, 1) {init = 0 : i32, sym_name = "sync_long_out_cons_lock_0"}
    %out_magsq_delay_cons_buff_0 = aie.buffer(%tile_0_5) {address = 10240 : i32, mem_bank = 0 : i32, sym_name = "out_magsq_delay_cons_buff_0"} : memref<2048xi16> 
    %out_magsq_delay_cons_buff_1 = aie.buffer(%tile_0_5) {address = 24576 : i32, mem_bank = 1 : i32, sym_name = "out_magsq_delay_cons_buff_1"} : memref<2048xi16> 
    %out_magsq_delay_cons_prod_lock_0 = aie.lock(%tile_0_5, 2) {init = 2 : i32, sym_name = "out_magsq_delay_cons_prod_lock_0"}
    %out_magsq_delay_cons_cons_lock_0 = aie.lock(%tile_0_5, 3) {init = 0 : i32, sym_name = "out_magsq_delay_cons_cons_lock_0"}
    %out_magsq_delay_buff_0 = aie.buffer(%tile_0_3) {address = 1024 : i32, mem_bank = 0 : i32, sym_name = "out_magsq_delay_buff_0"} : memref<2048xi16> 
    %out_magsq_delay_buff_1 = aie.buffer(%tile_0_3) {address = 16384 : i32, mem_bank = 1 : i32, sym_name = "out_magsq_delay_buff_1"} : memref<2048xi16> 
    %out_magsq_delay_prod_lock_0 = aie.lock(%tile_0_3, 4) {init = 2 : i32, sym_name = "out_magsq_delay_prod_lock_0"}
    %out_magsq_delay_cons_lock_0 = aie.lock(%tile_0_3, 5) {init = 0 : i32, sym_name = "out_magsq_delay_cons_lock_0"}
    %out_magsq_buff_0 = aie.buffer(%tile_0_3) {address = 32768 : i32, mem_bank = 2 : i32, sym_name = "out_magsq_buff_0"} : memref<1024xi32> 
    %out_magsq_buff_1 = aie.buffer(%tile_0_3) {address = 49152 : i32, mem_bank = 3 : i32, sym_name = "out_magsq_buff_1"} : memref<1024xi32> 
    %out_magsq_prod_lock_0 = aie.lock(%tile_0_3, 2) {init = 2 : i32, sym_name = "out_magsq_prod_lock_0"}
    %out_magsq_cons_lock_0 = aie.lock(%tile_0_3, 3) {init = 0 : i32, sym_name = "out_magsq_cons_lock_0"}
    %out_autocorr_0_cons_buff_0 = aie.buffer(%tile_0_4) {address = 1024 : i32, mem_bank = 0 : i32, sym_name = "out_autocorr_0_cons_buff_0"} : memref<2048xi32> 
    %out_autocorr_0_cons_buff_1 = aie.buffer(%tile_0_4) {address = 16384 : i32, mem_bank = 1 : i32, sym_name = "out_autocorr_0_cons_buff_1"} : memref<2048xi32> 
    %out_autocorr_0_cons_prod_lock_0 = aie.lock(%tile_0_4, 0) {init = 2 : i32, sym_name = "out_autocorr_0_cons_prod_lock_0"}
    %out_autocorr_0_cons_cons_lock_0 = aie.lock(%tile_0_4, 1) {init = 0 : i32, sym_name = "out_autocorr_0_cons_cons_lock_0"}
    %out_autocorr_1_cons_buff_0 = aie.buffer(%tile_0_5) {address = 2048 : i32, mem_bank = 0 : i32, sym_name = "out_autocorr_1_cons_buff_0"} : memref<2048xi32> 
    %out_autocorr_1_cons_buff_1 = aie.buffer(%tile_0_5) {address = 16384 : i32, mem_bank = 1 : i32, sym_name = "out_autocorr_1_cons_buff_1"} : memref<2048xi32> 
    %out_autocorr_1_cons_prod_lock_0 = aie.lock(%tile_0_5, 0) {init = 2 : i32, sym_name = "out_autocorr_1_cons_prod_lock_0"}
    %out_autocorr_1_cons_cons_lock_0 = aie.lock(%tile_0_5, 1) {init = 0 : i32, sym_name = "out_autocorr_1_cons_cons_lock_0"}
    %out_autocorr_buff_0 = aie.buffer(%tile_0_2) {address = 1024 : i32, mem_bank = 0 : i32, sym_name = "out_autocorr_buff_0"} : memref<2048xi32> 
    %out_autocorr_buff_1 = aie.buffer(%tile_0_2) {address = 16384 : i32, mem_bank = 1 : i32, sym_name = "out_autocorr_buff_1"} : memref<2048xi32> 
    %out_autocorr_prod_lock_0 = aie.lock(%tile_0_2, 2) {init = 2 : i32, sym_name = "out_autocorr_prod_lock_0"}
    %out_autocorr_cons_lock_0 = aie.lock(%tile_0_2, 3) {init = 0 : i32, sym_name = "out_autocorr_cons_lock_0"}
    %in_mem_0_cons_buff_0 = aie.buffer(%tile_0_2) {address = 32768 : i32, mem_bank = 2 : i32, sym_name = "in_mem_0_cons_buff_0"} : memref<2048xi16> 
    %in_mem_0_cons_buff_1 = aie.buffer(%tile_0_2) {address = 49152 : i32, mem_bank = 3 : i32, sym_name = "in_mem_0_cons_buff_1"} : memref<2048xi16> 
    %in_mem_0_cons_prod_lock_0 = aie.lock(%tile_0_2, 0) {init = 2 : i32, sym_name = "in_mem_0_cons_prod_lock_0"}
    %in_mem_0_cons_cons_lock_0 = aie.lock(%tile_0_2, 1) {init = 0 : i32, sym_name = "in_mem_0_cons_cons_lock_0"}
    %in_mem_1_cons_buff_0 = aie.buffer(%tile_0_3) {address = 5120 : i32, mem_bank = 0 : i32, sym_name = "in_mem_1_cons_buff_0"} : memref<2048xi16> 
    %in_mem_1_cons_buff_1 = aie.buffer(%tile_0_3) {address = 20480 : i32, mem_bank = 1 : i32, sym_name = "in_mem_1_cons_buff_1"} : memref<2048xi16> 
    %in_mem_1_cons_prod_lock_0 = aie.lock(%tile_0_3, 0) {init = 2 : i32, sym_name = "in_mem_1_cons_prod_lock_0"}
    %in_mem_1_cons_cons_lock_0 = aie.lock(%tile_0_3, 1) {init = 0 : i32, sym_name = "in_mem_1_cons_cons_lock_0"}
    %in_cons_buff_0 = aie.buffer(%mem_tile_0_1) {address = 0 : i32, mem_bank = 0 : i32, sym_name = "in_cons_buff_0"} : memref<2048xi16> 
    %in_cons_buff_1 = aie.buffer(%mem_tile_0_1) {address = 65536 : i32, mem_bank = 1 : i32, sym_name = "in_cons_buff_1"} : memref<2048xi16> 
    %in_cons_prod_lock_0 = aie.lock(%mem_tile_0_1, 0) {init = 2 : i32, sym_name = "in_cons_prod_lock_0"}
    %in_cons_cons_lock_0 = aie.lock(%mem_tile_0_1, 1) {init = 0 : i32, sym_name = "in_cons_cons_lock_0"}
    %in_prod_lock_0 = aie.lock(%shim_noc_tile_0_0, 0) {init = 0 : i32, sym_name = "in_prod_lock_0"}
    %in_cons_lock_0 = aie.lock(%shim_noc_tile_0_0, 1) {init = 0 : i32, sym_name = "in_cons_lock_0"}
    %frame_equalizer_prepared_meta_buff_0 = aie.buffer(%tile_1_4) {address = 32768 : i32, mem_bank = 2 : i32, sym_name = "frame_equalizer_prepared_meta_buff_0"} : memref<81xi32> 
    %frame_equalizer_prepared_meta_buff_1 = aie.buffer(%tile_1_4) {address = 49152 : i32, mem_bank = 3 : i32, sym_name = "frame_equalizer_prepared_meta_buff_1"} : memref<81xi32> 
    %frame_equalizer_prepared_meta_prod_lock_0 = aie.lock(%tile_1_4, 2) {init = 2 : i32, sym_name = "frame_equalizer_prepared_meta_prod_lock_0"}
    %frame_equalizer_prepared_meta_cons_lock_0 = aie.lock(%tile_1_4, 3) {init = 0 : i32, sym_name = "frame_equalizer_prepared_meta_cons_lock_0"}
    %frame_equalizer_prepared_0_cons_buff_0 = aie.buffer(%tile_1_5) {address = 16384 : i32, mem_bank = 1 : i32, sym_name = "frame_equalizer_prepared_0_cons_buff_0"} : memref<2048xi32> 
    %frame_equalizer_prepared_0_cons_buff_1 = aie.buffer(%tile_1_5) {address = 32768 : i32, mem_bank = 2 : i32, sym_name = "frame_equalizer_prepared_0_cons_buff_1"} : memref<2048xi32> 
    %frame_equalizer_prepared_0_cons_prod_lock_0 = aie.lock(%tile_1_5, 2) {init = 2 : i32, sym_name = "frame_equalizer_prepared_0_cons_prod_lock_0"}
    %frame_equalizer_prepared_0_cons_cons_lock_0 = aie.lock(%tile_1_5, 3) {init = 0 : i32, sym_name = "frame_equalizer_prepared_0_cons_cons_lock_0"}
    %frame_equalizer_prepared_1_cons_buff_0 = aie.buffer(%tile_2_2) {address = 49152 : i32, mem_bank = 3 : i32, sym_name = "frame_equalizer_prepared_1_cons_buff_0"} : memref<2048xi32> 
    %frame_equalizer_prepared_1_cons_buff_1 = aie.buffer(%tile_2_2) {address = 57344 : i32, mem_bank = 3 : i32, sym_name = "frame_equalizer_prepared_1_cons_buff_1"} : memref<2048xi32> 
    %frame_equalizer_prepared_1_cons_prod_lock_0 = aie.lock(%tile_2_2, 6) {init = 2 : i32, sym_name = "frame_equalizer_prepared_1_cons_prod_lock_0"}
    %frame_equalizer_prepared_1_cons_cons_lock_0 = aie.lock(%tile_2_2, 7) {init = 0 : i32, sym_name = "frame_equalizer_prepared_1_cons_cons_lock_0"}
    %frame_equalizer_prepared_buff_0 = aie.buffer(%tile_1_4) {address = 2560 : i32, mem_bank = 0 : i32, sym_name = "frame_equalizer_prepared_buff_0"} : memref<2048xi32> 
    %frame_equalizer_prepared_buff_1 = aie.buffer(%tile_1_4) {address = 16384 : i32, mem_bank = 1 : i32, sym_name = "frame_equalizer_prepared_buff_1"} : memref<2048xi32> 
    %frame_equalizer_prepared_prod_lock_0 = aie.lock(%tile_1_4, 0) {init = 2 : i32, sym_name = "frame_equalizer_prepared_prod_lock_0"}
    %frame_equalizer_prepared_cons_lock_0 = aie.lock(%tile_1_4, 1) {init = 0 : i32, sym_name = "frame_equalizer_prepared_cons_lock_0"}
    %frame_equalizer_out_meta_cons_prod_lock_0 = aie.lock(%shim_noc_tile_2_0, 2) {init = 0 : i32, sym_name = "frame_equalizer_out_meta_cons_prod_lock_0"}
    %frame_equalizer_out_meta_cons_cons_lock_0 = aie.lock(%shim_noc_tile_2_0, 3) {init = 0 : i32, sym_name = "frame_equalizer_out_meta_cons_cons_lock_0"}
    %frame_equalizer_out_meta_buff_0 = aie.buffer(%tile_2_2) {address = 4096 : i32, mem_bank = 0 : i32, sym_name = "frame_equalizer_out_meta_buff_0"} : memref<2242xi32> 
    %frame_equalizer_out_meta_buff_1 = aie.buffer(%tile_2_2) {address = 16384 : i32, mem_bank = 1 : i32, sym_name = "frame_equalizer_out_meta_buff_1"} : memref<2242xi32> 
    %frame_equalizer_out_meta_prod_lock_0 = aie.lock(%tile_2_2, 4) {init = 2 : i32, sym_name = "frame_equalizer_out_meta_prod_lock_0"}
    %frame_equalizer_out_meta_cons_lock_0 = aie.lock(%tile_2_2, 5) {init = 0 : i32, sym_name = "frame_equalizer_out_meta_cons_lock_0"}
    %frame_equalizer_out_cons_prod_lock_0 = aie.lock(%shim_noc_tile_2_0, 0) {init = 0 : i32, sym_name = "frame_equalizer_out_cons_prod_lock_0"}
    %frame_equalizer_out_cons_cons_lock_0 = aie.lock(%shim_noc_tile_2_0, 1) {init = 0 : i32, sym_name = "frame_equalizer_out_cons_cons_lock_0"}
    %frame_equalizer_out_buff_0 = aie.buffer(%tile_2_2) {address = 13064 : i32, mem_bank = 0 : i32, sym_name = "frame_equalizer_out_buff_0"} : memref<1024xi8> 
    %frame_equalizer_out_buff_1 = aie.buffer(%tile_2_2) {address = 25352 : i32, mem_bank = 1 : i32, sym_name = "frame_equalizer_out_buff_1"} : memref<1024xi8> 
    %frame_equalizer_out_prod_lock_0 = aie.lock(%tile_2_2, 2) {init = 2 : i32, sym_name = "frame_equalizer_out_prod_lock_0"}
    %frame_equalizer_out_cons_lock_0 = aie.lock(%tile_2_2, 3) {init = 0 : i32, sym_name = "frame_equalizer_out_cons_lock_0"}
    %frame_equalizer_meta_cons_buff_0 = aie.buffer(%tile_2_2) {address = 32768 : i32, mem_bank = 2 : i32, sym_name = "frame_equalizer_meta_cons_buff_0"} : memref<2168xi32> 
    %frame_equalizer_meta_cons_prod_lock_0 = aie.lock(%tile_2_2, 0) {init = 1 : i32, sym_name = "frame_equalizer_meta_cons_prod_lock_0"}
    %frame_equalizer_meta_cons_cons_lock_0 = aie.lock(%tile_2_2, 1) {init = 0 : i32, sym_name = "frame_equalizer_meta_cons_cons_lock_0"}
    %frame_equalizer_meta_buff_0 = aie.buffer(%tile_1_5) {address = 2048 : i32, mem_bank = 0 : i32, sym_name = "frame_equalizer_meta_buff_0"} : memref<2168xi32> 
    %frame_equalizer_meta_prod_lock_0 = aie.lock(%tile_1_5, 0) {init = 1 : i32, sym_name = "frame_equalizer_meta_prod_lock_0"}
    %frame_equalizer_meta_cons_lock_0 = aie.lock(%tile_1_5, 1) {init = 0 : i32, sym_name = "frame_equalizer_meta_cons_lock_0"}
    %fft_out_meta_buff_0 = aie.buffer(%tile_1_3) {address = 32768 : i32, mem_bank = 2 : i32, sym_name = "fft_out_meta_buff_0"} : memref<64xi32> 
    %fft_out_meta_buff_1 = aie.buffer(%tile_1_3) {address = 49152 : i32, mem_bank = 3 : i32, sym_name = "fft_out_meta_buff_1"} : memref<64xi32> 
    %fft_out_meta_prod_lock_0 = aie.lock(%tile_1_3, 2) {init = 2 : i32, sym_name = "fft_out_meta_prod_lock_0"}
    %fft_out_meta_cons_lock_0 = aie.lock(%tile_1_3, 3) {init = 0 : i32, sym_name = "fft_out_meta_cons_lock_0"}
    %fft_out_buff_0 = aie.buffer(%tile_1_3) {address = 1024 : i32, mem_bank = 0 : i32, sym_name = "fft_out_buff_0"} : memref<2048xi32> 
    %fft_out_buff_1 = aie.buffer(%tile_1_3) {address = 16384 : i32, mem_bank = 1 : i32, sym_name = "fft_out_buff_1"} : memref<2048xi32> 
    %fft_out_prod_lock_0 = aie.lock(%tile_1_3, 0) {init = 2 : i32, sym_name = "fft_out_prod_lock_0"}
    %fft_out_cons_lock_0 = aie.lock(%tile_1_3, 1) {init = 0 : i32, sym_name = "fft_out_cons_lock_0"}
    aie.flow(%tile_1_4, DMA : 0, %tile_1_5, DMA : 0)
    aie.flow(%mem_tile_0_1, DMA : 0, %tile_0_2, DMA : 0)
    aie.flow(%tile_0_2, DMA : 0, %tile_0_4, DMA : 0)
    func.func private @autocorr_cf(memref<2048xi16>, memref<2048xi32>, i32)
    func.func private @magsq_avg_cf(memref<2048xi16>, memref<1024xi32>, memref<2048xi16>, i32)
    func.func private @threshold_cf(memref<2048xi32>, memref<1024xi32>, memref<1024xi8>, i32)
    func.func private @sync_short_cf(memref<2048xi16>, memref<2048xi32>, memref<1024xi8>, memref<2688xi16>, memref<16xi32>, i32)
    func.func private @sync_long_cf(memref<2688xi16>, memref<16xi32>, memref<2048xi16>, memref<16xi32>, i32, i32)
    func.func private @fft_cf(memref<2048xi16>, memref<16xi32>, memref<2048xi32>, memref<64xi32>, i32, i32)
    %center_frequency = aie.buffer(%tile_1_4) {address = 10752 : i32, mem_bank = 0 : i32, sym_name = "center_frequency"} : memref<2xi32> 
    func.func private @frame_equalizer_preprocess(memref<2048xi32>, memref<64xi32>, memref<2048xi32>, memref<81xi32>, memref<2xi32>, i32, i32)
    func.func private @frame_equalizer_channel_estimate(memref<2048xi32>, memref<81xi32>, memref<2168xi32>)
    func.func private @frame_equalizer_equalize(memref<2048xi32>, memref<2168xi32>, memref<1024xi8>, memref<2242xi32>, i32, i32)
    %core_0_2 = aie.core(%tile_0_2) {
      %c2 = arith.constant 2 : index
      %c1024_i32 = arith.constant 1024 : i32
      %c16 = arith.constant 16 : index
      %c0 = arith.constant 0 : index
      %c9223372036854775807 = arith.constant 9223372036854775807 : index
      %c1 = arith.constant 1 : index
      cf.br ^bb1(%c0 : index)
    ^bb1(%0: index):  // 2 preds: ^bb0, ^bb5
      %1 = arith.cmpi slt, %0, %c9223372036854775807 : index
      cf.cond_br %1, ^bb2, ^bb6
    ^bb2:  // pred: ^bb1
      cf.br ^bb3(%c0 : index)
    ^bb3(%2: index):  // 2 preds: ^bb2, ^bb4
      %3 = arith.cmpi slt, %2, %c16 : index
      cf.cond_br %3, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      aie.use_lock(%in_mem_0_cons_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%out_autocorr_prod_lock_0, AcquireGreaterEqual, 1)
      func.call @autocorr_cf(%in_mem_0_cons_buff_0, %out_autocorr_buff_0, %c1024_i32) : (memref<2048xi16>, memref<2048xi32>, i32) -> ()
      aie.use_lock(%in_mem_0_cons_prod_lock_0, Release, 1)
      aie.use_lock(%out_autocorr_cons_lock_0, Release, 1)
      aie.use_lock(%in_mem_0_cons_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%out_autocorr_prod_lock_0, AcquireGreaterEqual, 1)
      func.call @autocorr_cf(%in_mem_0_cons_buff_1, %out_autocorr_buff_1, %c1024_i32) : (memref<2048xi16>, memref<2048xi32>, i32) -> ()
      aie.use_lock(%in_mem_0_cons_prod_lock_0, Release, 1)
      aie.use_lock(%out_autocorr_cons_lock_0, Release, 1)
      %4 = arith.addi %2, %c2 : index
      cf.br ^bb3(%4 : index)
    ^bb5:  // pred: ^bb3
      %5 = arith.addi %0, %c1 : index
      cf.br ^bb1(%5 : index)
    ^bb6:  // pred: ^bb1
      aie.end
    } {link_with = "autocorr_cf.o"}
    %core_0_3 = aie.core(%tile_0_3) {
      %c2 = arith.constant 2 : index
      %c1024_i32 = arith.constant 1024 : i32
      %c16 = arith.constant 16 : index
      %c0 = arith.constant 0 : index
      %c9223372036854775807 = arith.constant 9223372036854775807 : index
      %c1 = arith.constant 1 : index
      cf.br ^bb1(%c0 : index)
    ^bb1(%0: index):  // 2 preds: ^bb0, ^bb5
      %1 = arith.cmpi slt, %0, %c9223372036854775807 : index
      cf.cond_br %1, ^bb2, ^bb6
    ^bb2:  // pred: ^bb1
      cf.br ^bb3(%c0 : index)
    ^bb3(%2: index):  // 2 preds: ^bb2, ^bb4
      %3 = arith.cmpi slt, %2, %c16 : index
      cf.cond_br %3, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      aie.use_lock(%in_mem_1_cons_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%out_magsq_prod_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%out_magsq_delay_prod_lock_0, AcquireGreaterEqual, 1)
      func.call @magsq_avg_cf(%in_mem_1_cons_buff_0, %out_magsq_buff_0, %out_magsq_delay_buff_0, %c1024_i32) : (memref<2048xi16>, memref<1024xi32>, memref<2048xi16>, i32) -> ()
      aie.use_lock(%in_mem_1_cons_prod_lock_0, Release, 1)
      aie.use_lock(%out_magsq_cons_lock_0, Release, 1)
      aie.use_lock(%out_magsq_delay_cons_lock_0, Release, 1)
      aie.use_lock(%in_mem_1_cons_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%out_magsq_prod_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%out_magsq_delay_prod_lock_0, AcquireGreaterEqual, 1)
      func.call @magsq_avg_cf(%in_mem_1_cons_buff_1, %out_magsq_buff_1, %out_magsq_delay_buff_1, %c1024_i32) : (memref<2048xi16>, memref<1024xi32>, memref<2048xi16>, i32) -> ()
      aie.use_lock(%in_mem_1_cons_prod_lock_0, Release, 1)
      aie.use_lock(%out_magsq_cons_lock_0, Release, 1)
      aie.use_lock(%out_magsq_delay_cons_lock_0, Release, 1)
      %4 = arith.addi %2, %c2 : index
      cf.br ^bb3(%4 : index)
    ^bb5:  // pred: ^bb3
      %5 = arith.addi %0, %c1 : index
      cf.br ^bb1(%5 : index)
    ^bb6:  // pred: ^bb1
      aie.end
    } {link_with = "magsq_avg_cf.o"}
    %core_0_4 = aie.core(%tile_0_4) {
      %c2 = arith.constant 2 : index
      %c1024_i32 = arith.constant 1024 : i32
      %c16 = arith.constant 16 : index
      %c0 = arith.constant 0 : index
      %c9223372036854775807 = arith.constant 9223372036854775807 : index
      %c1 = arith.constant 1 : index
      cf.br ^bb1(%c0 : index)
    ^bb1(%0: index):  // 2 preds: ^bb0, ^bb5
      %1 = arith.cmpi slt, %0, %c9223372036854775807 : index
      cf.cond_br %1, ^bb2, ^bb6
    ^bb2:  // pred: ^bb1
      cf.br ^bb3(%c0 : index)
    ^bb3(%2: index):  // 2 preds: ^bb2, ^bb4
      %3 = arith.cmpi slt, %2, %c16 : index
      cf.cond_br %3, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      aie.use_lock(%out_autocorr_0_cons_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%out_magsq_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%threshold_met_prod_lock_0, AcquireGreaterEqual, 1)
      func.call @threshold_cf(%out_autocorr_0_cons_buff_0, %out_magsq_buff_0, %threshold_met_buff_0, %c1024_i32) : (memref<2048xi32>, memref<1024xi32>, memref<1024xi8>, i32) -> ()
      aie.use_lock(%out_autocorr_0_cons_prod_lock_0, Release, 1)
      aie.use_lock(%out_magsq_prod_lock_0, Release, 1)
      aie.use_lock(%threshold_met_cons_lock_0, Release, 1)
      aie.use_lock(%out_autocorr_0_cons_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%out_magsq_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%threshold_met_prod_lock_0, AcquireGreaterEqual, 1)
      func.call @threshold_cf(%out_autocorr_0_cons_buff_1, %out_magsq_buff_1, %threshold_met_buff_1, %c1024_i32) : (memref<2048xi32>, memref<1024xi32>, memref<1024xi8>, i32) -> ()
      aie.use_lock(%out_autocorr_0_cons_prod_lock_0, Release, 1)
      aie.use_lock(%out_magsq_prod_lock_0, Release, 1)
      aie.use_lock(%threshold_met_cons_lock_0, Release, 1)
      %4 = arith.addi %2, %c2 : index
      cf.br ^bb3(%4 : index)
    ^bb5:  // pred: ^bb3
      %5 = arith.addi %0, %c1 : index
      cf.br ^bb1(%5 : index)
    ^bb6:  // pred: ^bb1
      aie.end
    } {link_with = "threshold_cf.o"}
    %core_0_5 = aie.core(%tile_0_5) {
      %c2 = arith.constant 2 : index
      %c1024_i32 = arith.constant 1024 : i32
      %c16 = arith.constant 16 : index
      %c0 = arith.constant 0 : index
      %c9223372036854775807 = arith.constant 9223372036854775807 : index
      %c1 = arith.constant 1 : index
      cf.br ^bb1(%c0 : index)
    ^bb1(%0: index):  // 2 preds: ^bb0, ^bb5
      %1 = arith.cmpi slt, %0, %c9223372036854775807 : index
      cf.cond_br %1, ^bb2, ^bb6
    ^bb2:  // pred: ^bb1
      cf.br ^bb3(%c0 : index)
    ^bb3(%2: index):  // 2 preds: ^bb2, ^bb4
      %3 = arith.cmpi slt, %2, %c16 : index
      cf.cond_br %3, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      aie.use_lock(%out_magsq_delay_cons_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%out_autocorr_1_cons_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%threshold_met_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%sync_short_out_prod_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%sync_short_out_meta_prod_lock_0, AcquireGreaterEqual, 1)
      func.call @sync_short_cf(%out_magsq_delay_cons_buff_0, %out_autocorr_1_cons_buff_0, %threshold_met_buff_0, %sync_short_out_buff_0, %sync_short_out_meta_buff_0, %c1024_i32) : (memref<2048xi16>, memref<2048xi32>, memref<1024xi8>, memref<2688xi16>, memref<16xi32>, i32) -> ()
      aie.use_lock(%out_magsq_delay_cons_prod_lock_0, Release, 1)
      aie.use_lock(%out_autocorr_1_cons_prod_lock_0, Release, 1)
      aie.use_lock(%threshold_met_prod_lock_0, Release, 1)
      aie.use_lock(%sync_short_out_cons_lock_0, Release, 1)
      aie.use_lock(%sync_short_out_meta_cons_lock_0, Release, 1)
      aie.use_lock(%out_magsq_delay_cons_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%out_autocorr_1_cons_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%threshold_met_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%sync_short_out_prod_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%sync_short_out_meta_prod_lock_0, AcquireGreaterEqual, 1)
      func.call @sync_short_cf(%out_magsq_delay_cons_buff_1, %out_autocorr_1_cons_buff_1, %threshold_met_buff_1, %sync_short_out_buff_1, %sync_short_out_meta_buff_1, %c1024_i32) : (memref<2048xi16>, memref<2048xi32>, memref<1024xi8>, memref<2688xi16>, memref<16xi32>, i32) -> ()
      aie.use_lock(%out_magsq_delay_cons_prod_lock_0, Release, 1)
      aie.use_lock(%out_autocorr_1_cons_prod_lock_0, Release, 1)
      aie.use_lock(%threshold_met_prod_lock_0, Release, 1)
      aie.use_lock(%sync_short_out_cons_lock_0, Release, 1)
      aie.use_lock(%sync_short_out_meta_cons_lock_0, Release, 1)
      %4 = arith.addi %2, %c2 : index
      cf.br ^bb3(%4 : index)
    ^bb5:  // pred: ^bb3
      %5 = arith.addi %0, %c1 : index
      cf.br ^bb1(%5 : index)
    ^bb6:  // pred: ^bb1
      aie.end
    } {link_with = "sync_short_cf.o", stack_size = 2048 : i32}
    %core_1_2 = aie.core(%tile_1_2) {
      %c2 = arith.constant 2 : index
      %c16_i32 = arith.constant 16 : i32
      %c1024_i32 = arith.constant 1024 : i32
      %c16 = arith.constant 16 : index
      %c0 = arith.constant 0 : index
      %c9223372036854775807 = arith.constant 9223372036854775807 : index
      %c1 = arith.constant 1 : index
      cf.br ^bb1(%c0 : index)
    ^bb1(%0: index):  // 2 preds: ^bb0, ^bb5
      %1 = arith.cmpi slt, %0, %c9223372036854775807 : index
      cf.cond_br %1, ^bb2, ^bb6
    ^bb2:  // pred: ^bb1
      cf.br ^bb3(%c0 : index)
    ^bb3(%2: index):  // 2 preds: ^bb2, ^bb4
      %3 = arith.cmpi slt, %2, %c16 : index
      cf.cond_br %3, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      aie.use_lock(%sync_short_out_cons_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%sync_short_out_meta_cons_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%sync_long_out_prod_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%sync_long_out_meta_prod_lock_0, AcquireGreaterEqual, 1)
      func.call @sync_long_cf(%sync_short_out_cons_buff_0, %sync_short_out_meta_cons_buff_0, %sync_long_out_buff_0, %sync_long_out_meta_buff_0, %c1024_i32, %c16_i32) : (memref<2688xi16>, memref<16xi32>, memref<2048xi16>, memref<16xi32>, i32, i32) -> ()
      aie.use_lock(%sync_short_out_cons_prod_lock_0, Release, 1)
      aie.use_lock(%sync_short_out_meta_cons_prod_lock_0, Release, 1)
      aie.use_lock(%sync_long_out_cons_lock_0, Release, 1)
      aie.use_lock(%sync_long_out_meta_cons_lock_0, Release, 1)
      aie.use_lock(%sync_short_out_cons_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%sync_short_out_meta_cons_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%sync_long_out_prod_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%sync_long_out_meta_prod_lock_0, AcquireGreaterEqual, 1)
      func.call @sync_long_cf(%sync_short_out_cons_buff_1, %sync_short_out_meta_cons_buff_1, %sync_long_out_buff_1, %sync_long_out_meta_buff_1, %c1024_i32, %c16_i32) : (memref<2688xi16>, memref<16xi32>, memref<2048xi16>, memref<16xi32>, i32, i32) -> ()
      aie.use_lock(%sync_short_out_cons_prod_lock_0, Release, 1)
      aie.use_lock(%sync_short_out_meta_cons_prod_lock_0, Release, 1)
      aie.use_lock(%sync_long_out_cons_lock_0, Release, 1)
      aie.use_lock(%sync_long_out_meta_cons_lock_0, Release, 1)
      %4 = arith.addi %2, %c2 : index
      cf.br ^bb3(%4 : index)
    ^bb5:  // pred: ^bb3
      %5 = arith.addi %0, %c1 : index
      cf.br ^bb1(%5 : index)
    ^bb6:  // pred: ^bb1
      aie.end
    } {link_with = "sync_long_cf.o", stack_size = 2048 : i32}
    %core_1_3 = aie.core(%tile_1_3) {
      %c2 = arith.constant 2 : index
      %c64_i32 = arith.constant 64 : i32
      %c1024_i32 = arith.constant 1024 : i32
      %c16 = arith.constant 16 : index
      %c0 = arith.constant 0 : index
      %c9223372036854775807 = arith.constant 9223372036854775807 : index
      %c1 = arith.constant 1 : index
      cf.br ^bb1(%c0 : index)
    ^bb1(%0: index):  // 2 preds: ^bb0, ^bb5
      %1 = arith.cmpi slt, %0, %c9223372036854775807 : index
      cf.cond_br %1, ^bb2, ^bb6
    ^bb2:  // pred: ^bb1
      cf.br ^bb3(%c0 : index)
    ^bb3(%2: index):  // 2 preds: ^bb2, ^bb4
      %3 = arith.cmpi slt, %2, %c16 : index
      cf.cond_br %3, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      aie.use_lock(%sync_long_out_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%sync_long_out_meta_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%fft_out_prod_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%fft_out_meta_prod_lock_0, AcquireGreaterEqual, 1)
      func.call @fft_cf(%sync_long_out_buff_0, %sync_long_out_meta_buff_0, %fft_out_buff_0, %fft_out_meta_buff_0, %c1024_i32, %c64_i32) : (memref<2048xi16>, memref<16xi32>, memref<2048xi32>, memref<64xi32>, i32, i32) -> ()
      aie.use_lock(%sync_long_out_prod_lock_0, Release, 1)
      aie.use_lock(%sync_long_out_meta_prod_lock_0, Release, 1)
      aie.use_lock(%fft_out_cons_lock_0, Release, 1)
      aie.use_lock(%fft_out_meta_cons_lock_0, Release, 1)
      aie.use_lock(%sync_long_out_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%sync_long_out_meta_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%fft_out_prod_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%fft_out_meta_prod_lock_0, AcquireGreaterEqual, 1)
      func.call @fft_cf(%sync_long_out_buff_1, %sync_long_out_meta_buff_1, %fft_out_buff_1, %fft_out_meta_buff_1, %c1024_i32, %c64_i32) : (memref<2048xi16>, memref<16xi32>, memref<2048xi32>, memref<64xi32>, i32, i32) -> ()
      aie.use_lock(%sync_long_out_prod_lock_0, Release, 1)
      aie.use_lock(%sync_long_out_meta_prod_lock_0, Release, 1)
      aie.use_lock(%fft_out_cons_lock_0, Release, 1)
      aie.use_lock(%fft_out_meta_cons_lock_0, Release, 1)
      %4 = arith.addi %2, %c2 : index
      cf.br ^bb3(%4 : index)
    ^bb5:  // pred: ^bb3
      %5 = arith.addi %0, %c1 : index
      cf.br ^bb1(%5 : index)
    ^bb6:  // pred: ^bb1
      aie.end
    } {link_with = "fft_cf.o"}
    %core_1_4 = aie.core(%tile_1_4) {
      %c2 = arith.constant 2 : index
      %c64_i32 = arith.constant 64 : i32
      %c1024_i32 = arith.constant 1024 : i32
      %c16 = arith.constant 16 : index
      %c0 = arith.constant 0 : index
      %c9223372036854775807 = arith.constant 9223372036854775807 : index
      %c1 = arith.constant 1 : index
      cf.br ^bb1(%c0 : index)
    ^bb1(%0: index):  // 2 preds: ^bb0, ^bb5
      %1 = arith.cmpi slt, %0, %c9223372036854775807 : index
      cf.cond_br %1, ^bb2, ^bb6
    ^bb2:  // pred: ^bb1
      cf.br ^bb3(%c0 : index)
    ^bb3(%2: index):  // 2 preds: ^bb2, ^bb4
      %3 = arith.cmpi slt, %2, %c16 : index
      cf.cond_br %3, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      aie.use_lock(%fft_out_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%fft_out_meta_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%frame_equalizer_prepared_prod_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%frame_equalizer_prepared_meta_prod_lock_0, AcquireGreaterEqual, 1)
      func.call @frame_equalizer_preprocess(%fft_out_buff_0, %fft_out_meta_buff_0, %frame_equalizer_prepared_buff_0, %frame_equalizer_prepared_meta_buff_0, %center_frequency, %c1024_i32, %c64_i32) : (memref<2048xi32>, memref<64xi32>, memref<2048xi32>, memref<81xi32>, memref<2xi32>, i32, i32) -> ()
      aie.use_lock(%fft_out_prod_lock_0, Release, 1)
      aie.use_lock(%fft_out_meta_prod_lock_0, Release, 1)
      aie.use_lock(%frame_equalizer_prepared_cons_lock_0, Release, 1)
      aie.use_lock(%frame_equalizer_prepared_meta_cons_lock_0, Release, 1)
      aie.use_lock(%fft_out_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%fft_out_meta_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%frame_equalizer_prepared_prod_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%frame_equalizer_prepared_meta_prod_lock_0, AcquireGreaterEqual, 1)
      func.call @frame_equalizer_preprocess(%fft_out_buff_1, %fft_out_meta_buff_1, %frame_equalizer_prepared_buff_1, %frame_equalizer_prepared_meta_buff_1, %center_frequency, %c1024_i32, %c64_i32) : (memref<2048xi32>, memref<64xi32>, memref<2048xi32>, memref<81xi32>, memref<2xi32>, i32, i32) -> ()
      aie.use_lock(%fft_out_prod_lock_0, Release, 1)
      aie.use_lock(%fft_out_meta_prod_lock_0, Release, 1)
      aie.use_lock(%frame_equalizer_prepared_cons_lock_0, Release, 1)
      aie.use_lock(%frame_equalizer_prepared_meta_cons_lock_0, Release, 1)
      %4 = arith.addi %2, %c2 : index
      cf.br ^bb3(%4 : index)
    ^bb5:  // pred: ^bb3
      %5 = arith.addi %0, %c1 : index
      cf.br ^bb1(%5 : index)
    ^bb6:  // pred: ^bb1
      aie.end
    } {link_with = "frame_equalizer_preprocess.o", stack_size = 2560 : i32}
    %core_1_5 = aie.core(%tile_1_5) {
      %c2 = arith.constant 2 : index
      %c16 = arith.constant 16 : index
      %c0 = arith.constant 0 : index
      %c9223372036854775807 = arith.constant 9223372036854775807 : index
      %c1 = arith.constant 1 : index
      cf.br ^bb1(%c0 : index)
    ^bb1(%0: index):  // 2 preds: ^bb0, ^bb5
      %1 = arith.cmpi slt, %0, %c9223372036854775807 : index
      cf.cond_br %1, ^bb2, ^bb6
    ^bb2:  // pred: ^bb1
      cf.br ^bb3(%c0 : index)
    ^bb3(%2: index):  // 2 preds: ^bb2, ^bb4
      %3 = arith.cmpi slt, %2, %c16 : index
      cf.cond_br %3, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      aie.use_lock(%frame_equalizer_prepared_0_cons_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%frame_equalizer_prepared_meta_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%frame_equalizer_meta_prod_lock_0, AcquireGreaterEqual, 1)
      func.call @frame_equalizer_channel_estimate(%frame_equalizer_prepared_0_cons_buff_0, %frame_equalizer_prepared_meta_buff_0, %frame_equalizer_meta_buff_0) : (memref<2048xi32>, memref<81xi32>, memref<2168xi32>) -> ()
      aie.use_lock(%frame_equalizer_prepared_0_cons_prod_lock_0, Release, 1)
      aie.use_lock(%frame_equalizer_prepared_meta_prod_lock_0, Release, 1)
      aie.use_lock(%frame_equalizer_meta_cons_lock_0, Release, 1)
      aie.use_lock(%frame_equalizer_prepared_0_cons_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%frame_equalizer_prepared_meta_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%frame_equalizer_meta_prod_lock_0, AcquireGreaterEqual, 1)
      func.call @frame_equalizer_channel_estimate(%frame_equalizer_prepared_0_cons_buff_1, %frame_equalizer_prepared_meta_buff_1, %frame_equalizer_meta_buff_0) : (memref<2048xi32>, memref<81xi32>, memref<2168xi32>) -> ()
      aie.use_lock(%frame_equalizer_prepared_0_cons_prod_lock_0, Release, 1)
      aie.use_lock(%frame_equalizer_prepared_meta_prod_lock_0, Release, 1)
      aie.use_lock(%frame_equalizer_meta_cons_lock_0, Release, 1)
      %4 = arith.addi %2, %c2 : index
      cf.br ^bb3(%4 : index)
    ^bb5:  // pred: ^bb3
      %5 = arith.addi %0, %c1 : index
      cf.br ^bb1(%5 : index)
    ^bb6:  // pred: ^bb1
      aie.end
    } {link_with = "frame_equalizer_channel_estimate.o", stack_size = 2048 : i32}
    %core_2_2 = aie.core(%tile_2_2) {
      %c2 = arith.constant 2 : index
      %c2242_i32 = arith.constant 2242 : i32
      %c1024_i32 = arith.constant 1024 : i32
      %c16 = arith.constant 16 : index
      %c0 = arith.constant 0 : index
      %c9223372036854775807 = arith.constant 9223372036854775807 : index
      %c1 = arith.constant 1 : index
      cf.br ^bb1(%c0 : index)
    ^bb1(%0: index):  // 2 preds: ^bb0, ^bb5
      %1 = arith.cmpi slt, %0, %c9223372036854775807 : index
      cf.cond_br %1, ^bb2, ^bb6
    ^bb2:  // pred: ^bb1
      cf.br ^bb3(%c0 : index)
    ^bb3(%2: index):  // 2 preds: ^bb2, ^bb4
      %3 = arith.cmpi slt, %2, %c16 : index
      cf.cond_br %3, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      aie.use_lock(%frame_equalizer_meta_cons_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%frame_equalizer_prepared_1_cons_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%frame_equalizer_out_prod_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%frame_equalizer_out_meta_prod_lock_0, AcquireGreaterEqual, 1)
      func.call @frame_equalizer_equalize(%frame_equalizer_prepared_1_cons_buff_0, %frame_equalizer_meta_cons_buff_0, %frame_equalizer_out_buff_0, %frame_equalizer_out_meta_buff_0, %c1024_i32, %c2242_i32) : (memref<2048xi32>, memref<2168xi32>, memref<1024xi8>, memref<2242xi32>, i32, i32) -> ()
      aie.use_lock(%frame_equalizer_meta_cons_prod_lock_0, Release, 1)
      aie.use_lock(%frame_equalizer_prepared_1_cons_prod_lock_0, Release, 1)
      aie.use_lock(%frame_equalizer_out_cons_lock_0, Release, 1)
      aie.use_lock(%frame_equalizer_out_meta_cons_lock_0, Release, 1)
      aie.use_lock(%frame_equalizer_meta_cons_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%frame_equalizer_prepared_1_cons_cons_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%frame_equalizer_out_prod_lock_0, AcquireGreaterEqual, 1)
      aie.use_lock(%frame_equalizer_out_meta_prod_lock_0, AcquireGreaterEqual, 1)
      func.call @frame_equalizer_equalize(%frame_equalizer_prepared_1_cons_buff_1, %frame_equalizer_meta_cons_buff_0, %frame_equalizer_out_buff_1, %frame_equalizer_out_meta_buff_1, %c1024_i32, %c2242_i32) : (memref<2048xi32>, memref<2168xi32>, memref<1024xi8>, memref<2242xi32>, i32, i32) -> ()
      aie.use_lock(%frame_equalizer_meta_cons_prod_lock_0, Release, 1)
      aie.use_lock(%frame_equalizer_prepared_1_cons_prod_lock_0, Release, 1)
      aie.use_lock(%frame_equalizer_out_cons_lock_0, Release, 1)
      aie.use_lock(%frame_equalizer_out_meta_cons_lock_0, Release, 1)
      %4 = arith.addi %2, %c2 : index
      cf.br ^bb3(%4 : index)
    ^bb5:  // pred: ^bb3
      %5 = arith.addi %0, %c1 : index
      cf.br ^bb1(%5 : index)
    ^bb6:  // pred: ^bb1
      aie.end
    } {link_with = "frame_equalizer_equalize.o", stack_size = 4096 : i32}
    aie.runtime_sequence(%arg0: memref<32768xi16>, %arg1: memref<16384xi8>, %arg2: memref<35872xi32>) {
      aiex.npu.rtp_write(@center_frequency, 0, 324508639)
      aiex.npu.rtp_write(@center_frequency, 1, 610839776)
      %0 = aiex.dma_configure_task_for @in_shim_alloc {
        aie.dma_bd(%arg0 : memref<32768xi16>, 0, 32768, [<size = 1, stride = 0>, <size = 1, stride = 0>, <size = 1, stride = 0>, <size = 32768, stride = 1>]) {burst_length = 0 : i32}
        aie.end
      }
      aiex.dma_start_task(%0)
      %1 = aiex.dma_configure_task_for @frame_equalizer_out_shim_alloc {
        aie.dma_bd(%arg1 : memref<16384xi8>, 0, 16384, [<size = 1, stride = 0>, <size = 1, stride = 0>, <size = 1, stride = 0>, <size = 16384, stride = 1>]) {burst_length = 0 : i32}
        aie.end
      }
      aiex.dma_start_task(%1)
      %2 = aiex.dma_configure_task_for @frame_equalizer_out_meta_shim_alloc {
        aie.dma_bd(%arg2 : memref<35872xi32>, 0, 35872, [<size = 1, stride = 0>, <size = 1, stride = 0>, <size = 1, stride = 0>, <size = 35872, stride = 1>]) {burst_length = 0 : i32}
        aie.end
      } {issue_token = true}
      aiex.dma_start_task(%2)
      aiex.dma_await_task(%2)
      aiex.dma_free_task(%0)
      aiex.dma_free_task(%1)
    }
    %mem_1_5 = aie.mem(%tile_1_5) {
      %0 = aie.dma_start(MM2S, 0, ^bb1, ^bb2)
    ^bb1:  // 2 preds: ^bb0, ^bb1
      aie.use_lock(%frame_equalizer_meta_cons_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%frame_equalizer_meta_buff_0 : memref<2168xi32>, 0, 2168) {bd_id = 0 : i32, next_bd_id = 0 : i32}
      aie.use_lock(%frame_equalizer_meta_prod_lock_0, Release, 1)
      aie.next_bd ^bb1
    ^bb2:  // pred: ^bb0
      %1 = aie.dma_start(S2MM, 0, ^bb3, ^bb5)
    ^bb3:  // 2 preds: ^bb2, ^bb4
      aie.use_lock(%frame_equalizer_prepared_0_cons_prod_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%frame_equalizer_prepared_0_cons_buff_0 : memref<2048xi32>, 0, 2048) {bd_id = 1 : i32, next_bd_id = 2 : i32}
      aie.use_lock(%frame_equalizer_prepared_0_cons_cons_lock_0, Release, 1)
      aie.next_bd ^bb4
    ^bb4:  // pred: ^bb3
      aie.use_lock(%frame_equalizer_prepared_0_cons_prod_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%frame_equalizer_prepared_0_cons_buff_1 : memref<2048xi32>, 0, 2048) {bd_id = 2 : i32, next_bd_id = 1 : i32}
      aie.use_lock(%frame_equalizer_prepared_0_cons_cons_lock_0, Release, 1)
      aie.next_bd ^bb3
    ^bb5:  // pred: ^bb2
      aie.end
    }
    %mem_2_2 = aie.mem(%tile_2_2) {
      %0 = aie.dma_start(S2MM, 0, ^bb1, ^bb2)
    ^bb1:  // 2 preds: ^bb0, ^bb1
      aie.use_lock(%frame_equalizer_meta_cons_prod_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%frame_equalizer_meta_cons_buff_0 : memref<2168xi32>, 0, 2168) {bd_id = 0 : i32, next_bd_id = 0 : i32}
      aie.use_lock(%frame_equalizer_meta_cons_cons_lock_0, Release, 1)
      aie.next_bd ^bb1
    ^bb2:  // pred: ^bb0
      %1 = aie.dma_start(MM2S, 0, ^bb3, ^bb5)
    ^bb3:  // 2 preds: ^bb2, ^bb4
      aie.use_lock(%frame_equalizer_out_cons_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%frame_equalizer_out_buff_0 : memref<1024xi8>, 0, 1024) {bd_id = 1 : i32, next_bd_id = 2 : i32}
      aie.use_lock(%frame_equalizer_out_prod_lock_0, Release, 1)
      aie.next_bd ^bb4
    ^bb4:  // pred: ^bb3
      aie.use_lock(%frame_equalizer_out_cons_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%frame_equalizer_out_buff_1 : memref<1024xi8>, 0, 1024) {bd_id = 2 : i32, next_bd_id = 1 : i32}
      aie.use_lock(%frame_equalizer_out_prod_lock_0, Release, 1)
      aie.next_bd ^bb3
    ^bb5:  // pred: ^bb2
      %2 = aie.dma_start(MM2S, 1, ^bb6, ^bb8)
    ^bb6:  // 2 preds: ^bb5, ^bb7
      aie.use_lock(%frame_equalizer_out_meta_cons_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%frame_equalizer_out_meta_buff_0 : memref<2242xi32>, 0, 2242) {bd_id = 3 : i32, next_bd_id = 4 : i32}
      aie.use_lock(%frame_equalizer_out_meta_prod_lock_0, Release, 1)
      aie.next_bd ^bb7
    ^bb7:  // pred: ^bb6
      aie.use_lock(%frame_equalizer_out_meta_cons_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%frame_equalizer_out_meta_buff_1 : memref<2242xi32>, 0, 2242) {bd_id = 4 : i32, next_bd_id = 3 : i32}
      aie.use_lock(%frame_equalizer_out_meta_prod_lock_0, Release, 1)
      aie.next_bd ^bb6
    ^bb8:  // pred: ^bb5
      %3 = aie.dma_start(S2MM, 1, ^bb9, ^bb11)
    ^bb9:  // 2 preds: ^bb8, ^bb10
      aie.use_lock(%frame_equalizer_prepared_1_cons_prod_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%frame_equalizer_prepared_1_cons_buff_0 : memref<2048xi32>, 0, 2048) {bd_id = 5 : i32, next_bd_id = 6 : i32}
      aie.use_lock(%frame_equalizer_prepared_1_cons_cons_lock_0, Release, 1)
      aie.next_bd ^bb10
    ^bb10:  // pred: ^bb9
      aie.use_lock(%frame_equalizer_prepared_1_cons_prod_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%frame_equalizer_prepared_1_cons_buff_1 : memref<2048xi32>, 0, 2048) {bd_id = 6 : i32, next_bd_id = 5 : i32}
      aie.use_lock(%frame_equalizer_prepared_1_cons_cons_lock_0, Release, 1)
      aie.next_bd ^bb9
    ^bb11:  // pred: ^bb8
      aie.end
    }
    aie.shim_dma_allocation @frame_equalizer_out_shim_alloc(%shim_noc_tile_2_0, S2MM, 0)
    aie.shim_dma_allocation @frame_equalizer_out_meta_shim_alloc(%shim_noc_tile_2_0, S2MM, 1)
    %mem_1_4 = aie.mem(%tile_1_4) {
      %0 = aie.dma_start(MM2S, 0, ^bb1, ^bb3)
    ^bb1:  // 2 preds: ^bb0, ^bb2
      aie.use_lock(%frame_equalizer_prepared_cons_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%frame_equalizer_prepared_buff_0 : memref<2048xi32>, 0, 2048) {bd_id = 0 : i32, next_bd_id = 1 : i32}
      aie.use_lock(%frame_equalizer_prepared_prod_lock_0, Release, 1)
      aie.next_bd ^bb2
    ^bb2:  // pred: ^bb1
      aie.use_lock(%frame_equalizer_prepared_cons_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%frame_equalizer_prepared_buff_1 : memref<2048xi32>, 0, 2048) {bd_id = 1 : i32, next_bd_id = 0 : i32}
      aie.use_lock(%frame_equalizer_prepared_prod_lock_0, Release, 1)
      aie.next_bd ^bb1
    ^bb3:  // pred: ^bb0
      aie.end
    }
    aie.shim_dma_allocation @in_shim_alloc(%shim_noc_tile_0_0, MM2S, 0)
    %memtile_dma_0_1 = aie.memtile_dma(%mem_tile_0_1) {
      %0 = aie.dma_start(S2MM, 0, ^bb1, ^bb3)
    ^bb1:  // 2 preds: ^bb0, ^bb2
      aie.use_lock(%in_cons_prod_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%in_cons_buff_0 : memref<2048xi16>, 0, 2048) {bd_id = 0 : i32, next_bd_id = 1 : i32}
      aie.use_lock(%in_cons_cons_lock_0, Release, 1)
      aie.next_bd ^bb2
    ^bb2:  // pred: ^bb1
      aie.use_lock(%in_cons_prod_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%in_cons_buff_1 : memref<2048xi16>, 0, 2048) {bd_id = 1 : i32, next_bd_id = 0 : i32}
      aie.use_lock(%in_cons_cons_lock_0, Release, 1)
      aie.next_bd ^bb1
    ^bb3:  // pred: ^bb0
      %1 = aie.dma_start(MM2S, 0, ^bb4, ^bb6)
    ^bb4:  // 2 preds: ^bb3, ^bb5
      aie.use_lock(%in_cons_cons_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%in_cons_buff_0 : memref<2048xi16>, 0, 2048) {bd_id = 2 : i32, next_bd_id = 3 : i32}
      aie.use_lock(%in_cons_prod_lock_0, Release, 1)
      aie.next_bd ^bb5
    ^bb5:  // pred: ^bb4
      aie.use_lock(%in_cons_cons_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%in_cons_buff_1 : memref<2048xi16>, 0, 2048) {bd_id = 3 : i32, next_bd_id = 2 : i32}
      aie.use_lock(%in_cons_prod_lock_0, Release, 1)
      aie.next_bd ^bb4
    ^bb6:  // pred: ^bb3
      aie.end
    }
    %mem_0_2 = aie.mem(%tile_0_2) {
      %0 = aie.dma_start(S2MM, 0, ^bb1, ^bb3)
    ^bb1:  // 2 preds: ^bb0, ^bb2
      aie.use_lock(%in_mem_0_cons_prod_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%in_mem_0_cons_buff_0 : memref<2048xi16>, 0, 2048) {bd_id = 0 : i32, next_bd_id = 1 : i32}
      aie.use_lock(%in_mem_0_cons_cons_lock_0, Release, 1)
      aie.next_bd ^bb2
    ^bb2:  // pred: ^bb1
      aie.use_lock(%in_mem_0_cons_prod_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%in_mem_0_cons_buff_1 : memref<2048xi16>, 0, 2048) {bd_id = 1 : i32, next_bd_id = 0 : i32}
      aie.use_lock(%in_mem_0_cons_cons_lock_0, Release, 1)
      aie.next_bd ^bb1
    ^bb3:  // pred: ^bb0
      %1 = aie.dma_start(MM2S, 0, ^bb4, ^bb6)
    ^bb4:  // 2 preds: ^bb3, ^bb5
      aie.use_lock(%out_autocorr_cons_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%out_autocorr_buff_0 : memref<2048xi32>, 0, 2048) {bd_id = 2 : i32, next_bd_id = 3 : i32}
      aie.use_lock(%out_autocorr_prod_lock_0, Release, 1)
      aie.next_bd ^bb5
    ^bb5:  // pred: ^bb4
      aie.use_lock(%out_autocorr_cons_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%out_autocorr_buff_1 : memref<2048xi32>, 0, 2048) {bd_id = 3 : i32, next_bd_id = 2 : i32}
      aie.use_lock(%out_autocorr_prod_lock_0, Release, 1)
      aie.next_bd ^bb4
    ^bb6:  // pred: ^bb3
      aie.end
    }
    %mem_0_3 = aie.mem(%tile_0_3) {
      %0 = aie.dma_start(S2MM, 0, ^bb1, ^bb3)
    ^bb1:  // 2 preds: ^bb0, ^bb2
      aie.use_lock(%in_mem_1_cons_prod_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%in_mem_1_cons_buff_0 : memref<2048xi16>, 0, 2048) {bd_id = 0 : i32, next_bd_id = 1 : i32}
      aie.use_lock(%in_mem_1_cons_cons_lock_0, Release, 1)
      aie.next_bd ^bb2
    ^bb2:  // pred: ^bb1
      aie.use_lock(%in_mem_1_cons_prod_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%in_mem_1_cons_buff_1 : memref<2048xi16>, 0, 2048) {bd_id = 1 : i32, next_bd_id = 0 : i32}
      aie.use_lock(%in_mem_1_cons_cons_lock_0, Release, 1)
      aie.next_bd ^bb1
    ^bb3:  // pred: ^bb0
      %1 = aie.dma_start(MM2S, 0, ^bb4, ^bb6)
    ^bb4:  // 2 preds: ^bb3, ^bb5
      aie.use_lock(%out_magsq_delay_cons_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%out_magsq_delay_buff_0 : memref<2048xi16>, 0, 2048) {bd_id = 2 : i32, next_bd_id = 3 : i32}
      aie.use_lock(%out_magsq_delay_prod_lock_0, Release, 1)
      aie.next_bd ^bb5
    ^bb5:  // pred: ^bb4
      aie.use_lock(%out_magsq_delay_cons_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%out_magsq_delay_buff_1 : memref<2048xi16>, 0, 2048) {bd_id = 3 : i32, next_bd_id = 2 : i32}
      aie.use_lock(%out_magsq_delay_prod_lock_0, Release, 1)
      aie.next_bd ^bb4
    ^bb6:  // pred: ^bb3
      aie.end
    }
    %mem_0_4 = aie.mem(%tile_0_4) {
      %0 = aie.dma_start(S2MM, 0, ^bb1, ^bb3)
    ^bb1:  // 2 preds: ^bb0, ^bb2
      aie.use_lock(%out_autocorr_0_cons_prod_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%out_autocorr_0_cons_buff_0 : memref<2048xi32>, 0, 2048) {bd_id = 0 : i32, next_bd_id = 1 : i32}
      aie.use_lock(%out_autocorr_0_cons_cons_lock_0, Release, 1)
      aie.next_bd ^bb2
    ^bb2:  // pred: ^bb1
      aie.use_lock(%out_autocorr_0_cons_prod_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%out_autocorr_0_cons_buff_1 : memref<2048xi32>, 0, 2048) {bd_id = 1 : i32, next_bd_id = 0 : i32}
      aie.use_lock(%out_autocorr_0_cons_cons_lock_0, Release, 1)
      aie.next_bd ^bb1
    ^bb3:  // pred: ^bb0
      aie.end
    }
    %mem_0_5 = aie.mem(%tile_0_5) {
      %0 = aie.dma_start(S2MM, 0, ^bb1, ^bb3)
    ^bb1:  // 2 preds: ^bb0, ^bb2
      aie.use_lock(%out_autocorr_1_cons_prod_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%out_autocorr_1_cons_buff_0 : memref<2048xi32>, 0, 2048) {bd_id = 0 : i32, next_bd_id = 1 : i32}
      aie.use_lock(%out_autocorr_1_cons_cons_lock_0, Release, 1)
      aie.next_bd ^bb2
    ^bb2:  // pred: ^bb1
      aie.use_lock(%out_autocorr_1_cons_prod_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%out_autocorr_1_cons_buff_1 : memref<2048xi32>, 0, 2048) {bd_id = 1 : i32, next_bd_id = 0 : i32}
      aie.use_lock(%out_autocorr_1_cons_cons_lock_0, Release, 1)
      aie.next_bd ^bb1
    ^bb3:  // pred: ^bb0
      %1 = aie.dma_start(S2MM, 1, ^bb4, ^bb6)
    ^bb4:  // 2 preds: ^bb3, ^bb5
      aie.use_lock(%out_magsq_delay_cons_prod_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%out_magsq_delay_cons_buff_0 : memref<2048xi16>, 0, 2048) {bd_id = 2 : i32, next_bd_id = 3 : i32}
      aie.use_lock(%out_magsq_delay_cons_cons_lock_0, Release, 1)
      aie.next_bd ^bb5
    ^bb5:  // pred: ^bb4
      aie.use_lock(%out_magsq_delay_cons_prod_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%out_magsq_delay_cons_buff_1 : memref<2048xi16>, 0, 2048) {bd_id = 3 : i32, next_bd_id = 2 : i32}
      aie.use_lock(%out_magsq_delay_cons_cons_lock_0, Release, 1)
      aie.next_bd ^bb4
    ^bb6:  // pred: ^bb3
      %2 = aie.dma_start(MM2S, 0, ^bb7, ^bb9)
    ^bb7:  // 2 preds: ^bb6, ^bb8
      aie.use_lock(%sync_short_out_cons_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%sync_short_out_buff_0 : memref<2688xi16>, 0, 2688) {bd_id = 4 : i32, next_bd_id = 5 : i32}
      aie.use_lock(%sync_short_out_prod_lock_0, Release, 1)
      aie.next_bd ^bb8
    ^bb8:  // pred: ^bb7
      aie.use_lock(%sync_short_out_cons_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%sync_short_out_buff_1 : memref<2688xi16>, 0, 2688) {bd_id = 5 : i32, next_bd_id = 4 : i32}
      aie.use_lock(%sync_short_out_prod_lock_0, Release, 1)
      aie.next_bd ^bb7
    ^bb9:  // pred: ^bb6
      %3 = aie.dma_start(MM2S, 1, ^bb10, ^bb12)
    ^bb10:  // 2 preds: ^bb9, ^bb11
      aie.use_lock(%sync_short_out_meta_cons_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%sync_short_out_meta_buff_0 : memref<16xi32>, 0, 16) {bd_id = 6 : i32, next_bd_id = 7 : i32}
      aie.use_lock(%sync_short_out_meta_prod_lock_0, Release, 1)
      aie.next_bd ^bb11
    ^bb11:  // pred: ^bb10
      aie.use_lock(%sync_short_out_meta_cons_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%sync_short_out_meta_buff_1 : memref<16xi32>, 0, 16) {bd_id = 7 : i32, next_bd_id = 6 : i32}
      aie.use_lock(%sync_short_out_meta_prod_lock_0, Release, 1)
      aie.next_bd ^bb10
    ^bb12:  // pred: ^bb9
      aie.end
    }
    %mem_1_2 = aie.mem(%tile_1_2) {
      %0 = aie.dma_start(S2MM, 0, ^bb1, ^bb3)
    ^bb1:  // 2 preds: ^bb0, ^bb2
      aie.use_lock(%sync_short_out_cons_prod_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%sync_short_out_cons_buff_0 : memref<2688xi16>, 0, 2688) {bd_id = 0 : i32, next_bd_id = 1 : i32}
      aie.use_lock(%sync_short_out_cons_cons_lock_0, Release, 1)
      aie.next_bd ^bb2
    ^bb2:  // pred: ^bb1
      aie.use_lock(%sync_short_out_cons_prod_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%sync_short_out_cons_buff_1 : memref<2688xi16>, 0, 2688) {bd_id = 1 : i32, next_bd_id = 0 : i32}
      aie.use_lock(%sync_short_out_cons_cons_lock_0, Release, 1)
      aie.next_bd ^bb1
    ^bb3:  // pred: ^bb0
      %1 = aie.dma_start(S2MM, 1, ^bb4, ^bb6)
    ^bb4:  // 2 preds: ^bb3, ^bb5
      aie.use_lock(%sync_short_out_meta_cons_prod_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%sync_short_out_meta_cons_buff_0 : memref<16xi32>, 0, 16) {bd_id = 2 : i32, next_bd_id = 3 : i32}
      aie.use_lock(%sync_short_out_meta_cons_cons_lock_0, Release, 1)
      aie.next_bd ^bb5
    ^bb5:  // pred: ^bb4
      aie.use_lock(%sync_short_out_meta_cons_prod_lock_0, AcquireGreaterEqual, 1)
      aie.dma_bd(%sync_short_out_meta_cons_buff_1 : memref<16xi32>, 0, 16) {bd_id = 3 : i32, next_bd_id = 2 : i32}
      aie.use_lock(%sync_short_out_meta_cons_cons_lock_0, Release, 1)
      aie.next_bd ^bb4
    ^bb6:  // pred: ^bb3
      aie.end
    }
    aie.packet_flow(15) {
      aie.packet_source<%shim_noc_tile_0_0, TileControl : 0>
      aie.packet_dest<%shim_noc_tile_0_0, South : 0>
    } {keep_pkt_header = true, priority_route = true}
    aie.packet_flow(15) {
      aie.packet_source<%shim_noc_tile_2_0, TileControl : 0>
      aie.packet_dest<%shim_noc_tile_2_0, South : 0>
    } {keep_pkt_header = true, priority_route = true}
    %switchbox_1_2 = aie.switchbox(%tile_1_2) {
      aie.connect<North : 0, East : 2>
      aie.connect<North : 3, East : 3>
      aie.connect<West : 1, DMA : 0>
      aie.connect<North : 2, DMA : 1>
    }
    %switchbox_1_3 = aie.switchbox(%tile_1_3) {
      aie.connect<North : 3, South : 0>
      aie.connect<North : 1, South : 3>
      aie.connect<North : 0, South : 2>
    }
    %switchbox_1_4 = aie.switchbox(%tile_1_4) {
      aie.connect<North : 0, South : 3>
      aie.connect<DMA : 0, South : 1>
      aie.connect<DMA : 0, North : 3>
      aie.connect<West : 0, South : 0>
    }
    %switchbox_1_5 = aie.switchbox(%tile_1_5) {
      aie.connect<DMA : 0, South : 0>
      aie.connect<South : 3, DMA : 0>
    }
    %switchbox_2_2 = aie.switchbox(%tile_2_2) {
      aie.connect<West : 2, DMA : 0>
      aie.connect<DMA : 0, South : 2>
      aie.connect<DMA : 1, South : 1>
      aie.connect<West : 3, DMA : 1>
    }
    %switchbox_2_0 = aie.switchbox(%shim_noc_tile_2_0) {
      aie.connect<North : 2, South : 2>
      aie.connect<North : 1, South : 3>
      %0 = aie.amsel<5> (3)
      %1 = aie.masterset(South : 0, %0) {keep_pkt_header = true}
      aie.packet_rules(TileControl : 0) {
        aie.rule(31, 15, %0)
      }
    }
    %shim_mux_2_0 = aie.shim_mux(%shim_noc_tile_2_0) {
      aie.connect<North : 2, DMA : 0>
      aie.connect<North : 3, DMA : 1>
    }
    %mem_tile_2_1 = aie.tile(2, 1)
    %switchbox_2_1 = aie.switchbox(%mem_tile_2_1) {
      aie.connect<North : 2, South : 2>
      aie.connect<North : 1, South : 1>
    }
    %switchbox_0_0 = aie.switchbox(%shim_noc_tile_0_0) {
      aie.connect<South : 3, North : 3>
      %0 = aie.amsel<5> (3)
      %1 = aie.masterset(South : 0, %0) {keep_pkt_header = true}
      aie.packet_rules(TileControl : 0) {
        aie.rule(31, 15, %0)
      }
    }
    %shim_mux_0_0 = aie.shim_mux(%shim_noc_tile_0_0) {
      aie.connect<DMA : 0, North : 3>
    }
    %switchbox_0_1 = aie.switchbox(%mem_tile_0_1) {
      aie.connect<South : 3, DMA : 0>
      aie.connect<DMA : 0, North : 1>
    }
    %switchbox_0_2 = aie.switchbox(%tile_0_2) {
      aie.connect<South : 1, North : 1>
      aie.connect<South : 1, DMA : 0>
      aie.connect<DMA : 0, North : 3>
      aie.connect<North : 3, East : 1>
    }
    %switchbox_0_3 = aie.switchbox(%tile_0_3) {
      aie.connect<South : 1, DMA : 0>
      aie.connect<South : 3, North : 0>
      aie.connect<DMA : 0, North : 3>
      aie.connect<North : 0, South : 3>
    }
    %switchbox_0_4 = aie.switchbox(%tile_0_4) {
      aie.connect<South : 0, North : 4>
      aie.connect<South : 0, DMA : 0>
      aie.connect<South : 3, North : 0>
      aie.connect<North : 0, South : 0>
      aie.connect<North : 3, East : 0>
    }
    %switchbox_0_5 = aie.switchbox(%tile_0_5) {
      aie.connect<South : 4, DMA : 0>
      aie.connect<South : 0, DMA : 1>
      aie.connect<DMA : 0, South : 0>
      aie.connect<DMA : 1, South : 3>
    }
    aie.wire(%shim_mux_0_0 : North, %switchbox_0_0 : South)
    aie.wire(%shim_noc_tile_0_0 : DMA, %shim_mux_0_0 : DMA)
    aie.wire(%mem_tile_0_1 : Core, %switchbox_0_1 : Core)
    aie.wire(%mem_tile_0_1 : DMA, %switchbox_0_1 : DMA)
    aie.wire(%switchbox_0_0 : North, %switchbox_0_1 : South)
    aie.wire(%tile_0_2 : Core, %switchbox_0_2 : Core)
    aie.wire(%tile_0_2 : DMA, %switchbox_0_2 : DMA)
    aie.wire(%switchbox_0_1 : North, %switchbox_0_2 : South)
    aie.wire(%tile_0_3 : Core, %switchbox_0_3 : Core)
    aie.wire(%tile_0_3 : DMA, %switchbox_0_3 : DMA)
    aie.wire(%switchbox_0_2 : North, %switchbox_0_3 : South)
    aie.wire(%tile_0_4 : Core, %switchbox_0_4 : Core)
    aie.wire(%tile_0_4 : DMA, %switchbox_0_4 : DMA)
    aie.wire(%switchbox_0_3 : North, %switchbox_0_4 : South)
    aie.wire(%tile_0_5 : Core, %switchbox_0_5 : Core)
    aie.wire(%tile_0_5 : DMA, %switchbox_0_5 : DMA)
    aie.wire(%switchbox_0_4 : North, %switchbox_0_5 : South)
    aie.wire(%switchbox_0_2 : East, %switchbox_1_2 : West)
    aie.wire(%tile_1_2 : Core, %switchbox_1_2 : Core)
    aie.wire(%tile_1_2 : DMA, %switchbox_1_2 : DMA)
    aie.wire(%switchbox_0_3 : East, %switchbox_1_3 : West)
    aie.wire(%tile_1_3 : Core, %switchbox_1_3 : Core)
    aie.wire(%tile_1_3 : DMA, %switchbox_1_3 : DMA)
    aie.wire(%switchbox_1_2 : North, %switchbox_1_3 : South)
    aie.wire(%switchbox_0_4 : East, %switchbox_1_4 : West)
    aie.wire(%tile_1_4 : Core, %switchbox_1_4 : Core)
    aie.wire(%tile_1_4 : DMA, %switchbox_1_4 : DMA)
    aie.wire(%switchbox_1_3 : North, %switchbox_1_4 : South)
    aie.wire(%switchbox_0_5 : East, %switchbox_1_5 : West)
    aie.wire(%tile_1_5 : Core, %switchbox_1_5 : Core)
    aie.wire(%tile_1_5 : DMA, %switchbox_1_5 : DMA)
    aie.wire(%switchbox_1_4 : North, %switchbox_1_5 : South)
    aie.wire(%shim_mux_2_0 : North, %switchbox_2_0 : South)
    aie.wire(%shim_noc_tile_2_0 : DMA, %shim_mux_2_0 : DMA)
    aie.wire(%mem_tile_2_1 : Core, %switchbox_2_1 : Core)
    aie.wire(%mem_tile_2_1 : DMA, %switchbox_2_1 : DMA)
    aie.wire(%switchbox_2_0 : North, %switchbox_2_1 : South)
    aie.wire(%switchbox_1_2 : East, %switchbox_2_2 : West)
    aie.wire(%tile_2_2 : Core, %switchbox_2_2 : Core)
    aie.wire(%tile_2_2 : DMA, %switchbox_2_2 : DMA)
    aie.wire(%switchbox_2_1 : North, %switchbox_2_2 : South)
  }
}
