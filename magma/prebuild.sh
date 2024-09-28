#!/bin/bash
set -e

##
# Pre-requirements:
# - env MAGMA: path to Magma support files
# - env OUT: path to directory where artifacts are stored
# - env SHARED: path to directory shared with host (to store results)
##

# MAGMA=/magma/magma
# OUT=/magma_out
# SHARED=/magma_shared

# CC=/usr/bin/gcc
# CFLAGS="-include ${MAGMA}/src/canary.h ${CANARIES_FLAG} ${FIXES_FLAG} ${ISAN_FLAG} ${HARDEN_FLAG} -g -O0"
# LDFLAGS=-L"${OUT}" -g
# LIBS=-l:magma.o -lrt

# MAGMA_STORAGE="/magma_shared/canaries.raw"
MAGMA_STORAGE="$SHARED/canaries.raw"

# -include 选项：类似于源代码 #include 了一个头文件

# gcc -include ${MAGMA}/src/canary.h -g -O0 -D"MAGMA_STORAGE=\"/magma_shared/canaries.raw\"" -c "$MAGMA/src/storage.c" 
#     -fPIC -I "$MAGMA/src/" -o "$OUT/pre_storage.o" $LDFLAGS

set -x

# gcc '-DMAGMA_STORAGE="/magma_shared/canaries.raw"' -c /magma/magma/src/storage.c -fPIC -I /magma/magma/src/ -o /magma_out/pre_storage.o
# gcc -g -O0 '-DMAGMA_STORAGE="/magma_shared/canaries.raw"' /magma/magma/src/monitor.c /magma_out/pre_storage.o -I /magma/magma/src/ -o /magma_out/monitor
# rm /magma_out/pre_storage.o

$CC $CFLAGS -D"MAGMA_STORAGE=\"$MAGMA_STORAGE\"" -c "$MAGMA/src/storage.c" \
    -fPIC -I "$MAGMA/src/" -o "$OUT/pre_storage.o" $LDFLAGS

# gcc -include ${MAGMA}/src/canary.h -g -O0 -D"MAGMA_STORAGE=\"/magma_shared/canaries.raw\"" "$MAGMA/src/monitor.c" \
#     "$OUT/pre_storage.o" -I "$MAGMA/src/" -o "$OUT/monitor" $LDFLAGS $LIBS
$CC $CFLAGS -g -O0 -D"MAGMA_STORAGE=\"$MAGMA_STORAGE\"" "$MAGMA/src/monitor.c" \
    "$OUT/pre_storage.o" -I "$MAGMA/src/" -o "$OUT/monitor" $LDFLAGS $LIBS

rm "$OUT/pre_storage.o"

# /usr/bin/gcc '-DMAGMA_STORAGE="/magma_shared/canaries.raw"' -c /magma/magma/src/storage.c -fPIC -I /magma/magma/src/ -o /magma_out/pre_storage.o
# /usr/bin/gcc -g -O0 '-DMAGMA_STORAGE="/magma_shared/canaries.raw"' /magma/magma/src/monitor.c /magma_out/pre_storage.o -I /magma/magma/src/ -o /magma_out/monitor
# rm /magma_out/pre_storage.o

set +x
