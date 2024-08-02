# !/bin/bash
# 运行之前记得切换到 path_fuzzer_with_reduction 分支 

# 设置 控制流图 binary 路径
export CFG_BIN_FILE="./complex_cfg.bin"
# 设置 libpath_reduction.so 的路径
export LD_LIBRARY_PATH="$(pwd)"
# RUST 栈回溯设置为 1
export RUST_BACKTRACE=1
afl-fuzz -i ./input_dir -o ./output_dir -m none -c ./complex_cmplog -- ./complex_PUT @@

