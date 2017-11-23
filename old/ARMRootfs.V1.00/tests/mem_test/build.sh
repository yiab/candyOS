#!/bin/sh

export PATH=/usr/local/arm/arm-yiab-linux-gnueabi/usr/bin:$PATH
export FLAGS="-march=armv7-a -mtune=cortex-a8 -mfpu=neon -mfloat-abi=softfp -fno-tree-vectorize"
export GCC="arm-yiab-linux-gnueabi-gcc"

rm memtest*
$GCC -o memtest_0 -O0 mem_test_memcpy.c $FLAGS
$GCC -o memtest_s -Os mem_test_memcpy.c $FLAGS
$GCC -o memtest_2 -O2 mem_test_memcpy.c $FLAGS
$GCC -o memtest_3 -O3 mem_test_memcpy.c $FLAGS
$GCC -o memtest_D mem_test_memcpy.c $FLAGS

cp memtest_* /home/baiyun/beagleboard/dist-arm
