# !/bin/bash

export AFL_LLVM_CMPLOG=1
export CC="afl-clang-fast"
export CXX="afl-clang-fast++"
# 编译 edge.c
$CC edge.c -o edge_cmplog


