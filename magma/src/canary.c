#ifdef __cplusplus
extern "C" {
#endif

#include "canary.h"
#include "common.h"
#include <string.h>
#include <stdio.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <stdbool.h>

static pstored_data_t data_ptr = NULL;
static int magma_faulty = 0;

// 设置 data_ptr(MAGMA存储文件) 只读 or 可读可写
static void magma_protect(int write)
{
    if (write == 0) {
        mprotect(data_ptr, FILESIZE, PROT_READ);
    } else {
        mprotect(data_ptr, FILESIZE, PROT_READ | PROT_WRITE);
    }
}

// 只能被调用一次
// 其实就是打开 MAGMA_STORAGE 宏指定的文件，随后映射进内存，再设置为只读
// 通常，MAGMA_STORAGE="$SHARED/canaries.raw"
static bool magma_init(void)
{
    static bool init_called = false;
    if (init_called) {
        // if init is called more than once, then the first call failed, so
        // we assume every following call will fail.
        return false;
    }
    init_called = true;
    const char *file = getenv("MAGMA_STORAGE");
    if (file == NULL) {
        file = NAME;
    }
    int fd = open(file, O_RDWR);
    if (fd == -1) {
        fprintf(stderr, "Monitor not running. Canaries will be disabled.\n");
        data_ptr = NULL;
        return false;
    } else {
        data_ptr = mmap(0, FILESIZE, PROT_WRITE, MAP_SHARED, fd, 0);
        close(fd);

#ifdef MAGMA_HARDEN_CANARIES
        magma_protect(0);
#endif
        return true;
    }
}

void magma_log(const char *bug, int condition)
{
#ifndef MAGMA_DISABLE_CANARIES
    // 如果初始化出错，那么报错
    if (!data_ptr && !magma_init()) {
        goto fatal;
    }

#ifdef MAGMA_HARDEN_CANARIES
    // 把 MAGMA_STORAGE 设置为只读
    magma_protect(1);
#endif

    // 从代码来看，这应该是从 producer_buffer 获取一个 canary 结构体，用来记录 bug 触发信息
    pcanary_t prod_canary   = stor_get(data_ptr->producer_buffer, bug);
    // faulty: 从下面的代码来看，magma_faulty 的意思是，这个 bug 已经被触发
    // 也就是说，当这个 bug 被 triggered 过一次后，reached 和 triggered 都会停摆，不过仅限于这次执行的 PUT
    // 如果下次执行 PUT 时，又触发了，应该还会继续统计
    prod_canary->reached   += 1         & (magma_faulty ^ 1);
    prod_canary->triggered += (bool)condition & (magma_faulty ^ 1);
    // 猜测：一开始 data_ptr->consumed 是 false
    // 估计这个 flag 是给 monitor 使用的，当上一次执行 PUT 时产生的统计信息让 monitor consume 掉后，
    // PUT 才会把自己触发 bug 的信息发送给 monitor
    // 但这里就出现了一个问题：只有在 PUT 再次触发 bug 时，这些信息才会发送给 monitor
    // 一旦上次 triggered bug 的时候，monitor 的 consumed = false，那么这些信息就发送不出去了
    if (data_ptr->consumed) {
        memcpy(data_ptr->consumer_buffer, data_ptr->producer_buffer, sizeof(data_t));
        // memory barrier
	// 这个同步点可以防止编译器优化、处理器乱序执行以及缓存一致性等问题。
        __sync_synchronize();
        data_ptr->consumed = false;
    }

    // magma_faulty 的意思是，这里的错误已经被触发了
    magma_faulty = magma_faulty | (bool)condition;

#ifdef MAGMA_HARDEN_CANARIES
    magma_protect(0);
#endif

    // 给自己发送 SIGSEGV 信号
fatal: (void)0;
#ifdef MAGMA_FATAL_CANARIES
    // send SIGSEGV to self
    static pid_t pid = 0;
    if (pid == 0) {
        pid = getpid();
    }
    kill(pid, ((bool)condition)*11);
#endif
#endif
    return;
}

#ifdef __cplusplus
}
#endif
