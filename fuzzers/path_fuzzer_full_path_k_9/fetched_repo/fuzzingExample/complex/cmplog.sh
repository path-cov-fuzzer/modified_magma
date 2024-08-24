# !/bin/bash
# 运行之前记得切换到 stable 分支 

export AFL_LLVM_CMPLOG=1
export CC="afl-clang-fast"
export CXX="afl-clang-fast++"
make

mv complex complex_cmplog







