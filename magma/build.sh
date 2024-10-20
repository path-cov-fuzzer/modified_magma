#!/bin/bash
set -e

##
# Pre-requirements:
# - env MAGMA: path to Magma support files
# - env OUT: path to directory where artifacts are stored
# - env SHARED: path to directory shared with host (to store results)
##

set -x
MAGMA_STORAGE="$SHARED/canaries.raw"

$CC $CFLAGS -D"MAGMA_STORAGE=\"$MAGMA_STORAGE\"" -c "$MAGMA/src/canary.c" \
    -fPIC -I "$MAGMA/src/" -o "$OUT/canary.o" $LDFLAGS

$CC $CFLAGS -D"MAGMA_STORAGE=\"$MAGMA_STORAGE\"" -c "$MAGMA/src/storage.c" \
    -fPIC -I "$MAGMA/src/" -o "$OUT/storage.o" $LDFLAGS

$LD -r "$OUT/canary.o" "$OUT/storage.o" -o "$OUT/magma.o"
rm "$OUT/canary.o" "$OUT/storage.o"
set +x

