# modified_md5sum

### 支持单独编译 PUT md5sum

为了支持单独编译 PUT md5sum，我们对 coreutils-8.24-lava-safe/ 源码，以及一些 LAVAM 的支持代码做了一些修改

单独编译 PUT md5sum 的步骤如下 (系统 ubuntu20.04)：

首先运行如下命令
```bash
bash validate.sh
```

运行结束后，得到的日志的末尾大概长下面这个样子
```
Checking if buggy md5sum succeeds on non-trigger input...
Success: md5sum -c inputs/bin-ls-md5s returned 1
Validating bugs...
Validated 57 / 57 bugs
You can see validated.txt for the exit code of each buggy version.
```

意思是说，经过验证，md5sum 中注入的 44 个 bugs 全部顺利触发了

随后再运行如下命令，往 coreutils-8.24-lava-safe/Makefile 写入一些东西
```bash
bash modify_Makefile.sh
```

此时就可以单独编译 PUT md5sum 了，使用如下命令单独编译 PUT md5sum
```bash
cd coreutils-8.24-lava-safe/
make clean
make cyhmd5sum
```

这个时候的编译过程就只会编译一个可执行文件 PUT md5sum

编译出的 PUT md5sum 位于 coreutils-8.24-lava-safe/src/md5sum

---

### 使用 pathAFL++ 对 md5sum 进行插桩

<font color="red">注意：在运行下面提到的脚本之前，需要先运行一遍 "支持单独编译 PUT md5sum" 里的命令，否则运行下面的脚本会出错</font>

把 pathAFL++ 正确编译安装后，可以查看 coreutils-8.24-lava-safe/script_description 的内容

脚本文件名 | 描述 
--- | --- 
base_fuzzcompile_cmplog.sh  | 使用原生 AFL++ (不启用 LLVM) 编译 md5sum，生成 cmplog-version 和 noncmplog-version 的 PUTs，并且复制到 md5sum_test 的相应文件夹中
cfgcompile.sh               | 使用 最新的 一体式 AFL++ 生成 md5sum CFG
cfgcompile.sh.backup        | 使用 CFG-AFL++ 编译 md5sum，生成 md5sum 的 CFG (旧版本的备份)
cyhscript.sh                | 对 coreutils 代码进行一些细微修改，让它们能够适配 ubuntu20.04
pathfuzzcompile.sh          | 使用 最新的 一体式 AFL++ 进行插桩
pathfuzzcompile.sh.backup   | 使用 path-AFL++ 编译 md5sum，生成可供 path-fuzzer fuzzing 的 md5sum PUT (旧版本的备份)
singlecompile.sh            | 使用 gcc/g++ 单独编译一个 md5sum 的脚本
cfgcompile_llvm_ir.sh       | 生成 CFG 的同时，生成各个文件的 LLVM IR

如果想要获得经过插桩的 md5sum，在 coreutils-8.24-lava-safe/ 文件夹下先后运行下面两个脚本
 - cfgcompile.sh
 - pathfuzzcompile.sh

---

### 其它 PUT 做单独编译、插桩时要注意的内容

1. 拷贝 libpath_reduction.so 到编译文件夹这里

2. 拷贝所有脚本以及 backup，还有对脚本的描述文件到这里

3. 对 validate.sh 做一些特殊修改

4. port cyhscript.sh and apply it

5. 对 README 进行相应的改造

6. 拷贝 convert.cpp

---

