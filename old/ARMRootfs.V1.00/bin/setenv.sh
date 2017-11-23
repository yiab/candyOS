#!/bin/sh
clear

ROOTDIR=`(cd ".."; /bin/pwd)`

export NATIVETOOL=$ROOTDIR/nativegcc
export NATIVE_CFLAGS=" -O3 -msse4 -msse4.1 -msse3 -msse2 -mmmx -mfpmath=sse -march=core2 -m32 -pipe -fomit-frame-pointer"
export NATIVE_CXXFLAGS=$NATIVE_CFLAGS" -funroll-loops"
export MY_TARGET="arm-yiab-linux-gnueabi"
export CROSSCFLAGS="-O3 -march=armv7-a -mtune=cortex-a8 -mfpu=neon -mfloat-abi=softfp -mthumb-interwork -fno-tree-vectorize"
export CROSSTOOL=$ROOTDIR/crossgcc
export PATH=$CROSSTOOL/usr/bin:$NATIVETOOL/bin:/usr/bin:/bin
#export LD_LIBRARY_PATH=$NATIVETOOL/lib

echo "PATH=$PATH"
