# modified_base64

### 支持单独编译 PUT base64

为了支持单独编译 PUT base64，我们对 coreutils-8.24-lava-safe/ 源码，以及一些 LAVAM 的支持代码做了一些修改

单独编译 PUT base64 的步骤如下 (系统 ubuntu20.04)：

首先运行如下命令
```bash
bash validate.sh
```

运行结束后，得到的日志的末尾大概长下面这个样子
```
Checking if buggy base64 succeeds on non-trigger input...
Success: base64 -d inputs/utmp.b64 returned 0
Validating bugs...
Validated 44 / 44 bugs
You can see validated.txt for the exit code of each buggy version.
```

意思是说，经过验证，base64 中注入的 44 个 bugs 全部顺利触发了

随后再运行如下命令，往 coreutils-8.24-lava-safe/Makefile 写入一些东西
```bash
bash modify_Makefile.sh
```

此时就可以单独编译 PUT base64 了，使用如下命令单独编译 PUT base64
```bash
cd coreutils-8.24-lava-safe/
make clean
make cyhbase64
```

这个时候的编译过程就只会编译一个可执行文件 PUT base64

编译出的 PUT base64 位于 coreutils-8.24-lava-safe/src/base64

---

### 使用 pathAFL++ 对 base64 进行插桩

<font color="red">注意：在运行下面提到的脚本之前，需要先运行一遍 "支持单独编译 PUT base64" 里的命令，否则运行下面的脚本会出错</font>

把 pathAFL++ 正确编译安装后，可以查看 coreutils-8.24-lava-safe/script_description 的内容

脚本文件名 | 描述 
--- | --- 
base_fuzzcompile_cmplog.sh  | 使用 stable 分支 pathAFL++ 编译 base64，生成 cmplog-version 和 noncmplog-version 的 PUTs，并且复制到 base64_test 的相应文件夹中
singlecompile.sh            | 使用 gcc/g++ 单独编译一个 base64 的脚本
path.sh                     | 使用 path_fuzzer_with_reduction 分支 pathAFL++ 对 base64 插桩，同时生成 cfg.txt, callmap.txt, function_list.txt

---

### 其它 PUT 做单独编译、插桩时要注意的内容

1. 拷贝 libpath_reduction.so 到编译文件夹这里

2. 拷贝所有脚本以及 backup，还有对脚本的描述文件到这里

3. 对 validate.sh 做一些特殊修改

4. port cyhscript.sh and apply it

5. 对 README 进行相应的改造

6. 拷贝 convert.cpp

---

