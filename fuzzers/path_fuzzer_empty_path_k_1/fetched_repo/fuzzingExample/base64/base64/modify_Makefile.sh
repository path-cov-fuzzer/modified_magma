echo "cyhbase64: src/base64.o src/libver.a lib/libcoreutils.a" >> coreutils-8.24-lava-safe/Makefile
echo -e "\t\$(CC)   -g -O2 -Wl,--as-needed  -o src/base64 src/base64.o src/libver.a lib/libcoreutils.a  lib/libcoreutils.a  -lacl" >> coreutils-8.24-lava-safe/Makefile

