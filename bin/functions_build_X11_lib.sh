#!/bin/bash

#  All lib for X11
#  https://www.x.org/archive/individual/lib/
#
# List here:
#    1.hsakmt
#    2.libAppleWM
#    3.libdmx
#    4.libfontenc
#    5.libFS
#    6.libICE
#    7.liblbxutil
#    8.liboldX
#    9.libpciaccess
#    10.libpthread
#    11.libSM
#    12.libWindowsWM
#    13.libX11
#    14.libXau
#    15.libXaw
#    16.libXaw3d
#    17.libXcomposite
#    18.libXcursor
#    19.libXdamage
#    20.libXdmcp
#    21.libXevie
#    22.libXext
#    23.libXfixes
#    24.libXfont
#    25.libXfont2
#    26.libXfontcache
#    27.libXft
#    28.libXi
#    29.libXinerama
#    30.libxkbfile
#    31.libxkbui
#    32.libXmu
#    33.libXp
#    34.libXpm
#    35.libXpresent
#    36.libXprintAppUtil
#    37.libXprintUtil
#    38.libXrandr
#    39.libXrender
#    40.libXres
#    41.libXScrnSaver
#    42.libxshmfence
#    43.libXt
#    44.libXTrap
#    45.libXtst
#    46.libXv
#    47.libXvMC
#    48.libXxf86dga
#    49.libXxf86misc
#    50.libXxf86vm
#    51.pixman
#    52.xtrans

##############################
# 4. 编译libfontenc
X11_LIBFONTENC=libfontenc-1.1.3
generate_script     x11_libfontenc   x11/$X11_LIBFONTENC                      \
    '--prescript=autoreconf -v --install --force'       \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR --disable-static'          \
    '--depends=x11_util_macros fontutil libz x11_xproto'   \
    '--deploy-sdk=/  -/usr/lib/*.a'   \
    '--deploy-rootfs=/usr/lib  -/usr/lib/*.a -/usr/lib/pkgconfig'

##############################
# 6. 编译libice
X11_LIBICE=libICE-1.0.9
generate_script     x11_libice   x11/$X11_LIBICE                      \
    '--prescript=autoreconf -v --install --force'       \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR  --disable-static'          \
    '--depends=x11_xtrans x11_xproto'   \
    '--deploy-sdk=/  -/usr/lib/*.a'   \
    '--deploy-rootfs=/usr/lib  -/usr/lib/*.a -/usr/lib/pkgconfig'

##############################
# 9. 编译libpciaccess
X11_LIBPCIACCESS=libpciaccess-0.14
generate_script     x11_libpciaccess   x11/$X11_LIBPCIACCESS                      \
    '--prescript=autoreconf -v --install --force'       \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR --disable-static'          \
    '--depends=x11_util_macros'   \
    '--deploy-sdk=/  -/usr/lib/*.a'   \
    '--deploy-rootfs=/usr/lib  -/usr/lib/*.a -/usr/lib/pkgconfig'

##############################
# 11. 编译libsm
X11_LIBSM=libSM-1.2.2
generate_script     x11_libsm   x11/$X11_LIBSM                      \
    '--prescript=autoreconf -v --install --force'       \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR'          \
    '--depends=x11_util_macros x11_libice'   \
    '--deploy-sdk=/  -/usr/lib/*.a'   \
    '--deploy-rootfs=/usr/lib  -/usr/lib/*.a -/usr/lib/pkgconfig'

##############################
# 13. 编译libX11
X11_LIBX11=libX11-1.6.5
generate_script     x11_libx11   x11/$X11_LIBX11                      \
    '--prescript=autoreconf -v --install --force'       \
    '--prescript=export CFLAGS_FOR_BUILD="-I$SDKDIR/usr/include -D__ARM_PCS_VFP"'   \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR --disable-static --enable-composecache --enable-local-transport --enable-xf86bigfont --disable-tcp-transport --enable-unix-transport --with-keysymdefdir=$SDKDIR/usr/include/X11 --disable-ipv6 --enable-xlocale --enable-xthreads --enable-malloc0returnsnull --disable-lint-library --without-perl --enable-loadable-i18n ac_cv_func_mmap_fixed_mapped=yes'          \
    '--postscript=unset CFLAGS_FOR_BUILD'   \
    '--depends=x11_util_macros x11_xproto x11_xextproto x11_xtrans libxcb x11_inputproto x11_kbproto x11_xf86bigfontproto '   \
    '--deploy-sdk=/  -/usr/lib/*.a'   \
    '--deploy-rootfs=/usr/lib  -/usr/lib/*.a -/usr/lib/pkgconfig'

##############################
# 14.编译libxau
X11_LIBXAU=libXau-1.0.8
generate_script     x11_libxau   x11/$X11_LIBXAU                      \
    '--prescript=autoreconf -v --install --force'       \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR --disable-static'          \
    '--depends=x11_util_macros x11_xproto'   \
    '--deploy-sdk=/  -/usr/lib/*.a'   \
    '--deploy-rootfs=/  -/usr/lib/*.a -/usr/lib/pkgconfig'

##############################
# 15. 编译libXaw
X11_LIBXAW=libXaw-1.0.13
generate_script     x11_libxaw   x11/$X11_LIBXAW                      \
    '--prescript=autoreconf -v --install --force'       \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR --disable-static --disable-xaw6'          \
    '--depends=x11_util_macros x11_xproto x11_libx11 x11_libxext x11_xextproto x11_libxmu x11_libxpm'   \
    '--deploy-sdk=/  -/usr/lib/*.a'   \
    '--deploy-rootfs=/  -/usr/lib/*.a -/usr/lib/pkgconfig'
    
##############################
# 17. 编译libXcomposite
X11_LIBXCOMPOSITE=libXcomposite-0.4.4
generate_script     x11_libxcomposite   x11/$X11_LIBXCOMPOSITE                      \
    '--prescript=autoreconf -v --install --force'                                   \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR --disable-static'                     \
    '--depends=x11_util_macros x11_compositeproto x11_libx11 x11_libxfixes'         \
    '--deploy-sdk=/  -/usr/lib/*.a'                                   \
    '--deploy-rootfs=/usr/lib  -/usr/lib/*.a -/usr/lib/pkgconfig'

##############################
# 18. 编译libXcursor
X11_LIBXCURSOR=libXcursor-1.1.14
generate_script     x11_libxcursor   x11/$X11_LIBXCURSOR                      \
    '--prescript=autoreconf -v --install --force'                                   \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR --disable-static'                     \
    '--depends=x11_util_macros x11_libxrender x11_libxfixes x11_libx11 x11_fixesproto'         \
    '--deploy-sdk=/  -/usr/lib/*.a'                                   \
    '--deploy-rootfs=/usr/lib  -/usr/lib/*.a -/usr/lib/pkgconfig'
    
##############################
# 19. 编译libXdamage
X11_LIBXDAMAGE=libXdamage-1.1.4
generate_script     x11_libxdamage   x11/$X11_LIBXDAMAGE                            \
    '--prescript=autoreconf -v --install --force'                                   \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR --disable-static'                     \
    '--depends=x11_util_macros x11_damageproto x11_libxfixes x11_fixesproto x11_xextproto x11_libx11'         \
    '--deploy-sdk=/  -/usr/lib/*.a'                                   \
    '--deploy-rootfs=/usr/lib  -/usr/lib/*.a -/usr/lib/pkgconfig'

##############################
# 20. 编译libXdmcp
X11_LIBXDMCP=libXdmcp-1.1.2
generate_script     x11_libxdmcp   x11/$X11_LIBXDMCP                                 \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR --disable-static --disable-doc'    \
    '--depends=x11_util_macros  '                                                \
    '--deploy-sdk=/ -/usr/lib/*.a '                              \
    '--deploy-rootfs=/usr/lib  -/usr/lib/pkgconfig'     

##############################
# 22. 编译libxext
X11_LIBXEXT=libXext-1.3.3
generate_script     x11_libxext   x11/$X11_LIBXEXT                               \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR --disable-static --enable-malloc0returnsnull'                  \
    '--depends=x11_util_macros x11_xproto x11_libx11 x11_xextproto'              \
    '--deploy-sdk=/ -/usr/lib/*.a '                              \
    '--deploy-rootfs=/usr/lib  -/usr/lib/pkgconfig'    

##############################
# 23. 编译libXfixes
X11_LIBXFIXES=libXfixes-5.0.3
generate_script     x11_libxfixes   x11/$X11_LIBXFIXES                               \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR --disable-static'                  \
    '--depends=x11_util_macros x11_xproto x11_libx11 x11_xextproto x11_xproto x11_fixesproto'              \
    '--deploy-sdk=/ -/usr/lib/*.a '                              \
    '--deploy-rootfs=/usr/lib  -/usr/lib/pkgconfig'    

##############################
# 24. 编译libXfont
X11_LIBXFONT=libXfont-1.5.3
generate_script     x11_libxfont   x11/$X11_LIBXFONT                               \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR --disable-static --with-bzip2 --enable-local-transport --enable-freetype'                  \
    '--depends=x11_util_macros libz libbz2 libfreetype x11_xproto x11_xtrans x11_fontsproto x11_libfontenc'              \
    '--deploy-sdk=/ -/usr/lib/*.a '                              \
    '--deploy-rootfs=/usr/lib  -/usr/lib/pkgconfig'   

##############################
# 25. 编译libXfont2
X11_LIBXFONT2=libXfont2-2.0.2
generate_script     x11_libXfont2   x11/$X11_LIBXFONT2                              \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR --disable-static --with-bzip2 --enable-local-transport --enable-freetype --with-sysroot=$SDKDIR'                  \
    '--depends=x11_util_macros libbz2 libfreetype x11_libfontenc x11_xproto x11_xtrans x11_fontsproto'              \
    '--deploy-sdk=/ '                              \
    '--deploy-rootfs=/usr/lib -/usr/lib/pkgconfig' 
     
##############################
# 27. 编译libXft
X11_LIBXFT=libXft-2.3.2
generate_script     x11_libxft   x11/$X11_LIBXFT                               \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR --sysconfdir=/etc --disable-static'                  \
    '--depends=x11_util_macros libfreetype fontconfig x11_libxrender x11_libx11'              \
    '--deploy-sdk=/ -/usr/lib/*.a '                              \
    '--deploy-rootfs=/usr/lib  -/usr/lib/pkgconfig'  

##############################
# 28. 编译libXi
X11_LIBXI=libXi-1.7.9
generate_script     x11_libxi   x11/$X11_LIBXI                               \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR --disable-static  --enable-malloc0returnsnull'                  \
    '--depends=x11_util_macros x11_xproto x11_libx11 x11_xextproto x11_libxext x11_inputproto x11_libxfixes'              \
    '--deploy-sdk=/ -/usr/lib/*.a '                              \
    '--deploy-rootfs=/usr/lib  -/usr/lib/pkgconfig'  
    
##############################
# 30. 编译libxkbfile
X11_LIBXKBFILE=libxkbfile-1.0.9
generate_script     x11_libxkbfile   x11/$X11_LIBXKBFILE                               \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR --disable-static'                  \
    '--depends=	x11_util_macros x11_kbproto x11_libx11'              \
    '--deploy-sdk=/ -/usr/lib/*.a '                              \
    '--deploy-rootfs=/usr/lib  -/usr/lib/pkgconfig'    
    
##############################
# 32. 编译libXmu
X11_LIBXMU=libXmu-1.1.2
generate_script     x11_libxmu   x11/$X11_LIBXMU                         \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR --disable-static --disable-docs --enable-unix-transport --enable-tcp-transport --enable-ipv6 --enable-local-transport'                  \
    '--depends=x11_util_macros x11_libxt x11_libxext x11_libx11 x11_xextproto'                       \
    '--deploy-sdk=/ -/usr/lib/*.a '                              \
    '--deploy-rootfs=/usr/lib  -/usr/lib/pkgconfig'    

##############################
# 34. 编译 libXpm-3.5.10
X11_LIBXPM=libXpm-3.5.12
generate_script     x11_libxpm   x11/$X11_LIBXPM                         \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR --disable-static'                  \
    '--depends=x11_util_macros x11_libx11 x11_xproto'                       \
    '--deploy-sdk=/ -/usr/lib/*.a '                              \
    '--deploy-rootfs=/usr/lib  -/usr/lib/pkgconfig'    

##############################
# 38. 编译libXrandr-1.4.0
X11_LIBXRANDR=libXrandr-1.5.1
generate_script     x11_libxrandr   x11/$X11_LIBXRANDR                         \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR --disable-static --enable-malloc0returnsnull'                  \
    '--depends=x11_util_macros x11_libx11 x11_renderproto x11_xextproto x11_libxext x11_libxrender x11_randrproto'                  \
    '--deploy-sdk=/ -/usr/lib/*.a '                              \
    '--deploy-rootfs=/usr/lib  -/usr/lib/pkgconfig'    
 
##############################
# 39. 编译libxrender
X11_LIBXRENDER=libXrender-0.9.10
generate_script     x11_libxrender   x11/$X11_LIBXRENDER                         \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR --disable-static --enable-malloc0returnsnull'                  \
    '--depends=x11_util_macros x11_libx11 x11_renderproto'                       \
    '--deploy-sdk=/ -/usr/lib/*.a '                              \
    '--deploy-rootfs=/usr/lib  -/usr/lib/pkgconfig'    

##############################
# 42. 编译 libxshmfence
X11_LIBXSHMFENCE=libxshmfence-1.2
generate_script     x11_libxshmfence   x11/$X11_LIBXSHMFENCE                                   \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR --disable-static'                  \
    '--depends=x11_util_macros x11_xproto'                  \
    '--deploy-sdk=/  -/usr/lib/*.a'                                \
    '--deploy-rootfs=/usr/lib  -/usr/lib/*.a -/usr/lib/pkgconfig'

##############################
# 43. 编译libxt
X11_LIBXT=libXt-1.1.5
generate_script     x11_libxt   x11/$X11_LIBXT                                   \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR --disable-static --enable-malloc0returnsnull'                  \
    '--depends=x11_util_macros x11_libsm x11_libx11 x11_xproto'                  \
    '--deploy-sdk=/  -/usr/lib/*.a'                                \
    '--deploy-rootfs=/usr/lib  -/usr/lib/*.a -/usr/lib/pkgconfig'

##############################
# 45. 编译libXtst
X11_LIBXTST=libXtst-1.2.3
generate_script     x11_libxtst   x11/$X11_LIBXTST                               \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR --disable-static'                  \
    '--depends=x11_util_macros x11_libx11 x11_libxext x11_libxi x11_recordproto x11_xextproto x11_inputproto'                  \
    '--deploy-sdk=/  -/usr/lib/*.a'                                \
    '--deploy-rootfs=/usr/lib  -/usr/lib/*.a -/usr/lib/pkgconfig'
# unset CAIRO_LIBS

##############################
# 46. 编译libXv
X11_LIBXV=libXv-1.0.11
generate_script     x11_libxv   x11/$X11_LIBXV                                   \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR --disable-static --enable-malloc0returnsnull'                  \
    '--depends=x11_util_macros'                                                  \
    '--deploy-sdk=/  -/usr/lib/*.a'                                \
    '--deploy-rootfs=/usr/lib  -/usr/lib/*.a -/usr/lib/pkgconfig'

##############################
# 48. 编译libXxf86dga
X11_LIBXF86DGA=libXxf86dga-1.1.4
generate_script     x11_libxf86dga   x11/$X11_LIBXF86DGA                                   \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR --disable-static --enable-malloc0returnsnull'                  \
    '--depends=x11_xproto x11_libx11 x11_xextproto x11_libxext x11_xf86dgaproto'                                                  \
    '--deploy-sdk=/  -/usr/lib/*.a'                                \
    '--deploy-rootfs=/usr/lib  -/usr/lib/*.a -/usr/lib/pkgconfig'

##############################
# 51. 编译 pixman
X11_PIXMANFILE=pixman-0.34.0
generate_script     x11_pixman   x11/$X11_PIXMANFILE                                   \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--host=$MY_TARGET --with-sysroot=$SDKDIR --target=$MY_TARGET --prefix=/usr --disable-static --enable-libpng --enable-arm-neon --enable-openmp --enable-gcc-inline-asm'               \
    '--depends=cross_autoconf libpng'                                                  \
    '--deploy-sdk=/  -/usr/lib/*.a'                                \
    '--deploy-rootfs=/usr/lib  -/usr/lib/*.a -/usr/lib/pkgconfig'

##############################
# 52. 编译xtrans
X11_XTRANS=xtrans-1.3.5
generate_script     x11_xtrans   x11/$X11_XTRANS                      \
    '--prescript=autoreconf -v --install --force'                     \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR --disable-doc'          \
    '--depends=x11_util_macros  '                                     \
    '--deploy-sdk=/'


