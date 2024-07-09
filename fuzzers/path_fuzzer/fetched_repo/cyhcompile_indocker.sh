#!/bin/bash

bash update_path_reduction.sh

g++ -c hashcompare.cpp
ar rcs libhashcompare.a hashcompare.o
LLVM_CONFIG=llvm-config-17 LD_LIBRARY_PATH=$(pwd) CFLAGS="-I$(pwd)" LDFLAGS="-L$(pwd) -lcrypto -lhashcompare -lstdc++ -lpath_reduction" make -e -j$(nproc)

export CC=clang
export CXX=clang++
export AFL_NO_X86=1
export PYTHON_INCLUDE=/
LLVM_CONFIG=llvm-config-17 LD_LIBRARY_PATH=$(pwd) make -e -C utils/aflpp_driver || exit 1



