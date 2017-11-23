#!/bin/sh

############################################
# 编译 expat-2.1.0 
EXPATFILES=expat-2.1.0
compile_expat()
{
	if [ ! -e $CACHEDIR/$EXPATFILES.tar.gz ]; then
		rm -rf $TEMPDIR/$EXPATFILES
		
		dispenv
		
		prepare $EXPATFILES
		PARAM="--prefix=/usr --sysconfdir=/etc --host=$MY_TARGET --disable-static"
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/expat"
				
		exec_cmd "cd $CACHEDIR/expat"
		exec_cmd "tar czf $CACHEDIR/$EXPATFILES.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/expat $TEMPDIR/$EXPATFILES"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib /usr/bin"
	deploy $EXPATFILES expat
}
build_expat()
{
	run_task "构建$EXPATFILES" "compile_expat"
}

###########################
# dbus-1.6.2
DBUSFILE=dbus-1.6.2
compile_dbus()
{	
	if [ ! -e $CACHEDIR/$DBUSFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$DBUSFILE
		
		export CFLAGS="$CFLAGS $CROSS_FLAGS -fPIC"
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link ."
		dispenv
		
		prepare $DBUSFILE
		
		PARAM="--host=arm-none-linux-gnueabi --prefix=/usr --sysconfdir=/etc --disable-static --disable-selinux --disable-xml-docs --disable-doxygen-docs --enable-tests=no --enable-embedded-tests=no --enable-modular-tests=no --enable-installed-tests=no --with-x  --enable-x11-autolaunch --x-includes=$SDKDIR/usr/include --x-libraries=$SDKDIR/usr/lib" # --with-init-scripts=redhat
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10 "
		exec_cmd "make install DESTDIR=$CACHEDIR/dbus"
		
		exec_cmd "cd $CACHEDIR/dbus"
		
		cat << _MY_EOF_ > $INSTDIR/etc/profile.d/prepDBus
if [ ! -f /usr/var/lib/dbus/machine-id ] ; then
	echo "Prepare machine-id for DBUS environment"
	mkdir -p /usr/var/lib/dbus/
	/usr/bin/dbus-uuidgen --ensure
fi
_MY_EOF_
		exec_cmd "tar czf $CACHEDIR/$DBUSFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/dbus $TEMPDIR/$DBUSFILE"
	fi;
	
	DEPLOY_DIST="/etc /usr/bin /usr/lib /usr/libexec /usr/share /usr/var"
	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST="/usr/lib/pkgconfig /usr/share/doc /usr/share/man"
	deploy $DBUSFILE dbus
	
	## 2. 添加messagebus用户和messagebus组。配置项 /etc/group和/etc/passwd
	mkdir -p $INSTDIR/etc/init.d
	cat << _MY_EOF_ >> $INSTDIR/etc/group
messagebus:x:102:root
_MY_EOF_
	# /etc/passwd
	cat << _MY_EOF_ >> $INSTDIR/etc/passwd
messagebus:x:102:102:messagebus:/var/run/dbus:/bin/sh
_MY_EOF_

	cat << _MY_EOF_ >> $INSTDIR/etc/init.d/25.start-dbus
#!/bin/sh
/usr/bin/dbus-daemon --system &
_MY_EOF_
	chmod 755 $INSTDIR/etc/init.d/25.start-dbus

}
build_dbus()
{
	build_expat
	build_x11_xproto
	
	build_x11_libx11
	build_x11_libice
	build_x11_libsm
		
	run_task "构建$DBUSFILE" "compile_dbus"
}

###########################
# libffi 静态库
LIBFFIFILE=libffi-3.0.11
compile_libffi()
{	
	if [ ! -e $CACHEDIR/$LIBFFIFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$LIBFFIFILE
		
		CFLAGS="$CFLAGS $CROSS_FLAGS -fPIC"
		dispenv
		
		prepare $LIBFFIFILE
		
		PARAM="--host=$MY_TARGET --target=$MY_TARGET --prefix=/usr --disable-shared"
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10 "
		exec_cmd "make install DESTDIR=$CACHEDIR/libffi"
		
		exec_cmd "cd $CACHEDIR/libffi"
		exec_cmd "tar czf $CACHEDIR/$LIBFFIFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/libffi $TEMPDIR/$LIBFFIFILE"
	fi;
	
	DEPLOY_DIST=""
	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	deploy $LIBFFIFILE libffi
}
build_libffi()
{
	build_libz
	
	run_task "构建$LIBFFIFILE" "compile_libffi"
}

###########################
# glib core
#GLIBFILE=glib-2.34.0
GLIBFILE=glib-2.35.4
compile_glib()
{
	if [ ! -e $CACHEDIR/$GLIBFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$GLIBFILE

		export CFLAGS="$CFLAGS $CROSS_FLAGS -w"
		dispenv

		prepare $GLIBFILE
	cat <<_MYOWNEOF_ > my_config.cache
glib_cv_stack_grows=no
glib_cv_uscore=no
ac_cv_func_posix_getpwuid_r=yes
ac_cv_func_posix_getgrgid_r=yes
ac_cv_lib_rt_clock_gettime=no
glib_cv_monotonic_clock=yes
_MYOWNEOF_
		PARAM="--host=$MY_TARGET --prefix=/usr --disable-static --cache-file=my_config.cache --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf --disable-man --disable-gcov --disable-debug --disable-dtrace --disable-modular_tests --enable-iconv-cache=yes --disable-selinux --disable-dtrace --disable-systemtap --without-libiconv --disable-fam" #   --enable-systemtap  
		exec_cmd "autoreconf --force --install -v"
		exec_cmd "./configure $PARAM"
		exec_cmd "make V=1 -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/glib"
				
		exec_cmd "cd $CACHEDIR/glib"
		exec_cmd "tar czf $CACHEDIR/$GLIBFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/glib $TEMPDIR/$GLIBFILE"
		unset CFLAGS
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la "
	REMOVE_LIST="/usr/lib/pkgconfig /usr/share/aclocal /usr/share/gdb /usr/share/man /usr/share/gtk-doc"
	DEPLOY_DIST="/usr/bin /usr/lib /usr/share"
	deploy $GLIBFILE glib
	
	initenv
	if [ ! -e $CACHEDIR/native-$GLIBFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$LIBFFIFILE $TEMPDIR/$GLIBFILE

restore_native0
		unset CPPFLAGS 
		unset CFLAGS
		hash -r
		prepare $LIBFFIFILE
		
		PARAM="--prefix=/usr --disable-shared "

		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10 "
		exec_cmd "make install DESTDIR=$TEMPDIR/libffi-dist"
		
		export CFLAGS="-I$TEMPDIR/libffi-dist/usr/lib/$LIBFFIFILE/include"
		export LDFLAGS="-L$TEMPDIR/libffi-dist/usr/lib"
		dispenv
		prepare $GLIBFILE
		PARAM="--prefix=$SDKDIR/usr --disable-modular_tests --disable-gtk-doc --disable-gcov --disable-debug"
		exec_cmd "./configure $PARAM"
		exec_cmd "make V=1 -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/native-glib"
hide_native0
	
		exec_cmd "cd $CACHEDIR/native-glib/$SDKDIR"
		exec_cmd "tar czf $CACHEDIR/native-$GLIBFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/glib $TEMPDIR/$GLIBFILE $TEMPDIR/libffi-dist $TEMPDIR/$LIBFFIFILE"
	fi;
	
 	PRE_REMOVE_LIST="/usr/include /usr/share /usr/lib"
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy native-$GLIBFILE native-glib
}
build_glib()
{
	# *** Working zlib library and headers not found ***
	build_libz
	
	# Package requirements (libffi >= 3.0.0) were not met
	build_libffi
	
	run_task "构建$GLIBFILE" "compile_glib"
}
deploy_native_glib()
{
	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy native-$GLIBFILE native-glib
}
restore_cross_glib()
{
 	PRE_REMOVE_LIST="/usr/lib/*.la "
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $GLIBFILE glib
	
	PRE_REMOVE_LIST="/usr/include /usr/share /usr/lib"
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy native-$GLIBFILE native-glib
}

###########################
# gnome-atk
#ATKFILE=atk-1.91.92
ATKFILE=atk-2.7.4
compile_atk()
{
	if [ ! -e $CACHEDIR/$ATKFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$ATKFILE
		
		CFLAGS="$CFLAGS $CROSS_FLAGS "
		dispenv
		
		prepare $ATKFILE atk-use-deprecate-glib.patch
		
		PARAM="--host=$MY_TARGET --target=$MY_TARGET --prefix=/usr --disable-static --disable-glibtest --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf --with-gnu-ld "
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10 "
		exec_cmd "make install DESTDIR=$CACHEDIR/atk"
		
		exec_cmd "cd $CACHEDIR/atk"
		exec_cmd "tar czf $CACHEDIR/$ATKFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/atk $TEMPDIR/$ATKFILE"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la "
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib /usr/share/locale"
	deploy $ATKFILE atk
}
build_atk()
{
	build_glib
	run_task "构建$ATKFILE" "compile_atk"
}

###########################
# 编译 at-spi2-core-2.7.4
ATKSPI2FILE=at-spi2-core-2.7.4
compile_atk_spi2()
{
	if [ ! -e $CACHEDIR/$ATKSPI2FILE.tar.gz ]; then
		rm -rf $TEMPDIR/$ATKSPI2FILE
		
		export CFLAGS="$CFLAGS $CROSS_FLAGS "
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link ."
		dispenv
		
		prepare $ATKSPI2FILE
		
		PARAM="--host=$MY_TARGET --target=$MY_TARGET --prefix=/usr --disable-static"
		exec_cmd "autoreconf --install --force -v"
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10 "
		exec_cmd "make install DESTDIR=$CACHEDIR/atk_spi2"
		
		exec_cmd "cd $CACHEDIR/atk_spi2"
		exec_cmd "tar czf $CACHEDIR/$ATKSPI2FILE.tar.gz ."
exit;
		exec_cmd "rm -rf $CACHEDIR/atk_spi2 $TEMPDIR/$ATKSPI2FILE"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la "
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib /usr/share/locale"
	deploy $ATKSPI2FILE atk_spi2
}
build_atk_spi2()
{
	build_atk
	build_dbus
	build_xorg_server
	run_task "构建$ATKSPI2FILE" "compile_atk_spi2"
}

###########################
# 编译 at-spi2-atk-2.7.3
ATKBRIDGEFILE=at-spi2-atk-2.7.3
compile_atk_bridge()
{
	if [ ! -e $CACHEDIR/$ATKBRIDGEFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$ATKBRIDGEFILE
		
		CFLAGS="$CFLAGS $CROSS_FLAGS "
		dispenv
		
		prepare $ATKBRIDGEFILE
		
		PARAM="--host=$MY_TARGET --target=$MY_TARGET --prefix=/usr --disable-static"
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10 "
		exec_cmd "make install DESTDIR=$CACHEDIR/atk_bridge"
		
		exec_cmd "cd $CACHEDIR/atk_bridge"
		exec_cmd "tar czf $CACHEDIR/$ATKBRIDGEFILE.tar.gz ."
exit;
		exec_cmd "rm -rf $CACHEDIR/atk_bridge $TEMPDIR/$ATKBRIDGEFILE"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la "
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib /usr/share/locale"
	deploy $ATKBRIDGEFILE atk_bridge
}
build_atk_bridge()
{
	build_atk_spi2
	build_atk
	build_dbus
	run_task "构建$ATKBRIDGEFILE" "compile_atk_bridge"
}

###########################
# pixman-0.28.0
PIXMANFILE=pixman-0.28.0
compile_pixman()
{
	if [ ! -e $CACHEDIR/$PIXMANFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$PIXMANFILE
		
		CFLAGS="$CFLAGS $CROSS_FLAGS "
		LDFLAGS="$LDFLAGS -lz"
		export PATH=/usr/local/arm/arm-yiab-linux-gnueabi/usr/bin:$PATH
		export MY_TARGET=arm-yiab-linux-gnueabi
		dispenv
		
		prepare $PIXMANFILE 
		
		PARAM="--host=$MY_TARGET --target=$MY_TARGET --prefix=/usr --disable-static --enable-libpng --enable-arm-neon --enable-openmp --enable-gcc-inline-asm"
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/pixman"
		
		exec_cmd "cd $CACHEDIR/pixman"
		exec_cmd "tar czf $CACHEDIR/$PIXMANFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/pixman $TEMPDIR/$PIXMANFILE"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib"
	deploy $PIXMANFILE pixman
}
build_pixman()
{
	build_libpng
	
	run_task "构建$PIXMANFILE" "compile_pixman"
}

###########################
# cairo-1.12.8
#CAIROFILE=cairo-1.12.8
CAIROFILE=cairo-1.12.10
compile_cairo()
{
	if [ ! -e $CACHEDIR/$CAIROFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$CAIROFILE
		
		export CFLAGS="$CFLAGS $CROSS_FLAGS"	# _LINUX是为了openvg
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link ."
		dispenv
		prepare $CAIROFILE # cairo-xrender.patch
		
		PARAM="--host=$MY_TARGET --prefix=/usr --sysconfdir=/etc --disable-static --with-x "
		PARAM+=" --enable-fc --enable-ft --enable-xlib --enable-xlib-xrender "
				
		exec_cmd "./configure $PARAM"
		printf "all:\ninstall:\n" > doc/Makefile
		exec_cmd "make -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/cairo"
		
		exec_cmd "cd $CACHEDIR/cairo"
		exec_cmd "tar czf $CACHEDIR/$CAIROFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/cairo $TEMPDIR/$CAIROFILE"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la "
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib /usr/bin"
	deploy $CAIROFILE cairo
}
build_cairo()
{
	build_glib
	build_libz
	build_libpng
	build_pixman
	build_libfreetype
	build_fontconfig
	
	build_x11_xproto
	build_x11_libx11		# fsl egl需要
#	build_x11_libxcb
	build_x11_libxext		# fsl egl需要
	build_x11_libxrender	# fsl egl需要
		
#	build_dvsdk_x11
#	build_expat
		
	run_task "构建$CAIROFILE" "compile_cairo"
}
compile_cairo_again()
{
	if [ ! -e $CACHEDIR/$CAIROFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$CAIROFILE
		
		export CFLAGS="$CFLAGS $CROSS_FLAGS -D_LINUX"	# _LINUX是为了openvg
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link ."
		dispenv
		prepare $CAIROFILE cairo-xrender.patch
		PARAM="--host=$MY_TARGET --prefix=/usr --sysconfdir=/etc --disable-static --with-x"

		
		exec_cmd "./configure $PARAM"
		printf "all:\ninstall:\n" > doc/Makefile
		exec_cmd "make -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/cairo"
		
		exec_cmd "cd $CACHEDIR/cairo"
		exec_cmd "tar czf $CACHEDIR/$CAIROFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/cairo $TEMPDIR/$CAIROFILE"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la "
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib /usr/bin"
	deploy $CAIROFILE cairo
}
build_cairo_again()
{
	build_gtk2
		
	run_task "构建$CAIROFILE" "compile_cairo"
}

###########################
# pango-1.28.3
#PANGOFILE=pango-1.28.3
PANGOFILE=pango-1.32.6
compile_pango()
{
	if [ ! -e $CACHEDIR/$PANGOFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$PANGOFILE
		
		export CFLAGS="$CFLAGS $CROSS_FLAGS "
		export CXXFLAGS="$CFLAGS $CROSS_FLAGS "
		export CPPFLAGS="$CFLAGS $CROSS_FLAGS "
		export CXX="$MY_TARGET-g++"
		export CPP="$MY_TARGET-cpp"
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link ."
		dispenv
		
		prepare $PANGOFILE 
		
		# pango-1.28.3
		# PARAM="--host=$MY_TARGET --target=$MY_TARGET --prefix=/usr --disable-static --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf --disable-man --disable-doc-cross-references --with-x "
		PARAM="--host=$MY_TARGET --prefix=/usr --sysconfdir=/etc --disable-static "
		# PARAM+=" --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf --disable-man --disable-doc-cross-references  --with-gnu-ld --without-xft"
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/pango"
		
		exec_cmd "cd $CACHEDIR/pango"
		exec_cmd "tar czf $CACHEDIR/$PANGOFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/pango $TEMPDIR/$PANGOFILE"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la "
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/bin /usr/lib"
	deploy $PANGOFILE pango
}
build_pango()
{
	build_fontconfig
	build_harfbuzz
	build_glib
	
	build_cairo
	build_libfreetype
	build_x11_libxft
	
#	build_xorg_server
#	build_x11_libXfont
#	build_x11_libx11
	
	run_task "构建$PANGOFILE" "compile_pango"
}

###########################
# harfbuzz-0.9.12
HARFBUZZFILE=harfbuzz-0.9.12
compile_harfbuzz()
{
	if [ ! -e $CACHEDIR/$HARFBUZZFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$HARFBUZZFILE
		
		export CFLAGS="$CFLAGS $CROSS_FLAGS -fPIC"
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link ."
		
		dispenv
		
		prepare $HARFBUZZFILE 
		PARAM="--host=$MY_TARGET --prefix=/usr --disable-static --with-gnu-ld "
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/harfbuzz"
		
		exec_cmd "cd $CACHEDIR/harfbuzz"
		exec_cmd "tar czf $CACHEDIR/$HARFBUZZFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/harfbuzz $TEMPDIR/$HARFBUZZFILE"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la "
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/bin /usr/lib"
	deploy $HARFBUZZFILE harfbuzz
}
build_harfbuzz()
{
	build_glib
	build_libfreetype
#	build_cairo
	
	run_task "构建$HARFBUZZFILE" "compile_harfbuzz"
}

###########################
# tiff-4.0.3
LIBTIFF=tiff-4.0.3
compile_libtiff()
{
	if [ ! -e $CACHEDIR/$LIBTIFF.tar.gz ]; then
		rm -rf $TEMPDIR/$LIBTIFF
		
		dispenv
		export CFLAGS="$CFLAGS $CROSS_FLAGS -fPIC"
		prepare $LIBTIFF 
		
		PARAM="--host=$MY_TARGET --prefix=/usr --disable-static --enable-ccitt --enable-packbits --enable-lzw --enable-thunder --enable-next --enable-logluv --enable-zlib --enable-jpeg --with-x"
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/libtiff"
		
		exec_cmd "cd $CACHEDIR/libtiff"
		exec_cmd "tar czf $CACHEDIR/$LIBTIFF.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/libtiff $TEMPDIR/$LIBTIFF"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la "
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/bin /usr/lib"
	deploy $LIBTIFF libtiff
}
build_libtiff()
{
	build_libz
	build_libjpeg
	
#	build_xorg_server
	
	run_task "构建$LIBTIFF" "compile_libtiff"
}

#

###########################
# desktop-file-utils-0.21
DESKTOP_FILEUTILS=desktop-file-utils-0.21
compile_desktop_fileutils()
{
	if [ ! -e $CACHEDIR/$DESKTOP_FILEUTILS.tar.gz ]; then
		rm -rf $TEMPDIR/$DESKTOP_FILEUTILS
		
		dispenv
		export CFLAGS="$CFLAGS $CROSS_FLAGS -fPIC"
		prepare $DESKTOP_FILEUTILS 
		
		PARAM="--host=$MY_TARGET --target=$MY_TARGET --prefix=/usr --disable-static "
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/desktop_fileutils"
		
		exec_cmd "cd $CACHEDIR/desktop_fileutils"
		exec_cmd "tar czf $CACHEDIR/$DESKTOP_FILEUTILS.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/desktop_fileutils $TEMPDIR/$DESKTOP_FILEUTILS"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la "
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/bin /usr/lib"
	deploy $DESKTOP_FILEUTILS desktop_fileutils
}
build_desktop_fileutils()
{
	build_glib
	
	run_task "构建$DESKTOP_FILEUTILS" "compile_desktop_fileutils"
}

###########################
# gdk-pixbuf-2.26.5
GDKPIXBUF=gdk-pixbuf-2.26.5
compile_gdkpixbuf()
{
	if [ ! -e $CACHEDIR/$GDKPIXBUF.tar.gz ]; then
		rm -rf $TEMPDIR/$GDKPIXBUF
		
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link ."
		export CFLAGS="$CFLAGS $CROSS_FLAGS"
		export CPPFLAGS="$CFLAGS $CROSS_FLAGS"
		dispenv
		
		prepare $GDKPIXBUF 
		
		PARAM="--host=$MY_TARGET --target=$MY_TARGET --prefix=/usr --sysconfdir=/etc --disable-static --with-libpng --with-libjpeg --with-libtiff --with-x11 --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf --disable-man --disable-rpath --disable-debug --enable-nls" # --disable-glibtest 

		exec_cmd "./configure enable_gio_sniffing=no $PARAM"
		exec_cmd "make -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/gdkpixbuf"
		
		exec_cmd "cd $CACHEDIR/gdkpixbuf"
		exec_cmd "tar czf $CACHEDIR/$GDKPIXBUF.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/gdkpixbuf $TEMPDIR/$GDKPIXBUF"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la "
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/bin /usr/lib /usr/share/locale"
	deploy $GDKPIXBUF gdkpixbuf
}
build_gdkpixbuf()
{
	build_glib
	build_libtiff
	build_libjpeg
	build_libpng
	
	build_x11_libx11
	# 
	# build_desktop_fileutils	# 必须这个包识别MIME类型
	
	run_task "构建$GDKPIXBUF" "compile_gdkpixbuf"
}

###########################
# dbus-glib-0.100
DBUSGLIBFILE=dbus-glib-0.100
compile_dbusglib()
{
	if [ ! -e $CACHEDIR/$DBUSGLIBFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$DBUSGLIBFILE
		
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link ."
		export CFLAGS="$CFLAGS $CROSS_FLAGS"
		export CPPFLAGS="$CFLAGS $CROSS_FLAGS"
		dispenv
		
		prepare $DBUSGLIBFILE 
		PARAM="--host=$MY_TARGET --target=$MY_TARGET --prefix=/usr --disable-static --disable-tests"
		PARAM+=" --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf"
		PARAM+=" --disable-tests --disable-ansi --disable-verbose-mode --disable-asserts --disable-checks --disable-gcov"
		PARAM+=" --enable-bash-completion ac_cv_have_abstract_sockets=yes"
		exec_cmd "./configure $PARAM"
		
		# 禁用demo
		printf "all:\ninstall:\n" > doc/Makefile
		printf "all:\ninstall:\n" > test/Makefile
		printf "all:\ninstall:\n" > dbus/examples/Makefile
		printf "all:\ninstall:\n" > tools/Makefile
		
		exec_cmd "make -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/dbusglib"
		
		exec_cmd "cd $CACHEDIR/dbusglib"
		exec_cmd "tar czf $CACHEDIR/$DBUSGLIBFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/dbusglib $TEMPDIR/$DBUSGLIBFILE"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/bin /usr/lib /usr/libexec /usr/etc"
	deploy $DBUSGLIBFILE dbusglib
}
build_dbusglib()
{
	build_expat
	build_dbus
	build_glib
	
	run_task "构建$DBUSGLIBFILE" "compile_dbusglib"
}

###########################
# gnome-mime-data-2.18.0
GNOME_MIME_DATA=gnome-mime-data-2.18.0
compile_gnome_mime_data()
{
	if [ ! -e $CACHEDIR/$GNOME_MIME_DATA.tar.gz ]; then
		rm -rf $TEMPDIR/$GNOME_MIME_DATA
		export CFLAGS="$CFLAGS $CROSS_FLAGS"
		dispenv
		
		prepare $GNOME_MIME_DATA 
		
		PARAM="--host=$MY_TARGET --prefix=/usr --disable-static"
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10 install DESTDIR=$CACHEDIR/gnome_mime_data"
		
		exec_cmd "cd $CACHEDIR/gnome_mime_data"
		exec_cmd "tar czf $CACHEDIR/$GNOME_MIME_DATA.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/gnome_mime_data $TEMPDIR/$GNOME_MIME_DATA"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST="/usr"
	deploy $GNOME_MIME_DATA gnome_mime_data
}
build_gnome_mime_data()
{
	run_task "构建$GNOME_MIME_DATA" "compile_gnome_mime_data"
}

###########################
# popt-1.16
POPTFILE=popt-1.16
compile_popt()
{
	if [ ! -e $CACHEDIR/$POPTFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$POPTFILE
		export CFLAGS="$CFLAGS $CROSS_FLAGS"
		dispenv
		
		prepare $POPTFILE 
		
		PARAM="--host=$MY_TARGET --prefix=/usr --disable-static --disable-rpath --enable-nls"
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10 install DESTDIR=$CACHEDIR/popt"
		
		exec_cmd "cd $CACHEDIR/popt"
		exec_cmd "tar czf $CACHEDIR/$POPTFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/popt $TEMPDIR/$POPTFILE"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la "
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib"
	deploy $POPTFILE popt
}
build_popt()
{	
	run_task "构建$POPTFILE" "compile_popt"
}

###########################
# ORBit2-2.14.19
ORBITFILE=ORBit2-2.14.19
NATIVE_PREREQUIRST+=" libidl-dev"
compile_orbit()
{
	if [ ! -e $CACHEDIR/$ORBITFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$ORBITFILE

		if [[ $PLAT_ALIAS == "ecs" || $PLAT_ALIAS == "fsl" ]]; then
		PARAM="--disable-static --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf --disable-debug ac_cv_alignof_CORBA_octet=1 ac_cv_alignof_CORBA_boolean=1 ac_cv_alignof_CORBA_char=1 ac_cv_alignof_CORBA_wchar=2 ac_cv_alignof_CORBA_short=2 ac_cv_alignof_CORBA_long=4 ac_cv_alignof_CORBA_long_long=8 ac_cv_alignof_CORBA_float=4 ac_cv_alignof_CORBA_double=8 ac_cv_alignof_CORBA_long_double=8 ac_cv_alignof_CORBA_struct=1 ac_cv_alignof_CORBA_pointer=4"
		else
			echo "Don't know how to build on other platform, yet!"
			exec_cmd "choke"
		fi;
		
		prepare $ORBITFILE
		
		if [ ! -e $CACHEDIR/native-$ORBITFILE.tar.gz ]; then
restore_native0
			exec_cmd "./configure --prefix=$SDKDIR/usr $PARAM"
			exec_cmd "make -j 10 install DESTDIR=$CACHEDIR/native-orbit"
			exec_cmd "make clean"
hide_native0
			exec_cmd "cd $CACHEDIR/native-orbit/$SDKDIR"
			exec_cmd "tar czf $CACHEDIR/native-$ORBITFILE.tar.gz ."
			exec_cmd "rm -rf $CACHEDIR/native-orbit"
		fi;
		
		PRE_REMOVE_LIST="/usr/lib/*.la "
		REMOVE_LIST=""
		DEPLOY_DIST=""
		deploy native-$ORBITFILE native-orbit
	
		exec_cmd "cd $TEMPDIR/$ORBITFILE"		
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link ."
		export CFLAGS="$CFLAGS $CROSS_FLAGS"
		dispenv		
		
		PARAM="--host=$MY_TARGET --prefix=/usr $PARAM --with-idl-compiler=$SDKDIR/usr/bin/orbit-idl-2"
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10 install DESTDIR=$CACHEDIR/orbit "
		
		exec_cmd "cd $CACHEDIR/orbit"
		exec_cmd "tar czf $CACHEDIR/$ORBITFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/orbit $TEMPDIR/$ORBITFILE"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la "
	REMOVE_LIST="/usr/lib/pkgconfig /usr/lib/*.a"
	DEPLOY_DIST="/usr/bin /usr/lib /usr/share/idl"
	deploy $ORBITFILE orbit

	PRE_REMOVE_LIST="/usr/lib /usr/share /usr/include"
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy native-$ORBITFILE native-orbit
}
build_orbit()
{	
	# libIDL-2.0 >= 0.8.2 	glib-2.0 >= 2.8.0 	gobject-2.0 >= 2.8.0 	gmodule-2.0 >= 2.8.0
	build_glib
	build_libidl
	
	run_task "构建$ORBITFILE" "compile_orbit"
}

###########################
# libIDL-0.8.14
LIBIDLFILE=libIDL-0.8.14
compile_libidl()
{
	if [ ! -e $CACHEDIR/$LIBIDLFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$LIBIDLFILE
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link ."
		export CFLAGS="$CFLAGS $CROSS_FLAGS"
		dispenv
		
		prepare $LIBIDLFILE 
		
		PARAM="--host=$MY_TARGET --prefix=/usr --disable-static libIDL_cv_long_long_format=ll"

		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/libidl"
		
		exec_cmd "cd $CACHEDIR/libidl"
		exec_cmd "tar czf $CACHEDIR/$LIBIDLFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/libidl $TEMPDIR/$LIBIDLFILE"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la "
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib /usr/share"
	deploy $LIBIDLFILE libidl
}
build_libidl()
{
	# glib-2.0 >= 2.4.0
	build_glib
	
	run_task "构建$LIBIDLFILE" "compile_libidl"
}

##############################
# 编译 gtk+-2.24.3
GTK2FILES=gtk+-2.24.3
#GTK2FILES=gtk+-2.99.3
compile_gtk2()
{
	if [ ! -e $CACHEDIR/$GTK2FILES.tar.gz ]; then
		rm -rf $TEMPDIR/$GTK2FILES
		export CFLAGS="$CFLAGS $CROSS_FLAGS "
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link . -lgmodule-2.0"
		dispenv
		
		prepare $GTK2FILES
		PARAM="--prefix=/usr --host=$MY_TARGET --sysconfdir=/etc --disable-static --disable-maintainer-mode --disable-glibtest  --disable-test-print-backend  --disable-glibtest --enable-debug=yes --disable-cups"
		PARAM+=" --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf --disable-man"
		PARAM+=" --with-x --disable-xinerama  --enable-shm" # --disable-xkb
		PARAM+=" --enable-schemas-compile --with-gdktarget=x11"
		PARAM+=" --disable-test-print-backend --disable-papi --disable-cups"
		PARAM+=" ac_cv_func_mmap_fixed_mapped=yes"

		exec_cmd "./configure $PARAM"
		# 禁用demo
		printf "all:\ninstall:\n" > docs/Makefile
		printf "all:\ninstall:\n" > demos/Makefile
		printf "all:\ninstall:\n" > examples/Makefile
		printf "all:\ninstall:\n" > demos/gtk-demo/Makefile
		printf "all:\ninstall:\n" > tests/Makefile
		printf "all:\ninstall:\n" > gtk/tests/Makefile
		exec_cmd "make -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/gtk2"
			
		exec_cmd "cd $CACHEDIR/gtk2"
		exec_cmd "mkdir -p etc/profile.d"
	
		# 生成配置文件
		cat << _MY_EOF_ > etc/profile.d/setEnvGtk2
#!/bin/sh
if [ ! -f /etc/gtk-2.0/gdk-pixbuf.loaders ] ; then
	echo "Creating gdk-pixbuf.loaders for the first-time running"
	mkdir -p /etc/gtk-2.0
	/usr/bin/gdk-pixbuf-query-loaders > /etc/gtk-2.0/gdk-pixbuf.loaders
fi

if [ ! -f /usr/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache ] ; then
	echo "Creating loaders.cache for the first-time running"
	mkdir -p /usr/lib/gdk-pixbuf-2.0/2.10.0
	/usr/bin/gdk-pixbuf-query-loaders > /usr/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache
fi

if [ ! -f /etc/pango/pango.modules ] ; then
	echo "Creating pango.modules for the first-time running"
	mkdir -p /etc/pango/
	/usr/bin/pango-querymodules > /etc/pango/pango.modules
fi

if [ ! -f /usr/share/glib-2.0/schemas/gschemas.compiled ] ; then
	echo "Compile gschemas for the first-time running"
	/usr/bin/glib-compile-schemas /usr/share/glib-2.0/schemas
fi

_MY_EOF_

		exec_cmd "tar czf $CACHEDIR/$GTK2FILES.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/gtk2 $TEMPDIR/$GTK2FILES"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/share/gtk-doc /usr/share/man"
	REMOVE_LIST="/usr/lib/pkgconfig /usr/share/aclocal"
	DEPLOY_DIST="/etc /usr/bin /usr/lib /usr/share"
	deploy $GTK2FILES gtk2
}
build_gtk2()
{	
	# Package requirements (glib-2.0 >= 2.27.3  atk >= 1.29.2    pango >= 1.20    cairo >= 1.6    gdk-pixbuf-2.0 >= 2.21.0)
	build_glib
	
	build_atk
	build_pango
	build_gdkpixbuf
	build_cairo
	
#	build_xorg_server
#	build_x11_libx11
#	build_x11_libxi
#	build_x11_libxrandr
#	build_x11_libxfixes
#	build_x11_libxcomposite
#	build_x11_libxdamage
#	build_x11_xkbcomp
	
	run_task "构建$GTK2FILES" "compile_gtk2"
}

##############################
# 编译 gtk+-3.7.6
GTK3FILES=gtk+-3.7.6
compile_gtk3()
{
	if [ ! -e $CACHEDIR/$GTK3FILES.tar.gz ]; then
		rm -rf $TEMPDIR/$GTK3FILES
		export CFLAGS="$CFLAGS $CROSS_FLAGS "
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link . -lgmodule-2.0"
		dispenv
		
		prepare $GTK3FILES
		export PKG_CONFIG_FOR_BUILD="/usr/bin/pkg-config"
#restore_native0
		#	For Gtk3		
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static --disable-debug --disable-maintainer-mode --disable-glibtest  --disable-test-print-backend  --disable-glibtest --enable-debug=no --disable-cups --with-x --enable-x11-backend ac_cv_func_mmap_fixed_mapped=yes --without-atk-bridge"
#		PARAM+=" --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf --disable-man"
#		PARAM+=" --disable-win32-backend --disable-quartz-backend" # quartz is for mac
#		PARAM+="  --disable-xinerama --enable-xinput --enable-xrandr --enable-xfixes --enable-xcomposite --enable-xdamage --enable-xkb"
#		PARAM+=" --enable-schemas-compile "
		exec_cmd "./configure $PARAM"

		# 禁用demo
		printf "all:\ninstall:\n" > docs/Makefile
		printf "all:\ninstall:\n" > demos/Makefile
		printf "all:\ninstall:\n" > examples/Makefile
		printf "all:\ninstall:\n" > demos/gtk-demo/Makefile
		printf "all:\ninstall:\n" > tests/Makefile
		printf "all:\ninstall:\n" > gtk/tests/Makefile
		exec_cmd "make -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/gtk3"
#hide_native0
#		unset PKG_CONFIG_FOR_BUILD
		
		exec_cmd "cd $CACHEDIR/gtk3"
		exec_cmd "mkdir -p etc/profile.d"
	
		# 生成配置文件
		cat << _MY_EOF_ > etc/profile.d/setEnvGtk2
#!/bin/sh
if [ ! -f /etc/gtk-2.0/gdk-pixbuf.loaders ] ; then
	echo "Creating gdk-pixbuf.loaders for the first-time running"
	mkdir -p /etc/gtk-2.0
	/usr/bin/gdk-pixbuf-query-loaders > /etc/gtk-2.0/gdk-pixbuf.loaders
fi

if [ ! -f /etc/pango/pango.modules ] ; then
	echo "Creating pango.modules for the first-time running"
	mkdir -p /etc/pango/
	/usr/bin/pango-querymodules > /etc/pango/pango.modules
fi
_MY_EOF_

		exec_cmd "tar czf $CACHEDIR/$GTK3FILES.tar.gz ."
exit
		exec_cmd "rm -rf $CACHEDIR/gtk3 $TEMPDIR/$GTK3FILES"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/share/gtk-doc /usr/share/man"
	REMOVE_LIST="/usr/lib/pkgconfig /usr/share/aclocal"
	DEPLOY_DIST="/etc /usr/bin /usr/lib /usr/share"
	deploy $GTK3FILES gtk3
}
build_gtk3()
{
	# Package requirements (glib-2.0 >= 2.27.3  atk >= 1.29.2    pango >= 1.20    cairo >= 1.6    gdk-pixbuf-2.0 >= 2.21.0)
	build_glib
	
	build_atk
	build_pango
	build_gdkpixbuf
	build_cairo
	
	build_x11_libx11
	build_x11_libxi
	build_x11_libxrandr
	
	run_task "构建$GTK3FILES" "compile_gtk3"
}

build_libxml2()
{
	echo "没有必要使用libxml2，应该使用expat"
	exec_cmd "choke"
}

###############################
## 编译 upstream
#UPSTREAM=upstream_0.26.2
#compile_upstream()
#{
#	if [ ! -e $CACHEDIR/$UPSTREAM.tar.gz ]; then
#		rm -rf $TEMPDIR/$UPSTREAM
#		
#		dispenv
#		
#		prepare $UPSTREAM
#		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static --enable-arm-neon --enable-libpng"	# --enable-gtk 自己检测
 #   restore_native_header
#		exec_cmd "./configure $PARAM"
#		exec_cmd "make -j 10"
#		exec_cmd "make install DESTDIR=$CACHEDIR/upstream"
#	hide_native_header
#				
#		exec_cmd "cd $CACHEDIR/upstream"
#		exec_cmd "tar czf $CACHEDIR/$UPSTREAM.tar.gz ."
#		exec_cmd "rm -rf $CACHEDIR/upstream $TEMPDIR/$UPSTREAM"
#	fi;
#	
# 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
#	REMOVE_LIST="/usr/lib/pkgconfig"
#	DEPLOY_DIST="/usr/lib"
#	deploy $UPSTREAM upstream
#}
#build_upstream()
#{	
#	build_x11_util_macros
#
#	# build_glib
#	# build_gtk2
#	build_libpng
#	
#	run_task "构建$UPSTREAM" "compile_upstream"
#}

