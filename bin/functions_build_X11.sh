#!/bin/sh

[ -n "$PRODUCT_GLES" ] || fail "未指明PRODUCT_GLES, PRODUCT=${PRODUCT}"
generate_alias gles $PRODUCT_GLES

[ -n "$PRODUCT_EGL" ] || fail "未指明PRODUCT_EGL, PRODUCT=${PRODUCT}"
generate_alias egl $PRODUCT_EGL

[ -n "$PRODUCT_OPENVG" ] || fail "未指明PRODUCT_EGL, PRODUCT=${PRODUCT}"
generate_alias openvg $PRODUCT_OPENVG
generate_alias vg   openvg

##############################
# 编译 util-macros-1.19.1
X11_UTIL_MACROS=util-macros-1.19.1
generate_script     x11_util_macros   x11/$X11_UTIL_MACROS                      \
    '--prescript=autoreconf -v --install --force'                               \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR'                                  \
    '--install_key=DESTDIR'                                                     \
    '--depends=cross_autogen_env'                                               \
    '--deploy-sdk="/"'

###########################
# libfreetype
# sed -i -r 's:.*(#.*SUBPIXEL.*) .*:\1:' include/freetype/config/ftoption.h		# 打开cleartype
FREETYPEFILE=freetype-2.8.1
generate_script     libfreetype_no_harfbuzz   $FREETYPEFILE                                 \
    '--patch=freetype-enable-cleartype.patch' \
    '--config=--host=$MY_TARGET --target=$MY_TARGET --with-sysroot=$SDKDIR --prefix=/usr --sysconfdir=/etc --disable-static --enable-mmap --with-zlib  --with-bzip2 --with-png --without-harfbuzz'                 \
    '--depends=libz libbz2 libpng'                                                 \
    '--deploy-sdk=/'

generate_script     libfreetype   $FREETYPEFILE                                 \
    '--patch=freetype-enable-cleartype.patch' \
    '--config=--host=$MY_TARGET --target=$MY_TARGET --with-sysroot=$SDKDIR --prefix=/usr --sysconfdir=/etc --disable-static --enable-mmap --with-zlib  --with-bzip2 --with-png --with-harfbuzz'                 \
    '--depends=libz libbz2 libpng harfbuzz'                                                 \
    '--deploy-sdk=/'    \
    '--deploy-rootfs=/usr/lib -/usr/lib/pkgconfig -/usr/lib/*.la'
       
generate_alias freetype libfreetype


##############################
# 编译 xkeyboard-config-2.22
X11_XKEYBOARDCONFIG=xkeyboard-config-2.22
compile_x11_xkeyboardconfig()
{
	if [ ! -e $CACHEDIR/$X11_XKEYBOARDCONFIG.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_XKEYBOARDCONFIG
		
		dispenv
		
		prepare $X11_XKEYBOARDCONFIG
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static "
		exec_cmd "./configure $PARAM"
		exec_cmd "make V=1 -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/$X11_XKEYBOARDCONFIG"
				
		pack_cache $X11_XKEYBOARDCONFIG
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST="/usr/share/pkgconfig /usr/share/man"
	DEPLOY_DIST="/usr/share"
	deploy $X11_XKEYBOARDCONFIG
}
build_x11_xkeyboardconfig()
{
    # requires the infrastructure from gettext-0.18.1
    build_gettext		# build_native_gettext
    
    # must install xorg-macros 1.12 or later before
    build_x11_util_macros
    
    # No package 'xproto' found
    # No package 'x11' found
    build_x11_xproto
    build_x11_libx11
    
	run_task "构建$X11_XKEYBOARDCONFIG" "compile_x11_xkeyboardconfig"
}



# for yacc
NATIVE_PREREQUIRST+=" bison"
##############################
# 编译 xkbcomp-1.4.0
X11_XKBCOMP=xkbcomp-1.4.0
compile_x11_xkbcomp()
{
	if [ ! -e $CACHEDIR/$X11_XKBCOMP.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_XKBCOMP
		# export LIBS="-lxcb -lXau"
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link ."
		dispenv
		
		prepare $X11_XKBCOMP
		PARAM="--prefix=/usr --host=$MY_TARGET"
		exec_cmd "./configure $PARAM"
		exec_cmd "make V=1 -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/$X11_XKBCOMP"
				
		pack_cache $X11_XKBCOMP
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST="/usr/bin"
	deploy $X11_XKBCOMP
}
build_x11_xkbcomp()
{
	# must install xorg-macros 1.8 or later 
	build_x11_util_macros
	
	# Package requirements (x11 xkbfile xproto >= 7.0.17) were not met
	build_x11_libx11
	build_x11_libxkbfile
	build_x11_xproto
	
	run_task "构建$X11_XKBCOMP" "compile_x11_xkbcomp"
}

###############################
## 编译 xkbutils-1.0.3
#X11_XKBUTILS=xkbutils-1.0.3
#compile_x11_xkbutils()
#{
#	if [ ! -e $CACHEDIR/$X11_XKBUTILS.tar.gz ]; then
#		rm -rf $TEMPDIR/$X11_XKBUTILS
#		
#		export LIBS="-lxcb 	-lXext -lXmu -lXpm -lSM -lICE -lXau -lX11 -lXt"
#		dispenv
#		
#		prepare $X11_XKBUTILS
#		PARAM="--prefix=/usr --host=$MY_TARGET"
#		
#		exec_cmd "./configure $PARAM"
#		exec_cmd "make V=1 -j 10"
#		exec_cmd "make install DESTDIR=$CACHEDIR/x11_xkbutils"
#				
#		exec_cmd "cd $CACHEDIR/x11_xkbutils"
#		exec_cmd "tar czf $CACHEDIR/$X11_XKBUTILS.tar.gz ."
#		
#		exit;
#		exec_cmd "rm -rf $CACHEDIR/x11_xkbutils $TEMPDIR/$X11_XKBUTILS"
#	fi;
#	
#	PRE_REMOVE_LIST=""
#	REMOVE_LIST=""
#	DEPLOY_DIST="/usr/bin"
#	deploy $X11_XKBUTILS x11_xkbutils
#}
#build_x11_xkbutils()
#{
#	# must install xorg-macros 1.8 or later 
#	build_x11_util_macros
#	
#	# Package requirements (xproto xaw7 xt x11) were not met
#	build_x11_xproto
#    build_x11_libx11
#    build_x11_libxt
#   build_x11_libxaw
#    
#	run_task "构建$X11_XKBUTILS" "compile_x11_xkbutils"
#}


# no such project!
##############################
# 编译 libdri2-master
#X11_LIBDRI2=libdri2-master
#compile_x11_libdri2()
#{
#	if [ ! -e $CACHEDIR/$X11_LIBDRI2.tar.gz ]; then
#		rm -rf $TEMPDIR/$X11_LIBDRI2
#		
#		dispenv
#		
#		prepare $X11_LIBDRI2
#		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static --disable-test"
#		exec_cmd "./configure $PARAM"
#		exec_cmd "make V=1 -j 10"
#		exec_cmd "make install DESTDIR=$CACHEDIR/x11_libdri2"
#				
#		exec_cmd "cd $CACHEDIR/x11_libdri2"
#		exec_cmd "tar czf $CACHEDIR/$X11_LIBDRI2.tar.gz ."
#		exec_cmd "rm -rf $CACHEDIR/x11_libdri2 $TEMPDIR/$X11_LIBDRI2"
#	fi;
#	
#	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
#	REMOVE_LIST="/usr/lib/pkgconfig"
#	DEPLOY_DIST="/usr/lib"
#	deploy $X11_LIBDRI2 x11_libdri2
#}
#build_x11_libdri2()
#{
#    build_x11_util_macros
#    
#    # Package requirements (x11 xext xextproto libdrm) were not met
#    build_x11_libx11
#    build_x11_xextproto
#    build_x11_libxext
#    build_x11_libdrm
#    
#    # fatal error: X11/extensions/dri2proto.h: No such file or directory
#    build_x11_dri2proto
#    # fatal error: X11/extensions/Xfixes.h: No such file or directory
#    build_x11_fixesproto
#    build_x11_libxfixes
#    
#	run_task "构建$X11_LIBDRI2" "compile_x11_libdri2"
#}


##############################
# 编译 xrandr-1.3.5
X11_XRANDR=xrandr-1.5.0
generate_script     x11_xrandr   x11/$X11_XRANDR                      \
    '--prescript=autoreconf -v --install --force'       \
    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR'          \
    '--depends=x11_util_macros x11_libxrandr x11_libxrender x11_libx11 x11_xproto'   \
    '--deploy-rootfs=/usr/bin'

##############################
# 编译 xorg-server
XORG_SERVER=xorg-server-1.19.5
PARAM='--prefix=/usr --host=$MY_TARGET --enable-option-checking --with-sysroot=$SDKDIR'			# 基本设置
PARAM+=" --enable-shared --disable-static"                                                  # 编译动态库、不编译静态库
PARAM+=" --enable-fast-install --enable-libtool-lock"                                       # 快速安装、并行编译
PARAM+=" --disable-dependency-tracking"														# speeds up one-time build
PARAM+=" --disable-strict-compilation"							                            # 如果编译告警，则视为错误
PARAM+=" --disable-listen-tcp --disable-listen-unix --enable-listen-local"                  # 缺省只监听本地端口
PARAM+=" --enable-visibility"                                                               # 导出符号
PARAM+=" --disable-docs --disable-devel-docs --disable-unit-tests --disable-debug"          # 不编译文档/开发者文档/单元测试代码/调试代码

# 特性设置
PARAM+=" --disable-sparkle"						        # Sparkle: a free software update framework for the Mac             (default: disabled)
PARAM+=" --enable-composite"                            # Build Composite extension                                         (default: enabled)
PARAM+=" --enable-mitshm"                               # MIT-SHM(The MIT Shared Memory Extension)，用共享内存传递图像数据  (default: auto)
PARAM+=" --enable-xres"                                 # XRes，查询分辨率扩展                                              (default: enabled)
PARAM+=" --disable-record"                              # Record Extension，录制协议                                         (default: enabled)
PARAM+=" --enable-xv"                                   # Video Extension,视频协议
PARAM+=" --enable-xvmc --enable-xvfb"
PARAM+=" --enable-dga"                                  # DGA: Direct Graphics Access, XAA: EXA的前称
PARAM+=" --enable-screensaver"
PARAM+=" --enable-xdmcp"                                # XDMCP（X Display Manager Control Protocol） X显示监控协议
PARAM+=" --enable-xdm-auth-1"
PARAM+=" --disable-glx --disable-glamor"                # GLX， interface between OpenGL and the X Window System. 嵌入式一般不使用OpenGL，而是GLES。glamor是Xserver内嵌的一部分了
PARAM+=" --disable-dri --enable-dri2 --enable-dri3"     # dri3应该结合xcb，提供GLES图形加速
PARAM+=" --enable-present"
PARAM+=" --disable-xinerama"																# XINERAMA : 多屏显示( Xinerama is an extension to the X Window System
                                                                                            #       that enables X applications and window managers to use two or
                                                                                            #       more physical displays as one large virtual)
PARAM+=" --enable-xf86vidmode"
PARAM+=" --enable-xace"
PARAM+=" --disable-xselinux --disable-xcsecurity"       # 安全性（暂时关闭）
PARAM+=" --disable-tslib"                               # 触摸屏      
PARAM+=" --enable-dbe"
PARAM+=" --enable-xf86bigfont"                          # 大字体，需要libX11同时支持
PARAM+=" --enable-dpms"                                 # DPMS (Display Power Management Signaling)
PARAM+=" --enable-config-udev --enable-config-udev-kms --disable-config-hal" # 即插即用。Hotplugging through both libudev and hal not allowed
PARAM+=" --enable-config-wscons"
PARAM+=" --enable-xfree86-utils"
PARAM+=" --enable-vgahw"                                # vgahw: for saving, restoring and programming the standard VGA registers, and for handling VGA colourmaps
PARAM+=" --enable-vbe"
PARAM+=" --enable-int10-module"
PARAM+=" --disable-windowswm --disable-windowsdri"
PARAM+=" --enable-libdrm"

PARAM+=" --enable-clientids"
PARAM+=" --enable-pciaccess"
PARAM+=" --enable-linux-acpi"
PARAM+=" --enable-linux-apm"
PARAM+=" --enable-systemd-logind"
PARAM+=" --enable-suid-wrapper"

PARAM+=" --enable-xorg"
PARAM+=" --disable-dmx" 			        	# DMX : 分布式多屏显示 distributed multihead X system
PARAM+=" --disable-xnest"                       # Xnest在窗口之内可以用于跑另一台计算机一个虚拟桌面
PARAM+=" --disable-xquartz"                     # Build Xquartz server for OS-X (default: auto)
PARAM+=" --disable-xwayland"                    # Wayland is a complete window system in itself. XWayland是一个新的X11的替代品
PARAM+=" --disable-standalone-xpbproxy"         # Build a standalone xpbproxy (default: no)

PARAM+=" --disable-xwin"						# XWin - X Server for the Cygwin environment on Microsoft Windows
PARAM+=" --disable-kdrive --disable-kdrive-kbd --disable-kdrive-mouse --disable-kdrive-evdev"   # kdrive: TinyX
PARAM+=" --disable-xephyr --disable-xfake --disable-xfbdev"           # xephyr: 
PARAM+=" --disable-libunwind"                   # libunwind: to determine the call-chain of a program
PARAM+=" --enable-xshmfence"
PARAM+=" --enable-install-setuid"
PARAM+=" --disable-ipv6 --disable-tcp-transport --disable-unix-transport --enable-local-transport"
PARAM+=" --enable-secure-rpc"
PARAM+=" --enable-input-thread"
PARAM+=" --enable-xtrans-send-fds"
                          
### 不使用的功能
# PARAM+=" --disable-xf86vidmode --disable-xnest --disable-xvfb --disable-xquartz --disable-xfake --enable-pciaccess --disable-dri "  # --disable-libdrm

    #FROM configure.ac
    #dnl Optional modules
    # fixesproto >= 5.0 damageproto >= 1.1 xcmiscproto >= 1.2.0 xtrans >= 1.3.5 bigreqsproto >= 1.1.0 xproto >= 7.0.31 randrproto >= 1.5.0 renderproto >= 0.11 xextproto >= 7.2.99.901 inputproto >= 2.3 kbproto >= 1.0.3 fontsproto >= 2.1.3 pixman-1 >= 0.27.2 videoproto compositeproto >= 0.4 recordproto >= 1.13.99.1 scrnsaverproto >= 1.1 resourceproto >= 1.2.0 presentproto >= 1.0 xf86bigfontproto >= 1.2.0 xkbfile  pixman-1 >= 0.27.2 xfont2 >= 2.0.0 xau libsystemd-daemon xshmfence >= 1.1 xdmcp
    DEPENDS=''
    DEPENDS+='x11_videoproto '                  # VIDEOPROTO="videoproto"
    DEPENDS+='x11_compositeproto '              # COMPOSITEPROTO="compositeproto >= 0.4"
    DEPENDS+='x11_recordproto '                 # RECORDPROTO="recordproto >= 1.13.99.1"
    DEPENDS+='x11_scrnsaverproto '              # SCRNSAVERPROTO="scrnsaverproto >= 1.1"
    DEPENDS+='x11_resourceproto '               # RESOURCEPROTO="resourceproto >= 1.2.0"
    DEPENDS+='x11_xf86driproto '                # DRIPROTO="xf86driproto >= 2.1.0"
    DEPENDS+='x11_dri2proto '                   # DRI2PROTO="dri2proto >= 2.8"
    DEPENDS+='x11_dri3proto '                   # DRI3PROTO="dri3proto >= 1.0"
#    DEPENDS+='x11_xineramaproto '               # XINERAMAPROTO="xineramaproto"
	DEPENDS+='x11_xf86bigfontproto '            # BIGFONTPROTO="xf86bigfontproto >= 1.2.0"
    DEPENDS+='x11_xf86dgaproto '                # DGAPROTO="xf86dgaproto >= 2.0.99.1"
                                                # for --enable-dga
    DEPENDS+='x11_glproto '                     # GLPROTO="glproto >= 1.4.17"
    DEPENDS+='x11_dmxproto '                    # DMXPROTO="dmxproto >= 2.2.99.1"
    DEPENDS+='x11_xf86vidmodeproto '            # VIDMODEPROTO="xf86vidmodeproto >= 2.2.99.1"
    DEPENDS+='x11_windowswmproto '              # WINDOWSWMPROTO="windowswmproto"
    DEPENDS+='x11_applewmproto '                # APPLEWMPROTO="applewmproto >= 1.4"
    DEPENDS+='x11_libxshmfence '                # LIBXSHMFENCE="xshmfence >= 1.1"

    #dnl Required modules
    DEPENDS+='x11_xproto '                      # XPROTO="xproto >= 7.0.31"
    DEPENDS+='x11_randrproto '                  # RANDRPROTO="randrproto >= 1.5.0"
    DEPENDS+='x11_renderproto '                 # RENDERPROTO="renderproto >= 0.11"
    DEPENDS+='x11_xextproto '                   # XEXTPROTO="xextproto >= 7.2.99.901"
    DEPENDS+='x11_inputproto '                  # INPUTPROTO="inputproto >= 2.3"
    DEPENDS+='x11_kbproto '                     # KBPROTO="kbproto >= 1.0.3"
    DEPENDS+='x11_fontsproto '                  # FONTSPROTO="fontsproto >= 2.1.3"
    DEPENDS+='x11_fixesproto '                  # FIXESPROTO="fixesproto >= 5.0"
    DEPENDS+='x11_damageproto '                 # DAMAGEPROTO="damageproto >= 1.1"
    DEPENDS+='x11_xcmiscproto '                 # XCMISCPROTO="xcmiscproto >= 1.2.0"
    DEPENDS+='x11_bigreqsproto '                # BIGREQSPROTO="bigreqsproto >= 1.1.0"
    DEPENDS+='x11_xtrans '                      # XTRANS="xtrans >= 1.3.5"
    DEPENDS+='x11_presentproto '                # PRESENTPROTO="presentproto >= 1.0"

    DEPENDS+='x11_pixman '          #LIBPIXMAN="pixman-1 >= 0.27.2"
    DEPENDS+='x11_libXfont2 '       # ????????? LIBXFONT="xfont2 >= 2.0.0"
    DEPENDS+='x11_libxau '          # xau
    DEPENDS+='systemd '
    DEPENDS+='x11_libxdmcp '
    DEPENDS+='x11_libxkbfile '    # xkbfile
#    DEPENDS+='x11_libdri2 '
	DEPENDS+='x11_libxrandr '
	DEPENDS+='x11_libxv '

    #dnl List of libraries that require a specific version
#    DEPENDS+='x11_libapplewm '             #LIBAPPLEWM="applewm >= 1.4"
#    DEPENDS+='x11_libdmx '         #LIBDMX="dmx >= 1.0.99.1"
#    DEPENDS+='x11_libdri '         #LIBDRI="dri >= 7.8.0"
    DEPENDS+='libdrm '              #LIBDRM="libdrm >= 2.3.1"
    DEPENDS+=$PRODUCT_EGL' '        #LIBEGL="egl"
#    DEPENDS+='libgbm '              #LIBGBM="gbm >= 10.2.0"
    DEPENDS+=$PRODUCT_GLES' '         #LIBGL="gl >= 7.1.0"
    DEPENDS+='x11_libxext '         #LIBXEXT="xext >= 1.0.99.4"
    
    DEPENDS+='x11_libxi '           #LIBXI="xi >= 1.2.99.1"
    DEPENDS+='x11_libxtst '         #LIBXTST="xtst >= 1.0.99.2"
    DEPENDS+='x11_libpciaccess '    #LIBPCIACCESS="pciaccess >= 0.12.901"
    DEPENDS+='udev '                #LIBUDEV="libudev >= 143"
#    DEPENDS+='libselinux '         #LIBSELINUX="libselinux >= 2.0.86"
    DEPENDS+='dbus '                #LIBDBUS="dbus-1 >= 1.0"
    
	DEPENDS+='fontutil '            # must install font-util 1.1 or later before running autoconf/autogen
    DEPENDS+='libcrypto '   # We don't need all of the OpenSSL libraries, just libcrypto
    
#    DEPENDS+='x11_libxf86dga '		# ?? 有什么用？
#    DEPENDS+='x11_libxcomposite '
    # 出错才能调整好的依赖
    #No package 'xcb-renderutil'  'xcb-aux' 'xcb-image' 'xcb-icccm' 'xcb-keysyms'
    DEPENDS+='xcb_renderutil xcb_aux xcb_image xcb_icccm xcb_keysyms'
generate_script     xorg_server   x11/$XORG_SERVER                      \
    "--config=$PARAM"          \
    '--make-before-install'              \
    '--sudo-build'   \
    "--depends=$DEPENDS"        \
    '--deploy-rootfs=/usr/bin /usr/lib  -/usr/lib/pkgconfig -/usr/lib/xorg/modules/*.la /usr/libexec /usr/share/X11 /usr/var'     \
    '--deploy-sdk=/usr/include /usr/lib /usr/share'
    
NATIVE_PREREQUIRST+=" flex"
##############################
# 编译 fbset-2.1
FBSETFILE=fbset-2.1
compile_fbset()
{
	if [ ! -e $CACHEDIR/$FBSETFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$FBSETFILE
		
		dispenv
        
		prepare $FBSETFILE
		exec_cmd "make CC=$MY_TARGET-gcc"
		exec_cmd "mkdir -p $CACHEDIR/$FBSETFILE/usr/sbin"
		exec_cmd "cp fbset $CACHEDIR/$FBSETFILE/usr/sbin"
		
		pack_cache $FBSETFILE
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST="/usr/sbin"
	deploy $FBSETFILE
}
build_fbset()
{		
	run_task "构建$FBSETFILE" "compile_fbset"
}


