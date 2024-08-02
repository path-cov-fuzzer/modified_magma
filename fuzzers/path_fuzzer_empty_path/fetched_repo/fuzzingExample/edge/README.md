# 样例：Edge

### 清理所有临时文件

```bash
bash cleanEverything.sh
```

---

### 编译插桩程序，生成 PUT 和 CFG binary

生成 PUT 之前，要在 path_fuzzer_with_reduction 分支下运行 cyhcompile.sh 编译安装 fuzzer

```bash
bash compilePUT.sh
```

运行完毕后，应该会看到 ./edge 可执行文件

---

### 如何运行 fuzzing ? (没有 cmplog)

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

回到 edge 目录下，运行下面的脚本生成 cmplog binary
```bash
bash compileCMPLOG.sh
```

运行完毕后，可以看到 ./edge_cmplog 二进制文件

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





