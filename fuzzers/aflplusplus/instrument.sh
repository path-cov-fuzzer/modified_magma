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

if [[ "$TARGET" != *"base64"* ]] && [[ "$TARGET" != *"md5sum"* ]] && [[ "$TARGET" != *"uniq"* ]] && [[ "$TARGET" != *"who"* ]]; then

    echo "branch 1"

    export LIBS="$LIBS -lc++ -lc++abi $FUZZER/repo/utils/aflpp_driver/libAFLDriver.a"

    export CXXFLAGS="$CXXFLAGS -stdlib=libc++"

    # Build the AFL-only instrumented version
    (
        export OUT="$OUT/afl"
        export LDFLAGS="$LDFLAGS -L$OUT"
	export AFL_LLVM_CALLER=1

	export CFLAGS="$CFLAGS -fsanitize=address"
	export CXXFLAGS="$CXXFLAGS -fsanitize=address"
	export LDFLAGS="$LDFLAGS -fsanitize=address"

        "$MAGMA/build.sh"
        "$TARGET/build.sh"
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

else

    echo "branch 2"

	(
		export LIBS=""
		export CFLAGS="-I. -I./lib -Ilib -I./lib -Isrc -I./src -O2 -Wno-error=implicit-function-declaration"
		export CXXFLAGS="-I. -I./lib -Ilib -I./lib -Isrc -I./src -O2 -Wno-error=implicit-function-declaration"
	        export AFL_LLVM_CALLER=1

		export CXXFLAGS="$CXXFLAGS -fsanitize=address"
		export CFLAGS="$CFLAGS -fsanitize=address"
		export LDFLAGS="$LDFLAGS -fsanitize=address"

		"$TARGET/build.sh"
	)

	(
		export LIBS=""
		export CFLAGS="-I. -I./lib -Ilib -I./lib -Isrc -I./src -O2 -Wno-error=implicit-function-declaration"
		export CXXFLAGS="-I. -I./lib -Ilib -I./lib -Isrc -I./src -O2 -Wno-error=implicit-function-declaration"
                export AFL_LLVM_CMPLOG=1
	        export AFL_LLVM_CALLER=1

		"$TARGET/build.sh"
	)

fi



