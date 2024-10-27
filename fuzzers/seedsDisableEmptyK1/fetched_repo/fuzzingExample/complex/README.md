# 样例：Complex

### 清理所有临时文件

```bash
make clean
```

---

### 获取 path_reduction 动态库

```bash
bash update_path_reduction.sh
```

最后得到的是 libpath_reduction.so 动态库

---

### 编译所有可执行文件 (使用 gcc，不插桩)

```bash
make
```

运行 make 后会生成 3 个可执行文件，分别是:
- complex 
- test2
- test3

---

### 如何运行使用 path_fuzzer 进行插桩？ 

运行之前记得切换到 path_fuzzer_with_reduction 分支 

```bash
bash path.sh
```

path.sh 的代码包括四个部分:
- 1.获取最新的 libpath_reduction.so
- 2.插桩，生成 cfg.txt 和 callmap.txt
- 3.从 cfg.txt 和 callmap.txt 中过滤掉一些函数的 CFG，生成 cfg_filtered.txt 和 callmap_filtered.txt
- 4.把 cfg_filtered.txt 和 callmap_filtered.txt 转化为 CFG binary

---

### 如何运行 fuzzing ? (无 cmplog)

首先运行这一节 “如何运行使用 path_fuzzer 进行插桩？ ”

运行下面命令之前记得切换到 path_fuzzer_with_reduction 分支，并且编译安装

```bash
bash runFuzzing.sh
```

output_dir 文件夹下存放着 seeds 和 crashes 结果 

---

### 如何运行使用 AFL++ (stable branch) 进行生成 cmplog binary ?

首先编译安装 AFL++ (stable branch)
```bash
cd AFL++
LLVM_CONFIG=llvm-config-17 make -e source-only
sudo LLVM_CONFIG=llvm-config-17 make -e install
```

随后再生成 cmplog binary
```bash
(如果之前使用 path_fuzzer_with_reduction 的 pathAFL++ 进行过插桩的话，运行 make clean)
make clean
bash cmplog.sh
```

生成的二进制文件叫做 complex_cmplog

---

### 如何运行 fuzzing ? (有 cmplog)

运行下面命令之前记得切换到 path_fuzzer_with_reduction 分支，并且编译安装

```bash
bash runFuzzing_cmplog.sh
```

output_dir 文件夹下存放着 seeds 和 crashes 结果 

---
