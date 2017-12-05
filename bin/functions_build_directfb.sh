#!/bin/bash

NATIVE_PREREQUIRST+=" g++ "

# 目前DirectFB的使用似乎并没有很普遍，更多是在媒体播放上，暂时不跟这条线了

###########################
# directfb
# 由于directFB的网站有问题，这个包来自 https://github.com/deniskropp/DirectFB/archive/DIRECTFB_1_7_7.tar.gz

#DIRECTFBFILE=DirectFB-DIRECTFB_1_7_7
#PARAM='--host=$MY_TARGET --prefix=/usr --sysconfdir=/etc --with-sysroot=$SDKDIR --enable-zlib --enable-jpeg --enable-png --enable-freetype --enable-egl --enable-idirectfbgl-egl'
#PARAM+='--with-gfxdrivers=gles2,gl --with-inputdrivers=none --with-tests --with-tools'
#generate_script     directfb   $DIRECTFBFILE                                 \
#    "--config=$PARAM"                    \
#    '--depends=cross_autogen_env libz libpng libjpeg libtiff libfreetype gles egl x11_xproto x11_libx11 x11_libxext native_directfb_fluxcomp'                                                 \
#    '--deploy-rootfs=/usr/bin /usr/lib -/usr/lib/pkgconfig'  \
#    '--deploy-sdk=/'      --debug
    
# require vdpau.

#		prepare $DIRECTFBFILE dfb-fsl-egl.patch
# ./configure --host=arm-linux-gnueabihf --prefix=/usr --sysconfdir=/etc --with-sysroot=/home/baiyun/git/candyOS/dist/pi/sdk --enable-zlib --enable-jpeg --enable-png --enable-freetype --with-gfxdrivers=gles2,gl --enable-egl --enable-idirectfbgl-egl --with-gfxdrivers=gles2,gl --with-inputdrivers=none --without-tests --without-tools 1>/home/baiyun/git/candyOS/temp/log 2>/home/baiyun/git/candyOS/temp/warn

###########################
# native_directfb_fluxcomp
# fluxcomp是一个编译DirectFB时需要用到的工具
# 由于directFB的网站有问题，这个包来自 http://archive.ubuntu.com/ubuntu/pool/universe/d/directfb/directfb_1.7.7.orig-flux.tar.xz
DIRECTFB_FLUXCOMP_FILE=directfb_flux
generate_script     native_directfb_fluxcomp   $DIRECTFB_FLUXCOMP_FILE                                 \
    '--prescript=autoreconf -v --install --force'       \
    "--config=--prefix=/usr"                   \
    '--install_target=install-strip'    \
    '--deploy-sdk=/usr/bin' 
