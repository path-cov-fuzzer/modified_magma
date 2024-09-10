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

# common settings
export CC="$FUZZER/repo/afl-clang-fast"
export CXX="$FUZZER/repo/afl-clang-fast++"
export AS="llvm-as"
export LD_LIBRARY_PATH=$FUZZER/repo

if [[ "$TARGET" != *"base64"* ]] && [[ "$TARGET" != *"md5sum"* ]] && [[ "$TARGET" != *"uniq"* ]] && [[ "$TARGET" != *"who"* ]]; then

    echo "branch 1"
	export LIBS="$LIBS -lc++ -lc++abi $FUZZER/repo/utils/aflpp_driver/libAFLDriver.a"

	# AFL++'s driver is compiled against libc++
	export CXXFLAGS="$CXXFLAGS -stdlib=libc++"

	export OUTAUX=$OUT
	# Build the AFL-only instrumented version
	(
	    export OUT="$OUT/afl"
	    export LDFLAGS="$LDFLAGS -L$OUT"

	    # $TARGET/build.sh 所描述的是 PUT 的构建代码，需要插桩
	    export OUT="$OUTAUX"

	    # 1. 删除 $OUT/ 里的 "残余" 内容
	    rm $OUT/bbid.txt $OUT/callmap.txt $OUT/cfg.txt $OUT/function_list.txt $OUT/bbnum.txt $OUT/convert || true

	    # 2. 设置好环境变量，进行插桩
	    export BBIDFILE="$OUT/bbid.txt"
	    export CALLMAPFILE="$OUT/callmap.txt"
	    export CFGFILE="$OUT/cfg.txt"
	    export AFL_LLVM_CALLER=1
	    export AFL_USE_ASAN=1

	    export OUT="$OUT/afl"

	    "$MAGMA/build.sh"
	    "$TARGET/build.sh"
	     
	    # 在 $FUZZER/run.sh 中实现 3. 和 4. (分别是对 cfg.txt 和 callmap.txt 过滤，以及生成 CFG binary)
	)

	# Build the CmpLog instrumented version
	 
	(
	    export OUT="$OUT/cmplog"
	    export LDFLAGS="$LDFLAGS -L$OUT"
	    # export CFLAGS="$CFLAGS -DMAGMA_DISABLE_CANARIES"

	    export AFL_LLVM_CALLER=1
	    export AFL_LLVM_CMPLOG=1

	    "$MAGMA/build.sh"
	    "$TARGET/build.sh"
	)

# NOTE: We pass $OUT directly to the target build.sh script, since the artifact
#       itself is the fuzz target. In the case of Angora, we might need to
#       replace $OUT by $OUT/fast and $OUT/track, for instance.

    bash $FUZZER/generateCFG.sh

else 

    echo "branch 2"

	(
		export LIBS=""
		export CFLAGS="-I. -I./lib -Ilib -I./lib -Isrc -I./src -O2 -Wno-error=implicit-function-declaration"
		export CXXFLAGS="-I. -I./lib -Ilib -I./lib -Isrc -I./src -O2 -Wno-error=implicit-function-declaration"
		export AFL_LLVM_CALLER=1

		"$TARGET/build.sh"
	)

	(
		export LIBS=""
		export CFLAGS="-I. -I./lib -Ilib -I./lib -Isrc -I./src -O2 -Wno-error=implicit-function-declaration"
		export CXXFLAGS="-I. -I./lib -Ilib -I./lib -Isrc -I./src -O2 -Wno-error=implicit-function-declaration"
		export AFL_LLVM_CALLER=1
	    	export AFL_LLVM_CMPLOG=1

		"$TARGET/build.sh"
	)

fi

