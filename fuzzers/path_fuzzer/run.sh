#!/bin/bash
set -e

##
# Pre-requirements:
# - env FUZZER: path to fuzzer work dir
# - env TARGET: path to target work dir
# - env OUT: path to directory where artifacts are stored
# - env SHARED: path to directory shared with host (to store results)
# - env PROGRAM: name of program to run (should be found in $OUT)
# - env ARGS: extra arguments to pass to the program
# - env FUZZARGS: extra arguments to pass to the fuzzer
##

# 3. 过滤掉 cfg.txt 和 callmap.txt 的东西，以及生成一些别的文本
bash $FUZZER/filterCFG_Callmap_script.sh
cat $OUT/cfg.txt | grep "BasicBlock: " | wc -l > $OUT/bbnum.txt
cat $OUT/cfg_filtered.txt | grep "Function: " | nl -v 0 | awk '{print $1, $3, $4, $5, $6, $7, $8, $9}' > $OUT/function_list.txt

# 4. 使用之前构建的东西，生成 CFG binary
g++ $FUZZER/convert.cpp -o $OUT/convert
$OUT/convert
mv $OUT/top.bin $OUT/${PROGRAM}_cfg.bin

# run.sh 本来的内容
if nm "$OUT/afl/$PROGRAM" | grep -E '^[0-9a-f]+\s+[Ww]\s+main$'; then
    ARGS="-"
fi

mkdir -p "$SHARED/findings"

flag_cmplog=(-m none -c "$OUT/cmplog/$PROGRAM")

export AFL_SKIP_CPUFREQ=1
export AFL_NO_AFFINITY=1
export AFL_NO_UI=1
export AFL_MAP_SIZE=256000
# export AFL_DRIVER_DONT_DEFER=1

# 针对 path_fuzzer 的一些环境变量设置
export CFG_BIN_FILE="$OUT/${PROGRAM}_cfg.bin"
export LD_LIBRARY_PATH=$FUZZER/repo
export AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1

set -x

"$FUZZER/repo/afl-fuzz" -i "$TARGET/corpus/$PROGRAM" -o "$SHARED/findings" \
    "${flag_cmplog[@]}" -d \
    $FUZZARGS -- "$OUT/afl/$PROGRAM" $ARGS 2>&1

set +x

