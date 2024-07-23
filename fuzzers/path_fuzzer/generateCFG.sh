#!/bin/bash
set -e

source $TARGET/configrc

g++ $FUZZER/convert.cpp -o $OUT/convert
cat $OUT/cfg.txt | grep "BasicBlock: " | wc -l > $OUT/bbnum.txt

for each_PROGRAM in "${PROGRAMS[@]}"
do

    export PROGRAM=$each_PROGRAM

    # 1. 过滤掉 cfg.txt 和 callmap.txt 的东西，以及生成一些别的文本
    echo "before executing bash $FUZZER/filterCFG_Callmap_script.sh"
    source $FUZZER/filterCFG_Callmap_script.sh
    cat $OUT/cfg_filtered.txt | grep "Function: " | nl -v 0 | awk '{print $1, $3, $4, $5, $6, $7, $8, $9}' > $OUT/function_list.txt
    echo "after executing bash $FUZZER/filterCFG_Callmap_script.sh"

    # 2. 改些名字
    mv $OUT/cfg_filtered.txt $OUT/cfg_${PROGRAM}.txt 
    mv $OUT/callmap_filtered.txt $OUT/callmap_${PROGRAM}.txt 
    mv $OUT/function_list.txt $OUT/${PROGRAM}_function_list.txt 

done


for each_PROGRAM in "${PROGRAMS[@]}"
do

    export PROGRAM=$each_PROGRAM

    # 1. 获取 cfg_filtered.txt, callmap_filtered.txt 和 function_list.txt
    echo "before executing convert"
    cp $OUT/cfg_${PROGRAM}.txt $OUT/cfg_filtered.txt 
    cp $OUT/callmap_${PROGRAM}.txt $OUT/callmap_filtered.txt 
    cp $OUT/${PROGRAM}_function_list.txt $OUT/function_list.txt 

    pushd $OUT > /dev/null
    ./convert
    popd > /dev/null
    mv $OUT/top.bin $OUT/${PROGRAM}_cfg.bin
    echo "after executing convert"

    cp $OUT/${PROGRAM}_cfg.bin $SHARED/${PROGRAM}_cfg.bin

    cp $OUT/cfg_${PROGRAM}.txt $SHARED/cfg_${PROGRAM}.txt 
    cp $OUT/callmap_${PROGRAM}.txt $SHARED/callmap_${PROGRAM}.txt 
    cp $OUT/${PROGRAM}_function_list.txt $SHARED/${PROGRAM}_function_list.txt 

done

cp $OUT/bbnum.txt $SHARED/bbnum.txt



