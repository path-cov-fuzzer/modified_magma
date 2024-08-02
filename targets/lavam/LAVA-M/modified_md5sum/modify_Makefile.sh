echo "cyhmd5sum: src/md5sum-md5sum.o src/libver.a lib/libcoreutils.a" >> coreutils-8.24-lava-safe/Makefile
echo -e "\t\$(CC)   -g -O2 -Wl,--as-needed  -o src/md5sum src/md5sum-md5sum.o src/libver.a lib/libcoreutils.a  lib/libcoreutils.a  -lacl" >> coreutils-8.24-lava-safe/Makefile

