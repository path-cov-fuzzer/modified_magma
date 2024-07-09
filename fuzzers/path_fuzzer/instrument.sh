#!/bin/bash
set -e

##
# Pre-requirements:
# - env FUZZER: path to fuzzer work dir
# - env TARGET: path to target work dir
# - env MAGMA: path to Magma support files
# - env OUT: path to directory where artifacts are stored
# - env CFLAGS and CXXFLAGS must be set to link against Magma instrumentation
##

export CC="$FUZZER/repo/afl-clang-fast"
export CXX="$FUZZER/repo/afl-clang-fast++"
export AS="llvm-as"

export LIBS="$LIBS -lc++ -lc++abi $FUZZER/repo/utils/aflpp_driver/libAFLDriver.a"

# AFL++'s driver is compiled against libc++
export CXXFLAGS="$CXXFLAGS -stdlib=libc++"

# Build the AFL-only instrumented version
(
    export OUT="$OUT/afl"
    export LDFLAGS="$LDFLAGS -L$OUT"

    # $MAGMA/build.sh 所描述的是 MAGMA 日志协作代码，不需要在这上面插桩
    "$MAGMA/build.sh"

    # $TARGET/build.sh 所描述的是 PUT 的构建代码，需要插桩
    # 1. 删除 $OUT/ 里的 "残余" 内容
    rm $OUT/bbid.txt $OUT/callmap.txt $OUT/cfg.txt $OUT/function_list.txt $OUT/bbnum.txt $OUT/convert
    # 2. 设置好环境变量，进行插桩
    export BBIDFILE="$OUT/bbid.txt"
    export CALLMAPFILE="$OUT/callmap.txt"
    export CFGFILE="$OUT/cfg.txt"
    export LD_LIBRARY_PATH=$FUZZER
    export AFL_LLVM_CALLER=1
    "$TARGET/build.sh"
     
    # 在 $FUZZER/run.sh 中实现 3. 和 4. (分别是对 cfg.txt 和 callmap.txt 过滤，以及生成 CFG binary)
)

# !/bin/bash
# 运行之前记得切换到 path_fuzzer_with_reduction 分支





# # Build the CmpLog instrumented version
# 
# (
#     export OUT="$OUT/cmplog"
#     export LDFLAGS="$LDFLAGS -L$OUT"
#     # export CFLAGS="$CFLAGS -DMAGMA_DISABLE_CANARIES"
# 
#     export AFL_LLVM_CMPLOG=1
# 
#     "$MAGMA/build.sh"
#     "$TARGET/build.sh"
# )

# NOTE: We pass $OUT directly to the target build.sh script, since the artifact
#       itself is the fuzz target. In the case of Angora, we might need to
#       replace $OUT by $OUT/fast and $OUT/track, for instance.
