#include "storage.h"
#include <stdlib.h>
#include <stdio.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <assert.h>

pcanary_t stor_get(data_t buffer, const char *name)
{
    pcanary_t cur;
    size_t i;
    // 先在 producer_buffer 里寻找名为 bug_name 的 canary_t 结构体，若找到，则返回
    // 每个 bug 都有一个 canary_t 
    for (i = 0, cur = buffer; \
        i < BUFFERLEN && *cur->name != '\0'; \
        ++i, ++cur) {
        if (strncmp(name, cur->name, sizeof(cur->name)) == 0) {
            return cur;
        }
    }

    // 如果当前 bug 在 producer_buffer 里没有 canary_t，那么创建一个
    // 这里好像并不担心 cur 指针数组越界，我们加个 assert 吧
    assert(i < BUFFERLEN);
    // Bug record does not exist, create it
    strncpy(cur->name, name, sizeof(cur->name));
    cur->reached = 0;
    cur->triggered = 0;
    return cur;
}

bool stor_put(data_t buffer, const char *name, const pcanary_t value)
{
    pcanary_t cur;
    size_t i;
    for (i = 0, cur = buffer; \
            i < BUFFERLEN && *cur->name != '\0'; \
            ++i, ++cur) {
        if (strncmp(name, cur->name, sizeof(cur->name)) == 0) {
            break;
        }
    }
    if (i >= BUFFERLEN) {
        return false;
    }
    memcpy(cur, value, sizeof(canary_t));
    return true;
}

size_t stor_forall(data_t buffer, void * (* func)(pcanary_t,void *), \
    void *arg, void **results, size_t length)
{
    pcanary_t cur;
    size_t i;
    for (i = 0, cur = buffer; \
            i < BUFFERLEN && *cur->name != '\0'; \
            ++i, ++cur) {
        if (results == NULL) {
            func(cur, arg);
        } else if (i < length) {
            results[i] = func(cur, arg);
        } else {
            break;
        }
    }
    return i;
}
