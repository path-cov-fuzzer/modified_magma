#!/bin/bash

LLVM_CONFIG=llvm-config-14 make -e -j$(nproc)

export CC=clang
export CXX=clang++
export AFL_NO_X86=1
export PYTHON_INCLUDE=/
LLVM_CONFIG=llvm-config-14 make -e -C utils/aflpp_driver || exit 1

