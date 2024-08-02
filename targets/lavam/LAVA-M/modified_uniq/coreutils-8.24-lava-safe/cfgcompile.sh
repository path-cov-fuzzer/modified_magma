# !/bin/bash
# 运行之前正确安装 pathAFL++

rm ./cfg.txt ./processed_mapping_table.txt ./function_list.txt ./cfg_text.txt

make clean
rm src/uniq
export LD_LIBRARY_PATH=$(pwd)
export FUNCTION="TEXT_CFG" 
export CONTROL_FLOW_GRAPH="./cfg.txt" 
export AFL_LLVM_CALLER=1
export CFLAGS="-I. -I./lib -Ilib -I./lib -Isrc -I./src -O2"
export CXXFLAGS="-I. -I./lib -Ilib -I./lib -Isrc -I./src -O2"
export CC="afl-clang-fast"
export CXX="afl-clang-fast++"
make -e cyhuniq

# cat cfg.txt | grep "BasicBlock" | nl | awk '{print $1, $3, $4, $5, $6, $7, $8, $9}' > processed_mapping_table.txt
cat cfg.txt | grep "BasicBlock: " | nl -v 0 | awk '{print $1, $3, $4, $5, $6, $7, $8, $9}' > processed_mapping_table.txt
cat cfg.txt | grep "Function: " | nl -v 0 | awk '{print $1, $3, $4, $5, $6, $7, $8, $9}' > function_list.txt
mv cfg.txt cfg_text.txt

make clean
rm src/uniq
export LD_LIBRARY_PATH=$(pwd)
export FUNCTION="INT_CFG" 
export CONTROL_FLOW_GRAPH="./cfg.txt" 
export AFL_LLVM_CALLER=1
export CFLAGS="-I. -I./lib -Ilib -I./lib -Isrc -I./src -O2"
export CXXFLAGS="-I. -I./lib -Ilib -I./lib -Isrc -I./src -O2"
export CC="afl-clang-fast"
export CXX="afl-clang-fast++"
make -e cyhuniq

g++ convert.cpp -o convert
./convert

