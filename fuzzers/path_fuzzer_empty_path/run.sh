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

# CYHADDED: 打印一些变量 ------------------ start
# 设置 CFLAGS, CXXFLAGS, LD, LDFLAGS, SHARED, LIBS
echo "CFLAGS = $CFLAGS"
echo "CXXFLAGS = $CXXFLAGS"
echo "LD = $LD"
echo "LDFLAGS = $LDFLAGS"
echo "SHARED = $SHARED"
echo "LIBS = $LIBS"
# CYHADDED: 打印一些变量 ------------------ end

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
export CFG_BIN_FILE="$SHARED/${PROGRAM}_cfg.bin"
export LD_LIBRARY_PATH=$FUZZER/repo
# export AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1

cp $OUT/cfg.txt $SHARED/cfg.txt

set -x

cp -r $TARGET/corpus/ $SHARED/corpus
mkdir -p $SHARED/afl
mkdir -p $SHARED/cmplog
cp  $OUT/afl/$PROGRAM $SHARED/afl/$PROGRAM
cp  $OUT/cmplog/$PROGRAM $SHARED/cmplog/$PROGRAM

"$FUZZER/repo/afl-fuzz" -i "$TARGET/corpus/$PROGRAM" -o "$SHARED/findings" \
    "${flag_cmplog[@]}" -d \
    $FUZZARGS -- "$OUT/afl/$PROGRAM" $ARGS 2>&1

set +x

