# !/bin/bash
# 运行之前记得切换到 path_fuzzer_with_reduction 分支 

rm ./bbid.txt ./callmap.txt ./cfg.txt ./function_list.txt ./bbnum.txt ./convert

# 1. 获取最新的 libpath_reduction.so
bash update_path_reduction.sh

# 2. 插桩，生成 cfg.txt 和 callmap.txt
export BBIDFILE="./bbid.txt" 
export CALLMAPFILE="./callmap.txt" 
export CFGFILE="./cfg.txt" 
export LD_LIBRARY_PATH=$(pwd)
export AFL_LLVM_CALLER=1
export CC="afl-clang-fast"
export CXX="afl-clang-fast++"
make

# 3. 从 cfg.txt 和 callmap.txt 总过滤掉多余的东西
cat cfg.txt | grep "BasicBlock: " | wc -l > bbnum.txt
# 如果是其它 PUT，这里需要一个 filter CFG 和 callmap 的操作，这里直接拷贝改名就好
bash filterCFG_Callmap_script.sh
# 改完名字了
cat cfg_filtered.txt | grep "Function: " | nl -v 0 | awk '{print $1, $3, $4, $5, $6, $7, $8, $9}' > function_list.txt

# 4. 使用 cfg.txt 和 callmap.txt 转化为 CFG binary
g++ convert.cpp -o convert
./convert
mv top.bin complex_cfg.bin

mv complex complex_PUT







