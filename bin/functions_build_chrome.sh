#!/bin/sh

##############################
# 编译 libnss
# Download: https://ftp.mozilla.org/pub/security/nss/releases/NSS_3_34_1_RTM/src/
# Reference: https://developer.mozilla.org/en-US/docs/Mozilla/Projects/NSS/NSS_Sources_Building_Testing
NSS_VERSION=3.34.1
LIBNSSFILE=nss-${NSS_VERSION}
function generate_nss_pc()
{
    cd $TEMPDIR/dist
    
    mkdir -p usr/lib/pkgconfig usr/include/nss
    mv usr/include/*.h usr/include/nss
    rm -rf usr/share
    cat << MY_EOF > usr/lib/pkgconfig/nss.pc
prefix=/usr
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include/nss

Name: NSS
Description: Mozilla Network Security Services
Version: ${NSS_VERSION}
Requires: nspr
Libs: -L\${libdir} -lnss3 -lnssutil3 -lsmime3 -lssl3
Cflags: -I${includedir}
MY_EOF
}

generate_script  libnss     $LIBNSSFILE     \
    '--script=CC=$MY_TARGET-gcc CCC=$MY_TARGET-g++ CXX=$MY_TARGET-g++ OS_CFLAGS="-pipe -ffunction-sections -fdata-sections -DHAVE_STRERROR -fPIC"  make ARCHFLAG="" OS_ARCH=Linux OS_TARGET=Linux CROSS_COMPILE=1 USE_PTHREAD=1 CPU_ARCH=arm OS_TEST=arm NATIVE_CC=gcc IMPL_STRATEGY=_PTH USE_SYSTEM_ZLIB=1 ZLIB_LIBS=" -lz " NSS_USE_GCC=1 BUILD_OPT=1 NS_USE_GCC=1  NSS_ENABLE_ECC=1 CHECKLOC='' NSPR_INCLUDE_DIR="=/usr/include/nspr " NSS_DISABLE_GTESTS=1 NSS_USE_SYSTEM_SQLITE=1 MOZILLA_CLIENT=1 NSDISTMODE=copy SOURCE_PREFIX=`pwd`/out SOURCE_RELEASE_PREFIX=$TEMPDIR/dist/usr SOURCE_RELEASE_BIN_DIR=bin/ SOURCE_RELEASE_LIB_DIR=lib/ RELEASE_TREE=$TEMPDIR/dist/usr/share all release'  \
    '--script=generate_nss_pc'  \
    '--deploy-rootfs=/usr/lib -/usr/lib/*.a -/usr/lib/*.la -/usr/lib/pkgconfig' \
    '--deploy-sdk=/usr -/usr/lib/*.a'   \
    '--depends=libnspr sqlite libz'

# make后面是不允许脚本修改的，make 前面是可以修改的
# NSS_BUILD_UTIL_ONLY=1 只编译工具
# NSS_USE_SYSTEM_SQLITE=1 MOZILLA_CLIENT=1 使用系统的sqlite
# NSDISTMODE=copy 复制模式。否则都是链接，一旦原件删除则失效

##############################
# 编译 libnspr, libnss需要用到， 两个包也是一起下载的
# Download: https://ftp.mozilla.org/pub/security/nss/releases/NSS_3_34_1_RTM/src/
# Reference: https://developer.mozilla.org/en-US/docs/Mozilla/Projects/NSS/NSS_Sources_Building_Testing
LIBNSPRFILE=nspr-4.17
generate_script  libnspr     $LIBNSPRFILE     \
    '--script=./configure --host=$MY_TARGET --prefix=/usr --disable-debug --enable-strip'  \
    '--script=cd config'    \
    '--script=make CC=gcc' \
    '--script=cd ..'    \
    '--script=make STRIP=$MY_TARGET-strip'  \
    '--script=make install DESTDIR=$cachedir'  \
    '--deploy-rootfs=/usr/lib -/usr/lib/*.a -/usr/lib/pkgconfig -/usr/bin -/usr/include -/usr/share' \
    '--deploy-sdk=/usr -/usr/lib/*.a /usr/include /usr/share /usr/bin'

##############################
# 编译 sqlite
# Download: http://www.sqlite.org/2017/sqlite-autoconf-3210000.tar.gz
# Reference: http://www.sqlite.org/download.html
SQLITEFILE=sqlite-autoconf-3210000
generate_script  sqlite     $SQLITEFILE     \
    '--config=--host=$MY_TARGET --prefix=/usr --disable-static --with-sysroot=$SDKDIR --disable-editline --disable-readline --enable-threadsafe --enable-dynamic-extensions --disable-fts5  --disable-json1 --disable-session'       \
    '--deploy-rootfs=/usr/bin /usr/lib -/usr/lib/*.la -/usr/lib/pkgconfig' \
    '--deploy-sdk=/usr/include /usr/lib'   \
    '--depends=cross_autogen_env'

##############################
# 编译 gnome-keyring
# Download: http://ftp.acc.umu.se/pub/gnome/sources/gnome-keyring/3.27/
GNOMEKEYRINGFILE=gnome-keyring-3.27.2
generate_script  gnome_keyring     $GNOMEKEYRINGFILE     \
    '--config=--host=$MY_TARGET --prefix=/usr --disable-static --with-sysroot=$SDKDIR  --disable-doc --disable-debug --disable-strict --disable-coverage '       \
    '--deploy-rootfs=/usr/bin /usr/lib -/usr/lib/*.la -/usr/lib/pkgconfig' \
    '--deploy-sdk=/usr/include /usr/lib'   \
    '--depends=cross_autogen_env dbus glib'
 

