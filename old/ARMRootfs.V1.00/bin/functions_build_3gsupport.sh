#!/bin/sh

##############################
# 编译 usb-modeswitch-1.2.3
USBMODESWITCHFILE=usb-modeswitch-1.2.3
compile_usbmodeswitch()
{
	if [ ! -e $CACHEDIR/$USBMODESWITCHFILE.tar.gz ]; then
		export CFLAGS="$CFLAGS $CROSS_FLAGS"
		export LDFLAGS="$LDFLAGS -lusb-1.0 -lrt -pthread -lusb"
		dispenv
		
		rm -rf $TEMPDIR/$USBMODESWITCHFILE
		prepare $USBMODESWITCHFILE usb-modeswitch-gen-dispatcher-arm.patch
		OLDSTR="install\ -D\ -s"
		NEWSTR="install\ -D"
		replace_in_file Makefile  
		
		exec_cmd "make CC=$MY_TARGET-gcc"
		export CTARGET=$MY_TARGET
		restore_native0
		exec_cmd "./make_static_dispatcher.sh"
		exec_cmd "make install-static DESTDIR=$CACHEDIR/usbmodeswitch"
		hide_native0
		exec_cmd "cd $CACHEDIR/usbmodeswitch"
				
		exec_cmd "tar czf $CACHEDIR/$USBMODESWITCHFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/usbmodeswitch $TEMPDIR/$USBMODESWITCHFILE"
	fi;
	
	DEPLOY_DIST="/lib /etc /var /usr/sbin"
	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	deploy $USBMODESWITCHFILE usbmodeswitch
	
#	exec_cmd "mkdir -p $INSTDIR/etc $INSTDIR/var $INSTDIR/lib $INSTDIR/usr/sbin $CACHEDIR/usbmodeswitch"
#	exec_cmd "tar xf $CACHEDIR/$USBMODESWITCHFILE.tar.gz -C $CACHEDIR/usbmodeswitch"
#	exec_cmd "cp -R $CACHEDIR/usbmodeswitch/lib/* $INSTDIR/lib"
#	exec_cmd "cp -R $CACHEDIR/usbmodeswitch/etc/* $INSTDIR/etc"
#	exec_cmd "cp -R $CACHEDIR/usbmodeswitch/var/* $INSTDIR/var"
#	exec_cmd "cp -R $CACHEDIR/usbmodeswitch/usr/sbin/* $INSTDIR/usr/sbin"
#	exec_cmd "rm -rf $CACHEDIR/usbmodeswitch"
}
USBMODESWITCHDATAFILE=usb-modeswitch-data-20120531
compile_usbmodeswitchdata()
{
	if [ ! -e $CACHEDIR/$USBMODESWITCHDATAFILE.tar.gz ]; then
		dispenv
		
		rm -rf $TEMPDIR/$USBMODESWITCHDATAFILE
		prepare $USBMODESWITCHDATAFILE
		
		exec_cmd "make install DESTDIR=$CACHEDIR/usbmodeswitchdata"
		
		exec_cmd "cd $CACHEDIR/usbmodeswitchdata"
		exec_cmd "tar czf $CACHEDIR/$USBMODESWITCHDATAFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/usbmodeswitchdata $TEMPDIR/$USBMODESWITCHDATAFILE"
	fi;
	
	DEPLOY_DIST="/lib /etc /usr"
	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	deploy $USBMODESWITCHDATAFILE usbmodeswitchdata
	
#	exec_cmd "mkdir -p $INSTDIR/etc $INSTDIR/usr $INSTDIR/lib $CACHEDIR/usbmodeswitchdata"
#	exec_cmd "tar xf $CACHEDIR/$USBMODESWITCHDATAFILE.tar.gz -C $CACHEDIR/usbmodeswitchdata"
#	exec_cmd "cp -R $CACHEDIR/usbmodeswitchdata/lib/* $INSTDIR/lib"
#	exec_cmd "cp -R $CACHEDIR/usbmodeswitchdata/etc/* $INSTDIR/etc"
#	exec_cmd "cp -R $CACHEDIR/usbmodeswitchdata/usr/* $INSTDIR/usr"
#	exec_cmd "rm -rf $CACHEDIR/usbmodeswitchdata"
}

build_usbmodeswitch()
{
	build_libusbc
	
	run_task "构建$USBMODESWITCHFILE" "compile_usbmodeswitch"
	run_task "构建$USBMODESWITCHDATAFILE" "compile_usbmodeswitchdata"
}

##############################
# 编译 openssl
OPENSSLFILE=openssl-1.0.1c
compile_openssl()
{
	if [ ! -e $CACHEDIR/$OPENSSLFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$OPENSSLFILE
		prepare $OPENSSLFILE
		
		dispenv
		export MACHINE=armv7a
		exec_cmd "./config --prefix=/usr threads zlib shared $CFLAGS $CROSS_FLAGS $LDFLAGS"
		alias $MY_TARGET-ar="$MY_TARGET-ar csr"
		exec_cmd "make CC=$MY_TARGET-gcc" #-j 10 不能多任务运行
		exec_cmd "make CC=$MY_TARGET-gcc install_sw INSTALL_PREFIX=$CACHEDIR/openssl INSTALLTOP=/usr"
		
		exec_cmd "cd $CACHEDIR/openssl"
		exec_cmd "tar czf $CACHEDIR/$OPENSSLFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/openssl $TEMPDIR/$OPENSSLFILE"
	fi;
	
	DEPLOY_DIST="/usr/lib"
	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST="/usr/lib/*.a /usr/lib/pkgconfig"	
	deploy $OPENSSLFILE openssl
	
#	exec_cmd "mkdir -p $SDKDIR/include/openssl $INSTDIR/usr/lib $CACHEDIR/openssl"
#	exec_cmd "tar xf $CACHEDIR/$OPENSSLFILE.tar.gz -C $CACHEDIR/openssl"
#	exec_cmd "cd $CACHEDIR/openssl"
#	exec_cmd "rm -rf usr/bin usr/lib/*.a"
#	exec_cmd "cp -R $CACHEDIR/openssl/usr/lib/* $INSTDIR/usr/lib"
#	exec_cmd "cp -R $CACHEDIR/openssl/usr/include/openssl/* $SDKDIR/include/openssl"
#	exec_cmd "rm -rf $CACHEDIR/openssl"
}
build_openssl()
{	
	build_libz
	
	run_task "构建$OPENSSLFILE" "compile_openssl"
}

##############################
# 编译 ppp
PPPFILE=ppp-2.4.5
compile_ppp()
{
	if [ ! -e $CACHEDIR/$PPPFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$PPPFILE
		prepare $PPPFILE
		
		dispenv
		export COPT
		
		OLDSTR="DESTDIR=/usr/local"
		NEWSTR="DESTDIR=/usr"
		replace_in_file configure
		
		export CC="$MY_TARGET-gcc $CROSS_FLAGS -g -lcrypt -I$SDKDIR/include $CFLAGS $LDFLAGS -Daligned_u64='__u64 __attribute__((aligned(8)))'"
		exec_cmd "./configure"

		STRIP_FULLPATH=`which $MY_TARGET-strip`
		STRIP_PATH=`dirname $STRIP_FULLPATH`
		exec_cmd "pushd $STRIP_PATH"
		sudo rm -f strip
		exec_cmd "sudo ln -s $MY_TARGET-strip strip"
		exec_cmd "popd"
		exec_cmd "echo 当前目录是$PWD"
		exec_cmd "make"
		exec_cmd "make install DESTDIR=$CACHEDIR/ppp"
		sudo rm -f $STRIP_PATH/strip
		unset CC
		
		exec_cmd "cd $CACHEDIR/ppp"
		exec_cmd "tar czf $CACHEDIR/$PPPFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/ppp $TEMPDIR/$PPPFILE"
	fi;
	
	DEPLOY_DIST="/sbin /lib"
	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	deploy $PPPFILE ppp

	exec_cmd "tar jxvf $DLDIR/ppp-config-ubuntu.tar.bz2 -C $INSTDIR/"	
#	exec_cmd "mkdir -p $SDKDIR/include/ $INSTDIR/sbin $INSTDIR/lib $CACHEDIR/ppp"
#	exec_cmd "tar xf $CACHEDIR/$PPPFILE.tar.gz -C $CACHEDIR/ppp"
#	exec_cmd "cp -R $CACHEDIR/ppp/sbin/* $INSTDIR/sbin"
#	exec_cmd "cp -R $CACHEDIR/ppp/sbin/* $INSTDIR/lib"
#	exec_cmd "cp -R $CACHEDIR/ppp/include/* $SDKDIR/include/"
#	exec_cmd "rm -rf $CACHEDIR/ppp"
}
build_ppp()
{
#	build_openssl
	
	run_task "构建$PPPFILE" "compile_ppp"
}

##############################
# 编译 wvstreams
WVSTREAMSFILE=wvstreams-4.6.1
compile_wvstreams()
{
	if [ ! -e $CACHEDIR/$WVSTREAMSFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$WVSTREAMSFILE
		prepare $WVSTREAMSFILE wvstream_getcontext.patch
				
		export CFLAGS="$CROSS_FLAGS $CFLAGS `pkg-config --cflags openssl zlib`"
		export CXXFLAGS="$CFLAGS -fpermissive -DMACOS"
		export LDFLAGS="$LDFLAGS `pkg-config --libs openssl zlib`"
        dispenv
        
		exec_cmd "./configure --prefix=/usr --host=$MY_TARGET --sysconfdir=/etc --disable-static --without-dbus --without-qt --without-pam --without-tcl --without-valgrind --with-zlib --with-openssl"
		exec_cmd "make " # -j 10 无法多线程编译
		exec_cmd "make install DESTDIR=$CACHEDIR/wvstreams"
		
		exec_cmd "cd $CACHEDIR/wvstreams"
		exec_cmd "tar czf $CACHEDIR/$WVSTREAMSFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/wvstreams $TEMPDIR/$WVSTREAMSFILE"
	fi;
	
	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST="/usr/lib/*.a /usr/lib/pkgconfig"	
	DEPLOY_DIST="/usr/lib /usr/bin /etc /usr/sbin /usr/var"
	deploy $WVSTREAMSFILE wvstreams
}
build_wvstreams()
{
	build_libz
	build_openssl
	
	run_task "构建$WVSTREAMSFILE" "compile_wvstreams"
}

##############################
# 编译 wvdial
WVDIALFILE=wvdial-1.61
compile_wvdial()
{
	if [ ! -e $CACHEDIR/$WVDIALFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$WVDIALFILE
		prepare $WVDIALFILE wvdial-pppd-to-sbin.patch	
		# wvdial强制要求pppd在/usr/sbin目录，这个补丁改到/sbin目录
		
		export CFLAGS="$CFLAGS `pkg-config --cflags openssl zlib libwvstreams`"
		export CXXFLAGS="$CFLAGS -fpermissive -DMACOS"
		export LDFLAGS="$LDFLAGS `pkg-config --libs openssl zlib libwvstreams`"
		
		dispenv
		export COPT
		export CC="$MY_TARGET-gcc $CROSS_FLAGS $CFLAGS $LDFLAGS -Daligned_u64='__u64 __attribute__((aligned(8)))'"
		export CXX="$MY_TARGET-g++ $CROSS_FLAGS $CFLAGS $LDFLAGS -Daligned_u64='__u64 __attribute__((aligned(8)))'"
		exec_cmd "./configure"
		
		OLDSTR="PPPDIR=/etc/ppp/peers"
		NEWSTR="PPPDIR=\${prefix}/../etc/ppp/peers"
		replace_in_file Makefile  
		
#		exec_cmd "pushd $STRIP_PATH"
#		sudo rm -f strip
#		exec_cmd "sudo ln -s $MY_TARGET-strip strip"
#		exec_cmd "popd"
#		exec_cmd "echo 当前目录是$PWD"
		exec_cmd "make"
		exec_cmd "make install prefix=$CACHEDIR/wvdial/usr"

		
		exec_cmd "cd $CACHEDIR/wvdial"
		exec_cmd "tar czf $CACHEDIR/$WVDIALFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/wvdial $TEMPDIR/$WVDIALFILE"
		unset CC
		unset CXX
	fi;
	
	DEPLOY_DIST="/etc /usr/bin"
	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST="/usr/lib/*.a /usr/lib/pkgconfig"	
	deploy $WVDIALFILE wvdial
}
build_wvdial()
{
	build_wvstreams
	build_ppp
	
	run_task "构建$WVDIALFILE" "compile_wvdial"
}

##############################
# 编译 libusb-1.0.9
LIBUSBFILE=libusb-1.0.9
compile_libusb()
{
	if [ ! -e $CACHEDIR/$LIBUSBFILE.tar.gz ]; then
	
	    restore_native0
		rm -rf $TEMPDIR/$LIBUSBFILE
		prepare $LIBUSBFILE
		
		dispenv
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static" #--enable-debug-log "
		exec_cmd "./configure $PARAM"
		
		hide_native0
		exec_cmd "make"
		exec_cmd "make install DESTDIR=$CACHEDIR/libusb"
		
		exec_cmd "cd $CACHEDIR/libusb"
		exec_cmd "tar czf $CACHEDIR/$LIBUSBFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/libusb $TEMPDIR/$LIBUSBFILE"
	fi;
	DEPLOY_DIST="/usr/lib"
	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST="/usr/lib/*.a /usr/lib/pkgconfig"	
	deploy $LIBUSBFILE libusb
	
}
build_libusb()
{	
	run_task "构建$LIBUSBFILE" "compile_libusb"
}

##############################
# 编译 usbutils-006
USBUTILSFILE=usbutils-006
compile_usbutils()
{
	if [ ! -e $CACHEDIR/$USBUTILSFILE.tar.gz ]; then
		dispenv
		
		rm -rf $TEMPDIR/$USBUTILSFILE
		prepare $USBUTILSFILE
		
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-largefile"
		exec_cmd "./configure $PARAM"
		exec_cmd "make"
		exec_cmd "make install DESTDIR=$CACHEDIR/usbutils"
		
		exec_cmd "cd $CACHEDIR/usbutils"
		exec_cmd "tar czf $CACHEDIR/$USBUTILSFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/usbutils $TEMPDIR/$USBUTILSFILE"
	fi;
	
	DEPLOY_DIST="/usr/bin /usr/sbin"
	PRE_REMOVE_LIST=""
	REMOVE_LIST=""	
	deploy $USBUTILSFILE usbutils
}
build_usbutils()
{
	build_libusb
	build_libz
	
	run_task "构建$USBUTILSFILE" "compile_usbutils"
}

##############################
# 编译 libusb-compat-0.1.4
LIBUSBCFILE=libusb-compat-0.1.4
compile_libusbc()
{
	if [ ! -e $CACHEDIR/$LIBUSBCFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$LIBUSBCFILE
		prepare $LIBUSBCFILE
		
		dispenv
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static --disable-examples-build --disable-debug-log"
		exec_cmd "./autogen.sh $PARAM"
		exec_cmd "make"
		exec_cmd "make install DESTDIR=$CACHEDIR/libusbc"
		
#		exec_cmd "cp examples/lsusb examples/testlibusb $CACHEDIR/libusbc/usr/bin"
		exec_cmd "cd $CACHEDIR/libusbc"
		exec_cmd "tar czf $CACHEDIR/$LIBUSBCFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/libusbc $TEMPDIR/$LIBUSBCFILE"
	fi;
	
	DEPLOY_DIST="/usr/lib"
	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST="/usr/lib/*.a /usr/lib/pkgconfig"	
	deploy $LIBUSBCFILE libusbc
}
build_libusbc()
{	
	if [ ! -e $INSTDIR/usr/lib/libusb-1.0.a ]; then
		build_libusb
	fi;
	
	run_task "构建$LIBUSBCFILE" "compile_libusbc"
	
	rm -f $INSTDIR/usr/lib/libusb-1.0.a
}
