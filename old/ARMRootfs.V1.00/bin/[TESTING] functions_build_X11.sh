#!/bin/sh
##############################
# 编译 util-macros-1.17
X11_UTIL_MACROS=util-macros-1.17
compile_x11_util_macros()
{
	if [ ! -e $CACHEDIR/$X11_UTIL_MACROS.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_UTIL_MACROS
		dispenv
		
		prepare $X11_UTIL_MACROS
		PARAM="--prefix=/usr --host=$MY_TARGET"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_util_macros"
		
		exec_cmd "cd $CACHEDIR/x11_util_macros"
		exec_cmd "tar czf $CACHEDIR/$X11_UTIL_MACROS.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_util_macros $TEMPDIR/$X11_UTIL_MACROS"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $X11_UTIL_MACROS x11_util_macros
}
build_x11_util_macros()
{
	run_task "构建$X11_UTIL_MACROS" "compile_x11_util_macros"
}

##############################
# 编译 x11_xproto
X11_XPROTO=xproto-7.0.23
compile_x11_xproto()
{
	
	if [ ! -e $CACHEDIR/$X11_XPROTO.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_XPROTO
		
		dispenv
		
		prepare $X11_XPROTO
		PARAM="--prefix=/usr --host=$MY_TARGET"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_xproto"
		
		exec_cmd "cd $CACHEDIR/x11_xproto"
		exec_cmd "tar czf $CACHEDIR/$X11_XPROTO.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_xproto $TEMPDIR/$X11_XPROTO"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $X11_XPROTO x11_xproto
}
build_x11_xproto()
{	
	build_x11_util_macros
	
	run_task "构建$X11_XPROTO" "compile_x11_xproto"
}

##############################
# 编译 xf86bigfontproto-1.2.0
X11_XF86BIGFONTPROTO=xf86bigfontproto-1.2.0
compile_x11_xf86bigfontproto()
{
	
	if [ ! -e $CACHEDIR/$X11_XF86BIGFONTPROTO.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_XF86BIGFONTPROTO
		
		dispenv
		
		prepare $X11_XF86BIGFONTPROTO
		PARAM="--prefix=/usr --host=$MY_TARGET"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_xf86bigfontproto"
		
		exec_cmd "cd $CACHEDIR/x11_xf86bigfontproto"
		exec_cmd "tar czf $CACHEDIR/$X11_XF86BIGFONTPROTO.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_xf86bigfontproto $TEMPDIR/$X11_XF86BIGFONTPROTO"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $X11_XF86BIGFONTPROTO x11_xf86bigfontproto
}
build_x11_xf86bigfontproto()
{	
	build_x11_util_macros
	
	run_task "构建$X11_XF86BIGFONTPROTO" "compile_x11_xf86bigfontproto"
}
##############################
# 编译 x11_xextproto
X11_XEXTPROTO=xextproto-7.2.1
compile_x11_xextproto()
{
	
	if [ ! -e $CACHEDIR/$X11_XEXTPROTO.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_XEXTPROTO
		
		dispenv
		
		prepare $X11_XEXTPROTO
		PARAM="--prefix=/usr --host=$MY_TARGET"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_xextproto"
		
		exec_cmd "cd $CACHEDIR/x11_xextproto"
		exec_cmd "tar czf $CACHEDIR/$X11_XEXTPROTO.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_xextproto $TEMPDIR/$X11_XEXTPROTO"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $X11_XEXTPROTO x11_xproto
}
build_x11_xextproto()
{	
	build_x11_util_macros
	
	run_task "构建$X11_XEXTPROTO" "compile_x11_xextproto"
}

##############################
# 编译 x11_inputproto
X11_INPUTPROTO=inputproto-2.2
compile_x11_inputproto()
{
	if [ ! -e $CACHEDIR/$X11_INPUTPROTO.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_INPUTPROTO
		
		dispenv
		
		prepare $X11_INPUTPROTO
		PARAM="--prefix=/usr --host=$MY_TARGET"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_inputproto"
		
		exec_cmd "cd $CACHEDIR/x11_inputproto"
		exec_cmd "tar czf $CACHEDIR/$X11_INPUTPROTO.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_inputproto $TEMPDIR/$X11_INPUTPROTO"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $X11_INPUTPROTO x11_xproto
}
build_x11_inputproto()
{
	build_x11_util_macros
	run_task "构建$X11_INPUTPROTO" "compile_x11_inputproto"
}

##############################
# 编译 x11_kbproto
X11_KBPROTO=kbproto-1.0.6
compile_x11_kbproto()
{
	
	if [ ! -e $CACHEDIR/$X11_KBPROTO.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_KBPROTO
		
		dispenv
		
		prepare $X11_KBPROTO
		PARAM="--prefix=/usr --host=$MY_TARGET"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_kbproto"
		
		exec_cmd "cd $CACHEDIR/x11_kbproto"
		exec_cmd "tar czf $CACHEDIR/$X11_KBPROTO.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_kbproto $TEMPDIR/$X11_KBPROTO"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $X11_KBPROTO x11_kbproto
}
build_x11_kbproto()
{
	build_x11_util_macros
	run_task "构建$X11_KBPROTO" "compile_x11_kbproto"
}

##############################
# 编译 x11_renderproto
X11_RENDERPROTO=renderproto-0.11.1
compile_x11_renderproto()
{
	
	if [ ! -e $CACHEDIR/$X11_RENDERPROTO.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_RENDERPROTO
		
		dispenv
		
		prepare $X11_RENDERPROTO
		PARAM="--prefix=/usr --host=$MY_TARGET"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_renderproto"
		
		exec_cmd "cd $CACHEDIR/x11_renderproto"
		exec_cmd "tar czf $CACHEDIR/$X11_RENDERPROTO.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_renderproto $TEMPDIR/$X11_RENDERPROTO"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $X11_RENDERPROTO x11_renderproto
}
build_x11_renderproto()
{
	build_x11_util_macros
	run_task "构建$X11_RENDERPROTO" "compile_x11_renderproto"
}
##############################
# 编译 x11_xtrans
X11_XTRANS=xtrans-1.2.7
compile_x11_xtrans()
{
	
	if [ ! -e $CACHEDIR/$X11_XTRANS.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_XTRANS
		
		dispenv
		
		prepare $X11_XTRANS
		PARAM="--prefix=/usr --host=$MY_TARGET"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_xtrans"
		
		exec_cmd "cd $CACHEDIR/x11_xtrans"
		exec_cmd "tar czf $CACHEDIR/$X11_XTRANS.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_xtrans $TEMPDIR/$X11_XTRANS"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $X11_XTRANS x11_xtrans
}
build_x11_xtrans()
{
	build_x11_util_macros
	run_task "构建$X11_XTRANS" "compile_x11_xtrans"
}

##############################
# 编译 x11_libxau
X11_LIBXAU=libXau-1.0.7
compile_x11_libxau()
{	
	if [ ! -e $CACHEDIR/$X11_LIBXAU.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_LIBXAU
		
		dispenv
		
		prepare $X11_LIBXAU
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static" # 
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_libxau"
		
		exec_cmd "cd $CACHEDIR/x11_libxau"
		exec_cmd "tar czf $CACHEDIR/$X11_LIBXAU.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_libxau $TEMPDIR/$X11_LIBXAU"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib"
	deploy $X11_LIBXAU x11_libxau
}
build_x11_libxau()
{	
	build_x11_util_macros
	
	# Package requirements (xproto)
	build_x11_xproto
	
	run_task "构建$X11_LIBXAU" "compile_x11_libxau"
}

##############################
# 编译 x11_libice
X11_LIBICE=libICE-1.0.8
compile_x11_libice()
{
	
	if [ ! -e $CACHEDIR/$X11_LIBICE.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_LIBICE
		
		dispenv
		
		prepare $X11_LIBICE
		PARAM="--prefix=/usr --host=$MY_TARGET"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_libice"
		
		exec_cmd "cd $CACHEDIR/x11_libice"
		exec_cmd "tar czf $CACHEDIR/$X11_LIBICE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_libice $TEMPDIR/$X11_LIBICE"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib"
	deploy $X11_LIBICE x11_libice
}
build_x11_libice()
{	
	#prerequist: xproto xtrans
	build_x11_xproto
	build_x11_xtrans

	run_task "构建$X11_LIBICE" "compile_x11_libice"
}
##############################
# 编译 x11_libsm
X11_LIBSM=libSM-1.2.1
compile_x11_libsm()
{	
	if [ ! -e $CACHEDIR/$X11_LIBSM.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_LIBSM
		
		dispenv
		
		prepare $X11_LIBSM
		PARAM="--prefix=/usr --host=$MY_TARGET"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_libsm"
		
		exec_cmd "cd $CACHEDIR/x11_libsm"
		exec_cmd "tar czf $CACHEDIR/$X11_LIBSM.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_libsm $TEMPDIR/$X11_LIBSM"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib"
	deploy $X11_LIBSM x11_libsm
}
build_x11_libsm()
{	
	build_x11_util_macros
	
	# prerequist: (ice >= 1.0.5 xproto xtrans)
	build_x11_libice
	#	build_x11_xproto
	#	build_x11_xtrans
	
	run_task "构建$X11_LIBSM" "compile_x11_libsm"
}

##############################
# 编译 libxcb
PTHREAD_STUB=libpthread-stubs-0.3
compile_x11_libpthreadstubs()
{	
	# Package requirements (pthread-stubs xau >= 0.99.2)
	if [ ! -e $CACHEDIR/$PTHREAD_STUB.tar.gz ]; then
		rm -rf $TEMPDIR/$PTHREAD_STUB
		
		dispenv
		
		prepare $PTHREAD_STUB
		PARAM="--prefix=/usr --host=$MY_TARGET"
		exec_cmd "./configure $PARAM"
		exec_cmd "make install DESTDIR=$CACHEDIR/libpthread_stubs"
		
		exec_cmd "cd $CACHEDIR/libpthread_stubs"
		exec_cmd "tar czf $CACHEDIR/$PTHREAD_STUB.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/libpthread_stubs $TEMPDIR/$PTHREAD_STUB"
	fi;
	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $PTHREAD_STUB libpthread_stubs
}
build_x11_libpthreadstubs()
{
	run_task "构建$PTHREAD_STUB" "compile_x11_libpthreadstubs"
}

X11_LIBXCB=libxcb-1.9
X11_XCB_PROTO=xcb-proto-1.8
compile_x11_libxcb()
{
	#Package requirements (xcb-proto >= 1.7)
	if [ ! -e $CACHEDIR/$X11_XCB_PROTO.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_XCB_PROTO
		
		dispenv
		
		prepare $X11_XCB_PROTO
		PARAM="--prefix=/usr --host=$MY_TARGET"
	restore_native_header
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_xcb_proto"
	hide_native_header
		exec_cmd "cd $CACHEDIR/x11_xcb_proto"
		exec_cmd "tar czf $CACHEDIR/$X11_XCB_PROTO.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_xcb_proto $TEMPDIR/$X11_XCB_PROTO"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $X11_XCB_PROTO x11_xcb_proto
	
	if [ ! -e $CACHEDIR/$X11_LIBXCB.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_LIBXCB
		
		dispenv
		
		prepare $X11_LIBXCB libxcb-crosscompiling.patch		# ./configure用variable=xxx来获取变量，不能得到python脚本的路径
		PARAM="--prefix=/usr --host=$MY_TARGET --enable-xinput --enable-xkb --disable-static"
		#exec_cmd "autoreconf -v --install --force"

		exec_cmd "./autogen.sh --help"
    restore_native_header
        exec_cmd "./configure $PARAM"
		exec_cmd "make V=1 -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_libxcb"
    hide_native_header
		
		exec_cmd "cd $CACHEDIR/x11_libxcb"
		exec_cmd "tar czf $CACHEDIR/$X11_LIBXCB.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_libxcb $TEMPDIR/$X11_LIBXCB"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib"
	deploy $X11_LIBXCB x11_libxcb
}
build_x11_libxcb()
{	
	build_x11_util_macros
	
	# Package requirements (pthread-stubs xau >= 0.99.2)
	build_x11_libpthreadstubs
	build_x11_libxau

	run_task "构建$X11_LIBXCB" "compile_x11_libxcb"
}

##############################
# 编译 libX11-1.5.0
X11_LIBX11=libX11-1.5.0
compile_x11_libx11()
{
	if [ ! -e $CACHEDIR/$X11_LIBX11.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_LIBX11
		
		export CFLAGS="$CFLAGS $CROSS_FLAGS"	
		dispenv
		
		prepare $X11_LIBX11 libX11-pkgconfig.patch # ./configure用variable=xxx来获取变量，不能得到xproto的路径
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static --enable-composecache --disable-ipv6 --enable-xthreads --enable-malloc0returnsnull --without-perl"
		exec_cmd "./autogen.sh $PARAM"

		restore_native0
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_libx11"
		hide_native0
		
		exec_cmd "cd $CACHEDIR/x11_libx11"
		exec_cmd "tar czf $CACHEDIR/$X11_LIBX11.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_libx11 $TEMPDIR/$X11_LIBX11"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib /usr/share/X11"
	deploy $X11_LIBX11 x11_libx11
}
build_x11_libx11()
{
	build_x11_util_macros

	# Package requirements (xproto >= 7.0.17 xextproto xtrans xcb >= 1.1.92 kbproto inputproto)
	build_x11_xproto
	build_x11_xextproto
	build_x11_xtrans
	build_x11_libxcb
	build_x11_inputproto
	build_x11_kbproto

	
	run_task "构建$X11_LIBX11" "compile_x11_libx11"
}

##############################
# 编译 libXcomposite-0.4.3
X11_LIBXCOMPOSITE=libXcomposite-0.4.3
compile_x11_libxcomposite()
{
	
	if [ ! -e $CACHEDIR/$X11_LIBXCOMPOSITE.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_LIBXCOMPOSITE
		
		export CFLAGS="$CFLAGS $CROSS_FLAGS"	
		dispenv
		
		prepare $X11_LIBXCOMPOSITE
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_libxcomposite"

		exec_cmd "cd $CACHEDIR/x11_libxcomposite"
		exec_cmd "tar czf $CACHEDIR/$X11_LIBXCOMPOSITE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_libxcomposite $TEMPDIR/$X11_LIBXCOMPOSITE"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib"
	deploy $X11_LIBXCOMPOSITE x11_libxcomposite
}
build_x11_libxcomposite()
{
	build_x11_util_macros

	# Package requirements (compositeproto >= 0.4 x11)
	build_x11_compositeproto
	build_x11_libx11
	
	# Package requirements (xfixes) 
	build_x11_libxfixes
	
	run_task "构建$X11_LIBXCOMPOSITE" "compile_x11_libxcomposite"
}
##############################
# 编译 x11_libxt
X11_LIBXT=libXt-1.1.3
compile_x11_libxt()
{
	if [ ! -e $CACHEDIR/$X11_LIBXT.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_LIBXT
		
		dispenv
		
		prepare $X11_LIBXT
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		
		restore_native0
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_libxt"
		hide_native0
				
		exec_cmd "cd $CACHEDIR/x11_libxt"
		exec_cmd "tar czf $CACHEDIR/$X11_LIBXT.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_libxt $TEMPDIR/$X11_LIBXT"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib"
	deploy $X11_LIBXT x11_libxt
}
build_x11_libxt()
{	
	build_x11_util_macros
	
	# (sm ice x11 xproto kbproto)
	build_x11_libsm
	#	build_x11_libice
	build_x11_libx11
	#	build_x11_kbproto
	build_x11_xproto
	
	run_task "构建$X11_LIBXT" "compile_x11_libxt"
}


##############################
# 编译 libXdamage-1.1.3
X11_LIBXDAMAGE=libXdamage-1.1.3
compile_x11_libxdamage()
{
	if [ ! -e $CACHEDIR/$X11_LIBXDAMAGE.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_LIBXDAMAGE
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link ."
		dispenv
		
		prepare $X11_LIBXDAMAGE
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_libxdamage"
				
		exec_cmd "cd $CACHEDIR/x11_libxdamage"
		exec_cmd "tar czf $CACHEDIR/$X11_LIBXDAMAGE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_libxdamage $TEMPDIR/$X11_LIBXDAMAGE"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib"
	deploy $X11_LIBXDAMAGE x11_libxdamage
}
build_x11_libxdamage()
{	
	build_x11_util_macros

	# Package requirements (damageproto >= 1.1 xfixes fixesproto xextproto x11) 
	build_x11_damageproto
	build_x11_libxfixes
	build_x11_fixesproto
	build_x11_xextproto
	build_x11_libx11
	
	run_task "构建$X11_LIBXDAMAGE" "compile_x11_libxdamage"
}
##############################
# 编译 x11_libxrender
X11_LIBXRENDER=libXrender-0.9.7
compile_x11_libxrender()
{
	if [ ! -e $CACHEDIR/$X11_LIBXRENDER.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_LIBXRENDER
		
		dispenv
		
		prepare $X11_LIBXRENDER
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_libxrender"
				
		exec_cmd "cd $CACHEDIR/x11_libxrender"
		exec_cmd "tar czf $CACHEDIR/$X11_LIBXRENDER.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_libxrender $TEMPDIR/$X11_LIBXRENDER"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib"
	deploy $X11_LIBXRENDER x11_libxrender
}
build_x11_libxrender()
{	
	build_x11_util_macros
	
	# Package requirements (x11 renderproto >= 0.9) 
	build_x11_libx11
	build_x11_renderproto
	
	run_task "构建$X11_LIBXRENDER" "compile_x11_libxrender"
}
##############################
# 编译 x11_libxext
X11_LIBXEXT=libXext-1.3.1
compile_x11_libxext()
{
	if [ ! -e $CACHEDIR/$X11_LIBXEXT.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_LIBXEXT
		
		dispenv
		
		prepare $X11_LIBXEXT
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_libxext"
				
		exec_cmd "cd $CACHEDIR/x11_libxext"
		exec_cmd "tar czf $CACHEDIR/$X11_LIBXEXT.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_libxext $TEMPDIR/$X11_LIBXEXT"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib"
	deploy $X11_LIBXEXT x11_libxext
}
build_x11_libxext()
{	
	build_x11_util_macros
	
	# Package requirements (xproto >= 7.0.13 x11 >= 1.1.99.1 xextproto >= 7.1.99) 
	build_x11_xproto
	build_x11_libx11
	build_x11_xextproto
	
	run_task "构建$X11_LIBXEXT" "compile_x11_libxext"
}

##############################
# 编译 font-util-1.3.0
X11_FONTUTIL=font-util-1.3.0
compile_x11_fontutil()
{
	if [ ! -e $CACHEDIR/$X11_FONTUTIL.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_FONTUTIL
		
		dispenv
		
		prepare $X11_FONTUTIL
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_fontutil"
				
		exec_cmd "cd $CACHEDIR/x11_fontutil"
		exec_cmd "tar czf $CACHEDIR/$X11_FONTUTIL.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_fontutil $TEMPDIR/$X11_FONTUTIL"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST="/usr/bin /usr/share/fonts"
	deploy $X11_FONTUTIL x11_fontutil
}
build_x11_fontutil()
{	
	build_x11_util_macros
	
	run_task "构建$X11_FONTUTIL" "compile_x11_fontutil"
}

##############################
# 编译 glproto-1.4.16( useless )
X11_GLPROTO=glproto-1.4.16
compile_x11_glproto()
{
	if [ ! -e $CACHEDIR/$X11_GLPROTO.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_GLPROTO
		
		dispenv
		
		prepare $X11_GLPROTO
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_glproto"
				
		exec_cmd "cd $CACHEDIR/x11_glproto"
		exec_cmd "tar czf $CACHEDIR/$X11_GLPROTO.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_glproto $TEMPDIR/$X11_GLPROTO"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $X11_GLPROTO x11_glproto
}
build_x11_glproto()
{	
	build_x11_util_macros
	
	run_task "构建$X11_GLPROTO" "compile_x11_glproto"
}

##############################
# 编译 randrproto-1.4.0
X11_RANDRPROTO=randrproto-1.4.0
compile_x11_randrproto()
{
	if [ ! -e $CACHEDIR/$X11_RANDRPROTO.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_RANDRPROTO
		
		dispenv
		
		prepare $X11_RANDRPROTO
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_randrproto"
				
		exec_cmd "cd $CACHEDIR/x11_randrproto"
		exec_cmd "tar czf $CACHEDIR/$X11_RANDRPROTO.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_randrproto $TEMPDIR/$X11_RANDRPROTO"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $X11_RANDRPROTO x11_randrproto
}
build_x11_randrproto()
{	
	build_x11_util_macros
	
	run_task "构建$X11_RANDRPROTO" "compile_x11_randrproto"
}

##############################
# 编译 videoproto-2.3.1
X11_VIDEOPROTO=videoproto-2.3.1
compile_x11_videoproto()
{
	if [ ! -e $CACHEDIR/$X11_VIDEOPROTO.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_VIDEOPROTO
		
		dispenv
		
		prepare $X11_VIDEOPROTO
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_videoproto"
				
		exec_cmd "cd $CACHEDIR/x11_videoproto"
		exec_cmd "tar czf $CACHEDIR/$X11_VIDEOPROTO.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_videoproto $TEMPDIR/$X11_VIDEOPROTO"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $X11_VIDEOPROTO x11_videoproto
}
build_x11_videoproto()
{	
	build_x11_util_macros
	
	run_task "构建$X11_VIDEOPROTO" "compile_x11_videoproto"
}

##############################
# 编译 fontcacheproto-0.1.3
X11_FONTCACHEPROTO=fontcacheproto-0.1.3
compile_x11_fontcacheproto()
{
	if [ ! -e $CACHEDIR/$X11_FONTCACHEPROTO.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_FONTCACHEPROTO
		
		dispenv
		
		prepare $X11_FONTCACHEPROTO
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_fontcacheproto"
				
		exec_cmd "cd $CACHEDIR/x11_fontcacheproto"
		exec_cmd "tar czf $CACHEDIR/$X11_FONTCACHEPROTO.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_fontcacheproto $TEMPDIR/$X11_FONTCACHEPROTO"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $X11_FONTCACHEPROTO x11_fontcacheproto
}
build_x11_fontcacheproto()
{	
	build_x11_util_macros
	
	run_task "构建$X11_FONTCACHEPROTO" "compile_x11_fontcacheproto"
}

##############################
# 编译 fontsproto-2.1.2
X11_FONTSPROTO=fontsproto-2.1.2
compile_x11_fontsproto()
{
	if [ ! -e $CACHEDIR/$X11_FONTSPROTO.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_FONTSPROTO
		
		dispenv
		
		prepare $X11_FONTSPROTO
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_fontsproto"
				
		exec_cmd "cd $CACHEDIR/x11_fontsproto"
		exec_cmd "tar czf $CACHEDIR/$X11_FONTSPROTO.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_fontsproto $TEMPDIR/$X11_FONTSPROTO"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $X11_FONTSPROTO x11_fontsproto
}
build_x11_fontsproto()
{	
	build_x11_util_macros
	
	run_task "构建$X11_FONTSPROTO" "compile_x11_fontsproto"
}

##############################
# 编译 fixesproto-5.0
X11_FIXESPROTO=fixesproto-5.0
compile_x11_fixesproto()
{
	if [ ! -e $CACHEDIR/$X11_FIXESPROTO.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_FIXESPROTO
		
		dispenv
		
		prepare $X11_FIXESPROTO
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_fixesproto"
				
		exec_cmd "cd $CACHEDIR/x11_fixesproto"
		exec_cmd "tar czf $CACHEDIR/$X11_FIXESPROTO.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_fixesproto $TEMPDIR/$X11_FIXESPROTO"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $X11_FIXESPROTO x11_fixesproto
}
build_x11_fixesproto()
{	
	build_x11_util_macros
	
	run_task "构建$X11_FIXESPROTO" "compile_x11_fixesproto"
}


##############################
# 编译 damageproto-1.2.1
X11_DAMAGEPROTO=damageproto-1.2.1
compile_x11_damageproto()
{
	if [ ! -e $CACHEDIR/$X11_DAMAGEPROTO.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_DAMAGEPROTO
		
		dispenv
		
		prepare $X11_DAMAGEPROTO
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_damageproto"
				
		exec_cmd "cd $CACHEDIR/x11_damageproto"
		exec_cmd "tar czf $CACHEDIR/$X11_DAMAGEPROTO.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_damageproto $TEMPDIR/$X11_DAMAGEPROTO"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $X11_DAMAGEPROTO x11_damageproto
}
build_x11_damageproto()
{	
	build_x11_util_macros
	
	run_task "构建$X11_DAMAGEPROTO" "compile_x11_damageproto"
}

##############################
# 编译 xcmiscproto-1.2.2
X11_XCMISCPROTO=xcmiscproto-1.2.2
compile_x11_xcmiscproto()
{
	if [ ! -e $CACHEDIR/$X11_XCMISCPROTO.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_XCMISCPROTO
		
		dispenv
		
		prepare $X11_XCMISCPROTO
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_xcmiscproto"
				
		exec_cmd "cd $CACHEDIR/x11_xcmiscproto"
		exec_cmd "tar czf $CACHEDIR/$X11_XCMISCPROTO.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_xcmiscproto $TEMPDIR/$X11_XCMISCPROTO"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $X11_XCMISCPROTO x11_xcmiscproto
}
build_x11_xcmiscproto()
{	
	build_x11_util_macros
	
	run_task "构建$X11_XCMISCPROTO" "compile_x11_xcmiscproto"
}

##############################
# 编译 bigreqsproto-1.1.2
X11_BIGREQSPROTO=bigreqsproto-1.1.2
compile_x11_bigreqsproto()
{
	if [ ! -e $CACHEDIR/$X11_BIGREQSPROTO.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_BIGREQSPROTO
		
		dispenv
		
		prepare $X11_BIGREQSPROTO
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_bigreqsproto"
				
		exec_cmd "cd $CACHEDIR/x11_bigreqsproto"
		exec_cmd "tar czf $CACHEDIR/$X11_BIGREQSPROTO.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_bigreqsproto $TEMPDIR/$X11_BIGREQSPROTO"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $X11_BIGREQSPROTO x11_bigreqsproto
}
build_x11_bigreqsproto()
{	
	build_x11_util_macros
	
	run_task "构建$X11_BIGREQSPROTO" "compile_x11_bigreqsproto"
}


##############################
# 编译 compositeproto-0.4.2
X11_COMPOSITEPROTO=compositeproto-0.4.2
compile_x11_compositeproto()
{
	if [ ! -e $CACHEDIR/$X11_COMPOSITEPROTO.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_COMPOSITEPROTO
		
		dispenv
		
		prepare $X11_COMPOSITEPROTO
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_compositeproto"
				
		exec_cmd "cd $CACHEDIR/x11_compositeproto"
		exec_cmd "tar czf $CACHEDIR/$X11_COMPOSITEPROTO.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_compositeproto $TEMPDIR/$X11_COMPOSITEPROTO"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $X11_COMPOSITEPROTO x11_compositeproto
}
build_x11_compositeproto()
{	
	build_x11_util_macros
	
	run_task "构建$X11_COMPOSITEPROTO" "compile_x11_compositeproto"
}

##############################
# 编译 recordproto-1.14.2
X11_RECORDPROTO=recordproto-1.14.2
compile_x11_recordproto()
{
	if [ ! -e $CACHEDIR/$X11_RECORDPROTO.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_RECORDPROTO
		
		dispenv
		
		prepare $X11_RECORDPROTO
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_recordproto"
				
		exec_cmd "cd $CACHEDIR/x11_recordproto"
		exec_cmd "tar czf $CACHEDIR/$X11_RECORDPROTO.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_recordproto $TEMPDIR/$X11_RECORDPROTO"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $X11_RECORDPROTO x11_recordproto
}
build_x11_recordproto()
{	
	build_x11_util_macros
	
	run_task "构建$X11_RECORDPROTO" "compile_x11_recordproto"
}

##############################
# 编译 scrnsaverproto-1.2.2
X11_SCRNSAVERPROTO=scrnsaverproto-1.2.2
compile_x11_scrnsaverproto()
{
	if [ ! -e $CACHEDIR/$X11_SCRNSAVERPROTO.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_SCRNSAVERPROTO
		
		dispenv
		
		prepare $X11_SCRNSAVERPROTO
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_scrnsaverproto"
				
		exec_cmd "cd $CACHEDIR/x11_scrnsaverproto"
		exec_cmd "tar czf $CACHEDIR/$X11_SCRNSAVERPROTO.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_scrnsaverproto $TEMPDIR/$X11_SCRNSAVERPROTO"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $X11_SCRNSAVERPROTO x11_scrnsaverproto
}
build_x11_scrnsaverproto()
{	
	build_x11_util_macros
	
	run_task "构建$X11_SCRNSAVERPROTO" "compile_x11_scrnsaverproto"
}

##############################
# 编译 resourceproto-1.2.0
X11_RESOURCEPROTO=resourceproto-1.2.0
compile_x11_resourceproto()
{
	if [ ! -e $CACHEDIR/$X11_RESOURCEPROTO.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_RESOURCEPROTO
		
		dispenv
		
		prepare $X11_RESOURCEPROTO
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_resourceproto"
				
		exec_cmd "cd $CACHEDIR/x11_resourceproto"
		exec_cmd "tar czf $CACHEDIR/$X11_RESOURCEPROTO.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_resourceproto $TEMPDIR/$X11_RESOURCEPROTO"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $X11_RESOURCEPROTO x11_resourceproto
}
build_x11_resourceproto()
{	
	build_x11_util_macros
	
	run_task "构建$X11_RESOURCEPROTO" "compile_x11_resourceproto"
}

##############################
# 编译 xf86driproto-2.1.1
X11_XF86DRIPROTO=xf86driproto-2.1.1
compile_x11_xf86driproto()
{
	if [ ! -e $CACHEDIR/$X11_XF86DRIPROTO.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_XF86DRIPROTO
		
		dispenv
		
		prepare $X11_XF86DRIPROTO
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_xf86driproto"
				
		exec_cmd "cd $CACHEDIR/x11_xf86driproto"
		exec_cmd "tar czf $CACHEDIR/$X11_XF86DRIPROTO.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_xf86driproto $TEMPDIR/$X11_XF86DRIPROTO"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $X11_XF86DRIPROTO x11_xf86driproto
}
build_x11_xf86driproto()
{	
	build_x11_util_macros
	
	run_task "构建$X11_XF86DRIPROTO" "compile_x11_xf86driproto"
}

##############################
# 编译 xineramaproto-1.2.1
X11_XINERAMAPROTO=xineramaproto-1.2.1
compile_x11_xineramaproto()
{
	if [ ! -e $CACHEDIR/$X11_XINERAMAPROTO.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_XINERAMAPROTO
		
		dispenv
		
		prepare $X11_XINERAMAPROTO
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_xineramaproto"
				
		exec_cmd "cd $CACHEDIR/x11_xineramaproto"
		exec_cmd "tar czf $CACHEDIR/$X11_XINERAMAPROTO.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_xineramaproto $TEMPDIR/$X11_XINERAMAPROTO"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $X11_XINERAMAPROTO x11_xineramaproto
}
build_x11_xineramaproto()
{	
	build_x11_util_macros
	
	run_task "构建$X11_XINERAMAPROTO" "compile_x11_xineramaproto"
}

##############################
# 编译 libfontenc-1.1.1
X11_LIBFONTENC=libfontenc-1.1.1
compile_x11_libfontenc()
{
	if [ ! -e $CACHEDIR/$X11_LIBFONTENC.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_LIBFONTENC
		
		dispenv
		
		prepare $X11_LIBFONTENC
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_libfontenc"
				
		exec_cmd "cd $CACHEDIR/x11_libfontenc"
		exec_cmd "tar czf $CACHEDIR/$X11_LIBFONTENC.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_libfontenc $TEMPDIR/$X11_LIBFONTENC"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib"
	deploy $X11_LIBFONTENC x11_libfontenc
}
build_x11_libfontenc()
{	
	build_x11_util_macros
	
	build_x11_fontutil
	build_libz
	
	# Package requirements (xproto) were not met
	build_x11_xproto
	
	run_task "构建$X11_LIBFONTENC" "compile_x11_libfontenc"
}
##############################
# 编译 libXfont-1.4.5
X11_LIBXFONT=libXfont-1.4.5
compile_x11_libXfont()
{
	if [ ! -e $CACHEDIR/$X11_LIBXFONT.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_LIBXFONT
		
		dispenv
		
		prepare $X11_LIBXFONT libXfont-pkgconfig.patch
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_libXfont"
				
		exec_cmd "cd $CACHEDIR/x11_libXfont"
		exec_cmd "tar czf $CACHEDIR/$X11_LIBXFONT.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_libXfont $TEMPDIR/$X11_LIBXFONT"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib"
	deploy $X11_LIBXFONT x11_libXfont
}
build_x11_libXfont()
{	
	build_x11_util_macros
	
    build_libz
    build_libfreetype
    
    #  Package requirements (xproto xtrans fontsproto fontenc) were not met
    build_x11_xproto
	build_x11_xtrans
	build_x11_fontsproto
	build_x11_libfontenc
	
	run_task "构建$X11_LIBXFONT" "compile_x11_libXfont"
}
##############################
# 编译 dri2proto-2.8
X11_DRI2PROTO=dri2proto-2.8
compile_x11_dri2proto()
{
	if [ ! -e $CACHEDIR/$X11_DRI2PROTO.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_DRI2PROTO
		
		dispenv
		
		prepare $X11_DRI2PROTO
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_dri2proto"
				
		exec_cmd "cd $CACHEDIR/x11_dri2proto"
		exec_cmd "tar czf $CACHEDIR/$X11_DRI2PROTO.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_dri2proto $TEMPDIR/$X11_DRI2PROTO"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $X11_DRI2PROTO x11_dri2proto
}
build_x11_dri2proto()
{	
	build_x11_util_macros
	
	run_task "构建$X11_DRI2PROTO" "compile_x11_dri2proto"
}
##############################
# 编译 xkeyboard-config-2.7
X11_XKEYBOARDCONFIG=xkeyboard-config-2.7
compile_x11_xkeyboardconfig()
{
	if [ ! -e $CACHEDIR/$X11_XKEYBOARDCONFIG.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_XKEYBOARDCONFIG
		
		dispenv
		
		prepare $X11_XKEYBOARDCONFIG
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static "
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1 -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_xkeyboardconfig"
				
		exec_cmd "cd $CACHEDIR/x11_xkeyboardconfig"
		exec_cmd "tar czf $CACHEDIR/$X11_XKEYBOARDCONFIG.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_xkeyboardconfig $TEMPDIR/$X11_XKEYBOARDCONFIG"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST="/usr/share/pkgconfig /usr/share/man"
	DEPLOY_DIST="/usr/share"
	deploy $X11_XKEYBOARDCONFIG x11_xkeyboardconfig
}
build_x11_xkeyboardconfig()
{
    # requires the infrastructure from gettext-0.18.1
    build_native_gettext
    
    # must install xorg-macros 1.12 or later before
    build_x11_util_macros
    
    # No package 'xproto' found
    # No package 'x11' found
    build_x11_xproto
    build_x11_libx11
    
	run_task "构建$X11_XKEYBOARDCONFIG" "compile_x11_xkeyboardconfig"
}

##############################
# 编译 libXmu-1.1.1
X11_LIBXMU=libXmu-1.1.1
compile_x11_libxmu()
{
	if [ ! -e $CACHEDIR/$X11_LIBXMU.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_LIBXMU
		
		dispenv
		
		prepare $X11_LIBXMU
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static --disable-docs --enable-unix-transport --enable-tcp-transport --enable-ipv6 --enable-local-transport"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1 -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_libxmu"
				
		exec_cmd "cd $CACHEDIR/x11_libxmu"
		exec_cmd "tar czf $CACHEDIR/$X11_LIBXMU.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_libxmu $TEMPDIR/$X11_LIBXMU"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib"
	deploy $X11_LIBXMU x11_libxmu
}
build_x11_libxmu()
{
	# must install xorg-macros 1.12 or later
	build_x11_util_macros
	
	# Package requirements (xt xext x11 xextproto)
	build_x11_libxt
    build_x11_libxext
    build_x11_libx11
    build_x11_xextproto
	
	run_task "构建$X11_LIBXMU" "compile_x11_libxmu"
}

##############################
# 编译 libXpm-3.5.10
X11_LIBXPM=libXpm-3.5.10
compile_x11_libxpm()
{
	if [ ! -e $CACHEDIR/$X11_LIBXPM.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_LIBXPM
		
		dispenv
		
		prepare $X11_LIBXPM
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1 -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_libxpm"
				
		exec_cmd "cd $CACHEDIR/x11_libxpm"
		exec_cmd "tar czf $CACHEDIR/$X11_LIBXPM.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_libxpm $TEMPDIR/$X11_LIBXPM"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib /usr/lib"
	deploy $X11_LIBXPM x11_libxpm
}
build_x11_libxpm()
{
	# must install xorg-macros 1.12 or later
	build_x11_util_macros
	
	# Package requirements (xproto x11) were not met
    build_x11_libx11
    build_x11_xproto
	
	run_task "构建$X11_LIBXPM" "compile_x11_libxpm"
}

##############################
# 编译 libXaw-1.0.11
X11_LIBXAW=libXaw-1.0.11
compile_x11_libxaw()
{
	if [ ! -e $CACHEDIR/$X11_LIBXAW.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_LIBXAW
		
		dispenv
		
		prepare $X11_LIBXAW
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static --disable-xaw6"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1 -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_libxaw"
				
		exec_cmd "cd $CACHEDIR/x11_libxaw"
		exec_cmd "tar czf $CACHEDIR/$X11_LIBXAW.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_libxaw $TEMPDIR/$X11_LIBXAW"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib /usr/share/doc"
	deploy $X11_LIBXAW x11_libxaw
}
build_x11_libxaw()
{
	# must install xorg-macros 1.12 or later
	build_x11_util_macros
	
	# Package requirements (xproto x11 xext xextproto xt xmu) 
	build_x11_xproto
    build_x11_libx11
    build_x11_libxext
    build_x11_xextproto
    build_x11_libxmu
    build_x11_libxpm
	
	run_task "构建$X11_LIBXAW" "compile_x11_libxaw"
}

# for yacc
NATIVE_PREREQUIRST+=" bison"
##############################
# 编译 xkbcomp-1.2.4
X11_XKBCOMP=xkbcomp-1.2.4
compile_x11_xkbcomp()
{
	if [ ! -e $CACHEDIR/$X11_XKBCOMP.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_XKBCOMP
		# export LIBS="-lxcb -lXau"
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link ."
		dispenv
		
		prepare $X11_XKBCOMP
		PARAM="--prefix=/usr --host=$MY_TARGET"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1 -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_xkbcomp"
				
		exec_cmd "cd $CACHEDIR/x11_xkbcomp"
		exec_cmd "tar czf $CACHEDIR/$X11_XKBCOMP.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_xkbcomp $TEMPDIR/$X11_XKBCOMP"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST="/usr/bin"
	deploy $X11_XKBCOMP x11_xkbcomp
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

##############################
# 编译 twm-1.0.7
X11_TWM=twm-1.0.7
compile_x11_twm()
{
	if [ ! -e $CACHEDIR/$X11_TWM.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_TWM
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link ."
		dispenv
		
		prepare $X11_TWM
		PARAM="--prefix=/usr --host=$MY_TARGET"
		exec_cmd "./configure $PARAM"
		exec_cmd "make V=1 -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_twm"
				
		exec_cmd "cd $CACHEDIR/x11_twm"
		exec_cmd "tar czf $CACHEDIR/$X11_TWM.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_twm $TEMPDIR/$X11_TWM"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST="/usr/bin"
	deploy $X11_TWM x11_twm
}
build_x11_twm()
{
	# Package requirements (x11 xext xt xmu ice sm xproto >= 7.0.17)
	build_x11_libx11
	build_x11_libxext
	build_x11_libxt
	build_x11_libxmu
	build_x11_libice
	build_x11_libsm
	build_x11_libxproto
	
	run_task "构建$X11_TWM" "compile_x11_twm"
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
#		exec_cmd "./autogen.sh $PARAM"
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

##############################
# 编译 libxkbfile-1.0.8
X11_LIBXKBFILE=libxkbfile-1.0.8
compile_x11_libxkbfile()
{
	if [ ! -e $CACHEDIR/$X11_LIBXKBFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_LIBXKBFILE
		
		dispenv
		
		prepare $X11_LIBXKBFILE
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static "
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1 -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_libxkbfile"
				
		exec_cmd "cd $CACHEDIR/x11_libxkbfile"
		exec_cmd "tar czf $CACHEDIR/$X11_LIBXKBFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_libxkbfile $TEMPDIR/$X11_LIBXKBFILE"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib"
	deploy $X11_LIBXKBFILE x11_libxkbfile
}
build_x11_libxkbfile()
{
    build_x11_util_macros
    
    # Package requirements (x11 kbproto) were not met
    build_x11_kbproto
    build_x11_libx11
    
	run_task "构建$X11_LIBXKBFILE" "compile_x11_libxkbfile"
}


##############################
# 编译 libXfixes-5.0
X11_LIBXFIXES=libXfixes-5.0
compile_x11_libxfixes()
{
	if [ ! -e $CACHEDIR/$X11_LIBXFIXES.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_LIBXFIXES
		
		dispenv
		
		prepare $X11_LIBXFIXES
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1 -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_libxfixes"
				
		exec_cmd "cd $CACHEDIR/x11_libxfixes"
		exec_cmd "tar czf $CACHEDIR/$X11_LIBXFIXES.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_libxfixes $TEMPDIR/$X11_LIBXFIXES"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib"
	deploy $X11_LIBXFIXES x11_libxfixes
}
build_x11_libxfixes()
{
    build_x11_util_macros
    
    # Package requirements (xproto fixesproto >= 5.0 xextproto x11) were not met
    build_x11_xproto
    build_x11_fixesproto
    build_x11_xextproto
    build_x11_libx11
    
	run_task "构建$X11_LIBXFIXES" "compile_x11_libxfixes"
}
##############################
# 编译 libdri2-master
X11_LIBDRI2=libdri2-master
compile_x11_libdri2()
{
	if [ ! -e $CACHEDIR/$X11_LIBDRI2.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_LIBDRI2
		
		dispenv
		
		prepare $X11_LIBDRI2
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static --disable-test"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1 -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_libdri2"
				
		exec_cmd "cd $CACHEDIR/x11_libdri2"
		exec_cmd "tar czf $CACHEDIR/$X11_LIBDRI2.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_libdri2 $TEMPDIR/$X11_LIBDRI2"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib"
	deploy $X11_LIBDRI2 x11_libdri2
}
build_x11_libdri2()
{
    build_x11_util_macros
    
    # Package requirements (x11 xext xextproto libdrm) were not met
    build_x11_libx11
    build_x11_xextproto
    build_x11_libxext
    build_x11_libdrm
    
    # fatal error: X11/extensions/dri2proto.h: No such file or directory
    build_x11_dri2proto
    # fatal error: X11/extensions/Xfixes.h: No such file or directory
    build_x11_fixesproto
    build_x11_libxfixes
    
	run_task "构建$X11_LIBDRI2" "compile_x11_libdri2"
}

##############################
# 编译 libXrandr-1.4.0
X11_LIBXRANDR=libXrandr-1.4.0
compile_x11_libxrandr()
{
	if [ ! -e $CACHEDIR/$X11_LIBXRANDR.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_LIBXRANDR
		
		dispenv
		
		prepare $X11_LIBXRANDR
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static "
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1 -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_libxrandr"
				
		exec_cmd "cd $CACHEDIR/x11_libxrandr"
		exec_cmd "tar czf $CACHEDIR/$X11_LIBXRANDR.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_libxrandr $TEMPDIR/$X11_LIBXRANDR"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib"
	deploy $X11_LIBXRANDR x11_libxrandr
}
build_x11_libxrandr()
{	
	# must install xorg-macros 1.8 or later before running autoconf/autogen
	build_x11_util_macros
	
	# Package requirements (x11 randrproto >= 1.4 xext xextproto xrender renderproto) were not met
	build_x11_libx11
	build_x11_randrproto
	build_x11_xextproto
	build_x11_libxext
	build_x11_libxrender
	build_x11_renderproto
	
	run_task "构建$X11_LIBXRANDR" "compile_x11_libxrandr"
}

##############################
# 编译 xrandr-1.3.5
X11_XRANDR=xrandr-1.3.5
compile_x11_xrandr()
{
	if [ ! -e $CACHEDIR/$X11_XRANDR.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_XRANDR
		# export LIBS="-lxcb -lXau -lXrandr -lXext -lXrender -lX11"
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link ."
		dispenv
		
		prepare $X11_XRANDR
		PARAM="--prefix=/usr --host=$MY_TARGET"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1 -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_xrandr"
				
		exec_cmd "cd $CACHEDIR/x11_xrandr"
		exec_cmd "tar czf $CACHEDIR/$X11_XRANDR.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_xrandr $TEMPDIR/$X11_XRANDR"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST="/usr/bin"
	deploy $X11_XRANDR x11_xrandr
}
build_x11_xrandr()
{	
	#  must install xorg-macros 1.8 or later
	build_x11_util_macros
	
	# Package requirements (xrandr >= 1.3 xrender x11 xproto >= 7.0.17) were not met
	build_x11_libxrandr
	build_x11_libxrender
	build_x11_libx11
	build_x11_xproto
		
	run_task "构建$X11_XRANDR" "compile_x11_xrandr"
}
##############################
# 编译 libpciaccess-0.13.1
X11_LIBPCIACCESS=libpciaccess-0.13.1
compile_x11_libpciaccess()
{
	if [ ! -e $CACHEDIR/$X11_LIBPCIACCESS.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_LIBPCIACCESS
		
		dispenv
		
		prepare $X11_LIBPCIACCESS
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static "
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1 -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_libpciaccess"
				
		exec_cmd "cd $CACHEDIR/x11_libpciaccess"
		exec_cmd "tar czf $CACHEDIR/$X11_LIBPCIACCESS.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_libpciaccess $TEMPDIR/$X11_LIBPCIACCESS"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib"
	deploy $X11_LIBPCIACCESS x11_libpciaccess
}
build_x11_libpciaccess()
{	
	# must install xorg-macros 1.8 or later before running autoconf/autogen
	build_x11_util_macros
	
	run_task "构建$X11_LIBPCIACCESS" "compile_x11_libpciaccess"
}

##############################
# 编译 libXi-1.6.1
X11_LIBXI=libXi-1.6.1
compile_x11_libxi()
{
	if [ ! -e $CACHEDIR/$X11_LIBXI.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_LIBXI
		
		dispenv
		
		prepare $X11_LIBXI
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1 -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_libxi"
				
		exec_cmd "cd $CACHEDIR/x11_libxi"
		exec_cmd "tar czf $CACHEDIR/$X11_LIBXI.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_libxi $TEMPDIR/$X11_LIBXI"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib"
	deploy $X11_LIBXI x11_libxi
}
build_x11_libxi()
{	
	build_x11_util_macros
	
	# Package requirements (xproto >= 7.0.13 x11 >= 1.4.99.1 xextproto >= 7.0.3 xext >= 1.0.99.1 inputproto >= 2.1.99.6) were not met:
	build_x11_xproto
	build_x11_libx11
	build_x11_xextproto
	build_x11_libxext
	build_x11_inputproto
		
	run_task "构建$X11_LIBXI" "compile_x11_libxi"
}

##############################
# 编译 libXtst-1.2.1
X11_LIBXTST=libXtst-1.2.1
compile_x11_libxtst()
{
    unset CAIRO_LIBS
	if [ ! -e $CACHEDIR/$X11_LIBXTST.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_LIBXTST
		
		dispenv
		
		prepare $X11_LIBXTST libXtst-depends.patch
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1 -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_libxtst"
				
		exec_cmd "cd $CACHEDIR/x11_libxtst"
		exec_cmd "tar czf $CACHEDIR/$X11_LIBXTST.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_libxtst $TEMPDIR/$X11_LIBXTST"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib"
	deploy $X11_LIBXTST x11_libxtst
}
build_x11_libxtst()
{	
	build_x11_util_macros
	
	#Package requirements (x11 xext >= 1.0.99.4 xi recordproto >= 1.13.99.1 xextproto >= 7.0.99.3 inputproto) were not met
	build_x11_libx11
	build_x11_libxext
	build_x11_libxi
	build_x11_recordproto
	build_x11_xextproto
	build_x11_inputproto
	
	run_task "构建$X11_LIBXTST" "compile_x11_libxtst"
}


##############################
# 编译 xf86-input-evdev-2.7.3
X11_INPUTEVDEV=xf86-input-evdev-2.7.3
compile_x11_inputevdev()
{
	if [ ! -e $CACHEDIR/$X11_INPUTEVDEV.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_INPUTEVDEV
		
		dispenv
		
		prepare $X11_INPUTEVDEV
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1 -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_inputevdev"
				
		exec_cmd "cd $CACHEDIR/x11_inputevdev"
		exec_cmd "tar czf $CACHEDIR/$X11_INPUTEVDEV.tar.gz ."		
		exec_cmd "rm -rf $CACHEDIR/x11_inputevdev $TEMPDIR/$X11_INPUTEVDEV"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/xorg/modules/*.la"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib"
	deploy $X11_INPUTEVDEV x11_inputevdev
}
build_x11_inputevdev()
{	
	# must install xorg-macros 1.8 or later
	build_x11_util_macros
	
	# Package requirements (xorg-server >= 1.10 xproto inputproto) 
	build_xorg_server
	build_x11_xproto
	build_x11_inputproto

	
	run_task "构建$X11_INPUTEVDEV" "compile_x11_inputevdev"
}

##############################
# 编译 libXcursor-1.1.13
X11_LIBXCURSOR=libXcursor-1.1.13
compile_x11_libxcursor()
{
	if [ ! -e $CACHEDIR/$X11_LIBXCURSOR.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_LIBXCURSOR
		
		dispenv
		
		prepare $X11_LIBXCURSOR
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1 -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_libxcursor"
				
		exec_cmd "cd $CACHEDIR/x11_libxcursor"
		exec_cmd "tar czf $CACHEDIR/$X11_LIBXCURSOR.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_libxcursor $TEMPDIR/$X11_LIBXCURSOR"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib"
	deploy $X11_LIBXCURSOR x11_libxcursor
}
build_x11_libxcursor()
{	
	# must install xorg-macros 1.8 or later before running autoconf/autogen
	build_x11_util_macros
	
	# Package requirements (xrender >= 0.8.2 xfixes x11 fixesproto) were not met:
	build_x11_libxrender
	build_x11_libxfixes
	build_x11_libx11
	build_x11_fixesproto
	
	run_task "构建$X11_LIBXCURSOR" "compile_x11_libxcursor"
}
##############################
# 编译 libdrm-2.4.40
X11_LIBDRM=libdrm-2.4.40
compile_x11_libdrm()
{
    unset CAIRO_LIBS
	if [ ! -e $CACHEDIR/$X11_LIBDRM.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_LIBDRM
		
		dispenv
		
		prepare $X11_LIBDRM
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static --disable-radeon --disable-nouveau --disable-vmwgfx --enable-udev --disable-cairo-tests"
		exec_cmd "./configure $PARAM"
		exec_cmd "make V=1 -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_libdrm"
				
		exec_cmd "cd $CACHEDIR/x11_libdrm"
		exec_cmd "tar czf $CACHEDIR/$X11_LIBDRM.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_libdrm $TEMPDIR/$X11_LIBDRM"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib"
	deploy $X11_LIBDRM x11_libdrm
}
build_x11_libdrm()
{	
	# No package 'pthread-stubs' found
	build_x11_libpthreadstubs
	
	# 可选库
	build_udev
	
	run_task "构建$X11_LIBDRM" "compile_x11_libdrm"
}

##############################
# 编译 libXft-2.3.1
X11_LIBXFT=libXft-2.3.1
compile_x11_libxft()
{
	if [ ! -e $CACHEDIR/$X11_LIBXFT.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_LIBXFT
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link ."
		dispenv
		
		prepare $X11_LIBXFT
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1 -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_libxft"
				
		exec_cmd "cd $CACHEDIR/x11_libxft"
		exec_cmd "tar czf $CACHEDIR/$X11_LIBXFT.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_libxft $TEMPDIR/$X11_LIBXFT"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib"
	deploy $X11_LIBXFT x11_libxft
}
build_x11_libxft()
{	
	#  must install xorg-macros 1.8 or later before running autoconf/autogen
	build_x11_util_macros
	
	# Package requirements (xrender >= 0.8.2 x11)
	build_x11_libxrender
	build_x11_libx11
	
	# Package requirements (freetype2 >= 2.1.6)
	build_libfreetype
	
	# Package requirements (fontconfig >= 2.5.92) 
	build_fontconfig
	
	run_task "构建$X11_LIBXFT" "compile_x11_libxft"
}
##############################
# 编译 xf86dgaproto-2.1
X11_XF86DGAPROTO=xf86dgaproto-2.1
compile_x11_xf86dgaproto()
{
	
	if [ ! -e $CACHEDIR/$X11_XF86DGAPROTO.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_XF86DGAPROTO
		
		dispenv
		
		prepare $X11_XF86DGAPROTO
		PARAM="--prefix=/usr --host=$MY_TARGET"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_xf86dgaproto"
		
		exec_cmd "cd $CACHEDIR/x11_xf86dgaproto"
		exec_cmd "tar czf $CACHEDIR/$X11_XF86DGAPROTO.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_xf86dgaproto $TEMPDIR/$X11_XF86DGAPROTO"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $X11_XF86DGAPROTO x11_xf86dgaproto
}
build_x11_xf86dgaproto()
{	
	build_x11_util_macros
	
	run_task "构建$X11_XF86DGAPROTO" "compile_x11_xf86dgaproto"
}

##############################
# 编译 libXxf86dga-1.1.3
X11_LIBXF86DGA=libXxf86dga-1.1.3
compile_x11_libxf86dga()
{
    unset CAIRO_LIBS
	if [ ! -e $CACHEDIR/$X11_LIBXF86DGA.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_LIBXF86DGA
		
		dispenv
		
		prepare $X11_LIBXF86DGA
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static --enable-malloc0returnsnull"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1 -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_libxf86dga"
				
		exec_cmd "cd $CACHEDIR/x11_libxf86dga"
		exec_cmd "tar czf $CACHEDIR/$X11_LIBXF86DGA.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_libxf86dga $TEMPDIR/$X11_LIBXF86DGA"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib"
	deploy $X11_LIBXF86DGA x11_libxf86dga
}
build_x11_libxf86dga()
{	
	# Package requirements (xproto x11 xextproto xext xf86dgaproto >= 2.0.99.2)
	build_x11_xproto
	build_x11_libx11
	build_x11_xextproto
	build_x11_libxext
	build_x11_xf86dgaproto
	
	run_task "构建$X11_LIBXF86DGA" "compile_x11_libxf86dga"
}

###########################
# dvsdk 输出DVSDK_HOME
DVSDKFILE=DVSDK-dist.4.05
GRAPHICSSDKFILE=
copy_dvsdk_ti()
{
	exec_cmd "tar axf $BUILDINDIR/$DVSDKFILE.tar.bz2 -C $SDKDIR"
	LIB_INSTALL_PATH=$SDKDIR/$DVSDKFILE/opt/gfxlibraries/gfx_rel_es3.x
	
	exec_cmd "cd $LIB_INSTALL_PATH"
	sed -i "s/\$(uname \-r)/$LINUXVER/g" install.sh || exit 1;			# 把所有的$(uname -r)替换为linux版本号
	sed -i "s/bc_example.ko/bufferclass_ti.ko/g" install.sh || exit 1;	# 没有bc_example.ko这个文件，替换为bufferclass_ti.ko
	exec_cmd "./install.sh --no-x --root $INSTDIR"
	exec_cmd "mkdir -p $DVSDK_HOME/lib/modules/$LINUXVER"	# 建一个假的库文件目录，骗过DVSDK的安装程序
	exec_cmd "./install.sh --no-x --root $DVSDK_HOME"
	exec_cmd "cp -R $DVSDK_HOME/etc $INSTDIR/"
	cd $INSTDIR/etc/init.d
	sed -i "s/bc_example.ko/bufferclass_ti.ko/g" rc.pvr || exit 1;	# 没有bc_example.ko这个文件，替换为bufferclass_ti.ko
	exec_cmd "rm -rf $DVSDK_HOME/lib $INSTDIR/etc/powervr_ddk_install.log $INSTDIR/etc/init.d/omap-demo"	
	
	cat << _MY_EOF_ >> $INSTDIR/etc/init.d/rcS
#
# powervr-ddk-startup
echo "-------------Starting PowerVR--------------"
#/etc/init.d/rc.pvr start
/etc/init.d/pvr-init start

_MY_EOF_
	
	cd $INSTDIR/etc/init.d
	tar jxf $BUILDINDIR/etc-prg.tar.bz2 pvr-init || exit 3;
	
	cd $INSTDIR/usr/sbin
	rm -r fbset
	tar jxf $BUILDINDIR/etc-prg.tar.bz2 fbset || exit 3;
	
	mv $INSTDIR/ect/init.d/devmem2 $INSTDIR/usr/sbin
}
copy_dvsdk_fsl()
{
exec_cmd "choke"
	export FSL_GPULIB_FILE="amd-gpu-bin-mx51-11.09.01_201112"

	prepare $FSL_GPULIB_FILE
	exec_cmd "cp -Ra . $SDKDIR/"
	
	exec_cmd "mkdir -p $SDKDIR/include/gpusdk $INSTDIR/usr/lib "

	exec_cmd "cp -Ra usr/lib/*.so* 	$INSTDIR/usr/lib"
#	exec_cmd "cp -R usr/lib/*.a 	$SDKDIR/lib"
#	exec_cmd "cp -R usr/include/* $SDKDIR/include/gpusdk"
	
	exec_cmd "rm -rf $TEMPDIR/$FSL_GPULIB_FILE"	
}
copy_dvsdk_fsl_x11()
{
	#export FSL_GPULIB_FILE="amd-gpu-x11-bin-mx51-11.09.01_201112"
	export FSL_GPULIB_FILE="amd-gpu-x11-bin-mx51-new"
	
	prepare $FSL_GPULIB_FILE
	exec_cmd "cp -Ra * $SDKDIR/"
	
	exec_cmd "mkdir -p $INSTDIR/usr/lib $INSTDIR/usr/bin"
	exec_cmd "cp -Ra usr/lib/*.so* 	$INSTDIR/usr/lib"
	exec_cmd "cp -Ra usr/bin/*	$INSTDIR/usr/bin"
	exec_cmd "cd $INSTDIR/lib"
	exec_cmd "sudo ln -s ld-linux.so.3  ld-linux-armhf.so.3"
	
	exec_cmd "rm -rf $TEMPDIR/$FSL_GPULIB_FILE"	
	
#	export LIBZ160_FILE="libz160-bin-11.09.01"
#	prepare $LIBZ160_FILE
#	exec_cmd "cp -Ra * $SDKDIR/"	
#	exec_cmd "mkdir -p $INSTDIR/usr/lib "
#	exec_cmd "cp -Ra usr/lib/*.so* 	$INSTDIR/usr/lib"
#	exec_cmd "rm -rf $TEMPDIR/$LIBZ160_FILE"	
}
copy_dvsdk_ecs()
{
	copy_dvsdk_fsl
}
copy_dvsdk_ecs_x11()
{
	copy_dvsdk_fsl_x11
}
build_dvsdk()
{
exec_cmd "choke"
	run_task "解压$DVSDKFILE" "copy_dvsdk_$PLAT_ALIAS"
}
build_dvsdk_x11()
{
	run_task "解压$DVSDKFILE" "copy_dvsdk_${PLAT_ALIAS}_x11"
}
setenv_dvsdk()
{
case $PLAT_ALIAS in
"ti" )
	export DVSDK_HOME="$SDKDIR/$DVSDKFILE"
	export DVSDK_INC=$DVSDK_HOME/usr/include
	export DVSDK_LIB=$DVSDK_HOME/usr/lib
	export CFLAGS="$CFLAGS -I$DVSDK_INC"
	export LDFLAGS="$LDFLAGS -L$DVSDK_LIB"
	;;
"fsl" )
	export CFLAGS="$CFLAGS -I$SDKDIR/include/gpusdk"
	export LDFLAGS="$LDFLAGS -L$SDKDIR/lib -lgsl-fsl "
	;;
"ecs" )
	export CFLAGS="$CFLAGS -I$SDKDIR/include/gpusdk"
	export LDFLAGS="$LDFLAGS -L$SDKDIR/lib"
	;;
esac	

}

##############################
# 编译 xorg-server
XORG_SERVER=xorg-server-1.13.1
#XORG_SERVER=xorg-server-1.12.4
#XORG_SERVER=xorg-server-1.7.6.902
compile_xorg_server()
{
	if [ ! -e $CACHEDIR/$XORG_SERVER.tar.gz ]; then
		rm -rf $TEMPDIR/$XORG_SERVER
		
		export CFLAGS="$CFLAGS $CROSS_FLAGS -O2"
		export CFLAGS="$CFLAGS -w"	# xorg-server-1.7.6.902有一些无谓的告警被处理为错误
		dispenv
		
		# from ltib
		# --enable-composite  --enable-kdrive --disable-dri --disable-xinerama --disable-xf86vidmode --disable-xnest --enable-xfbdev --disable-dmx --disable-glx --with-default-font-path=built-ins --enable-xorg --enable-dga
		#     --with-default-font-path=built-ins  --enable-dga
		
		##########################################################
		#	xorg-server-1.12.4 以上
		prepare $XORG_SERVER
		PARAM="--prefix=/usr --host=$MY_TARGET --enable-xorg --enable-composite  --enable-kdrive  --disable-static --disable-xf86vidmode --disable-glx --disable-xfbdev --disable-xinerama --disable-docs --disable-devel-docs --disable-unit-tests --disable-debug --disable-xnest  --disable-dmx --enable-dga --disable-xfake --enable-pciaccess --enable-xf86bigfont --disable-xselinux --disable-xcsecurity --enable-vgahw --enable-config-udev --disable-dri --disable-debug"  # --disable-libdrm
		
		##########################################################
		#	xorg-server-1.7.6.902
		# prepare $XORG_SERVER
		# PARAM="--prefix=/usr --localstatedir=/var --host=$MY_TARGET --disable-static --disable-debug --disable-unit-tests --disable-builddocs --disable-sparkle --enable-xorg --enable-composite --disable-xvfb --enable-dga --enable-kdrive  --disable-screensaver  --disable-xf86vidmode --disable-glx --enable-xfbdev --disable-xinerama --disable-xnest  --disable-dmx  --disable-xfake --enable-xf86bigfont --disable-xselinux --disable-xcsecurity --disable-vgahw --disable-dri "  
		
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make V=1 -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/xorg_server"
		
		exec_cmd "cd $CACHEDIR/xorg_server"
		exec_cmd "tar czf $CACHEDIR/$XORG_SERVER.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/xorg_server $TEMPDIR/$XORG_SERVER"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/bin /usr/lib /usr/share/X11 /usr/var"
#	DEPLOY_DIST="/usr/bin /usr/lib /usr/share/X11 /var"
	deploy $XORG_SERVER xorg_server
}
build_xorg_server()
{	
	# must install xorg-macros 1.14 or later before running autoconf/autogen
	build_x11_util_macros
	
	# must install fontutil 1.1 or later before running autoconf/autogen
	build_x11_fontutil
	
    #No suitable SHA1 implementation found
    build_openssl
    
    # for --enable-dga
    # Package requirements (xf86dgaproto >= 2.0.99.1) #DGAPROTO="xf86dgaproto >= 2.0.99.1"
    build_x11_xf86dgaproto
    build_x11_libxf86dga		# ?? 有什么用？
    
    # Package requirements (fixesproto >= 5.0 damageproto >= 1.1 xcmiscproto >= 1.2.0 xtrans >= 1.2.2 bigreqsproto >= 1.1.0 xproto >= 7.0.22 randrproto >= 1.4.0 renderproto >= 0.11 xextproto >= 7.1.99 inputproto >= 2.1.99.6 kbproto >= 1.0.3 fontsproto pixman-1 >= 0.21.8 videoproto compositeproto >= 0.4 recordproto >= 1.13.99.1 scrnsaverproto >= 1.1 resourceproto >= 1.2.0 xf86driproto >= 2.1.0 glproto >= 1.4.16 dri >= 7.8.0 xineramaproto xkbfile  pixman-1 >= 0.21.8 xfont >= 1.4.2 xau) were not met:
	build_x11_xtrans        # xtrans >= 1.2.2
	build_x11_xproto        # xproto >= 7.0.22
	build_x11_inputproto    # inputproto >= 2.1.99.6
	build_x11_randrproto    # randrproto >= 1.4.0
	build_x11_renderproto   # renderproto >= 0.11
	build_x11_kbproto       # kbproto >= 1.0.3
	build_x11_xextproto	    # xextproto >= 7.1.99
	build_x11_fontsproto    # fontsproto
    build_x11_videoproto    # videoproto
    build_pixman          	# pixman-1 >= 0.21.8 ，老版本是build_upstream
    build_x11_libXfont      # xfont >= 1.4.2
    build_x11_fixesproto    # fixesproto >= 5.0
    build_x11_damageproto   # damageproto >= 1.1
    build_x11_libxau        # xau
    build_x11_xcmiscproto   # xcmiscproto >= 1.2.0
    build_x11_bigreqsproto  # bigreqsproto >= 1.1.0
    build_x11_compositeproto    # compositeproto >= 0.4
    build_x11_recordproto   # recordproto >= 1.13.99.1
    build_x11_scrnsaverproto    # scrnsaverproto >= 1.1
    build_x11_resourceproto # resourceproto >= 1.2.0
    build_x11_xineramaproto # xineramaproto
    build_x11_xf86driproto  # xf86driproto >= 2.1.0
    build_x11_libxkbfile    # xkbfile

	# Package requirements (libdrm >= 2.3.0) were not met
	build_x11_libdrm
	
	# LIBUDEV="libudev >= 143"
	build_udev
	
    #DRI2PROTO="dri2proto >= 2.8"
    build_x11_dri2proto
    # ??  dri >= 7.8.0
    build_x11_libdri2
    
    # LIBXEXT="xext >= 1.0.99.4"
	build_x11_libxext

	# --disable-pciaccess
    # LIBPCIACCESS="pciaccess >= 0.12.901"	
	build_x11_libpciaccess
	
	# for driver
	build_x11_libxrandr
	
	# BIGFONTPROTO="xf86bigfontproto >= 1.2.0"
	build_x11_xf86bigfontproto
	
	
#DRIPROTO="xf86driproto >= 2.1.0"
#DMXPROTO="dmxproto >= 2.2.99.1"
#VIDMODEPROTO="xf86vidmodeproto >= 2.2.99.1"
#WINDOWSWMPROTO="windowswmproto"
#APPLEWMPROTO="applewmproto >= 1.4"

#LIBAPPLEWM="applewm >= 1.4"
#LIBDMX="dmx >= 1.0.99.1"
#LIBDRI="dri >= 7.8.0"
#LIBXI="xi >= 1.2.99.1"
#LIBXTST="xtst >= 1.0.99.2"

# disabled!
# LIBGL="gl >= 7.1.0"
#    build_x11_glproto       # glproto >= 1.4.16
#LIBSELINUX="libselinux >= 2.0.86"

# ignored!
#LIBDBUS="dbus-1 >= 1.0"
	
	run_task "构建$XORG_SERVER" "compile_xorg_server"
}

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
		exec_cmd "mkdir -p $CACHEDIR/fbset/usr/sbin"
		exec_cmd "cp fbset $CACHEDIR/fbset/usr/sbin"
		exec_cmd "cd $CACHEDIR/fbset"
		exec_cmd "tar czf $CACHEDIR/$FBSETFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/fbset $TEMPDIR/$FBSETFILE"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST="/usr/sbin"
	deploy $FBSETFILE fbset
}
build_fbset()
{		
	run_task "构建$FBSETFILE" "compile_fbset"
}
##############################
# 编译 xserver-xorg-video-imx-11.09.01
#X11_VIDEOFSL=xserver-xorg-video-imx-11.09.01
X11_VIDEOFSL=xserver-xorg-video-imx-2.0.1
compile_x11_video_fsl()
{
	if [ ! -e $CACHEDIR/$X11_VIDEOFSL.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_VIDEOFSL
		export CFLAGS="$CFLAGS $CROSS_FLAGS -I$SDKDIR/usr/include/xorg"
		dispenv
		
		# prepare $X11_VIDEOFSL								# 对xorg-server-1.7.6
		# prepare $X11_VIDEOFSL xorg-imx-oldapi.patch 		# 对xorg-server-12.4以前版本都不需要修改
		# prepare $X11_VIDEOFSL xorg-imx-newapi.patch 		# 对xorg-server-13.1以后版本都不需要修改
		# prepare $X11_VIDEOFSL								# 网上下载的xserver-xorg-video-new什么都不用改
		# PARAM="--prefix=/usr --host=$MY_TARGET --disable-static --disable-pciaccess"
		
		# xorg-13.1 + imx-2.01
		prepare $X11_VIDEOFSL imx-x11drv-exa26.patch
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static --enable-pciaccess --enable-neon"

		exec_cmd "autoreconf -v --install --force"
		exec_cmd "./configure $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_video_fsl"
		exec_cmd "mkdir -p $CACHEDIR/x11_video_fsl/etc/X11"
		exec_cmd "cp $BUILDINDIR/xorg.conf $CACHEDIR/x11_video_fsl/etc/X11"
				
		exec_cmd "cd $CACHEDIR/x11_video_fsl"
		exec_cmd "tar czf $CACHEDIR/$X11_VIDEOFSL.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_video_fsl $TEMPDIR/$X11_VIDEOFSL"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/xorg/modules/drivers/*.la"
	REMOVE_LIST=""
	DEPLOY_DIST="/usr/lib /etc/X11"
	deploy $X11_VIDEOFSL x11_video_fsl
}
build_x11_video_fsl()
{	
	 # Package requirements (xorg-server >= 1.0.99.901 xproto fontsproto ) were not met
	build_xorg_server
	build_x11_xproto
	build_x11_fontsproto
	
	# checking if RANDR is defined... no
	build_x11_randrproto
	build_x11_libxrandr
	
	build_x11_libpciaccess
	
	build_dvsdk_x11
	
	# 其它配置文件中要求的内容
	# 1. 键盘
	build_x11_xkeyboardconfig
	build_x11_xkbcomp
	build_x11_inputevdev	
	build_x11_xrandr
	build_fbset
	
	run_task "构建$X11_VIDEOFSL" "compile_x11_video_fsl"
}
build_x11_video_ecs()
{
    build_x11_video_fsl
}
