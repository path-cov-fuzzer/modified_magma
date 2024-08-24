#!/bin/bash
set -e

git submodule update --init path_reduction

cd path_reduction
git pull origin master
cargo build --release
cp target/release/libpath_reduction.so ../

