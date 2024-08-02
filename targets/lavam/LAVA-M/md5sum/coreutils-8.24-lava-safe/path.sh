# !/bin/bash
# 运行之前记得切换到 path_fuzzer_with_reduction 分支 

rm ./bbid.txt ./callmap.txt ./cfg.txt ./function_list.txt ./bbnum.txt ./convert

make clean
rm src/md5sum
export BBIDFILE="$(pwd)/bbid.txt" 
export CALLMAPFILE="$(pwd)/callmap.txt" 
export CFGFILE="$(pwd)/cfg.txt" 
export LD_LIBRARY_PATH=$(pwd)
export AFL_LLVM_CALLER=1
export CFLAGS="-I. -I./lib -Ilib -I./lib -Isrc -I./src -O2 -Wno-error=implicit-function-declaration"
export CXXFLAGS="-I. -I./lib -Ilib -I./lib -Isrc -I./src -O2 -Wno-error=implicit-function-declaration"
export CC="afl-clang-fast"
export CXX="afl-clang-fast++"
make -e cyhmd5sum

cat cfg.txt | grep "BasicBlock: " | wc -l > bbnum.txt
# 如果是其它 PUT，这里需要一个 filter CFG 和 callmap 的操作，这里直接拷贝改名就好
cp cfg.txt cfg_filtered.txt
cp callmap.txt callmap_filtered.txt
# 改完名字了
cat cfg_filtered.txt | grep "Function: " | nl -v 0 | awk '{print $1, $3, $4, $5, $6, $7, $8, $9}' > function_list.txt

g++ convert.cpp -o convert
./convert
mv top.bin md5sum_cfg.bin


