# !/bin/bash
# 运行之前正确安装 pathAFL++
# 注意：这需要先运行 cfgcompile.sh

make clean
rm src/md5sum
export LD_LIBRARY_PATH=$(pwd)
export FUNCTION="PATH_INJECT" 
# export CONTROL_FLOW_GRAPH="./cfg.txt"  这个玩意儿应该不需要
export AFL_LLVM_CALLER=1
export CFLAGS="-I. -I./lib -Ilib -I./lib -Isrc -I./src -O2"
export CXXFLAGS="-I. -I./lib -Ilib -I./lib -Isrc -I./src -O2"
export CC="afl-clang-fast"
export CXX="afl-clang-fast++"
make -e cyhmd5sum


