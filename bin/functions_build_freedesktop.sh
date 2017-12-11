
#######################################################################
# 编译 font-util
# http://cgit.freedesktop.org/xorg/font/util
FREEDESKTOP_FONTUTIL=font-util-1.3.1
generate_script     fontutil   freedesktop/$FREEDESKTOP_FONTUTIL                \
    '--config=--prefix=/usr --host=$MY_TARGET'                 \
    '--depends=x11_util_macros  '                               \
    '--deploy-sdk=/usr/lib /usr/share'                          \
    '--deploy-rootfs=/usr/bin /usr/share/fonts'

############################################
# 编译 fontconfig
# fc-cache程序
FONTCONFIG=fontconfig-2.12.6
generate_script     fontconfig   freedesktop/$FONTCONFIG                                 \
    '--config=--prefix=/usr --sysconfdir=/etc --host=$MY_TARGET --disable-static --with-sysroot=$SDKDIR  --enable-iconv --disable-libxml2 --disable-docs'                 \
    '--depends=expat libfreetype'                                                 \
    '--deploy-sdk=/usr/include /usr/lib'            \
    '--deploy-rootfs=/etc /usr/bin /usr/lib -/usr/lib/pkgconfig -/usr/lib/*.la /usr/share /usr/var'

###########################
# shared-mime-info
# https://people.freedesktop.org/~hadess/
SHAREDMIMEINFOFILE=shared-mime-info-1.9
generate_script  shared_mime_info     freedesktop/$SHAREDMIMEINFOFILE     \
    '--config=--host=$MY_TARGET --target=$MY_TARGET --prefix=/usr --disable-static --with-sysroot=$SDKDIR'  \
    '--deploy-sdk=/usr/share -/usr/share/locale -/usr/share/man'                      \
    '--deploy-rootfs=/usr/bin /usr/share/locale /usr/share/mime'        \
    '--depends=libxml2 glib' 

###########################
# 编译 harfbuzz 
# https://www.freedesktop.org/software/harfbuzz/release/
FREEDESKTOP_HARFBUZZFILE=harfbuzz-1.6.3
generate_script  harfbuzz     freedesktop/$FREEDESKTOP_HARFBUZZFILE     \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--host=$MY_TARGET --prefix=/usr --disable-static --without-icu --with-glib --with-freetype --with-sysroot=$SDKDIR'  \
    '--deploy-sdk=/usr/lib /usr/include'                                                \
    '--deploy-rootfs=/usr/lib /usr/bin -/usr/lib/pkgconfig -/usr/lib/*.la'        \
    '--depends=cross_autogen_env glib libfreetype_no_harfbuzz' 
# TODO: --without-icu ?

###########################
# 编译 libevdev 
# https://www.freedesktop.org/software/libevdev/
FREEDESKTOP_LIBEVDEV=libevdev-1.5.7
generate_script  libevdev     freedesktop/$FREEDESKTOP_LIBEVDEV     \
    '--patch=libevdev-test-no-werror.patch'             \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--host=$MY_TARGET --prefix=/usr --disable-static --disable-test-run --disable-gcov --with-sysroot=$SDKDIR'  \
    '--deploy-sdk=/usr/lib /usr/include'                                                \
    '--deploy-rootfs=/usr/lib /usr/bin -/usr/lib/pkgconfig -/usr/lib/*.la'          \
    '--depends=cross_autogen_env' 
   
##############################
# 编译 libdrm-2.4.40
# https://dri.freedesktop.org/libdrm/
FREEDESKTOP_LIBDRM=libdrm-2.4.88
generate_script     libdrm   freedesktop/$FREEDESKTOP_LIBDRM                      \
    '--prescript=autoreconf -v --install --force'       \
    '--config=--prefix=/usr --host=$MY_TARGET --disable-static --disable-radeon --disable-nouveau --disable-vmwgfx --enable-udev --disable-cairo-tests'          \
    '--depends=cross_autogen_env x11_libpthreadstubs udev'   \
    '--deploy-rootfs=/usr/lib -/usr/lib/*.la -/usr/lib/pkgconfig /usr/share -/usr/share/man'    \
    '--deploy-sdk=/'

# libdri2
# https://cgit.freedesktop.org/~robclark/libdri2/


##############################
# 编译本机运行的 pkg-config
# https://pkg-config.freedesktop.org/releases/
#----------------------------------------------------------------------------
# --with-internal-glib，  使用内部的glib，可以不需要编译新的glib
FREEDESKTOP_PKGCONFIGFILE="pkg-config-0.29.2"
generate_script  pkgconfig     freedesktop/$FREEDESKTOP_PKGCONFIGFILE     \
    '--config=--prefix=/usr --host=$MY_TARGET --disable-static --disable-host-tool --without-gcov --with-internal-glib glib_cv_stack_grows=no glib_cv_uscore=no ac_cv_func_posix_getpwuid_r=yes ac_cv_func_posix_getgrgid_r=yes ac_cv_lib_rt_clock_gettime=no glib_cv_monotonic_clock=yes'       \
    '--deploy-sdk=/usr/share'       \
    '--deploy-rootfs=/usr/bin'  

generate_script  cross_pkgconfig     freedesktop/$FREEDESKTOP_PKGCONFIGFILE     \
    --build-native                  \
    '--config=--prefix=/usr --disable-static --disable-host-tool --without-gcov --with-internal-glib'       \
    '--postscript=prepare_pkgconfig_for_sysroot'        \
    '--deploy-sdk=/usr/bin -/usr/bin/pkg-config /usr/share/aclocal -/usr/share/doc -/usr/share/man'                \
    '--deploy-dev=/usr/bin/pkg-config /usr/share/aclocal -/usr/share/doc -/usr/share/man'
function prepare_pkgconfig_for_sysroot()
{
    cd $TEMPDIR/dist
    cp usr/bin/pkg-config usr/bin/$MY_TARGET-pkg-config-real
    cat << MY_EOF > usr/bin/$MY_TARGET-pkg-config
#!/bin/bash
if [ -n "\$CANDY_PKG_CONFIG_SYSROOT_PATCH" ]; then
    RUNDIR=\$(cd \`dirname \$0\`; pwd)
    MYNAME=\`basename \$0\`
    ROOTDIR=\$(cd \`dirname \$0\`/../..; pwd)
    \$RUNDIR/\${MYNAME}-real "\$@" 1>\$RUNDIR/\${MYNAME}-last-response
    ret=\$?
    sed -r "s#(^|\ +)/usr#\1\$ROOTDIR/usr#g" \$RUNDIR/\${MYNAME}-last-response
    exit \$ret
else
    \$0-real "\$@"
fi;
MY_EOF
    chmod +x usr/bin/$MY_TARGET-pkg-config
}
generate_alias  native_pkgconfig  cross_pkgconfig
    
##############################
# 编译 dbus-1.11.22
# https://dbus.freedesktop.org/releases/dbus/
FREEDESKTOP_DBUSFILE=dbus-1.11.22
PARAM=' --host=$MY_TARGET --prefix=/usr --sysconfdir=/etc --disable-static --disable-developer --disable-verbose-mode --disable-asserts --disable-checks --disable-xml-docs'
PARAM+=' --disable-doxygen-docs --disable-ducktype-docs --disable-tests --disable-installed-tests --disable-selinux --disable-modular-tests'
PARAM+=' --without-x  --disable-x11-autolaunch'
generate_script     dbus   freedesktop/$FREEDESKTOP_DBUSFILE                                                                          \
    "--config=$PARAM"            \
    '--install_target=install'          \
    '--depends=cross_pkgconfig libz expat'                                                                                           \
    '--deploy-rootfs=/etc /usr/bin /usr/lib /usr/libexec /usr/var /usr/share -/usr/lib/*.la -/usr/lib/pkgconfig -/usr/share/doc -/usr/share/man'    \
    '--deploy-sdk=/ -/usr/bin -/etc -/usr/libexec'
config_dbus()
{
		cat << _MY_EOF_ > $INSTDIR/etc/profile.d/prepDBus
if [ ! -f /usr/var/lib/dbus/machine-id ] ; then
	echo "Prepare machine-id for DBUS environment"
	mkdir -p /usr/var/lib/dbus/
	/usr/bin/dbus-uuidgen --ensure
fi
_MY_EOF_
	
	DEPLOY_DIST="/etc /usr/bin /usr/lib /usr/libexec /usr/share /usr/var"
	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST="/usr/lib/pkgconfig "
	deploy $DBUSFILE
	
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

NATIVE_PREREQUIRST+=" gperf "
##############################
# 编译 systemd-204(原udev) 
# https://www.freedesktop.org/software/systemd/
#---------------------------------------------------------------------
# systemd 204这个版本是udev的老结构最后一个版本，之后变为新的systemd服务，变化非常大
#FREEDESKTOP_SYSTEMDFILE=systemd-235
FREEDESKTOP_SYSTEMDFILE=systemd-204
PARAM='--host=$MY_TARGET --prefix=/ --exec-prefix=/usr --datarootdir=/usr/share --sbindir=/sbin --sysconfdir=/etc --bindir=/sbin --sbindir=/sbin --libexecdir=/lib --with-rootlibdir=/lib --with-sysroot=$SDKDIR'
PARAM+=" --disable-static --enable-nls --enable-kmod --enable-blkid --enable-pam --disable-gcrypt --enable-gudev"
PARAM+=' --with-dbuspolicydir=/etc/dbus-1 --with-dbussessionservicedir=/usr/share/dbus-1/services --with-dbussystemservicedir=/usr/share/dbus-1/system-services --with-dbusinterfacedir=/usr/share/dbus-1/interfaces'
PARAM+=" --without-python --disable-manpages --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf --disable-keymap --disable-tests --disable-introspection" 
PARAM+=" ac_cv_func_malloc_0_nonnull=yes"
generate_script     systemd   freedesktop/$FREEDESKTOP_SYSTEMDFILE                                                                          \
    "--config=$PARAM"                                     \
    '--patch=systemd-no-uint32-bug.patch'   \
    '--depends=utillinux libz libkmod dbus libcap2 glib libpam'                                                                                           \
    '--deploy-rootfs=/etc /var /lib /sbin /usr/bin /usr/lib /usr/share -/usr/lib/*.la -/usr/lib/pkgconfig -/usr/share/doc -/usr/share/pkgconfig'    \
    '--deploy-sdk=/include /lib /usr/lib /usr/share/pkgconfig'
    
generate_alias udev     systemd
generate_alias libudev  systemd

# 发布目录还需要调整!!!
#REQUIREMENTS:
#        Linux kernel >= 2.6.39
#          CONFIG_DEVTMPFS
#          CONFIG_CGROUPS (it's OK to disable all controllers)
#          CONFIG_INOTIFY_USER
#          CONFIG_SIGNALFD
#          CONFIG_TIMERFD
#          CONFIG_EPOLL
#          CONFIG_NET
#          CONFIG_SYSFS
#        Linux kernel >= 3.8 for Smack support
#        Udev will fail to work with the legacy layout:
#          CONFIG_SYSFS_DEPRECATED=n
#        Legacy hotplug slows down the system and confuses udev:
#          CONFIG_UEVENT_HELPER_PATH=""
#
#        Userspace firmware loading is deprecated, will go away, and
#        sometimes causes problems:
#          CONFIG_FW_LOADER_USER_HELPER=n
#        Some udev rules and virtualization detection relies on it:
#          CONFIG_DMIID
#        Mount and bind mount handling might require it:
#          CONFIG_FHANDLE
#
#        Optional but strongly recommended:
#          CONFIG_IPV6
#          CONFIG_AUTOFS4_FS
#          CONFIG_TMPFS_POSIX_ACL
#          CONFIG_TMPFS_XATTR
#          CONFIG_SECCOMP
#
#        For systemd-bootchart a kernel with procfs support and several
#        proc output options enabled is required:
#          CONFIG_PROC_FS
#          CONFIG_SCHEDSTATS
#          CONFIG_SCHED_DEBUG
#
#        For UEFI systems:
#          CONFIG_EFI_VARS
#          CONFIG_EFI_PARTITION
#        dbus >= 1.4.0
#        libcap
#        libblkid >= 2.20 (from util-linux) (optional)
#        libkmod >= 5 (optional)
#        PAM >= 1.1.2 (optional)
#        libcryptsetup (optional)
#        libaudit (optional)
#        libacl (optional)
#        libattr (optional)
#        libselinux (optional)
#        liblzma (optional)
#        tcpwrappers (optional)
#        libgcrypt (optional)
#        libqrencode (optional)
#        libmicrohttpd (optional)
#        libpython (optional)
#        make, gcc, and similar tools
#
#        During runtime you need the following additional dependencies:
#
#        util-linux >= v2.19 (requires fsck -l, agetty -s)
#        sulogin (from util-linux >= 2.22 or sysvinit-tools, optional but recommended)
#       dracut (optional)
#        PolicyKit (optional)

config_systemd()
{
	# 0. 根据udev README: 添加下列组
	# disk, cdrom, floppy, tape, audio, video, lp, tty, dialout, kmem	
	sudo cat << _MY_EOF_ >> $INSTDIR/etc/group
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
	cat << _MY_EOF_ > $TEMPDIR/20.start-udev
echo "-------------Starting UDEV Plug&Play Framework--------------"
#!/bin/sh

# disable old mdev plugin helper
#/sbin/sysctl -w kernel.hotplug=""
echo "" > /proc/sys/kernel/hotplug

/usr/lib/systemd/systemd-udevd --daemon
/usr/bin/udevadm trigger

# freescale GPU和pulseaudio都需要/dev/shm
mkdir -p /dev/shm /dev/pts
mount -t tmpfs tmpfs /dev/shm
mount -n -t devpts devpts /dev/pts

_MY_EOF_
    exec_cmd "sudo cp $TEMPDIR/20.start-udev $INSTDIR/etc/init.d"
    
	# 装了udev以后不需要任何预建设备
	sudo rm -rf $INSTDIR/dev/*	
}
setenv_systemd()
{
#	export CFLAGS="$CFLAGS -I$SDKDIR/include/udev"
#	export LDFLAGS="$LDFLAGS"
	echo
}
