#!/bin/bash
set -e

export program="md5sum"

if [[ "$AFL_LLVM_CMPLOG" != "1" ]]; then

    pushd $TARGET/repo/coreutils-8.24-lava-safe

    rm $OUT/bbid.txt $OUT/callmap.txt $OUT/cfg.txt $OUT/function_list.txt $OUT/bbnum.txt $OUT/convert || true
    make clean
    rm src/$program || true

    export BBIDFILE="$OUT/bbid.txt"
    export CALLMAPFILE="$OUT/callmap.txt"
    export CFGFILE="$OUT/cfg.txt"
    make -e cyh$program

    cat $OUT/cfg.txt | grep "BasicBlock: " | wc -l > $OUT/bbnum.txt
    # 如果是其它 TARGET，这里需要一个 filter CFG 和 callmap 的操作，这里直接拷贝改名就好
    cp $OUT/cfg.txt $OUT/cfg_filtered.txt
    cp $OUT/callmap.txt $OUT/callmap_filtered.txt
    # 生成 function_list.txt
    cat $OUT/cfg_filtered.txt | grep "Function: " | nl -v 0 | awk '{print $1, $3, $4, $5, $6, $7, $8, $9}' > $OUT/function_list.txt

    cp "src/$program" "$OUT/afl/$program"

    g++ -g $FUZZER/convert.cpp -o $OUT/convert
    pushd $OUT > /dev/null
    ./convert
    popd > /dev/null

    mv $OUT/top.bin $OUT/${program}_cfg.bin

    # 改名，防止冲突
    mv $OUT/cfg_filtered.txt $OUT/cfg_${program}.txt
    mv $OUT/callmap_filtered.txt $OUT/callmap_${program}.txt
    mv $OUT/function_list.txt $OUT/${program}_function_list.txt

    popd

else

    pushd $TARGET/repo/coreutils-8.24-lava-safe

    make clean
    rm src/$program

    make -e cyh$program
    cp "src/$program" "$OUT/cmplog/$program"

    popd

fi

