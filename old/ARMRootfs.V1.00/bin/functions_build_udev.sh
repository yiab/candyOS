#!/bin/sh

##############################
# 编译 udev-182
UDEVFILE=udev-182
compile_udev()
{
	if [ ! -e $CACHEDIR/$UDEVFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$UDEVFILE
		prepare $UDEVFILE udev-patches
		
		#setenv_libblkid
		#setenv_libkmod
		export LDFLAGS="$LDFLAGS -lz"
		dispenv
		PARAM="--prefix=/usr --sysconfdir=/etc --bindir=/sbin --sbindir=/sbin --libexecdir=/lib --with-rootlibdir=/lib --host=$MY_TARGET --disable-static --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf --disable-debug --disable-manpages --enable-rule_generator --disable-gudev --disable-introspection --disable-keymap --disable-floppy --with-pci-ids-path=/usr/share/misc/pci.ids --without-selinux" #  --disable-mtd_probe 
		    
		exec_cmd "./configure $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/udev"
		
		exec_cmd "cd $CACHEDIR/udev"
		exec_cmd "tar czf $CACHEDIR/$UDEVFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/udev $TEMPDIR/$UDEVFILE"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib /sbin /etc /lib"
	deploy $UDEVFILE udev

	# 0. 根据udev README: 添加下列组
	# disk, cdrom, floppy, tape, audio, video, lp, tty, dialout, kmem	
	cat << _MY_EOF_ >> $INSTDIR/etc/group
disk:x:110:root
cdrom:x:111:root
floppy:x:112:root
tape:x:113:root
audio:x:114:root
video:x:115:root
lp:x:116:root
tty:x:117:root
dialout:x:118:root
kmem:x:119:root
_MY_EOF_

	## 1. 设置启动udev脚本/etc/init.d/20.start-udev.sh--->  依赖于 10.Mount-All
	cat << _MY_EOF_ > $INSTDIR/etc/init.d/20.start-udev
echo "-------------Starting UDEV Plug&Play Framework--------------"
#!/bin/sh

# disable old mdev plugin helper
#/sbin/sysctl -w kernel.hotplug=""
echo "" > /proc/sys/kernel/hotplug

/lib/udev/udevd --daemon
/sbin/udevadm trigger

# freescale GPU和pulseaudio都需要/dev/shm
mkdir -p /dev/shm /dev/pts
mount -t tmpfs tmpfs /dev/shm
mount -n -t devpts devpts /dev/pts

_MY_EOF_

	# 装了udev以后不需要任何预建设备
	sudo rm -rf $INSTDIR/dev/*	
}
build_udev()
{
	build_utillinux
	build_libkmod
	build_usbutils
	
	run_task "构建$UDEVFILE" "compile_udev"
}
setenv_udev()
{
#	export CFLAGS="$CFLAGS -I$SDKDIR/include/udev"
#	export LDFLAGS="$LDFLAGS"
	echo
}

NATIVE_PREREQUIRST+=" gtk-doc-tools autoconf"

##############################
# 编译 kmod-20120815
LIBKMODFILE=kmod-20120815
compile_libkmod()
{
	if [ ! -e $CACHEDIR/$LIBKMODFILE.tar.gz ]; then
		export CFLAGS="$CFLAGS $CROSS_FLAGS -O2 "
		export LDFLAGS="$LDFLAGS -lz"
		dispenv
		
		# kmod 不能用prepare，因其中的testsuite有设备名不能成功解压
		rm -rf $TEMPDIR/$LIBKMODFILE
		tar axf $SRCDIR/$LIBKMODFILE.* -C $TEMPDIR/ 1>/dev/null 2>&1
		cd $TEMPDIR/$LIBKMODFILE
		exec_cmd "patch -Np1 -i $PATCHDIR/kmod-not-using-gtk-doc.patch"
		echo "当前目录是: $PWD"

#restore_native_autoconf		
		PARAM="--prefix=/usr --sysconfdir=/etc --libdir=/usr/lib --host=$MY_TARGET --disable-manpages --with-zlib "
		exec_cmd "./autogen.sh"
#hide_native_autoconf	
		exec_cmd "./configure $PARAM"
		exec_cmd "make V=1 -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/libkmod"
	
		
		exec_cmd "cd $CACHEDIR/libkmod"
		exec_cmd "tar czf $CACHEDIR/$LIBKMODFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/libkmod $TEMPDIR/$LIBKMODFILE"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib /usr/bin"
	deploy $LIBKMODFILE libkmod
	
#	exec_cmd "mkdir -p $SDKDIR/include/libkmod $INSTDIR/usr/lib $INSTDIR $CACHEDIR/libkmod"
#	exec_cmd "tar xf $CACHEDIR/$LIBKMODFILE.tar.gz -C $CACHEDIR/libkmod"
#	exec_cmd "rm $CACHEDIR/libkmod/usr/lib/*.la"

#	exec_cmd "cp -R $CACHEDIR/libkmod/usr/bin/* $INSTDIR/usr/bin"
#	exec_cmd "cp -R $CACHEDIR/libkmod/usr/lib/* $INSTDIR/usr/lib"
#	exec_cmd "cp -R $CACHEDIR/libkmod/usr/include/* $SDKDIR/include/libkmod"
#	exec_cmd "rm -rf $CACHEDIR/libkmod"
}
build_libkmod()
{
	build_libz
	
	run_task "构建$LIBKMODFILE" "compile_libkmod"
}
setenv_libkmod()
{
#	export CFLAGS="$CFLAGS -I$SDKDIR/include/libkmod"
#	export LDFLAGS="$LDFLAGS -lkmod -lz"
	echo
}

