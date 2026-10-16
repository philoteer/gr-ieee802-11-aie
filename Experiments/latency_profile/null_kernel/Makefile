# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
.DEFAULT_GOAL := all
srcdir := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

AIETOOLS_DIR ?= /opt/vitis_aie_essentials
export LD_LIBRARY_PATH := ${AIETOOLS_DIR}/lib/lnx64.o/:$(LD_LIBRARY_PATH)
export RDI_DATADIR := ${AIETOOLS_DIR}/data
export PATH := ${AIETOOLS_DIR}/tps/lnx64/target_aie_ml/bin/LNa64bin/:$(PATH)
PHY_INCLUDE := ${srcdir}/../../../base/kernel

.PHONY: all test clean
all: build/final.xclbin build/insts.bin

build/aie.mlir: ${srcdir}/aie2.py
	mkdir -p ${@D}
	python3 $< > $@

build/null_phy.o: ${srcdir}/null_phy.cc ${PHY_INCLUDE}/frame_equalizer_metadata.h
	mkdir -p ${@D}
	cd ${@D} && xchesscc_wrapper aie2 -I ${AIETOOLS_DIR}/include -I ${PHY_INCLUDE} -c $< -o ${@F}

build/final.xclbin: build/aie.mlir build/null_phy.o
	cd ${@D} && aiecc.py --aie-generate-xclbin --no-compile-host \
		--xclbin-name=${@F} --aie-generate-npu-insts --npu-insts-name=insts.bin aie.mlir

build/insts.bin: build/final.xclbin
	@test -f $@

test: all
	python3 ${srcdir}/test.py

clean:
	rm -rf build
