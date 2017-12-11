#!/bin/bash

# xcb
# https://www.x.org/archive/individual/lib/

# 1. libpthread
# 2. libxcb
# 3. xcb_proto
# 4. xcb_util
# 5. xcb_util-cursor
# 6. xcb_util-image
# 7. xcb_util-keysyms
# 8. xcb_util-renderutil 
# 9. xcb_util 
# 10. xpyb

##############################
# 1. 编译 libpthreadstubs
X11_LIBPTHREADSTUBS=libpthread-stubs-0.4
generate_script     x11_libpthreadstubs   x11/$X11_LIBPTHREADSTUBS              \
    '--prescript=autoreconf -v --install --force'                               \
    '--config=--prefix=/usr --host=$MY_TARGET'                                  \
    '--deploy-sdk=/'

##############################
# 2. 编译 libxcb
X11_LIBXCB=libxcb-1.12
PARAM='--prefix=/usr --host=$MY_TARGET --disable-static --with-sysroot=$SDKDIR '
PARAM+=" --disable-strict-compilation"
PARAM+=" --disable-devel-docs"                  # 开发文档
PARAM+=" --enable-composite"                    # 
PARAM+=" --enable-damage"                       #
PARAM+=" --enable-dpms"                    #
PARAM+=" --enable-dri2"                    #
PARAM+=" --enable-dri3"                    #
PARAM+=" --enable-glx"                    #
PARAM+=" --enable-present"                    #
PARAM+=" --enable-randr"                    #
PARAM+=" --enable-record"                    #
PARAM+=" --enable-render"                       #
PARAM+=" --enable-resource"                     #
PARAM+=" --enable-screensaver"                  #
PARAM+=" --enable-shape"                        #
PARAM+=" --enable-shm"                          #
PARAM+=" --enable-sync"                         #
PARAM+=" --enable-xevie"                        #
PARAM+=" --enable-xfixes"                       #
PARAM+=" --disable-xfree86-dri"                 #
PARAM+=" --enable-xinerama"                     #
PARAM+=" --enable-xinput"                       #
PARAM+=" --enable-xkb"                          #
PARAM+=" --enable-xprint"                       # 
PARAM+=" --disable-selinux"                     #
PARAM+=" --disable-xtest"                       #
PARAM+=" --enable-xv"                           #
PARAM+=" --enable-xvmc"                         #
generate_script     libxcb   x11/$X11_LIBXCB                                                \
    '--prescript=autoreconf -v --install --force'                                               \
    "--config=$PARAM"    \
    '--depends=x11_util_macros xcb_proto x11_libpthreadstubs x11_libxau x11_libxdmcp cross_python'        \
    '--deploy-sdk=/'                                                                            \
    '--deploy-rootfs=/usr/lib -/usr/lib/*.la -/usr/lib/pkgconfig'

generate_alias      xcb                 libxcb
generate_alias      xcb_composite       libxcb
generate_alias      xcb_damage          libxcb
generate_alias      xcb_dpms            libxcb
generate_alias      xcb_dri2            libxcb
generate_alias      xcb_dri3            libxcb
generate_alias      xcb_glx             libxcb
generate_alias      xcb_randr           libxcb
generate_alias      xcb_record          libxcb
generate_alias      xcb_render          libxcb
generate_alias      xcb_res             libxcb
generate_alias      xcb_screensaver     libxcb
generate_alias      xcb_shape           libxcb
generate_alias      xcb_shm             libxcb
generate_alias      xcb_sync            libxcb
generate_alias      xcb_xevie           libxcb
generate_alias      xcb_xfixes          libxcb
generate_alias      xcb_xinerama        libxcb
generate_alias      xcb_xinput          libxcb
generate_alias      xcb_xkb             libxcb
generate_alias      xcb_xprint          libxcb
generate_alias      xcb_xv              libxcb
generate_alias      xcb_xvmc            libxcb

##############################
# 3. 编译 xcb_proto
X11_XCBPROTO=xcb-proto-1.12
generate_script     xcb_proto   x11/$X11_XCBPROTO                            \
    '--prescript=autoreconf -v --install --force'                               \
    '--config=--prefix=/usr --host=$MY_TARGET'                                  \
    '--depends=x11_util_macros'                                                 \
    '--deploy-sdk=/'  
    
##############################
# 4. 编译 xcb_util
X11_LIBXCB_UTIL=xcb-util-0.4.0
generate_script     xcb_util        x11/$X11_LIBXCB_UTIL                                      \
    '--prescript=autoreconf -v --install --force'                                               \
    '--config=--prefix=/usr --host=$MY_TARGET -disable-devel-docs --disable-static --with-sysroot=$SDKDIR'    \
    '--depends=x11_util_macros  xcb x11_libxdmcp'        \
    '--deploy-sdk=/'                                                                            \
    '--deploy-rootfs=/usr/lib -/usr/lib/*.la -/usr/lib/pkgconfig'
    
generate_alias xcb_atom     xcb_util
generate_alias xcb_aux      xcb_util
generate_alias xcb_event    xcb_util

##############################
# 5. 编译 xcb_util-renderutil
X11_LIBXCB_RENDERUTIL=xcb-util-renderutil-0.3.9
generate_script     xcb_renderutil   x11/$X11_LIBXCB_RENDERUTIL                                      \
    '--prescript=autoreconf -v --install --force'                                               \
    '--config=--prefix=/usr --host=$MY_TARGET -disable-devel-docs --disable-static --with-sysroot=$SDKDIR'    \
    '--depends=x11_util_macros xcb x11_libxdmcp'        \
    '--deploy-sdk=/'                                                                            \
    '--deploy-rootfs=/usr/lib -/usr/lib/*.la -/usr/lib/pkgconfig' 
    
##############################
# 6. 编译 xcb_util-image
X11_LIBXCB_IMAGE=xcb-util-image-0.4.0
generate_script     xcb_image    x11/$X11_LIBXCB_IMAGE                                      \
    '--prescript=autoreconf -v --install --force'                                               \
    '--config=--prefix=/usr --host=$MY_TARGET -disable-devel-docs --disable-static --with-sysroot=$SDKDIR'    \
    '--depends=x11_util_macros  xcb x11_libxdmcp  xcb_util'        \
    '--deploy-sdk=/'                                                                            \
    '--deploy-rootfs=/usr/lib -/usr/lib/*.la -/usr/lib/pkgconfig'

generate_alias libxcb_image         xcb_image

##############################
# 7. 编译 xcb_util-keysyms
X11_LIBXCB_KEYSYMS=xcb-util-keysyms-0.4.0
generate_script     xcb_keysyms    x11/$X11_LIBXCB_KEYSYMS                                      \
    '--prescript=autoreconf -v --install --force'                                               \
    '--config=--prefix=/usr --host=$MY_TARGET -disable-devel-docs --disable-static --with-sysroot=$SDKDIR'    \
    '--depends=x11_util_macros  xcb x11_libxdmcp'        \
    '--deploy-sdk=/'                                                                            \
    '--deploy-rootfs=/usr/lib -/usr/lib/*.la -/usr/lib/pkgconfig'

generate_alias libxcb_keysyms       xcb_keysyms 

##############################
# 8. 编译 xcb_util-cursor
X11_LIBXCB_CURSOR=xcb-util-cursor-0.1.3
generate_script    xcb_cursor    x11/$X11_LIBXCB_CURSOR                                      \
    '--prescript=autoreconf -v --install --force'                                               \
    '--config=--prefix=/usr --host=$MY_TARGET -disable-devel-docs --disable-static --with-sysroot=$SDKDIR'    \
    '--depends=x11_util_macros  xcb x11_libxdmcp'        \
    '--deploy-sdk=/'                                                                            \
    '--deploy-rootfs=/usr/lib -/usr/lib/*.la -/usr/lib/pkgconfig'
    
##############################
# 9. 编译 xcb_util-errors
X11_LIBXCB_ERRORS=xcb-util-errors-1.0
generate_script     xcb_errors    x11/$X11_LIBXCB_ERRORS                                      \
    '--prescript=autoreconf -v --install --force'                                               \
    '--config=--prefix=/usr --host=$MY_TARGET -disable-devel-docs --disable-static --with-sysroot=$SDKDIR'    \
    '--depends=x11_util_macros  xcb x11_libxdmcp'        \
    '--deploy-sdk=/'                                                                            \
    '--deploy-rootfs=/usr/lib -/usr/lib/*.la -/usr/lib/pkgconfig'
    
##############################
# 10. 编译 xcb_util-wm
X11_LIBXCB_WM=xcb-util-wm-0.4.1
generate_script     xcb_wm    x11/$X11_LIBXCB_WM                                      \
    '--prescript=autoreconf -v --install --force'                                               \
    '--config=--prefix=/usr --host=$MY_TARGET -disable-devel-docs --disable-static --with-sysroot=$SDKDIR'    \
    '--depends=x11_util_macros  xcb x11_libxdmcp'        \
    '--deploy-sdk=/'                                                                            \
    '--deploy-rootfs=/usr/lib -/usr/lib/*.la -/usr/lib/pkgconfig'

generate_alias xcb_ewmh     xcb_wm
generate_alias xcb_icccm    xcb_wm
generate_alias libxcb_ewmh  xcb_ewmh
generate_alias libxcb_icccm xcb_icccm

##############################
# 11. 编译 xcb_demo
X11_LIBXCB_DEMO=xcb-demo-0.1
generate_script     xcb_demo    x11/$X11_LIBXCB_DEMO                                      \
    '--prescript=autoreconf -v --install --force'                                               \
    '--config=--prefix=/usr --host=$MY_TARGET -disable-devel-docs --disable-static --with-sysroot=$SDKDIR'    \
    '--depends=x11_util_macros  xcb x11_libxdmcp'        \
    '--deploy-sdk=/'                                                                            \
    '--deploy-rootfs=/usr/lib -/usr/lib/*.la -/usr/lib/pkgconfig'
