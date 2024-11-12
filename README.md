# 运行 Fuzzing 实验

### 快速运行

```bash
cd <root-dir>
cd tools/captain
bash run.sh
```
即可运行

---

### 如何对运行环境进行配置？

```bash
cd <root-dir>
cd tools/captain
vim captainrc
```

可以看到配置

captainrc 这个文件很长，内容很多，但是关键参数就下面几个
```
# This file contains the configuration for the run.sh script. It follows the
# Bash syntax and is sourced by the script to access the variables. Variables
# are mandatory unless marked with [brackets].

###
## Configuration parameters
###

# WORKDIR: 存放 fuzzing 结果的文件夹路径
# WORKDIR: path to directory where shared volumes will be created
WORKDIR=./workdir

# REPEAT: 每个 fuzzer-target pair 重复多少次实验
# REPEAT: number of campaigns to run per program (per fuzzer)
REPEAT=2

...

# TIMEOUT: 每个实验运行多长时间
# [TIMEOUT]: time to run each campaign. This variable supports one-letter
# suffixes to indicate duration (s: seconds, m: minutes, h: hours, d: days)
# (default: 1m)
TIMEOUT=5m

# POLL: 这个是用于 magma PUT 的 monitor 运行参数，不用管
# [POLL]: time (in seconds) between polls (default: 5)
POLL=5

# CACHE_ON_DISK 这个参数决定把 fuzzing 结果暂时放在内存上，还是直接放磁盘上。
# 内存容量够的话，就不设置
# [CACHE_ON_DISK]: if set, the cache workdir is mounted on disk instead of
# in-memory (default: unset)
# CACHE_ON_DISK=1

...

###
## Campaigns to run
###

# FUZZERS: an array of fuzzer names (from magma/fuzzers/*) to evaluate

# 参与实验的 fuzzers
FUZZERS=(aflplusplus nopathreduction)
# 每个 fuzzer 要运行的 TARGET
aflplusplus_TARGETS=(base64 md5sum uniq who php libpng lua sqlite3 libsndfile libtiff libxml2 openssl)
nopathreduction_TARGETS=(base64 md5sum uniq who php libpng lua sqlite3 libsndfile libtiff libxml2 openssl)

...

```

<font color="red">FUZZERS 和 aflplusplus_TARGETS 这些环境变量尽量不要修改，因为我不一定有上传相应的 docker images。其它的修改问题不大</font>




