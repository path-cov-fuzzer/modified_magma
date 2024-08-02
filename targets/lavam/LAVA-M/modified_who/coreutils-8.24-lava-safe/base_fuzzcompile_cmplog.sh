# !/bin/bash
# 执行之前请切换到 stable 分支，并编译安装

# 这里只有 cmplog 版本的 PUT
rm src/who
make clean
export AFL_LLVM_CMPLOG=1
export CFLAGS="-I. -I./lib -Ilib -I./lib -Isrc -I./src -O2 -Wno-error=implicit-function-declaration"
export CXXFLAGS="-I. -I./lib -Ilib -I./lib -Isrc -I./src -O2 -Wno-error=implicit-function-declaration"
export CC="afl-clang-fast"
export CXX="afl-clang-fast++"
make -e cyhwho

