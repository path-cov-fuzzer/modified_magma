# !/bin/bash
# 运行之前记得切换到 path_fuzzer_with_reduction 分支 

# 更新 libpath_reduction.so
bash update_path_reduction.sh

# 设置 控制流图 binary 路径
export CFG_BIN_FILE="$(pwd)/base64_cfg.bin"
# 设置 libpath_reduction.so 的路径
export AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1
LD_LIBRARY_PATH=$(pwd) afl-fuzz -i input_dir -o output_dir -m none -- ./base64_PUT -d @@

