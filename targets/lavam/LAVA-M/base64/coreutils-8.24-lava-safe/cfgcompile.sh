# !/bin/bash
# 运行之前记得切换到 test1_base64_sync_CFG_instrumentation 分支

rm ./cfg.txt ./processed_mapping_table.txt ./function_list.txt ./cfg_text.txt

make clean
rm src/base64
export LD_LIBRARY_PATH=$(pwd)
export FUNCTION="TEXT_CFG" 
export CONTROL_FLOW_GRAPH="./cfg.txt" 
export AFL_LLVM_CALLER=1
export CFLAGS="-I. -I./lib -Ilib -I./lib -Isrc -I./src -O2"
export CXXFLAGS="-I. -I./lib -Ilib -I./lib -Isrc -I./src -O2"
export CC="afl-clang-fast"
export CXX="afl-clang-fast++"
make -e cyhbase64

# cat cfg.txt | grep "BasicBlock" | nl | awk '{print $1, $3, $4, $5, $6, $7, $8, $9}' > processed_mapping_table.txt
cat cfg.txt | grep "BasicBlock: " | nl -v 0 | awk '{print $1, $3, $4, $5, $6, $7, $8, $9}' > processed_mapping_table.txt
cat cfg.txt | grep "Function: " | nl -v 0 | awk '{print $1, $3, $4, $5, $6, $7, $8, $9}' > function_list.txt
mv cfg.txt cfg_text.txt

make clean
rm src/base64
export LD_LIBRARY_PATH=$(pwd)
export FUNCTION="INT_CFG" 
export CONTROL_FLOW_GRAPH="./cfg.txt" 
export AFL_LLVM_CALLER=1
export CFLAGS="-I. -I./lib -Ilib -I./lib -Isrc -I./src -O2"
export CXXFLAGS="-I. -I./lib -Ilib -I./lib -Isrc -I./src -O2"
export CC="afl-clang-fast"
export CXX="afl-clang-fast++"
make -e cyhbase64

g++ convert.cpp -o convert
./convert

