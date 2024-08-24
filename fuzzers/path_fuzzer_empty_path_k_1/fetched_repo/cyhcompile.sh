#!/bin/bash

bash update_path_reduction.sh

g++ -c hashcompare.cpp
ar rcs libhashcompare.a hashcompare.o
LLVM_CONFIG=llvm-config-17 LD_LIBRARY_PATH=$(pwd) CFLAGS="-I$(pwd)" LDFLAGS="-L$(pwd) -lcrypto -lhashcompare -lstdc++ -lpath_reduction" make -e source-only
sudo LLVM_CONFIG=llvm-config-17 LD_LIBRARY_PATH=$(pwd) CFLAGS="-I$(pwd)" LDFLAGS="-L$(pwd) -lcrypto -lhashcompare -lstdc++ -lpath_reduction" make -e install

