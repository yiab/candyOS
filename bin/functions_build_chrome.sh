#!/bin/sh

##############################
# 编译 libnss
# Download: https://ftp.mozilla.org/pub/security/nss/releases/NSS_3_34_1_RTM/src/
# Reference: https://developer.mozilla.org/en-US/docs/Mozilla/Projects/NSS/NSS_Sources_Building_Testing
#LIBNSSFILE=nss-3.34.1
generate_script  libnss     $LIBNSSFILE     \
    '--prescript=export CC=$MY_TARGET-gcc'  \
    '--config=--prefix=/usr'       \
    '--deploy-rootfs=/usr/lib -/usr/lib/*.a -/usr/lib/*.la -/usr/lib/pkgconfig' \
    '--deploy-sdk=/usr -/usr/lib/*.a'   \
    '--depends=libnspr'

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
