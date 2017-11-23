#!/bin/sh

#####################
# libz
ZLIBFILE="zlib-1.2.6"
compile_libz()
{
	if [ ! -e $CACHEDIR/$ZLIBFILE.tar.gz ]; then
		export CC=$MY_TARGET-gcc
		export CFLAGS="$CFLAGS $CROSS_FLAGS"
		dispenv
		echo CC=`which $CC`
		
		rm -rf $TEMPDIR/$ZLIBFILE
		prepare $ZLIBFILE
		
		PARAM="--prefix=/usr"
		build_native $ZLIBFILE --dest DESTDIR=$CACHEDIR/zlib --inside
		
		exec_cmd "cd $CACHEDIR/zlib"
		exec_cmd "tar czf $CACHEDIR/$ZLIBFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/zlib $TEMPDIR/$ZLIBFILE"
	fi;
	
	DEPLOY_DIST="/usr/lib"
	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"	
	deploy $ZLIBFILE zlib
}
build_libz()
{
	run_task "构建$ZLIBFILE" "compile_libz"
}

#####################
# libpng : libz
#PNGFILE="libpng-1.4.9"
PNGFILE="libpng-1.5.13"
compile_libpng()
{
	if [ ! -e $CACHEDIR/$PNGFILE.tar.gz ]; then
		export CC=$MY_TARGET-gcc
		export CFLAGS="$CFLAGS $CROSS_FLAGS"
		export CPPFLAGS=$CFLAGS		# libpng 特殊要求
		dispenv
	
		prepare $PNGFILE
# for libpng-1.4.9
#		PARAM="--host=$MY_TARGET --target=$MY_TARGET --prefix=/usr --disable-static"
# for libpng-1.5.13
		PARAM="--host=$MY_TARGET --target=$MY_TARGET --prefix=/usr --disable-static --enable-arm-neon"
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/libpng"
		
		exec_cmd "cd $CACHEDIR/libpng"
		exec_cmd "tar czf $CACHEDIR/$PNGFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/libpng $TEMPDIR/$PNGFILE"
	fi;
	
	DEPLOY_DIST="/usr/lib"
	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST="/usr/lib/*.a /usr/lib/pkgconfig"	
	deploy $PNGFILE libpng
}
build_libpng()
{
	build_libz
	run_task "构建$PNGFILE" "compile_libpng"
}

########################
# libjpeg
JPEGFILE="jpeg-8d"
compile_libjpeg()
{
	if [ ! -e $CACHEDIR/$JPEGFILE.tar.gz ]; then
		export CFLAGS="$CFLAGS $CROSS_FLAGS"
		dispenv
		prepare $JPEGFILE
		
		PARAM="--host=$MY_TARGET --target=$MY_TARGET --prefix=/usr --disable-static"
		build_native $JPEGFILE --dest DESTDIR=$CACHEDIR/libjpeg --inside
		
		exec_cmd "cd $CACHEDIR/libjpeg"
		exec_cmd "tar czf $CACHEDIR/$JPEGFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/libjpeg $TEMPDIR/$JPEGFILE"
	fi;
	
	DEPLOY_DIST="/usr/lib"
	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST="/usr/lib/*.a /usr/lib/pkgconfig"	
	deploy $JPEGFILE libjpeg
}
build_libjpeg()
{
	run_task "构建$JPEGFILE" "compile_libjpeg"
}


#################################
# bzip2-1.0.6.tar.gz
BZ2FILE="bzip2-1.0.6"
compile_libbz2()
{
	if [ ! -e $CACHEDIR/$BZ2FILE.tar.gz ]; then
		export CFLAGS="$CFLAGS $CROSS_FLAGS"
		dispenv
		prepare $BZ2FILE
		
		PARAM="--host=$MY_TARGET --target=$MY_TARGET --prefix=/usr --disable-static"
		exec_cmd "mkdir -p $CACHEDIR/libbz2/usr"
		exec_cmd "make install PREFIX='$CACHEDIR/libbz2/usr' CC=${MY_TARGET}-gcc"
		#exec_cmd "make install DESTDIR=$CACHEDIR/libbz2"
				
		exec_cmd "cd $CACHEDIR/libbz2"
		exec_cmd "tar czf $CACHEDIR/$BZ2FILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/libbz2 $TEMPDIR/$BZ2FILE"
	fi;
	
	DEPLOY_DIST=""
	PRE_REMOVE_LIST="/usr/bin"
	REMOVE_LIST=""
	deploy $BZ2FILE libbz2
}
build_libbz2()
{
	run_task "构建$BZ2FILE" "compile_libbz2"
}
###########################
# libfreetype
FREETYPEFILE=freetype-2.4.11
compile_libfreetype()
{
	if [ ! -e $CACHEDIR/$FREETYPEFILE.tar.gz ]; then
		export CFLAGS="$CFLAGS $CROSS_FLAGS"
		dispenv
		prepare $FREETYPEFILE
		sed -i -r 's:.*(#.*SUBPIXEL.*) .*:\1:' include/freetype/config/ftoption.h		# 打开cleartype
		
		PARAM="--host=$MY_TARGET --target=$MY_TARGET --prefix=/usr --sysconfdir=/etc --disable-static --enable-mmap --with-zlib  --with-bzip2"
		
		exec_cmd "./configure $PARAM"
restore_native_header
		exec_cmd "make V=1 -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/libfreetype"
hide_native_header

		exec_cmd "cd $CACHEDIR/libfreetype"
		exec_cmd "tar czf $CACHEDIR/$FREETYPEFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/libfreetype $TEMPDIR/$FREETYPEFILE"
	fi;
	
	DEPLOY_DIST="/usr/lib"
	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST="/usr/lib/*.a /usr/lib/pkgconfig"	
	deploy $FREETYPEFILE libfreetype
}
build_libfreetype()
{
	build_libz
	build_libbz2
	run_task "构建$FREETYPEFILE" "compile_libfreetype"
}

###########################
# directfb
DIRECTFBFILE=DirectFB-1.6.2
compile_directfb_ecs()
{
	compile_directfb_fsl
}
compile_directfb_fsl()
{
	if [ ! -e $CACHEDIR/$DIRECTFBFILE.tar.gz ]; then
		setenv_libz
		setenv_libpng
		setenv_libjpeg
		setenv_libfreetype
		setenv_dvsdk
		
#		export LDFLAGS="$LDFLAGS -lz -lstdc++ -lpvr2d -lsrv_um -lGLESv2 -lIMGegl -lEGL -lGLES_CM -lusc"		#directfb比较变态，这些需要的库都要自己指定
		export CFLAGS="$CFLAGS $CROSS_FLAGS"
		export CXXFLAGS="$CFLAGS -fpermissive"
		export LDFLAGS="$LDFLAGS -lgsl-fsl -lGLESv2 -lEGL -lm"

		dispenv
		prepare $DIRECTFBFILE dfb-fsl-egl.patch
		
		PARAM="--host=$MY_TARGET --prefix=/usr --sysconfdir=/etc --enable-zlib --enable-jpeg --enable-png --enable-freetype "
		PARAM+="--with-gfxdrivers=gles2,gl --with-inputdrivers=none --enable-egl --with-tests --with-tools" #  --without-software #  有bug
		# ti
		# --enable-pvr2d=yes --with-tests --with-inputdrivers=keyboard,linuxinput,ps2mouse,serialmouse --with-gfxdrivers=omap,pvr2d"
		#build_native $DIRECTFBFILE --dest DESTDIR=$CACHEDIR/directfb --inside
		exec_cmd "./configure $PARAM"
		cd $INSTDIR/usr/lib/
		ln -s libEGL.so libGL.so
#		ln -s libGLESv2.so libGLES2_EGL.so
		cd $TEMPDIR/$DIRECTFBFILE
		exec_cmd "make " # -j 10 无法多线程编译
		exec_cmd "make install DESTDIR=$CACHEDIR/directfb"
		exec_cmd "cd $CACHEDIR/directfb"
		exec_cmd "tar czf $CACHEDIR/$DIRECTFBFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/directfb $TEMPDIR/$DIRECTFBFILE"
	fi;
	
	DEPLOY_DIST="/usr/lib /usr/bin"
	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST="/usr/lib/*.a /usr/lib/pkgconfig"	
	deploy $DIRECTFBFILE directfb
	
#	exec_cmd "mkdir -p $SDKDIR/include/directfb $INSTDIR/usr/lib $INSTDIR/usr/bin $CACHEDIR/directfb"
#	exec_cmd "tar xf $CACHEDIR/$DIRECTFBFILE.tar.gz -C $CACHEDIR/directfb"
#	exec_cmd "rm $CACHEDIR/directfb/usr/lib/*.la"
	
#	exec_cmd "cp -R $CACHEDIR/directfb/usr/lib/* $INSTDIR/usr/lib"
#	exec_cmd "cp -R $CACHEDIR/directfb/usr/bin/* $INSTDIR/usr/bin"
#	exec_cmd "cp -R $CACHEDIR/directfb/usr/include/* $SDKDIR/include/directfb"
#	exec_cmd "rm -rf $CACHEDIR/directfb"	
}
build_directfb()
{
	build_libz
	build_libpng
	build_libjpeg
	build_libfreetype
	#build_dvsdk
	build_dvsdk_x11
	run_task "构建$DIRECTFBFILE" "compile_directfb_$PLAT_ALIAS"
}
setenv_directfb()
{
#	export CFLAGS="$CFLAGS -I$INSTDIR/usr/include/directfb"
#	export LDFLAGS="$LDFLAGS -ldirectfb -lpvr2d -lsrv_um -lGLESv2 -lIMGegl -lEGL -lGLES_CM -lusc -lfusion -ldirect"
	echo
}
