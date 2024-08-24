#include <iostream>
#include <openssl/sha.h>
#include <unordered_map>

std::unordered_map<std::string, bool> hashMap;

extern "C" {

    bool hashcompare(unsigned char trace_hash[SHA256_DIGEST_LENGTH]);

    bool hashcompare(unsigned char trace_hash[SHA256_DIGEST_LENGTH]) {

        bool interesting = false;

        // 1. 转成字符串
        char hash[2 * SHA256_DIGEST_LENGTH + 1];
        int total_len = 0;

        for (int i = 0; i < SHA256_DIGEST_LENGTH; i++) {
          int written_bytes = snprintf((&hash[0]) + total_len, 2 * SHA256_DIGEST_LENGTH + 1 - total_len, "%02x", trace_hash[i]);
          total_len += written_bytes;
        }

        std::string hashStr(hash); // 使用char数组初始化字符串

        // std::cout << "String: " << hashStr << std::endl; // 输出字符串
        // 2. 判断是否在哈希表中
        if (hashMap.find(hashStr) == hashMap.end()) {
            // 不存在
            interesting = true;
            hashMap[hashStr] = true;
        }

        return interesting;

    }
}


