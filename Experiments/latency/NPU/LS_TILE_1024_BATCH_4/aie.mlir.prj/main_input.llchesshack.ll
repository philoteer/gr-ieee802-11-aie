; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"
target triple = "aie2"

@center_frequency = external global [2 x i32]
@fft_out_buff_1 = external global [2048 x i32]
@fft_out_buff_0 = external global [2048 x i32]
@fft_out_meta_buff_1 = external global [64 x i32]
@fft_out_meta_buff_0 = external global [64 x i32]
@frame_equalizer_out_buff_1 = external global [1024 x i8]
@frame_equalizer_out_buff_0 = external global [1024 x i8]
@frame_equalizer_out_meta_buff_1 = external global [2242 x i32]
@frame_equalizer_out_meta_buff_0 = external global [2242 x i32]
@frame_equalizer_prepared_buff_1 = external global [2048 x i32]
@frame_equalizer_prepared_buff_0 = external global [2048 x i32]
@frame_equalizer_prepared_meta_buff_1 = external global [81 x i32]
@frame_equalizer_prepared_meta_buff_0 = external global [81 x i32]
@in_cons_buff_1 = external global [2048 x i16]
@in_cons_buff_0 = external global [2048 x i16]
@in_mem_1_cons_buff_1 = external global [2048 x i16]
@in_mem_1_cons_buff_0 = external global [2048 x i16]
@in_mem_0_cons_buff_1 = external global [2048 x i16]
@in_mem_0_cons_buff_0 = external global [2048 x i16]
@out_autocorr_buff_1 = external global [2048 x i32]
@out_autocorr_buff_0 = external global [2048 x i32]
@out_autocorr_1_cons_buff_1 = external global [2048 x i32]
@out_autocorr_1_cons_buff_0 = external global [2048 x i32]
@out_autocorr_0_cons_buff_1 = external global [2048 x i32]
@out_autocorr_0_cons_buff_0 = external global [2048 x i32]
@out_magsq_buff_1 = external global [1024 x i32]
@out_magsq_buff_0 = external global [1024 x i32]
@out_magsq_delay_buff_1 = external global [2048 x i16]
@out_magsq_delay_buff_0 = external global [2048 x i16]
@out_magsq_delay_cons_buff_1 = external global [2048 x i16]
@out_magsq_delay_cons_buff_0 = external global [2048 x i16]
@sync_long_out_buff_1 = external global [2048 x i16]
@sync_long_out_buff_0 = external global [2048 x i16]
@sync_long_out_meta_buff_1 = external global [16 x i32]
@sync_long_out_meta_buff_0 = external global [16 x i32]
@sync_short_out_buff_1 = external global [2688 x i16]
@sync_short_out_buff_0 = external global [2688 x i16]
@sync_short_out_cons_buff_1 = external global [2688 x i16]
@sync_short_out_cons_buff_0 = external global [2688 x i16]
@sync_short_out_meta_buff_1 = external global [16 x i32]
@sync_short_out_meta_buff_0 = external global [16 x i32]
@sync_short_out_meta_cons_buff_1 = external global [16 x i32]
@sync_short_out_meta_cons_buff_0 = external global [16 x i32]
@threshold_met_buff_1 = external global [1024 x i8]
@threshold_met_buff_0 = external global [1024 x i8]

declare void @debug_i32(i32)

; Unknown intrinsic
declare void @llvm.aie2.event(i32)

; Unknown intrinsic
declare void @llvm.aie2.put.ms(i32, i32)

; Unknown intrinsic
declare { i32, i32 } @llvm.aie2.get.ss()

; Unknown intrinsic
declare void @llvm.aie2.mcd.write.vec(<16 x i32>, i32)

; Unknown intrinsic
declare <16 x i32> @llvm.aie2.scd.read.vec(i32)

; Unknown intrinsic
declare void @llvm.aie2.acquire(i32, i32)

; Unknown intrinsic
declare void @llvm.aie2.release(i32, i32)

declare void @autocorr_cf(ptr, ptr, i32)

declare void @magsq_avg_cf(ptr, ptr, ptr, i32)

declare void @threshold_cf(ptr, ptr, ptr, i32)

declare void @sync_short_cf(ptr, ptr, ptr, ptr, ptr, i32)

declare void @sync_long_cf(ptr, ptr, ptr, ptr, i32, i32)

declare void @fft_cf(ptr, ptr, ptr, ptr, i32, i32)

declare void @frame_equalizer_preprocess(ptr, ptr, ptr, ptr, ptr, i32, i32)

declare void @frame_equalizer_equalize(ptr, ptr, ptr, ptr, i32, i32)

define void @core_1_5() {
  br label %1

1:                                                ; preds = %9, %0
  %2 = phi i64 [ %10, %9 ], [ 0, %0 ]
  %3 = icmp slt i64 %2, 9223372036854775807
  br i1 %3, label %4, label %11

4:                                                ; preds = %7, %1
  %5 = phi i64 [ %8, %7 ], [ 0, %1 ]
  %6 = icmp slt i64 %5, 4
  br i1 %6, label %7, label %9

7:                                                ; preds = %4
  call void @llvm.aie2.acquire(i32 1, i32 -1)
  call void @llvm.aie2.acquire(i32 3, i32 -1)
  call void @llvm.aie2.acquire(i32 48, i32 -1)
  call void @llvm.aie2.acquire(i32 50, i32 -1)
  call void @frame_equalizer_equalize(ptr @frame_equalizer_prepared_buff_0, ptr @frame_equalizer_prepared_meta_buff_0, ptr @frame_equalizer_out_buff_0, ptr @frame_equalizer_out_meta_buff_0, i32 1024, i32 2242)
  call void @llvm.aie2.release(i32 0, i32 1)
  call void @llvm.aie2.release(i32 2, i32 1)
  call void @llvm.aie2.release(i32 49, i32 1)
  call void @llvm.aie2.release(i32 51, i32 1)
  call void @llvm.aie2.acquire(i32 1, i32 -1)
  call void @llvm.aie2.acquire(i32 3, i32 -1)
  call void @llvm.aie2.acquire(i32 48, i32 -1)
  call void @llvm.aie2.acquire(i32 50, i32 -1)
  call void @frame_equalizer_equalize(ptr @frame_equalizer_prepared_buff_1, ptr @frame_equalizer_prepared_meta_buff_1, ptr @frame_equalizer_out_buff_1, ptr @frame_equalizer_out_meta_buff_1, i32 1024, i32 2242)
  call void @llvm.aie2.release(i32 0, i32 1)
  call void @llvm.aie2.release(i32 2, i32 1)
  call void @llvm.aie2.release(i32 49, i32 1)
  call void @llvm.aie2.release(i32 51, i32 1)
  %8 = add i64 %5, 2
  br label %4

9:                                                ; preds = %4
  %10 = add i64 %2, 1
  br label %1

11:                                               ; preds = %1
  ret void
}

define void @core_1_4() {
  br label %1

1:                                                ; preds = %9, %0
  %2 = phi i64 [ %10, %9 ], [ 0, %0 ]
  %3 = icmp slt i64 %2, 9223372036854775807
  br i1 %3, label %4, label %11

4:                                                ; preds = %7, %1
  %5 = phi i64 [ %8, %7 ], [ 0, %1 ]
  %6 = icmp slt i64 %5, 4
  br i1 %6, label %7, label %9

7:                                                ; preds = %4
  call void @llvm.aie2.acquire(i32 1, i32 -1)
  call void @llvm.aie2.acquire(i32 3, i32 -1)
  call void @llvm.aie2.acquire(i32 48, i32 -1)
  call void @llvm.aie2.acquire(i32 50, i32 -1)
  call void @frame_equalizer_preprocess(ptr @fft_out_buff_0, ptr @fft_out_meta_buff_0, ptr @frame_equalizer_prepared_buff_0, ptr @frame_equalizer_prepared_meta_buff_0, ptr @center_frequency, i32 1024, i32 64)
  call void @llvm.aie2.release(i32 0, i32 1)
  call void @llvm.aie2.release(i32 2, i32 1)
  call void @llvm.aie2.release(i32 49, i32 1)
  call void @llvm.aie2.release(i32 51, i32 1)
  call void @llvm.aie2.acquire(i32 1, i32 -1)
  call void @llvm.aie2.acquire(i32 3, i32 -1)
  call void @llvm.aie2.acquire(i32 48, i32 -1)
  call void @llvm.aie2.acquire(i32 50, i32 -1)
  call void @frame_equalizer_preprocess(ptr @fft_out_buff_1, ptr @fft_out_meta_buff_1, ptr @frame_equalizer_prepared_buff_1, ptr @frame_equalizer_prepared_meta_buff_1, ptr @center_frequency, i32 1024, i32 64)
  call void @llvm.aie2.release(i32 0, i32 1)
  call void @llvm.aie2.release(i32 2, i32 1)
  call void @llvm.aie2.release(i32 49, i32 1)
  call void @llvm.aie2.release(i32 51, i32 1)
  %8 = add i64 %5, 2
  br label %4

9:                                                ; preds = %4
  %10 = add i64 %2, 1
  br label %1

11:                                               ; preds = %1
  ret void
}

define void @core_1_3() {
  br label %1

1:                                                ; preds = %9, %0
  %2 = phi i64 [ %10, %9 ], [ 0, %0 ]
  %3 = icmp slt i64 %2, 9223372036854775807
  br i1 %3, label %4, label %11

4:                                                ; preds = %7, %1
  %5 = phi i64 [ %8, %7 ], [ 0, %1 ]
  %6 = icmp slt i64 %5, 4
  br i1 %6, label %7, label %9

7:                                                ; preds = %4
  call void @llvm.aie2.acquire(i32 1, i32 -1)
  call void @llvm.aie2.acquire(i32 3, i32 -1)
  call void @llvm.aie2.acquire(i32 48, i32 -1)
  call void @llvm.aie2.acquire(i32 50, i32 -1)
  call void @fft_cf(ptr @sync_long_out_buff_0, ptr @sync_long_out_meta_buff_0, ptr @fft_out_buff_0, ptr @fft_out_meta_buff_0, i32 1024, i32 64)
  call void @llvm.aie2.release(i32 0, i32 1)
  call void @llvm.aie2.release(i32 2, i32 1)
  call void @llvm.aie2.release(i32 49, i32 1)
  call void @llvm.aie2.release(i32 51, i32 1)
  call void @llvm.aie2.acquire(i32 1, i32 -1)
  call void @llvm.aie2.acquire(i32 3, i32 -1)
  call void @llvm.aie2.acquire(i32 48, i32 -1)
  call void @llvm.aie2.acquire(i32 50, i32 -1)
  call void @fft_cf(ptr @sync_long_out_buff_1, ptr @sync_long_out_meta_buff_1, ptr @fft_out_buff_1, ptr @fft_out_meta_buff_1, i32 1024, i32 64)
  call void @llvm.aie2.release(i32 0, i32 1)
  call void @llvm.aie2.release(i32 2, i32 1)
  call void @llvm.aie2.release(i32 49, i32 1)
  call void @llvm.aie2.release(i32 51, i32 1)
  %8 = add i64 %5, 2
  br label %4

9:                                                ; preds = %4
  %10 = add i64 %2, 1
  br label %1

11:                                               ; preds = %1
  ret void
}

define void @core_1_2() {
  br label %1

1:                                                ; preds = %9, %0
  %2 = phi i64 [ %10, %9 ], [ 0, %0 ]
  %3 = icmp slt i64 %2, 9223372036854775807
  br i1 %3, label %4, label %11

4:                                                ; preds = %7, %1
  %5 = phi i64 [ %8, %7 ], [ 0, %1 ]
  %6 = icmp slt i64 %5, 4
  br i1 %6, label %7, label %9

7:                                                ; preds = %4
  call void @llvm.aie2.acquire(i32 53, i32 -1)
  call void @llvm.aie2.acquire(i32 55, i32 -1)
  call void @llvm.aie2.acquire(i32 48, i32 -1)
  call void @llvm.aie2.acquire(i32 50, i32 -1)
  call void @sync_long_cf(ptr @sync_short_out_cons_buff_0, ptr @sync_short_out_meta_cons_buff_0, ptr @sync_long_out_buff_0, ptr @sync_long_out_meta_buff_0, i32 1024, i32 16)
  call void @llvm.aie2.release(i32 52, i32 1)
  call void @llvm.aie2.release(i32 54, i32 1)
  call void @llvm.aie2.release(i32 49, i32 1)
  call void @llvm.aie2.release(i32 51, i32 1)
  call void @llvm.aie2.acquire(i32 53, i32 -1)
  call void @llvm.aie2.acquire(i32 55, i32 -1)
  call void @llvm.aie2.acquire(i32 48, i32 -1)
  call void @llvm.aie2.acquire(i32 50, i32 -1)
  call void @sync_long_cf(ptr @sync_short_out_cons_buff_1, ptr @sync_short_out_meta_cons_buff_1, ptr @sync_long_out_buff_1, ptr @sync_long_out_meta_buff_1, i32 1024, i32 16)
  call void @llvm.aie2.release(i32 52, i32 1)
  call void @llvm.aie2.release(i32 54, i32 1)
  call void @llvm.aie2.release(i32 49, i32 1)
  call void @llvm.aie2.release(i32 51, i32 1)
  %8 = add i64 %5, 2
  br label %4

9:                                                ; preds = %4
  %10 = add i64 %2, 1
  br label %1

11:                                               ; preds = %1
  ret void
}

define void @core_0_5() {
  br label %1

1:                                                ; preds = %9, %0
  %2 = phi i64 [ %10, %9 ], [ 0, %0 ]
  %3 = icmp slt i64 %2, 9223372036854775807
  br i1 %3, label %4, label %11

4:                                                ; preds = %7, %1
  %5 = phi i64 [ %8, %7 ], [ 0, %1 ]
  %6 = icmp slt i64 %5, 4
  br i1 %6, label %7, label %9

7:                                                ; preds = %4
  call void @llvm.aie2.acquire(i32 51, i32 -1)
  call void @llvm.aie2.acquire(i32 49, i32 -1)
  call void @llvm.aie2.acquire(i32 3, i32 -1)
  call void @llvm.aie2.acquire(i32 52, i32 -1)
  call void @llvm.aie2.acquire(i32 54, i32 -1)
  call void @sync_short_cf(ptr @out_magsq_delay_cons_buff_0, ptr @out_autocorr_1_cons_buff_0, ptr @threshold_met_buff_0, ptr @sync_short_out_buff_0, ptr @sync_short_out_meta_buff_0, i32 1024)
  call void @llvm.aie2.release(i32 50, i32 1)
  call void @llvm.aie2.release(i32 48, i32 1)
  call void @llvm.aie2.release(i32 2, i32 1)
  call void @llvm.aie2.release(i32 53, i32 1)
  call void @llvm.aie2.release(i32 55, i32 1)
  call void @llvm.aie2.acquire(i32 51, i32 -1)
  call void @llvm.aie2.acquire(i32 49, i32 -1)
  call void @llvm.aie2.acquire(i32 3, i32 -1)
  call void @llvm.aie2.acquire(i32 52, i32 -1)
  call void @llvm.aie2.acquire(i32 54, i32 -1)
  call void @sync_short_cf(ptr @out_magsq_delay_cons_buff_1, ptr @out_autocorr_1_cons_buff_1, ptr @threshold_met_buff_1, ptr @sync_short_out_buff_1, ptr @sync_short_out_meta_buff_1, i32 1024)
  call void @llvm.aie2.release(i32 50, i32 1)
  call void @llvm.aie2.release(i32 48, i32 1)
  call void @llvm.aie2.release(i32 2, i32 1)
  call void @llvm.aie2.release(i32 53, i32 1)
  call void @llvm.aie2.release(i32 55, i32 1)
  %8 = add i64 %5, 2
  br label %4

9:                                                ; preds = %4
  %10 = add i64 %2, 1
  br label %1

11:                                               ; preds = %1
  ret void
}

define void @core_0_4() {
  br label %1

1:                                                ; preds = %9, %0
  %2 = phi i64 [ %10, %9 ], [ 0, %0 ]
  %3 = icmp slt i64 %2, 9223372036854775807
  br i1 %3, label %4, label %11

4:                                                ; preds = %7, %1
  %5 = phi i64 [ %8, %7 ], [ 0, %1 ]
  %6 = icmp slt i64 %5, 4
  br i1 %6, label %7, label %9

7:                                                ; preds = %4
  call void @llvm.aie2.acquire(i32 49, i32 -1)
  call void @llvm.aie2.acquire(i32 3, i32 -1)
  call void @llvm.aie2.acquire(i32 50, i32 -1)
  call void @threshold_cf(ptr @out_autocorr_0_cons_buff_0, ptr @out_magsq_buff_0, ptr @threshold_met_buff_0, i32 1024)
  call void @llvm.aie2.release(i32 48, i32 1)
  call void @llvm.aie2.release(i32 2, i32 1)
  call void @llvm.aie2.release(i32 51, i32 1)
  call void @llvm.aie2.acquire(i32 49, i32 -1)
  call void @llvm.aie2.acquire(i32 3, i32 -1)
  call void @llvm.aie2.acquire(i32 50, i32 -1)
  call void @threshold_cf(ptr @out_autocorr_0_cons_buff_1, ptr @out_magsq_buff_1, ptr @threshold_met_buff_1, i32 1024)
  call void @llvm.aie2.release(i32 48, i32 1)
  call void @llvm.aie2.release(i32 2, i32 1)
  call void @llvm.aie2.release(i32 51, i32 1)
  %8 = add i64 %5, 2
  br label %4

9:                                                ; preds = %4
  %10 = add i64 %2, 1
  br label %1

11:                                               ; preds = %1
  ret void
}

define void @core_0_3() {
  br label %1

1:                                                ; preds = %9, %0
  %2 = phi i64 [ %10, %9 ], [ 0, %0 ]
  %3 = icmp slt i64 %2, 9223372036854775807
  br i1 %3, label %4, label %11

4:                                                ; preds = %7, %1
  %5 = phi i64 [ %8, %7 ], [ 0, %1 ]
  %6 = icmp slt i64 %5, 4
  br i1 %6, label %7, label %9

7:                                                ; preds = %4
  call void @llvm.aie2.acquire(i32 49, i32 -1)
  call void @llvm.aie2.acquire(i32 50, i32 -1)
  call void @llvm.aie2.acquire(i32 52, i32 -1)
  call void @magsq_avg_cf(ptr @in_mem_1_cons_buff_0, ptr @out_magsq_buff_0, ptr @out_magsq_delay_buff_0, i32 1024)
  call void @llvm.aie2.release(i32 48, i32 1)
  call void @llvm.aie2.release(i32 51, i32 1)
  call void @llvm.aie2.release(i32 53, i32 1)
  call void @llvm.aie2.acquire(i32 49, i32 -1)
  call void @llvm.aie2.acquire(i32 50, i32 -1)
  call void @llvm.aie2.acquire(i32 52, i32 -1)
  call void @magsq_avg_cf(ptr @in_mem_1_cons_buff_1, ptr @out_magsq_buff_1, ptr @out_magsq_delay_buff_1, i32 1024)
  call void @llvm.aie2.release(i32 48, i32 1)
  call void @llvm.aie2.release(i32 51, i32 1)
  call void @llvm.aie2.release(i32 53, i32 1)
  %8 = add i64 %5, 2
  br label %4

9:                                                ; preds = %4
  %10 = add i64 %2, 1
  br label %1

11:                                               ; preds = %1
  ret void
}

define void @core_0_2() {
  br label %1

1:                                                ; preds = %9, %0
  %2 = phi i64 [ %10, %9 ], [ 0, %0 ]
  %3 = icmp slt i64 %2, 9223372036854775807
  br i1 %3, label %4, label %11

4:                                                ; preds = %7, %1
  %5 = phi i64 [ %8, %7 ], [ 0, %1 ]
  %6 = icmp slt i64 %5, 4
  br i1 %6, label %7, label %9

7:                                                ; preds = %4
  call void @llvm.aie2.acquire(i32 49, i32 -1)
  call void @llvm.aie2.acquire(i32 50, i32 -1)
  call void @autocorr_cf(ptr @in_mem_0_cons_buff_0, ptr @out_autocorr_buff_0, i32 1024)
  call void @llvm.aie2.release(i32 48, i32 1)
  call void @llvm.aie2.release(i32 51, i32 1)
  call void @llvm.aie2.acquire(i32 49, i32 -1)
  call void @llvm.aie2.acquire(i32 50, i32 -1)
  call void @autocorr_cf(ptr @in_mem_0_cons_buff_1, ptr @out_autocorr_buff_1, i32 1024)
  call void @llvm.aie2.release(i32 48, i32 1)
  call void @llvm.aie2.release(i32 51, i32 1)
  %8 = add i64 %5, 2
  br label %4

9:                                                ; preds = %4
  %10 = add i64 %2, 1
  br label %1

11:                                               ; preds = %1
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
