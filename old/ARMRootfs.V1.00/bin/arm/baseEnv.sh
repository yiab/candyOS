export PLATFORM=arm
export BINDIR=$ROOTDIR/bin
export TEMPDIR=$ROOTDIR/temp
export SRCDIR=$ROOTDIR/source
export DLDIR=$SRCDIR		# 为util.sh脚本中的兼容性使用
export INCDIR=$ROOTDIR/include
export DISTDIR=$ROOTDIR/dist
export SDKDIR=$DISTDIR/sdk
export BOOTDIR=$DISTDIR/boot
export INSTDIR=$ROOTDIR/dist/rootfs

export CROSS_FLAGS=" -O3 -march=armv7-a -mtune=cortex-a8 -mfpu=neon -mthumb-interwork -mfloat-abi=softfp -fno-tree-vectorize "
export CFLAGS=""
export CXXFLAGS=""
export LDFLAGS=""
export PATH=$ROOTDIR/crossgcc/usr/bin:$ROOTDIR/nativegcc/bin:/usr/sbin:/usr/bin:/sbin:/bin
export MY_TARGET=arm-yiab-linux-gnueabi
