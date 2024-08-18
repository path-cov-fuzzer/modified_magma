#!/bin/bash

source $TARGET/configrc

for PROGRAM in "${PROGRAMS[@]}"
do
    # prune the seed corpus for any fault-triggering test-cases
    for seed in "$TARGET/corpus/$PROGRAM"/*; do
        echo "seed = $seed" 
        out="$("$MAGMA"/runonce.sh "$seed")"
        echo 
        code=$?

        if [ $code -ne 0 ]; then
            echo "$seed: $out"
            rm "$seed"
        fi
    done
done

