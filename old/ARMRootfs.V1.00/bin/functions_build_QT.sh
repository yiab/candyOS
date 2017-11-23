#!/bin/sh

############################################
# 编译 fontconfig-2.10.2
#FONTCONFIG=fontconfig-2.10.2
FONTCONFIG=fontconfig-2.10.91
compile_fontconfig()
{
	if [ ! -e $CACHEDIR/$FONTCONFIG.tar.gz ]; then
		rm -rf $TEMPDIR/$FONTCONFIG
		export CFLAGS="$CFLAGS $CROSS_FLAGS"
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link ."
		dispenv
		
		prepare $FONTCONFIG
		# PARAM="--prefix=/usr --sysconfdir=/etc --host=$MY_TARGET --disable-static --enable-iconv --with-libiconv=$SDKDIR/usr --enable-libxml2 --disable-docs"
		PARAM="--prefix=/usr --sysconfdir=/etc --host=$MY_TARGET --disable-static --enable-iconv --disable-libxml2 --disable-docs"
		
		exec_cmd "autoreconf --install --force -v"
		exec_cmd "./configure $PARAM "
		exec_cmd "make -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/fontconfig"
				
		exec_cmd "cd $CACHEDIR/fontconfig"
		exec_cmd "tar czf $CACHEDIR/$FONTCONFIG.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/fontconfig $TEMPDIR/$FONTCONFIG"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST="/usr/lib/pkgconfig /usr/include"
	DEPLOY_DIST="/etc /usr"
	deploy $FONTCONFIG fontconfig
}
build_fontconfig()
{	
	# 使用expat而不使用libxml2
	build_expat
	build_libfreetype
	
	run_task "构建$FONTCONFIG" "compile_fontconfig"
}

##############################
# 编译 qt-everywhere-opensource-src-4.8.3
#QTFILE=qt-everywhere-opensource-src-4.8.3
QTFILE=qt-everywhere-opensource-src-4.8.4
QT_X11_PREFIX="/opt/qt-4.8.3-arm"
compile_qt_x11()
{
	
	if [ ! -e $CACHEDIR/$QTFILE.tar.gz ]; then
		# QT太大了，不要放在内存盘中编译
		exec_cmd "mkdir -p $ROOTDIR/qttemp"
		exec_cmd "cd $ROOTDIR/qttemp"
		if [ ! -d $QTFILE ]; then
		    FULLNAME=`(cd $DLDIR; ls -b $QTFILE.tar*)`
		    exec_cmd "cd $ROOTDIR/qttemp"
		    exec_cmd "tar axf $DLDIR/$FULLNAME"
	    fi;

	    exec_cmd "cd $ROOTDIR/qttemp/$QTFILE"	
		if [ -e $ROOTDIR/patch/${MY_TARGET}-qmake.conf ]; then
		    echo "修改QT Mkspecs文件，使用${MY_TARGET}-gcc编译器"
		    exec_cmd "cp $ROOTDIR/patch/${MY_TARGET}-qmake.conf $ROOTDIR/qttemp/$QTFILE/mkspecs/linux-arm-gnueabi-g++/qmake.conf"
		fi;
		
		
		PARAM=" -prefix $QT_X11_PREFIX -opensource -confirm-license -release -shared -largefile -exceptions -stl  -reduce-relocations"
	#	PARAM+=" -system-sqlite -optimized-qmake -fast"
		PARAM+=" -nomake docs " # -nomake tools -nomake examples -nomake demos"
		PARAM+=" -no-qt3support -no-xmlpatterns -no-multimedia -no-audio-backend -no-phonon -no-phonon-backend -no-svg -no-javascript-jit -no-script -no-scripttools -no-declarative -no-declarative-debug"		# 不需要编译的内容
		PARAM+=" -webkit"
       # PARAM+="  -xmlpatterns -multimedia -audio-backend -phonon -phonon-backend -svg -webkit -javascript-jit -script -scripttools -declarative -no-declarative-debug "
        PARAM+=" -system-zlib  -system-libpng -system-libjpeg " # -system-libtiff -system-libmng
        PARAM+=" -gtkstyle -iconv" 
        PARAM+=" -sm -xshape -xsync -no-xinerama -xcursor -xfixes -xrandr -xrender -mitshm -xinput -xkb -glib -egl -opengl es2 -openvg" # -xvideo
        PARAM+=" -arch arm -xplatform linux-arm-gnueabi-g++ -little-endian -host-little-endian -x11 -no-pch" # -embedded arm X11版本不需要的参数
        PARAM+=" -fontconfig" 
        
 		# 生成qmake
		restore_native0
	    ./configure $PARAM 1>>$DBG 2>$WARN
	    hide_native0

		export SDKDIR
		export CROSS_FLAGS="$CROSS_FLAGS -fpermissive"
		export CROSS_FLAGS
		dispenv
		echo "export SDKDIR=$SDKDIR"
		echo "export CROSS_FLAGS=\"$CROSS_FLAGS\""
		#        exec_cmd "mv $SDKDIR/usr/lib/pkgconfig/libpulse-mainloop-glib.pc $SDKDIR/usr/lib/pkgconfig/libpulse-mainloop-glib.pc.bk"
#       exec_cmd "cp $BUILDINDIR/libpulse-mainloop-glib.pc.patch $SDKDIR/usr/lib/pkgconfig/libpulse-mainloop-glib.pc"
		exec_cmd "./configure $PARAM -force-pkg-config"
	restore_native_header
		exec_cmd "make -j 10"
		exec_cmd "make install INSTALL_ROOT=$CACHEDIR/qt_x11"
	hide_native_header
		exec_cmd "cd $CACHEDIR/qt_x11"
		exec_cmd "tar czf $CACHEDIR/$QTFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/qt_x11 "
		
		exec_cmd "cd $ROOTDIR"
		exec_cmd "rm -rf $ROOTDIR/qttemp"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST="$QT_X11_PREFIX/lib/pkgconfig"
	DEPLOY_DIST="$QT_X11_PREFIX/lib $QT_X11_PREFIX/plugins $QT_X11_PREFIX/translations"
	deploy $QTFILE qt_x11
}
build_qt_x11()
{
    build_libz
    build_libpng
    build_libjpeg
    
    build_xorg_server
    build_glib
    build_pulseaudio
    build_dvsdk_x11
    build_openssl
    build_x11_libx11
    
    build_x11_video_fsl
    
    # -lxcb -lXau -lX11 -lXrender -lXfixes -lXrandr -lXext
    build_x11_libx11
    build_x11_libxcursor
    build_x11_libxrandr
    build_x11_libxrender
    build_x11_libxfixes
    build_x11_libxext
    
    build_fontconfig
    
    # for gtk style
    build_gtk2
    build_atk
    
	run_task "构建$QTFILE" "compile_qt_x11"
}

##############################
# 编译 qt5
QT5FILE=qt-everywhere-opensource-src-5.0.0
compile_qt5_x11()
{
	if [ ! -e $CACHEDIR/$QT5FILE.tar.gz ]; then
		# QT太大了，不要放在内存盘中编译
		exec_cmd "mkdir -p $ROOTDIR/qttemp"
		exec_cmd "cd $ROOTDIR/qttemp"
		if [ ! -d $QT5FILE ]; then
		    FULLNAME=`(cd $DLDIR; ls -b $QT5FILE.tar*)`
		    exec_cmd "cd $ROOTDIR/qttemp"
		    exec_cmd "tar axf $DLDIR/$FULLNAME"
	    fi;

	    exec_cmd "cd $ROOTDIR/qttemp/$QT5FILE"	
#		if [ -e $ROOTDIR/patch/${MY_TARGET}-qmake.conf ]; then
#		    echo "修改QT Mkspecs文件，使用${MY_TARGET}-gcc编译器"
#		    exec_cmd "cp $ROOTDIR/patch/${MY_TARGET}-qmake.conf $ROOTDIR/qttemp/$QT5FILE/qtbase/mkspecs/linux-arm-gnueabi-g++/qmake.conf"
#		fi;
		
		PARAM=" -prefix /opt/qt5-arm-x11/ -opensource -confirm-license -release -shared -largefile -reduce-relocations"
	#	PARAM+=" -system-sqlite -optimized-qmake -fast"
		PARAM+=" -nomake docs " # -nomake tools -nomake examples -nomake demos"
        PARAM+=" -system-zlib  -system-libpng -system-libjpeg -dbus " # -system-libtiff -system-libmng
        PARAM+=" -gtkstyle -iconv" 
        PARAM+=" -sm -xshape -xcb -xsync -no-xinerama -xcursor -xfixes -xrandr -xrender -mitshm -xinput -xkb -glib -egl -eglfs -opengl es2 -openvg"
        PARAM+=" -arch arm -xplatform linux-arm-gnueabi-g++ -no-pch" # -embedded arm X11版本不需要的参数 
        PARAM+=" -fontconfig" # -little-endian
        
 		# 生成qmake
		restore_native0
	    ./configure $PARAM 1>>$DBG 2>$WARN
	    hide_native0

		export SDKDIR
		export CROSS_FLAGS="$CROSS_FLAGS -fpermissive"
		export CROSS_FLAGS
		dispenv
		echo "export SDKDIR=$SDKDIR"
		echo "export CROSS_FLAGS=\"$CROSS_FLAGS\""
		#        exec_cmd "mv $SDKDIR/usr/lib/pkgconfig/libpulse-mainloop-glib.pc $SDKDIR/usr/lib/pkgconfig/libpulse-mainloop-glib.pc.bk"
#       exec_cmd "cp $BUILDINDIR/libpulse-mainloop-glib.pc.patch $SDKDIR/usr/lib/pkgconfig/libpulse-mainloop-glib.pc"
		exec_cmd "./configure $PARAM -v -force-pkg-config"
	restore_native_header
		exec_cmd "make -j 10"
		exec_cmd "make install INSTALL_ROOT=$CACHEDIR/qt5_x11"
	hide_native_header
		exec_cmd "cd $CACHEDIR/qt5_x11"
		exec_cmd "tar czf $CACHEDIR/$QT5FILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/qt5_x11 "
		
		exec_cmd "cd $ROOTDIR"
		exec_cmd "rm -rf $ROOTDIR/qttemp"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST="/opt"
	deploy $QT5FILE qt5_x11
}
build_qt5_x11()
{
    build_libz
    build_libpng
    build_libjpeg
    
    build_xorg_server
    build_glib
    build_pulseaudio
    build_dvsdk_x11
    build_openssl
    build_x11_libx11
    
    build_x11_video_fsl
    
    # -lxcb -lXau -lX11 -lXrender -lXfixes -lXrandr -lXext
    build_x11_libx11
    build_x11_libxcursor
    build_x11_libxrandr
    build_x11_libxrender
    build_x11_libxfixes
    build_x11_libxext
    
    build_fontconfig
    
    # for gtk style
    build_gtk2
    build_atk
        
	run_task "构建$QT5FILE" "compile_qt5_x11"
}
###########################
# 编译Qt
#QTFILE=qt-everywhere-opensource-src-4.8.0
compile_qt()
{
	prepare $QTFILE qt-4.8.0-mouseWheel.patch
	cd $TEMPDIR/$QTFILE/mkspecs/qws || exit 1;
	tar axf $BUILDINDIR/linux-omap3-g++.tar.xz
	
	changeoption $TEMPDIR/$QTFILE/mkspecs/qws/linux-omap3-g++/qmake.conf QT_CFLAGS_DIRECTFB "-I$INSTDIR/usr/include/directfb"
	changeoption $TEMPDIR/$QTFILE/mkspecs/qws/linux-omap3-g++/qmake.conf QT_LIBS_DIRECTFB "-L$INSTDIR/usr/lib -ldirectfb -lz -lstdc++ -lpvr2d -lsrv_um -lGLESv2 -lIMGegl -lEGL -lGLES_CM -lusc"
	sed -i 's/load(qt_config)/\#/g' $TEMPDIR/$QTFILE/mkspecs/qws/linux-omap3-g++/qmake.conf
	
	cat << __MY_EOF__ >> $TEMPDIR/$QTFILE/mkspecs/qws/linux-omap3-g++/qmake.conf
QMAKE_INCDIR += $INSTDIR/usr/include
QMAKE_INCDIR += $INSTDIR/usr/include/directfb
QMAKE_INCDIR += $INSTDIR/usr/include/libpng14
QMAKE_INCDIR += $INSTDIR/usr/include/freetype2

QMAKE_LIBDIR += $INSTDIR/usr/lib
QMAKE_LIBS += -lz -lstdc++ -lpvr2d -lsrv_um -lGLESv2 -lIMGegl -lEGL -lGLES_CM -lusc

load(qt_config)
__MY_EOF__

	PARAM="-opensource -confirm-license "
	PARAM+="-prefix /usr/local/qt-lib-4.8.0-directfb -release -v -no-rpath "
	PARAM+="-nomake demos -nomake examples -nomake docs -nomake tools "
	PARAM+="-no-xmlpatterns -no-multimedia -no-audio-backend -no-phonon -no-phonon-backend -no-webkit -no-javascript-jit "
	PARAM+="-no-script -no-s-I$KERNEL_ROOT/includecripttools -no-declarative -no-declarative-debug  -no-nis -no-cups -no-iconv -no-pch -no-dbus -no-svg "
	PARAM+="-no-largefile -no-exceptions -no-stl -no-qt3support -no-optimized-qmake -no-separate-debug-info -no-accessibility "
	PARAM+="-no-sql-db2 -no-sql-ibase -no-sql-mysql -no-sql-oci -no-sql-odbc -no-sql-psql -no-sql-sqlite -no-sql-sqlite2 -no-sql-sqlite_symbian -no-sql-symsql -no-sql-tds "
	PARAM+="-embedded arm -little-endian -host-little-endian -depths all " #-neon
	PARAM+="-xplatform qws/linux-omap3-g++ -platform linux-g++ "
	PARAM+="-qt-gfx-linuxfb -qt-gfx-directfb "
	PARAM+="-qt-kbd-linuxinput "
	PARAM+="-qt-mouse-linuxinput -qt-mouse-pc "
	PARAM+="-system-zlib -system-libpng -system-libjpeg -no-libmng -no-openssl -system-freetype "

	build_libz
	build_libpng
	build_libjpeg
	build_libfreetype
	build_directfb
	
	build_native $QTFILE --dest INSTALL_ROOT=$INSTDIR
}
build_qt()
{
	echo
	#run_task "构建$QTFILE" "compile_qt"
}

build_libiconv()
{
	echo "不应该编译libiconv,而应该使用libc的iconv"
	exec_cmd "choke"
}
