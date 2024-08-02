# !/bin/bash
# 运行之前记得切换到 test1_base64_sync_CFG_instrumentation 分支

rm ./cfg.txt ./processed_mapping_table.txt ./function_list.txt ./cfg_text.txt

make clean
rm src/base64
export LD_LIBRARY_PATH=/data/cse12132329/aflplusplus-alltests/aflplusplus-base64
export FUNCTION="TEXT_CFG" 
export CONTROL_FLOW_GRAPH="./cfg.txt" 
export AFL_LLVM_CALLER=1
export CFLAGS="-I. -I./lib -Ilib -I./lib -Isrc -I./src -O2 -emit-llvm -S"
export CXXFLAGS="-I. -I./lib -Ilib -I./lib -Isrc -I./src -O2 -emit-llvm -S"
export CC="afl-clang-fast"
export CXX="afl-clang-fast++"
make -e cyhbase64


