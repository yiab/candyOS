###########################################
# 编译来自https://www.x.org/archive//individual/app/的软件包

##############################
# 编译 xinit-1.3.2
X11_XINIT=xinit-1.3.4
generate_script     x11_xinit   x11/$X11_XINIT                      \
    '--config=--prefix=/usr --host=$MY_TARGET --sysconfdir=/etc --disable-static --with-sysroot=$SDKDIR'    \
    '--depends=xorg_server'             \
    '--deploy-rootfs=/usr/bin /etc'

##############################
# 编译 mkfontscale-1.1.2
X11_MKFONTSCALE=mkfontscale-1.1.2
generate_script     x11_mkfontscale   x11/$X11_MKFONTSCALE                      \
    '--config=--prefix=/usr --host=$MY_TARGET --disable-static --with-bzip2 --with-sysroot=$SDKDIR'    \
    '--depends=x11_util_macros libz libbz2 x11_libfontenc libfreetype'          \
    '--deploy-rootfs=/usr/bin'

##############################
# 编译 mkfontdir-1.0.7
X11_MKFONTDIR=mkfontdir-1.0.7
generate_script     x11_mkfontdir   x11/$X11_MKFONTDIR                          \
    '--config=--prefix=/usr --host=$MY_TARGET --disable-static --with-sysroot=$SDKDIR'                 \
    '--depends=x11_util_macros'                                                 \
    '--deploy-rootfs=/usr/bin'

##############################
# 编译 twm-1.0.9
X11_TWM=twm-1.0.9
generate_script     x11_twm   x11/$X11_TWM                          \
    '--config=--prefix=/usr --host=$MY_TARGET --disable-static --with-sysroot=$SDKDIR'                 \
    '--depends=x11_libx11 x11_libxext x11_libxt x11_libxmu x11_libice x11_libsm x11_xproto'            \
    '--deploy-rootfs=/usr/bin /usr/share/X11'
    







