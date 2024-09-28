#ifndef STORAGE_H_
#define STORAGE_H_

#include <stddef.h>
#include <stdbool.h>

#define FILESIZE 2048
// The `2` in the denominator is for splitting the region between producer and
// consumer buffers. It has nothing to do with CANARY_TYPE_COUNT.
#define BUFFERLEN ((FILESIZE-sizeof(max_align_t))/sizeof(canary_t)/2)

typedef enum {
    REACHED = 0,
    TRIGGERED,
    CANARY_TYPE_COUNT
} canary_type_e;
typedef unsigned long long canary_storage_t;

// 从结构体来看，canary 只有名字，reached，triggered 这几个属性比较重要
typedef struct {
    char name[16];
    union {
        struct {
            canary_storage_t reached;
            canary_storage_t triggered;
        };
        canary_storage_t raw[CANARY_TYPE_COUNT];
    };
} canary_t, *pcanary_t;

// 定义 canary 结构体数组
// 定义一个新的类型，data_t，它是 BUFFRLEN 个 canary_t 类型元素的数组
typedef canary_t data_t[BUFFERLEN];

typedef struct {
    bool consumed;
    data_t producer_buffer;
    data_t consumer_buffer;
} stored_data_t, *pstored_data_t;

pcanary_t stor_get(data_t buffer, const char *name);
bool stor_put(data_t buffer, const char *name, const pcanary_t value);
size_t stor_forall(data_t buffer, void * (* func)(pcanary_t,void*), \
    void *arg, void **results, size_t length);

#endif
