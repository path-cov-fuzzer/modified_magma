#!/bin/bash

# 定义文件名数组
puts=(
    "base64_base64"
    "md5sum_md5sum"
    "uniq_uniq"
    "who_who"
    "php_exif"
    "libpng_libpng_read_fuzzer"
    "libsndfile_sndfile_fuzzer"
    "lua_lua"
    "sqlite3_sqlite3_fuzz"
    "libtiff_tiffcp"
    "libtiff_tiff_read_rgba_fuzzer"
    "libxml2_libxml2_xml_read_memory_fuzzer"
    "libxml2_xmllint"
    "openssl_client"
    "openssl_server"
    "openssl_x509"
)

# 遍历文件数组并逐个 cat
for put in "${puts[@]}"; do
    echo "$put"
    file="checkirregular_${put}_0_container.log"
    unique_count=$(cat $file | grep "unique_count" | tail -n 1 | awk '{ print $3 }')
    # 去掉所有空白字符
    unique_count="${unique_count//[[:space:]]/}"
    unique_count=$((unique_count + 1))
    echo "path_reduction_count = $unique_count"
    invalid_count=$(cat $file | grep "invalid" | wc -l)
    echo "invalid_count = $invalid_count"
    # 计算百分比 (part / total) * 100，并使用 bc 保留两位小数
    percentage=$(echo "scale=4; $invalid_count / $unique_count * 100" | bc)
    echo "Percentage: $percentage%"
    echo # 输出文件后加空行
done


