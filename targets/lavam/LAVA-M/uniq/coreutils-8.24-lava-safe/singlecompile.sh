#!/bin/bash

make clean
rm src/base64
export CFLAGS="-I. -I./lib -Ilib -I./lib -Isrc -I./src -O2"
export CXXFLAGS="-I. -I./lib -Ilib -I./lib -Isrc -I./src -O2"
export CC="gcc"
export CXX="g++"
make -e cyhbase64



