# pathAFL++ (pathAFLplusplus)

### 编译安装 pathAFL++ 的方法

首先切换到 path_fuzzer_with_reduction 分支

```bash
bash cyhcompile.sh
```

---

### 一些简单的样例

进入到 fuzzingExample 文件夹下，可以看到两个子目录，如下
```
edge/ complex/ base64/
```

edge/ 是一个单文件例子，complex/ 是一个稍微复杂点的例子，还有 base64 是一个真正的 PUT

关于如何对这两者进行 fuzzing，可以进入它们文件夹下看各自的 README

edge/ 例子不包含 CFG 过滤

complex/ 例子包含 CFG 过滤

base64/ 例子不包含 CFG 过滤

---



