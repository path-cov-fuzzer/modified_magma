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
# - env POLL: time (in seconds) to sleep between polls
# - env TIMEOUT: time to run the campaign
# - env MAGMA: path to Magma support files
# + env LOGSIZE: size (in bytes) of log file to generate (default: 1 MiB)
##

# CYHADDED: 生成 CFG binary
echo "============= FUZZER = $FUZZER"
if [[ "$FUZZER" != *"aflplusplus"* ]]; then
	echo "branch 1"
	# if [[ "$TARGET" != *"base64"* ]] && [[ "$TARGET" != *"md5sum"* ]] && [[ "$TARGET" != *"uniq"* ]] && [[ "$TARGET" != *"who"* ]]; then
	# 	source $FUZZER/generateCFG.sh
	# else
    cp $OUT/cfg_${PROGRAM}.txt $SHARED/cfg_${PROGRAM}.txt
    cp $OUT/callmap_${PROGRAM}.txt $SHARED/callmap_${PROGRAM}.txt
    cp $OUT/${PROGRAM}_function_list.txt $SHARED/${PROGRAM}_function_list.txt
    cp $OUT/${PROGRAM}_cfg.bin $SHARED/${PROGRAM}_cfg.bin
    cp $OUT/bbnum.txt $SHARED/bbnum.txt
    cp $OUT/cfg.txt $SHARED/cfg.txt
	# fi
fi

# CYHADDED: 打印一些变量 ------------------ start
# 设置 CFLAGS, CXXFLAGS, LD, LDFLAGS, SHARED, LIBS
echo "CFLAGS = $CFLAGS"
echo "CXXFLAGS = $CXXFLAGS"
echo "LD = $LD"
echo "LDFLAGS = $LDFLAGS"
echo "SHARED = $SHARED"
echo "LIBS = $LIBS"
# CYHADDED: 打印一些变量 ------------------ end

# CYHADDED: 打印另外一些变量 ------------------ start
echo "SHARED = $SHARED"
echo "TARGET = $TARGET"
echo "PROGRAM = $PROGRAM"
echo "MAGMA = $MAGMA"
echo "POLL = $POLL"
echo "OUT = $OUT"
echo "TIMEOUT = $TIMEOUT"
echo "FUZZER = $FUZZER"
echo "LOGSIZE = $LOGSIZE"
# CYHADDED: 打印另外一些变量 ------------------ end

# set -x
# 
# if [ "$FUZZER" == "path_fuzzer" ]; then
# 
# # 3. 过滤掉 cfg.txt 和 callmap.txt 的东西，以及生成一些别的文本
# echo "3 start"
# bash $FUZZER/filterCFG_Callmap_script.sh
# cat $OUT/cfg.txt | grep "BasicBlock: " | wc -l > $OUT/bbnum.txt
# cat $OUT/cfg_filtered.txt | grep "Function: " | nl -v 0 | awk '{print $1, $3, $4, $5, $6, $7, $8, $9}' > $OUT/function_list.txt
# 
# # 4. 使用之前构建的东西，生成 CFG binary
# echo "4 start"
# g++ $FUZZER/convert.cpp -o $OUT/convert
# $OUT/convert 
# mv $OUT/top.bin $OUT/${PROGRAM}_cfg.bin
# 
# fi
# 
# set +x

# set default max log size to 1 MiB
LOGSIZE=${LOGSIZE:-$[1 << 20]}

export MONITOR="$SHARED/monitor"
mkdir -p "$MONITOR"

# change working directory to somewhere accessible by the fuzzer and target
cd "$SHARED"

set +e

# prune the seed corpus for any fault-triggering test-cases
for seed in "$TARGET/corpus/$PROGRAM"/*; do
    out="$("$MAGMA"/runonce.sh "$seed")"
    code=$?

    if [ $code -ne 0 ]; then
        echo "$seed: $out"
        rm "$seed"
    fi
done

set -e

shopt -s nullglob
seeds=("$1"/*)
shopt -u nullglob
if [ ${#seeds[@]} -eq 0 ]; then
    echo "No seeds remaining! Campaign will not be launched."
    exit 1
fi


# launch the fuzzer in parallel with the monitor
rm -f "$MONITOR/tmp"*
# CYHADDED: 只添加一个 counter = 0
counter=0
# polls=("$MONITOR"/*)
# if [ ${#polls[@]} -eq 0 ]; then
#     counter=0
# else
#     timestamps=($(sort -n < <(basename -a "${polls[@]}")))
#     last=${timestamps[-1]}
#     echo "last ================ start" 
#     echo "last = $last" 
#     echo "last ================ end" 
#     echo "POLL ================ start" 
#     echo "POLL = $POLL" 
#     echo "POLL ================ end" 
#     counter=$(( last + POLL ))
# fi

while true; do
    "$OUT/monitor" --dump row > "$MONITOR/tmp"
    echo "counter ================ start" 
    echo "counter = $counter" 
    echo "counter ================ end" 
    if [ $? -eq 0 ]; then
        echo "yes, this is 0, reserve"
        mv "$MONITOR/tmp" "$MONITOR/$counter"
    else
        echo "no, this is not 0, delete"
        rm "$MONITOR/tmp"
    fi
    counter=$(( counter + POLL ))
    sleep $POLL
done &

echo "Campaign launched at $(date '+%F %R')"

timeout $TIMEOUT "$FUZZER/run.sh" | \
    multilog n2 s$LOGSIZE "$SHARED/log"

if [ -f "$SHARED/log/current" ]; then
    cat "$SHARED/log/current"
fi

echo "Campaign terminated at $(date '+%F %R')"

kill $(jobs -p)
