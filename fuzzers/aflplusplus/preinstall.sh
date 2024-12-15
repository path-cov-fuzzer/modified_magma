#!/bin/bash
set -e

apt-get update && \
    apt-get install -y make clang-11 llvm-config-11-dev libc++-11-dev libc++abi-11-dev \
        build-essential git wget gcc-11-plugin-dev python-dev python3-dev linux-tools-common linux-tools-generic linux-cloud-tools-generic

update-alternatives \
  --install /usr/lib/llvm              llvm             /usr/lib/llvm-11  20 \
  --slave   /usr/bin/llvm-config       llvm-config      /usr/bin/llvm-config-11  \
    --slave   /usr/bin/llvm-ar           llvm-ar          /usr/bin/llvm-ar-11 \
    --slave   /usr/bin/llvm-as           llvm-as          /usr/bin/llvm-as-11 \
    --slave   /usr/bin/llvm-bcanalyzer   llvm-bcanalyzer  /usr/bin/llvm-bcanalyzer-11 \
    --slave   /usr/bin/llvm-c-test       llvm-c-test      /usr/bin/llvm-c-test-11 \
    --slave   /usr/bin/llvm-cov          llvm-cov         /usr/bin/llvm-cov-11 \
    --slave   /usr/bin/llvm-diff         llvm-diff        /usr/bin/llvm-diff-11 \
    --slave   /usr/bin/llvm-dis          llvm-dis         /usr/bin/llvm-dis-11 \
    --slave   /usr/bin/llvm-dwarfdump    llvm-dwarfdump   /usr/bin/llvm-dwarfdump-11 \
    --slave   /usr/bin/llvm-extract      llvm-extract     /usr/bin/llvm-extract-11 \
    --slave   /usr/bin/llvm-link         llvm-link        /usr/bin/llvm-link-11 \
    --slave   /usr/bin/llvm-mc           llvm-mc          /usr/bin/llvm-mc-11 \
    --slave   /usr/bin/llvm-nm           llvm-nm          /usr/bin/llvm-nm-11 \
    --slave   /usr/bin/llvm-objdump      llvm-objdump     /usr/bin/llvm-objdump-11 \
    --slave   /usr/bin/llvm-ranlib       llvm-ranlib      /usr/bin/llvm-ranlib-11 \
    --slave   /usr/bin/llvm-readobj      llvm-readobj     /usr/bin/llvm-readobj-11 \
    --slave   /usr/bin/llvm-rtdyld       llvm-rtdyld      /usr/bin/llvm-rtdyld-11 \
    --slave   /usr/bin/llvm-size         llvm-size        /usr/bin/llvm-size-11 \
    --slave   /usr/bin/llvm-stress       llvm-stress      /usr/bin/llvm-stress-11 \
    --slave   /usr/bin/llvm-symbolizer   llvm-symbolizer  /usr/bin/llvm-symbolizer-11 \
    --slave   /usr/bin/llvm-tblgen       llvm-tblgen      /usr/bin/llvm-tblgen-11

update-alternatives \
  --install /usr/bin/clang                 clang                  /usr/bin/clang-11     20 \
  --slave   /usr/bin/clang++               clang++                /usr/bin/clang++-11 \
  --slave   /usr/bin/clang-cpp             clang-cpp              /usr/bin/clang-cpp-11
