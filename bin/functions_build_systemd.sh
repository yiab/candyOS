#!/bin/sh

NATIVE_PREREQUIRST+=" gtk-doc-tools autoconf"

##############################
# 编译 util-linux
# util-linux等价与：busybox中若干命令／libblkid/libfdisk/libmount/libsmartcols/libuuid
UTILLINUXFILE=util-linux-2.31
generate_script     utillinux   $UTILLINUXFILE                                                                          \
    --sudo-build --make-before-install                                                                                  \
    '--prescript=autoreconf -v --install --force'                               \
    '--config=--host=$MY_TARGET --target=$MY_TARGET --prefix=/usr --disable-static --without-python --with-sysroot=$SDKDIR --disable-pylibmount --disable-gtk-doc --disable-plymouth_support --without-systemd --without-systemdsystemunitdir --without-python'            \
    '--depends=ncursesw libz libpam cross_autogen_env'                                                                                           \
    '--install_target=install PATH=$PATH'                                                                               \
    '--deploy-rootfs=/bin /sbin /lib /usr -/usr/include -/usr/lib/*.la -/usr/lib/pkgconfig -/usr/share/man -/usr/share/doc'    \
    '--deploy-sdk=/lib /usr/lib /usr/include'
# 遗留： libcap-ng   linux/blkzoned.h PAM  libpython

generate_alias libuuid      utillinux
generate_alias libmount     utillinux
generate_alias libblkid     utillinux
generate_alias libfdisk     utillinux
generate_alias libsmartcols     utillinux

##############################
# 编译 kmod-23     https://www.kernel.org/pub/linux/utils/kernel/kmod/
LIBKMODFILE=kmod-24
generate_script     libkmod   $LIBKMODFILE                                                                          \
    '--config=--prefix=/usr --sysconfdir=/etc --libdir=/usr/lib --host=$MY_TARGET --disable-debug --disable-python --disable-coverage --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf --disable-manpages --with-zlib'            \
    '--depends=libz cross_autogen_env'                                                                                           \
    '--deploy-rootfs=/usr/bin /usr/lib -/usr/lib/*.la -/usr/lib/pkgconfig'    \
    '--deploy-sdk=/'
# prepare $LIBKMODFILE  libkmod-no-private-lib.patch  # kmod把依赖的库都放到privateLib里面了，导致其它用到libkmod的库链接libz找不到
	
##############################
# 编译 libusb-1.0.9  http://www.libusb.org/
LIBUSBFILE=libusb-1.0.21
generate_script     libusb   $LIBUSBFILE                                                                          \
    '--config=--prefix=/usr --host=$MY_TARGET --disable-static --disable-debug-log'            \
    '--deploy-rootfs=/usr/lib -/usr/lib/*.la -/usr/lib/pkgconfig'    \
    '--deploy-sdk=/ '

# '--depends=libudev'   

##############################
# 编译 libusb-compat-0.1.4 http://www.libusb.org/
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


##############################
# 编译 usbutils https://www.kernel.org/pub/linux/utils/usb/usbutils/
USBUTILSFILE=usbutils-008
generate_script     usbutils   $USBUTILSFILE                    \
    '--depends=libusb systemd'                                               \
    '--config=--prefix=/usr --host=$MY_TARGET --disable-largefile'            \
    '--deploy-rootfs=/usr/bin'    \
    '--deploy-sdk=/usr/share/pkgconfig' 

