# 样例：Base64

### 首先初始化所有子模块

```bash
git submodule update --init AFL++
git submodule update --init base64
```

### 编译插桩程序，生成 PUT 和 CFG binary

在运行下面的命令之前，要在 path_fuzzer_with_reduction 分支下运行 cyhcompile.sh 编译安装 pathAFL++

```bash
cd base64
bash validate.sh (等待直到出现 "Validated 44 / 44 bugs" 字样)
bash modify_Makefile.sh
cd coreutils-8.24-lava-safe/
bash path.sh
cp src/base64 ../../base64_PUT
cp base64_cfg.bin ../../
```

运行完这一套后，回到当前目录，我们已经拥有了 base64 的 PUT 和 CFG binary    

---

### 如何运行 fuzzing ? (没有 cmplog) 

在运行下面的命令之前，要在 path_fuzzer_with_reduction 分支下运行 cyhcompile.sh 编译安装 pathAFL++

```bash
bash runFuzzing.sh
```

output_dir 文件夹下存放着 seeds 和 crashes 结果 

---

### 如何生成 cmplog binary ?

cmplog binary 需要使用原生的 AFL++ 生成，首先更新子模块，然后使用子模块编译安装 AFL++
```bash
git submodule update --init AFL++
cd AFL++
LLVM_CONFIG=llvm-config-17 make -e source-only
sudo LLVM_CONFIG=llvm-config-17 make -e install
```

回到 base64 目录下，运行下面的命令生成 cmplog binary
```bash
cd base64
bash validate.sh (等待直到出现 "Validated 44 / 44 bugs" 字样)
bash modify_Makefile.sh (如果之前运行过一次则不需要)
cd coreutils-8.24-lava-safe/
bash base_fuzzcompile_cmplog.sh
cp src/base64 ../../base64_cmplog
```

运行完毕后，回到当前目录，我们已经拥有了 base64 的 cmplog binary

---

### 如何运行 fuzzing ? (有 cmplog) 

需要先运行这一节 “编译插桩程序，生成 PUT 和 CFG binary” 生成 PUT 可执行文件 和 CFG binary

同时还要运行这一节 “如何生成 cmplog binary ?” 生成 cmplog binary

注意：获得 cmplog 之后，还要再次切换回 path_fuzzer_with_reduction 分支进行编译安装，因为我们运行的 afl-fuzz 必须是 path_fuzzer_with_reduction 分支下的

```bash
bash runFuzzing_cmplog.sh
```

output_dir 文件夹下存放着 seeds 和 crashes 结果 

---





