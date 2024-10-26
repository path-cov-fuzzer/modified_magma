#!/bin/bash
set -e

set -x
# 3. 过滤掉 cfg.txt 和 callmap.txt 的东西，以及生成一些别的文本
echo "before executing bash $FUZZER/filterCFG_Callmap_script.sh"
source $FUZZER/filterCFG_Callmap_script.sh
cat $OUT/cfg.txt | grep "BasicBlock: " | wc -l > $OUT/bbnum.txt
cat $OUT/cfg_filtered.txt | grep "Function: " | nl -v 0 | awk '{print $1, $3, $4, $5, $6, $7, $8, $9}' > $OUT/function_list.txt
echo "after executing bash $FUZZER/filterCFG_Callmap_script.sh"

# 4. 使用之前构建的东西，生成 CFG binary
echo "before executing convert"
g++ $FUZZER/convert.cpp -o $OUT/convert
$OUT/convert
mv $OUT/top.bin $OUT/${PROGRAM}_cfg.bin
echo "after executing convert"
set +x


