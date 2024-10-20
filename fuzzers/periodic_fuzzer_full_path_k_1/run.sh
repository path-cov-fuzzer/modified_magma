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
export AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1

# 对 path_reduction 的一些设置
export PATH_REDUCTION_ON_ERROR="EMPTY_PATH"
# export PATH_REDUCTION_DEBUG=1

cp $OUT/cfg.txt $SHARED/cfg.txt

mkdir -p $SHARED/afl
mkdir -p $SHARED/cmplog
cp  $OUT/afl/$PROGRAM $SHARED/afl/$PROGRAM
cp  $OUT/cmplog/$PROGRAM $SHARED/cmplog/$PROGRAM

# ===============================================================
interval=600
output="$SHARED/findings"

"$FUZZER/repo/afl-fuzz" -i "$SHARED/corpus/$PROGRAM" -o "$SHARED/findings" \
    "${flag_cmplog[@]}" -d \
    $FUZZARGS -- "$OUT/afl/$PROGRAM" $ARGS 2>&1 &
pid=$!
elapsed_time=0

while true
do
    # 每隔 interval 执行一次循环体
    sleep $interval
    elapsed_time=$(( elapsed_time + interval ))
    echo "Running command at $(date)"
    # 如果 +cov 文件相比之前增加了，那么 kill 掉 afl-fuzz，随后删掉所有 +pat 种子，再重启
    cov_count=$(find "$output/default/queue" -type f -name '*+cov*' | wc -l)
    echo "cov_count = $cov_count"
    if [ "$cov_count" -gt 0 ]; then
        kill -9 $pid
	# 拷贝 plot_data 数据，加上时间命名
	# cp "$output/default/plot_data" "$plot_data_dir/$elapsed_time"
	# 使用 find 查找文件名包含 '+pat' 的文件并删除
        find "$output/default/queue" -type f -name '*+pat*' -exec rm -f {} \;
	# 整理 crashes 文件夹
	mv "$output/default/crashes" "$SHARED/crashes.$elapsed_time"
	# 把剩余的种子作为新一轮的起始种子
	mv "$output/default/queue" "$SHARED/corpus.$elapsed_time"
	# 把所有种子重命名一遍
	counter=1
        for file in "$SHARED/corpus.$elapsed_time"/*; do
        # 如果是文件才重命名
            if [ -f "$file" ]; then
                # 生成新的文件名
                new_name=$(printf "a%04d" "$counter")
                # 生成新的文件路径
                new_path="$SHARED/corpus.$elapsed_time/$new_name"
                # 重命名文件
                mv "$file" "$new_path"
                # 增加计数器
                counter=$((counter + 1))
            fi
        done

	# 重启命令
	mv $output "$SHARED/findings_deprecated.$elapsed_time"
	"$FUZZER/repo/afl-fuzz" -i "$SHARED/corpus.$elapsed_time" -o "$SHARED/findings" \
    		"${flag_cmplog[@]}" -d \
    		$FUZZARGS -- "$OUT/afl/$PROGRAM" $ARGS 2>&1 &
        pid=$!
    fi
done



