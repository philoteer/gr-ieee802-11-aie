module attributes {llvm.target_triple = "aie2"} {
  llvm.mlir.global external @center_frequency() {addr_space = 0 : i32} : !llvm.array<2 x i32>
  llvm.mlir.global external @fft_out_buff_1() {addr_space = 0 : i32} : !llvm.array<2048 x i32>
  llvm.mlir.global external @fft_out_buff_0() {addr_space = 0 : i32} : !llvm.array<2048 x i32>
  llvm.mlir.global external @fft_out_meta_buff_1() {addr_space = 0 : i32} : !llvm.array<64 x i32>
  llvm.mlir.global external @fft_out_meta_buff_0() {addr_space = 0 : i32} : !llvm.array<64 x i32>
  llvm.mlir.global external @frame_equalizer_out_buff_1() {addr_space = 0 : i32} : !llvm.array<1024 x i8>
  llvm.mlir.global external @frame_equalizer_out_buff_0() {addr_space = 0 : i32} : !llvm.array<1024 x i8>
  llvm.mlir.global external @frame_equalizer_out_meta_buff_1() {addr_space = 0 : i32} : !llvm.array<2242 x i32>
  llvm.mlir.global external @frame_equalizer_out_meta_buff_0() {addr_space = 0 : i32} : !llvm.array<2242 x i32>
  llvm.mlir.global external @frame_equalizer_prepared_buff_1() {addr_space = 0 : i32} : !llvm.array<2048 x i32>
  llvm.mlir.global external @frame_equalizer_prepared_buff_0() {addr_space = 0 : i32} : !llvm.array<2048 x i32>
  llvm.mlir.global external @frame_equalizer_prepared_meta_buff_1() {addr_space = 0 : i32} : !llvm.array<81 x i32>
  llvm.mlir.global external @frame_equalizer_prepared_meta_buff_0() {addr_space = 0 : i32} : !llvm.array<81 x i32>
  llvm.mlir.global external @in_cons_buff_1() {addr_space = 0 : i32} : !llvm.array<2048 x i16>
  llvm.mlir.global external @in_cons_buff_0() {addr_space = 0 : i32} : !llvm.array<2048 x i16>
  llvm.mlir.global external @in_mem_1_cons_buff_1() {addr_space = 0 : i32} : !llvm.array<2048 x i16>
  llvm.mlir.global external @in_mem_1_cons_buff_0() {addr_space = 0 : i32} : !llvm.array<2048 x i16>
  llvm.mlir.global external @in_mem_0_cons_buff_1() {addr_space = 0 : i32} : !llvm.array<2048 x i16>
  llvm.mlir.global external @in_mem_0_cons_buff_0() {addr_space = 0 : i32} : !llvm.array<2048 x i16>
  llvm.mlir.global external @out_autocorr_buff_1() {addr_space = 0 : i32} : !llvm.array<2048 x i32>
  llvm.mlir.global external @out_autocorr_buff_0() {addr_space = 0 : i32} : !llvm.array<2048 x i32>
  llvm.mlir.global external @out_autocorr_1_cons_buff_1() {addr_space = 0 : i32} : !llvm.array<2048 x i32>
  llvm.mlir.global external @out_autocorr_1_cons_buff_0() {addr_space = 0 : i32} : !llvm.array<2048 x i32>
  llvm.mlir.global external @out_autocorr_0_cons_buff_1() {addr_space = 0 : i32} : !llvm.array<2048 x i32>
  llvm.mlir.global external @out_autocorr_0_cons_buff_0() {addr_space = 0 : i32} : !llvm.array<2048 x i32>
  llvm.mlir.global external @out_magsq_buff_1() {addr_space = 0 : i32} : !llvm.array<1024 x i32>
  llvm.mlir.global external @out_magsq_buff_0() {addr_space = 0 : i32} : !llvm.array<1024 x i32>
  llvm.mlir.global external @out_magsq_delay_buff_1() {addr_space = 0 : i32} : !llvm.array<2048 x i16>
  llvm.mlir.global external @out_magsq_delay_buff_0() {addr_space = 0 : i32} : !llvm.array<2048 x i16>
  llvm.mlir.global external @out_magsq_delay_cons_buff_1() {addr_space = 0 : i32} : !llvm.array<2048 x i16>
  llvm.mlir.global external @out_magsq_delay_cons_buff_0() {addr_space = 0 : i32} : !llvm.array<2048 x i16>
  llvm.mlir.global external @sync_long_out_buff_1() {addr_space = 0 : i32} : !llvm.array<2048 x i16>
  llvm.mlir.global external @sync_long_out_buff_0() {addr_space = 0 : i32} : !llvm.array<2048 x i16>
  llvm.mlir.global external @sync_long_out_meta_buff_1() {addr_space = 0 : i32} : !llvm.array<16 x i32>
  llvm.mlir.global external @sync_long_out_meta_buff_0() {addr_space = 0 : i32} : !llvm.array<16 x i32>
  llvm.mlir.global external @sync_short_out_buff_1() {addr_space = 0 : i32} : !llvm.array<2688 x i16>
  llvm.mlir.global external @sync_short_out_buff_0() {addr_space = 0 : i32} : !llvm.array<2688 x i16>
  llvm.mlir.global external @sync_short_out_cons_buff_1() {addr_space = 0 : i32} : !llvm.array<2688 x i16>
  llvm.mlir.global external @sync_short_out_cons_buff_0() {addr_space = 0 : i32} : !llvm.array<2688 x i16>
  llvm.mlir.global external @sync_short_out_meta_buff_1() {addr_space = 0 : i32} : !llvm.array<16 x i32>
  llvm.mlir.global external @sync_short_out_meta_buff_0() {addr_space = 0 : i32} : !llvm.array<16 x i32>
  llvm.mlir.global external @sync_short_out_meta_cons_buff_1() {addr_space = 0 : i32} : !llvm.array<16 x i32>
  llvm.mlir.global external @sync_short_out_meta_cons_buff_0() {addr_space = 0 : i32} : !llvm.array<16 x i32>
  llvm.mlir.global external @threshold_met_buff_1() {addr_space = 0 : i32} : !llvm.array<1024 x i8>
  llvm.mlir.global external @threshold_met_buff_0() {addr_space = 0 : i32} : !llvm.array<1024 x i8>
  llvm.func @debug_i32(i32) attributes {sym_visibility = "private"}
  llvm.func @llvm.aie2.event(i32) attributes {sym_visibility = "private"}
  llvm.func @llvm.aie2.put.ms(i32, i32) attributes {sym_visibility = "private"}
  llvm.func @llvm.aie2.get.ss() -> !llvm.struct<(i32, i32)> attributes {sym_visibility = "private"}
  llvm.func @llvm.aie2.mcd.write.vec(vector<16xi32>, i32) attributes {sym_visibility = "private"}
  llvm.func @llvm.aie2.scd.read.vec(i32) -> vector<16xi32> attributes {sym_visibility = "private"}
  llvm.func @llvm.aie2.acquire(i32, i32) attributes {sym_visibility = "private"}
  llvm.func @llvm.aie2.release(i32, i32) attributes {sym_visibility = "private"}
  llvm.func @autocorr_cf(!llvm.ptr, !llvm.ptr, i32) attributes {sym_visibility = "private"}
  llvm.func @magsq_avg_cf(!llvm.ptr, !llvm.ptr, !llvm.ptr, i32) attributes {sym_visibility = "private"}
  llvm.func @threshold_cf(!llvm.ptr, !llvm.ptr, !llvm.ptr, i32) attributes {sym_visibility = "private"}
  llvm.func @sync_short_cf(!llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32) attributes {sym_visibility = "private"}
  llvm.func @sync_long_cf(!llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32) attributes {sym_visibility = "private"}
  llvm.func @fft_cf(!llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32) attributes {sym_visibility = "private"}
  llvm.func @frame_equalizer_preprocess(!llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32) attributes {sym_visibility = "private"}
  llvm.func @frame_equalizer_equalize(!llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32) attributes {sym_visibility = "private"}
  llvm.func @core_1_5() {
    %0 = llvm.mlir.addressof @frame_equalizer_out_buff_1 : !llvm.ptr
    %1 = llvm.mlir.addressof @frame_equalizer_out_meta_buff_1 : !llvm.ptr
    %2 = llvm.mlir.addressof @frame_equalizer_prepared_buff_1 : !llvm.ptr
    %3 = llvm.mlir.addressof @frame_equalizer_prepared_meta_buff_1 : !llvm.ptr
    %4 = llvm.mlir.addressof @frame_equalizer_out_buff_0 : !llvm.ptr
    %5 = llvm.mlir.addressof @frame_equalizer_out_meta_buff_0 : !llvm.ptr
    %6 = llvm.mlir.addressof @frame_equalizer_prepared_buff_0 : !llvm.ptr
    %7 = llvm.mlir.addressof @frame_equalizer_prepared_meta_buff_0 : !llvm.ptr
    %8 = llvm.mlir.constant(51 : i32) : i32
    %9 = llvm.mlir.constant(49 : i32) : i32
    %10 = llvm.mlir.constant(2 : i32) : i32
    %11 = llvm.mlir.constant(0 : i32) : i32
    %12 = llvm.mlir.constant(50 : i32) : i32
    %13 = llvm.mlir.constant(48 : i32) : i32
    %14 = llvm.mlir.constant(3 : i32) : i32
    %15 = llvm.mlir.constant(1 : i32) : i32
    %16 = llvm.mlir.constant(-1 : i32) : i32
    %17 = llvm.mlir.constant(2 : index) : i64
    %18 = llvm.mlir.constant(0 : index) : i64
    %19 = llvm.mlir.constant(1 : index) : i64
    %20 = llvm.mlir.constant(2242 : i32) : i32
    %21 = llvm.mlir.constant(1024 : i32) : i32
    %22 = llvm.mlir.constant(8 : index) : i64
    %23 = llvm.mlir.constant(9223372036854775807 : index) : i64
    llvm.br ^bb1(%18 : i64)
  ^bb1(%24: i64):  // 2 preds: ^bb0, ^bb4
    %25 = llvm.icmp "slt" %24, %23 : i64
    llvm.cond_br %25, ^bb2(%18 : i64), ^bb5
  ^bb2(%26: i64):  // 2 preds: ^bb1, ^bb3
    %27 = llvm.icmp "slt" %26, %22 : i64
    llvm.cond_br %27, ^bb3, ^bb4
  ^bb3:  // pred: ^bb2
    llvm.call @llvm.aie2.acquire(%15, %16) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%14, %16) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%13, %16) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%12, %16) : (i32, i32) -> ()
    %28 = llvm.getelementptr %7[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<81 x i32>
    %29 = llvm.getelementptr %6[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2048 x i32>
    %30 = llvm.getelementptr %5[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2242 x i32>
    %31 = llvm.getelementptr %4[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<1024 x i8>
    llvm.call @frame_equalizer_equalize(%29, %28, %31, %30, %21, %20) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32) -> ()
    llvm.call @llvm.aie2.release(%11, %15) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%10, %15) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%9, %15) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%8, %15) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%15, %16) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%14, %16) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%13, %16) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%12, %16) : (i32, i32) -> ()
    %32 = llvm.getelementptr %3[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<81 x i32>
    %33 = llvm.getelementptr %2[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2048 x i32>
    %34 = llvm.getelementptr %1[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2242 x i32>
    %35 = llvm.getelementptr %0[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<1024 x i8>
    llvm.call @frame_equalizer_equalize(%33, %32, %35, %34, %21, %20) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32) -> ()
    llvm.call @llvm.aie2.release(%11, %15) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%10, %15) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%9, %15) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%8, %15) : (i32, i32) -> ()
    %36 = llvm.add %26, %17 : i64
    llvm.br ^bb2(%36 : i64)
  ^bb4:  // pred: ^bb2
    %37 = llvm.add %24, %19 : i64
    llvm.br ^bb1(%37 : i64)
  ^bb5:  // pred: ^bb1
    llvm.return
  }
  llvm.func @core_1_4() {
    %0 = llvm.mlir.addressof @fft_out_buff_1 : !llvm.ptr
    %1 = llvm.mlir.addressof @fft_out_meta_buff_1 : !llvm.ptr
    %2 = llvm.mlir.addressof @frame_equalizer_prepared_buff_1 : !llvm.ptr
    %3 = llvm.mlir.addressof @frame_equalizer_prepared_meta_buff_1 : !llvm.ptr
    %4 = llvm.mlir.addressof @center_frequency : !llvm.ptr
    %5 = llvm.mlir.addressof @fft_out_buff_0 : !llvm.ptr
    %6 = llvm.mlir.addressof @fft_out_meta_buff_0 : !llvm.ptr
    %7 = llvm.mlir.addressof @frame_equalizer_prepared_buff_0 : !llvm.ptr
    %8 = llvm.mlir.addressof @frame_equalizer_prepared_meta_buff_0 : !llvm.ptr
    %9 = llvm.mlir.constant(51 : i32) : i32
    %10 = llvm.mlir.constant(49 : i32) : i32
    %11 = llvm.mlir.constant(2 : i32) : i32
    %12 = llvm.mlir.constant(0 : i32) : i32
    %13 = llvm.mlir.constant(50 : i32) : i32
    %14 = llvm.mlir.constant(48 : i32) : i32
    %15 = llvm.mlir.constant(3 : i32) : i32
    %16 = llvm.mlir.constant(1 : i32) : i32
    %17 = llvm.mlir.constant(-1 : i32) : i32
    %18 = llvm.mlir.constant(2 : index) : i64
    %19 = llvm.mlir.constant(0 : index) : i64
    %20 = llvm.mlir.constant(1 : index) : i64
    %21 = llvm.mlir.constant(64 : i32) : i32
    %22 = llvm.mlir.constant(1024 : i32) : i32
    %23 = llvm.mlir.constant(8 : index) : i64
    %24 = llvm.mlir.constant(9223372036854775807 : index) : i64
    llvm.br ^bb1(%19 : i64)
  ^bb1(%25: i64):  // 2 preds: ^bb0, ^bb4
    %26 = llvm.icmp "slt" %25, %24 : i64
    llvm.cond_br %26, ^bb2(%19 : i64), ^bb5
  ^bb2(%27: i64):  // 2 preds: ^bb1, ^bb3
    %28 = llvm.icmp "slt" %27, %23 : i64
    llvm.cond_br %28, ^bb3, ^bb4
  ^bb3:  // pred: ^bb2
    llvm.call @llvm.aie2.acquire(%16, %17) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%15, %17) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%14, %17) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%13, %17) : (i32, i32) -> ()
    %29 = llvm.getelementptr %8[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<81 x i32>
    %30 = llvm.getelementptr %7[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2048 x i32>
    %31 = llvm.getelementptr %6[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<64 x i32>
    %32 = llvm.getelementptr %5[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2048 x i32>
    %33 = llvm.getelementptr %4[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2 x i32>
    llvm.call @frame_equalizer_preprocess(%32, %31, %30, %29, %33, %22, %21) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32) -> ()
    llvm.call @llvm.aie2.release(%12, %16) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%11, %16) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%10, %16) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%9, %16) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%16, %17) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%15, %17) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%14, %17) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%13, %17) : (i32, i32) -> ()
    %34 = llvm.getelementptr %3[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<81 x i32>
    %35 = llvm.getelementptr %2[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2048 x i32>
    %36 = llvm.getelementptr %1[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<64 x i32>
    %37 = llvm.getelementptr %0[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2048 x i32>
    llvm.call @frame_equalizer_preprocess(%37, %36, %35, %34, %33, %22, %21) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32) -> ()
    llvm.call @llvm.aie2.release(%12, %16) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%11, %16) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%10, %16) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%9, %16) : (i32, i32) -> ()
    %38 = llvm.add %27, %18 : i64
    llvm.br ^bb2(%38 : i64)
  ^bb4:  // pred: ^bb2
    %39 = llvm.add %25, %20 : i64
    llvm.br ^bb1(%39 : i64)
  ^bb5:  // pred: ^bb1
    llvm.return
  }
  llvm.func @core_1_3() {
    %0 = llvm.mlir.addressof @fft_out_buff_1 : !llvm.ptr
    %1 = llvm.mlir.addressof @fft_out_meta_buff_1 : !llvm.ptr
    %2 = llvm.mlir.addressof @sync_long_out_buff_1 : !llvm.ptr
    %3 = llvm.mlir.addressof @sync_long_out_meta_buff_1 : !llvm.ptr
    %4 = llvm.mlir.addressof @fft_out_buff_0 : !llvm.ptr
    %5 = llvm.mlir.addressof @fft_out_meta_buff_0 : !llvm.ptr
    %6 = llvm.mlir.addressof @sync_long_out_buff_0 : !llvm.ptr
    %7 = llvm.mlir.addressof @sync_long_out_meta_buff_0 : !llvm.ptr
    %8 = llvm.mlir.constant(51 : i32) : i32
    %9 = llvm.mlir.constant(49 : i32) : i32
    %10 = llvm.mlir.constant(2 : i32) : i32
    %11 = llvm.mlir.constant(0 : i32) : i32
    %12 = llvm.mlir.constant(50 : i32) : i32
    %13 = llvm.mlir.constant(48 : i32) : i32
    %14 = llvm.mlir.constant(3 : i32) : i32
    %15 = llvm.mlir.constant(1 : i32) : i32
    %16 = llvm.mlir.constant(-1 : i32) : i32
    %17 = llvm.mlir.constant(2 : index) : i64
    %18 = llvm.mlir.constant(0 : index) : i64
    %19 = llvm.mlir.constant(1 : index) : i64
    %20 = llvm.mlir.constant(64 : i32) : i32
    %21 = llvm.mlir.constant(1024 : i32) : i32
    %22 = llvm.mlir.constant(8 : index) : i64
    %23 = llvm.mlir.constant(9223372036854775807 : index) : i64
    llvm.br ^bb1(%18 : i64)
  ^bb1(%24: i64):  // 2 preds: ^bb0, ^bb4
    %25 = llvm.icmp "slt" %24, %23 : i64
    llvm.cond_br %25, ^bb2(%18 : i64), ^bb5
  ^bb2(%26: i64):  // 2 preds: ^bb1, ^bb3
    %27 = llvm.icmp "slt" %26, %22 : i64
    llvm.cond_br %27, ^bb3, ^bb4
  ^bb3:  // pred: ^bb2
    llvm.call @llvm.aie2.acquire(%15, %16) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%14, %16) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%13, %16) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%12, %16) : (i32, i32) -> ()
    %28 = llvm.getelementptr %7[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<16 x i32>
    %29 = llvm.getelementptr %6[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2048 x i16>
    %30 = llvm.getelementptr %5[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<64 x i32>
    %31 = llvm.getelementptr %4[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2048 x i32>
    llvm.call @fft_cf(%29, %28, %31, %30, %21, %20) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32) -> ()
    llvm.call @llvm.aie2.release(%11, %15) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%10, %15) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%9, %15) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%8, %15) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%15, %16) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%14, %16) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%13, %16) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%12, %16) : (i32, i32) -> ()
    %32 = llvm.getelementptr %3[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<16 x i32>
    %33 = llvm.getelementptr %2[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2048 x i16>
    %34 = llvm.getelementptr %1[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<64 x i32>
    %35 = llvm.getelementptr %0[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2048 x i32>
    llvm.call @fft_cf(%33, %32, %35, %34, %21, %20) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32) -> ()
    llvm.call @llvm.aie2.release(%11, %15) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%10, %15) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%9, %15) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%8, %15) : (i32, i32) -> ()
    %36 = llvm.add %26, %17 : i64
    llvm.br ^bb2(%36 : i64)
  ^bb4:  // pred: ^bb2
    %37 = llvm.add %24, %19 : i64
    llvm.br ^bb1(%37 : i64)
  ^bb5:  // pred: ^bb1
    llvm.return
  }
  llvm.func @core_1_2() {
    %0 = llvm.mlir.addressof @sync_long_out_buff_1 : !llvm.ptr
    %1 = llvm.mlir.addressof @sync_long_out_meta_buff_1 : !llvm.ptr
    %2 = llvm.mlir.addressof @sync_short_out_cons_buff_1 : !llvm.ptr
    %3 = llvm.mlir.addressof @sync_short_out_meta_cons_buff_1 : !llvm.ptr
    %4 = llvm.mlir.addressof @sync_long_out_buff_0 : !llvm.ptr
    %5 = llvm.mlir.addressof @sync_long_out_meta_buff_0 : !llvm.ptr
    %6 = llvm.mlir.addressof @sync_short_out_cons_buff_0 : !llvm.ptr
    %7 = llvm.mlir.addressof @sync_short_out_meta_cons_buff_0 : !llvm.ptr
    %8 = llvm.mlir.constant(51 : i32) : i32
    %9 = llvm.mlir.constant(49 : i32) : i32
    %10 = llvm.mlir.constant(54 : i32) : i32
    %11 = llvm.mlir.constant(52 : i32) : i32
    %12 = llvm.mlir.constant(50 : i32) : i32
    %13 = llvm.mlir.constant(48 : i32) : i32
    %14 = llvm.mlir.constant(55 : i32) : i32
    %15 = llvm.mlir.constant(53 : i32) : i32
    %16 = llvm.mlir.constant(1 : i32) : i32
    %17 = llvm.mlir.constant(-1 : i32) : i32
    %18 = llvm.mlir.constant(2 : index) : i64
    %19 = llvm.mlir.constant(16 : i32) : i32
    %20 = llvm.mlir.constant(1024 : i32) : i32
    %21 = llvm.mlir.constant(8 : index) : i64
    %22 = llvm.mlir.constant(0 : index) : i64
    %23 = llvm.mlir.constant(9223372036854775807 : index) : i64
    %24 = llvm.mlir.constant(1 : index) : i64
    llvm.br ^bb1(%22 : i64)
  ^bb1(%25: i64):  // 2 preds: ^bb0, ^bb4
    %26 = llvm.icmp "slt" %25, %23 : i64
    llvm.cond_br %26, ^bb2(%22 : i64), ^bb5
  ^bb2(%27: i64):  // 2 preds: ^bb1, ^bb3
    %28 = llvm.icmp "slt" %27, %21 : i64
    llvm.cond_br %28, ^bb3, ^bb4
  ^bb3:  // pred: ^bb2
    llvm.call @llvm.aie2.acquire(%15, %17) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%14, %17) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%13, %17) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%12, %17) : (i32, i32) -> ()
    %29 = llvm.getelementptr %7[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<16 x i32>
    %30 = llvm.getelementptr %6[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2688 x i16>
    %31 = llvm.getelementptr %5[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<16 x i32>
    %32 = llvm.getelementptr %4[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2048 x i16>
    llvm.call @sync_long_cf(%30, %29, %32, %31, %20, %19) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32) -> ()
    llvm.call @llvm.aie2.release(%11, %16) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%10, %16) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%9, %16) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%8, %16) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%15, %17) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%14, %17) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%13, %17) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%12, %17) : (i32, i32) -> ()
    %33 = llvm.getelementptr %3[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<16 x i32>
    %34 = llvm.getelementptr %2[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2688 x i16>
    %35 = llvm.getelementptr %1[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<16 x i32>
    %36 = llvm.getelementptr %0[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2048 x i16>
    llvm.call @sync_long_cf(%34, %33, %36, %35, %20, %19) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32, i32) -> ()
    llvm.call @llvm.aie2.release(%11, %16) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%10, %16) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%9, %16) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%8, %16) : (i32, i32) -> ()
    %37 = llvm.add %27, %18 : i64
    llvm.br ^bb2(%37 : i64)
  ^bb4:  // pred: ^bb2
    %38 = llvm.add %25, %24 : i64
    llvm.br ^bb1(%38 : i64)
  ^bb5:  // pred: ^bb1
    llvm.return
  }
  llvm.func @core_0_5() {
    %0 = llvm.mlir.addressof @out_autocorr_1_cons_buff_1 : !llvm.ptr
    %1 = llvm.mlir.addressof @out_magsq_delay_cons_buff_1 : !llvm.ptr
    %2 = llvm.mlir.addressof @sync_short_out_buff_1 : !llvm.ptr
    %3 = llvm.mlir.addressof @sync_short_out_meta_buff_1 : !llvm.ptr
    %4 = llvm.mlir.addressof @threshold_met_buff_1 : !llvm.ptr
    %5 = llvm.mlir.addressof @out_autocorr_1_cons_buff_0 : !llvm.ptr
    %6 = llvm.mlir.addressof @out_magsq_delay_cons_buff_0 : !llvm.ptr
    %7 = llvm.mlir.addressof @sync_short_out_buff_0 : !llvm.ptr
    %8 = llvm.mlir.addressof @sync_short_out_meta_buff_0 : !llvm.ptr
    %9 = llvm.mlir.addressof @threshold_met_buff_0 : !llvm.ptr
    %10 = llvm.mlir.constant(55 : i32) : i32
    %11 = llvm.mlir.constant(53 : i32) : i32
    %12 = llvm.mlir.constant(2 : i32) : i32
    %13 = llvm.mlir.constant(48 : i32) : i32
    %14 = llvm.mlir.constant(50 : i32) : i32
    %15 = llvm.mlir.constant(54 : i32) : i32
    %16 = llvm.mlir.constant(52 : i32) : i32
    %17 = llvm.mlir.constant(3 : i32) : i32
    %18 = llvm.mlir.constant(49 : i32) : i32
    %19 = llvm.mlir.constant(51 : i32) : i32
    %20 = llvm.mlir.constant(1 : i32) : i32
    %21 = llvm.mlir.constant(-1 : i32) : i32
    %22 = llvm.mlir.constant(2 : index) : i64
    %23 = llvm.mlir.constant(1024 : i32) : i32
    %24 = llvm.mlir.constant(8 : index) : i64
    %25 = llvm.mlir.constant(0 : index) : i64
    %26 = llvm.mlir.constant(9223372036854775807 : index) : i64
    %27 = llvm.mlir.constant(1 : index) : i64
    llvm.br ^bb1(%25 : i64)
  ^bb1(%28: i64):  // 2 preds: ^bb0, ^bb4
    %29 = llvm.icmp "slt" %28, %26 : i64
    llvm.cond_br %29, ^bb2(%25 : i64), ^bb5
  ^bb2(%30: i64):  // 2 preds: ^bb1, ^bb3
    %31 = llvm.icmp "slt" %30, %24 : i64
    llvm.cond_br %31, ^bb3, ^bb4
  ^bb3:  // pred: ^bb2
    llvm.call @llvm.aie2.acquire(%19, %21) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%18, %21) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%17, %21) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%16, %21) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%15, %21) : (i32, i32) -> ()
    %32 = llvm.getelementptr %9[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<1024 x i8>
    %33 = llvm.getelementptr %8[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<16 x i32>
    %34 = llvm.getelementptr %7[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2688 x i16>
    %35 = llvm.getelementptr %6[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2048 x i16>
    %36 = llvm.getelementptr %5[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2048 x i32>
    llvm.call @sync_short_cf(%35, %36, %32, %34, %33, %23) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32) -> ()
    llvm.call @llvm.aie2.release(%14, %20) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%13, %20) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%12, %20) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%11, %20) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%10, %20) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%19, %21) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%18, %21) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%17, %21) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%16, %21) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%15, %21) : (i32, i32) -> ()
    %37 = llvm.getelementptr %4[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<1024 x i8>
    %38 = llvm.getelementptr %3[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<16 x i32>
    %39 = llvm.getelementptr %2[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2688 x i16>
    %40 = llvm.getelementptr %1[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2048 x i16>
    %41 = llvm.getelementptr %0[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2048 x i32>
    llvm.call @sync_short_cf(%40, %41, %37, %39, %38, %23) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, !llvm.ptr, i32) -> ()
    llvm.call @llvm.aie2.release(%14, %20) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%13, %20) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%12, %20) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%11, %20) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%10, %20) : (i32, i32) -> ()
    %42 = llvm.add %30, %22 : i64
    llvm.br ^bb2(%42 : i64)
  ^bb4:  // pred: ^bb2
    %43 = llvm.add %28, %27 : i64
    llvm.br ^bb1(%43 : i64)
  ^bb5:  // pred: ^bb1
    llvm.return
  }
  llvm.func @core_0_4() {
    %0 = llvm.mlir.addressof @out_autocorr_0_cons_buff_1 : !llvm.ptr
    %1 = llvm.mlir.addressof @out_magsq_buff_1 : !llvm.ptr
    %2 = llvm.mlir.addressof @threshold_met_buff_1 : !llvm.ptr
    %3 = llvm.mlir.addressof @out_autocorr_0_cons_buff_0 : !llvm.ptr
    %4 = llvm.mlir.addressof @out_magsq_buff_0 : !llvm.ptr
    %5 = llvm.mlir.addressof @threshold_met_buff_0 : !llvm.ptr
    %6 = llvm.mlir.constant(51 : i32) : i32
    %7 = llvm.mlir.constant(2 : i32) : i32
    %8 = llvm.mlir.constant(48 : i32) : i32
    %9 = llvm.mlir.constant(50 : i32) : i32
    %10 = llvm.mlir.constant(3 : i32) : i32
    %11 = llvm.mlir.constant(49 : i32) : i32
    %12 = llvm.mlir.constant(1 : i32) : i32
    %13 = llvm.mlir.constant(-1 : i32) : i32
    %14 = llvm.mlir.constant(2 : index) : i64
    %15 = llvm.mlir.constant(1024 : i32) : i32
    %16 = llvm.mlir.constant(8 : index) : i64
    %17 = llvm.mlir.constant(0 : index) : i64
    %18 = llvm.mlir.constant(9223372036854775807 : index) : i64
    %19 = llvm.mlir.constant(1 : index) : i64
    llvm.br ^bb1(%17 : i64)
  ^bb1(%20: i64):  // 2 preds: ^bb0, ^bb4
    %21 = llvm.icmp "slt" %20, %18 : i64
    llvm.cond_br %21, ^bb2(%17 : i64), ^bb5
  ^bb2(%22: i64):  // 2 preds: ^bb1, ^bb3
    %23 = llvm.icmp "slt" %22, %16 : i64
    llvm.cond_br %23, ^bb3, ^bb4
  ^bb3:  // pred: ^bb2
    llvm.call @llvm.aie2.acquire(%11, %13) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%10, %13) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%9, %13) : (i32, i32) -> ()
    %24 = llvm.getelementptr %5[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<1024 x i8>
    %25 = llvm.getelementptr %4[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<1024 x i32>
    %26 = llvm.getelementptr %3[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2048 x i32>
    llvm.call @threshold_cf(%26, %25, %24, %15) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i32) -> ()
    llvm.call @llvm.aie2.release(%8, %12) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%7, %12) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%6, %12) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%11, %13) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%10, %13) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%9, %13) : (i32, i32) -> ()
    %27 = llvm.getelementptr %2[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<1024 x i8>
    %28 = llvm.getelementptr %1[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<1024 x i32>
    %29 = llvm.getelementptr %0[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2048 x i32>
    llvm.call @threshold_cf(%29, %28, %27, %15) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i32) -> ()
    llvm.call @llvm.aie2.release(%8, %12) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%7, %12) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%6, %12) : (i32, i32) -> ()
    %30 = llvm.add %22, %14 : i64
    llvm.br ^bb2(%30 : i64)
  ^bb4:  // pred: ^bb2
    %31 = llvm.add %20, %19 : i64
    llvm.br ^bb1(%31 : i64)
  ^bb5:  // pred: ^bb1
    llvm.return
  }
  llvm.func @core_0_3() {
    %0 = llvm.mlir.addressof @in_mem_1_cons_buff_1 : !llvm.ptr
    %1 = llvm.mlir.addressof @out_magsq_buff_1 : !llvm.ptr
    %2 = llvm.mlir.addressof @out_magsq_delay_buff_1 : !llvm.ptr
    %3 = llvm.mlir.addressof @in_mem_1_cons_buff_0 : !llvm.ptr
    %4 = llvm.mlir.addressof @out_magsq_buff_0 : !llvm.ptr
    %5 = llvm.mlir.addressof @out_magsq_delay_buff_0 : !llvm.ptr
    %6 = llvm.mlir.constant(53 : i32) : i32
    %7 = llvm.mlir.constant(51 : i32) : i32
    %8 = llvm.mlir.constant(48 : i32) : i32
    %9 = llvm.mlir.constant(52 : i32) : i32
    %10 = llvm.mlir.constant(50 : i32) : i32
    %11 = llvm.mlir.constant(49 : i32) : i32
    %12 = llvm.mlir.constant(1 : i32) : i32
    %13 = llvm.mlir.constant(-1 : i32) : i32
    %14 = llvm.mlir.constant(2 : index) : i64
    %15 = llvm.mlir.constant(1024 : i32) : i32
    %16 = llvm.mlir.constant(8 : index) : i64
    %17 = llvm.mlir.constant(0 : index) : i64
    %18 = llvm.mlir.constant(9223372036854775807 : index) : i64
    %19 = llvm.mlir.constant(1 : index) : i64
    llvm.br ^bb1(%17 : i64)
  ^bb1(%20: i64):  // 2 preds: ^bb0, ^bb4
    %21 = llvm.icmp "slt" %20, %18 : i64
    llvm.cond_br %21, ^bb2(%17 : i64), ^bb5
  ^bb2(%22: i64):  // 2 preds: ^bb1, ^bb3
    %23 = llvm.icmp "slt" %22, %16 : i64
    llvm.cond_br %23, ^bb3, ^bb4
  ^bb3:  // pred: ^bb2
    llvm.call @llvm.aie2.acquire(%11, %13) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%10, %13) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%9, %13) : (i32, i32) -> ()
    %24 = llvm.getelementptr %5[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2048 x i16>
    %25 = llvm.getelementptr %4[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<1024 x i32>
    %26 = llvm.getelementptr %3[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2048 x i16>
    llvm.call @magsq_avg_cf(%26, %25, %24, %15) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i32) -> ()
    llvm.call @llvm.aie2.release(%8, %12) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%7, %12) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%6, %12) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%11, %13) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%10, %13) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%9, %13) : (i32, i32) -> ()
    %27 = llvm.getelementptr %2[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2048 x i16>
    %28 = llvm.getelementptr %1[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<1024 x i32>
    %29 = llvm.getelementptr %0[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2048 x i16>
    llvm.call @magsq_avg_cf(%29, %28, %27, %15) : (!llvm.ptr, !llvm.ptr, !llvm.ptr, i32) -> ()
    llvm.call @llvm.aie2.release(%8, %12) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%7, %12) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%6, %12) : (i32, i32) -> ()
    %30 = llvm.add %22, %14 : i64
    llvm.br ^bb2(%30 : i64)
  ^bb4:  // pred: ^bb2
    %31 = llvm.add %20, %19 : i64
    llvm.br ^bb1(%31 : i64)
  ^bb5:  // pred: ^bb1
    llvm.return
  }
  llvm.func @core_0_2() {
    %0 = llvm.mlir.addressof @in_mem_0_cons_buff_1 : !llvm.ptr
    %1 = llvm.mlir.addressof @out_autocorr_buff_1 : !llvm.ptr
    %2 = llvm.mlir.addressof @in_mem_0_cons_buff_0 : !llvm.ptr
    %3 = llvm.mlir.addressof @out_autocorr_buff_0 : !llvm.ptr
    %4 = llvm.mlir.constant(51 : i32) : i32
    %5 = llvm.mlir.constant(48 : i32) : i32
    %6 = llvm.mlir.constant(50 : i32) : i32
    %7 = llvm.mlir.constant(49 : i32) : i32
    %8 = llvm.mlir.constant(1 : i32) : i32
    %9 = llvm.mlir.constant(-1 : i32) : i32
    %10 = llvm.mlir.constant(2 : index) : i64
    %11 = llvm.mlir.constant(1024 : i32) : i32
    %12 = llvm.mlir.constant(8 : index) : i64
    %13 = llvm.mlir.constant(0 : index) : i64
    %14 = llvm.mlir.constant(9223372036854775807 : index) : i64
    %15 = llvm.mlir.constant(1 : index) : i64
    llvm.br ^bb1(%13 : i64)
  ^bb1(%16: i64):  // 2 preds: ^bb0, ^bb4
    %17 = llvm.icmp "slt" %16, %14 : i64
    llvm.cond_br %17, ^bb2(%13 : i64), ^bb5
  ^bb2(%18: i64):  // 2 preds: ^bb1, ^bb3
    %19 = llvm.icmp "slt" %18, %12 : i64
    llvm.cond_br %19, ^bb3, ^bb4
  ^bb3:  // pred: ^bb2
    llvm.call @llvm.aie2.acquire(%7, %9) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%6, %9) : (i32, i32) -> ()
    %20 = llvm.getelementptr %3[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2048 x i32>
    %21 = llvm.getelementptr %2[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2048 x i16>
    llvm.call @autocorr_cf(%21, %20, %11) : (!llvm.ptr, !llvm.ptr, i32) -> ()
    llvm.call @llvm.aie2.release(%5, %8) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%4, %8) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%7, %9) : (i32, i32) -> ()
    llvm.call @llvm.aie2.acquire(%6, %9) : (i32, i32) -> ()
    %22 = llvm.getelementptr %1[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2048 x i32>
    %23 = llvm.getelementptr %0[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<2048 x i16>
    llvm.call @autocorr_cf(%23, %22, %11) : (!llvm.ptr, !llvm.ptr, i32) -> ()
    llvm.call @llvm.aie2.release(%5, %8) : (i32, i32) -> ()
    llvm.call @llvm.aie2.release(%4, %8) : (i32, i32) -> ()
    %24 = llvm.add %18, %10 : i64
    llvm.br ^bb2(%24 : i64)
  ^bb4:  // pred: ^bb2
    %25 = llvm.add %16, %15 : i64
    llvm.br ^bb1(%25 : i64)
  ^bb5:  // pred: ^bb1
    llvm.return
  }
}
