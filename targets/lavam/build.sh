#!/bin/bash
set -e

for program in base64 md5sum uniq who; do
	export WHITELIST="${program}.c"
	# Compile program
	pushd $TARGET/repo/$program/coreutils-8.24-lava-safe/
	autoreconf
	./configure LIBS="$LIBS -lacl"

	# Hook functions for uniq
	if [[ "$program" == "uniq" ]]; then
		find . -type f -name "*.h" -exec sed -i \
			's/#define\s*HAVE_GETC_UNLOCKED\s*[0-9]/#undef HAVE_GETC_UNLOCKED/' {} +
		find . -type f -name "*.h" -exec sed -i \
			's/#define\s*HAVE_DECL_GETC_UNLOCKED\s*[0-9]/#undef HAVE_GETC_UNLOCKED/' {} +
	fi

	make
	cp "src/$program" "$OUT/$program"

	popd
done
