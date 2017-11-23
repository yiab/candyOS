#!/bin/sh
clear

# 关键变量1. ROOTDIR
ROOTDIR=`(cd ".."; /bin/pwd)`

# 关键变量2. PLATFORM
KNOWN_PLATFORM="ti fsl ecs"
for i in $KNOWN_PLATFORM; do
	if [ "$i" = "$1" ]; then
		PLAT_ALIAS=$1
		break;
	fi;
done;
if [ -z $PLAT_ALIAS ]; then
	echo "Usage:	./build_all.sh [Platform-alias]"
	echo "All Known platform aliases are :"
	echo "    $KNOWN_PLATFORM"
	exit;
fi;
PLATFORM=arm-$PLAT_ALIAS
echo "======TO BUILD: $PLATFORM"

# 关键变量3:
SRCDIR=/home/baiyun/Packages
BINDIR=$ROOTDIR/bin
CACHEDIR=$ROOTDIR/cache/$PLATFORM
TEMPDIR=$ROOTDIR/temp
DLDIR=$SRCDIR		# 为util.sh脚本中的兼容性使用
INCDIR=$ROOTDIR/include
DISTDIR=$ROOTDIR/dist/$PLATFORM
SDKDIR=$DISTDIR/sdk
BOOTDIR=$DISTDIR/boot
INSTDIR=$DISTDIR/rootfs
PATCHDIR=$ROOTDIR/patch
BUILDINDIR=$PATCHDIR/buildin/$PLATFORM

# 必须在主机安装的包

#让cp命令保持符号链接
alias cp="cp -a"
alias install="install -D"

DBG="$TEMPDIR/log"
WARN="$TEMPDIR/warn"
#DBG=/dev/stdout
#WARN=/dev/stdout


##############################
# 脚本开始
source ./utils.sh
restore_native0

remount_temp()
{
	df | grep -q "$TEMPDIR"
	while [[ $? == 0 ]];
	do
		echo "Umounting"
		sudo umount $TEMPDIR
		if [[ $? != 0 ]]; then
			sudo rm -rf $TEMPDIR/* 1>/dev/null 2>&1
			return
		fi
		
		df | grep -q "$TEMPDIR"
	done;
	
	sudo rm -rf $TEMPDIR 1>/dev/null 2>&1
	mkdir -p $TEMPDIR
	sudo mount -t tmpfs tmpfs $TEMPDIR -o size=2048M
}
remount_temp
sudo rm -rf $DISTDIR $STAMPDIR 1>/dev/null 2>&1
mkdir -p $SDKDIR/bin $SDKDIR/lib $BOOTDIR $CACHEDIR $INSTDIR

setup_cross_env()
{
	NATIVETOOL=$ROOTDIR/nativegcc
	CROSSTOOL=$ROOTDIR/crossgcc
	if [[ ! -d $NATIVETOOL || ! -d $CROSSTOOL ]]; then
		echo "==========================================="
		echo "+ 解压交叉编译环境"
		echo "+	PATH=$PATH"
		echo "==========================================="
	fi;
	if [[ ! -d $NATIVETOOL ]]; then
		exec_cmd "tar axf $BUILDINDIR/nativegcc.tar.bz2 -C $ROOTDIR"
		exec_cmd "tar axf $BUILDINDIR/glibc-2.15-dist-dev.tar.bz2 -C $NATIVETOOL"
	fi;
#	if [[ ! -d $CROSSTOOL ]]; then
#		exec_cmd "tar axf $BUILDINDIR/crossgcc.tar.bz2 -C $ROOTDIR"
#	fi;	
	
	#export LD_LIBRARY_PATH=$ROOTDIR/nativegcc/lib
	export PATH=$ROOTDIR/crossgcc/usr/bin:$ROOTDIR/nativegcc/bin:$ROOTDIR/nativetool/bin:$PATH	
	export MY_TARGET=arm-yiab-linux-gnueabi
}

initenv()
{
	# 基本的路径
	export PATH=$SDKDIR/bin:$SDKDIR/usr/bin:/usr/sbin:/usr/bin:/sbin:/bin	## $SDKDIR/bin
	#setup_cross_env		# 设置交叉编译环境，设置MY_TARGET变量
	
	# 用gcc编译的uImage不能引导，奇怪的问题，尚未解决
	export PATH=/usr/local/arm/arm-2011.09/bin:$PATH
	export MY_TARGET=arm-none-linux-gnueabi
#	export PATH=/usr/local/arm/arm-yiab-linux-gnueabi/usr/bin:$PATH
#	export MY_TARGET=arm-yiab-linux-gnueabi
	
	case $PLAT_ALIAS in
"ti" )
	export CROSS_FLAGS=" -march=armv7-a -mtune=cortex-a8 -mfpu=neon -mfloat-abi=softfp -fno-tree-vectorize -O2"
	;;
"fsl" )
	export CROSS_FLAGS=" -march=armv7-a -mtune=cortex-a8 -mfpu=neon -mfloat-abi=softfp -fno-tree-vectorize -O2"
	;;
"ecs" )
	export CROSS_FLAGS=" -march=armv7-a -mtune=cortex-a8 -mfpu=neon -mfloat-abi=softfp -fno-tree-vectorize -O2"
	;;
esac
	
	export CFLAGS="-I$SDKDIR/include -I$SDKDIR/usr/include"
	export CXXFLAGS=""
	export LDFLAGS="-L$SDKDIR/usr/lib"
	export LIBS=""

	rm $TEMPDIR/log $TEMPDIR/warn 1>/dev/null 2>&1
	
}

dispenv()
{
	echo "==============================================================================="
	echo "export PATH=$PATH"
	echo "export MY_TARGET=$MY_TARGET"
	echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
	echo "export CFLAGS=\"$CFLAGS\""
	echo "export LDFLAGS=\"$LDFLAGS\""
	echo "export CXXFLAGS=\"$CXXFLAGS\""
	echo "export PKG_CONFIG_PATH=$PKG_CONFIG_PATH"
	echo "export PKG_CONFIG_SYSROOT_DIR=$PKG_CONFIG_SYSROOT_DIR"
	echo "export PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=$PKG_CONFIG_ALLOW_SYSTEM_CFLAGS"
	echo "export PKG_CONFIG_ALLOW_SYSTEM_LIBS=$PKG_CONFIG_ALLOW_SYSTEM_LIBS"
	echo "==============================================================================="
}
initenv
dispenv
source ./init_etc.sh

construct_rootfs()
{
	#必备的8个目录
	exec_cmd "cd $INSTDIR"
	echo "当前目录是$PWD"
	exec_cmd "mkdir -p bin/ dev/ etc/ lib/ proc/ sbin/ sys/ usr/ usr/bin usr/lib usr/sbin lib/modules mnt/ tmp/ var/ home/root run/"

	if [[ ! -e dev/console ]]; then
		exec_cmd "sudo mknod -m 600 dev/console c 5 1"
	fi;
	if [[ ! -e dev/null ]]; then
		exec_cmd "sudo mknod -m 666 dev/null c 1 3"
	fi;	
	exec_cmd "sudo chmod 1777 tmp"
	exec_cmd "mkdir -p mnt/etc mnt/jffs2 mnt/yaffs mnt/data mnt/temp var/lib var/lock var/log var/run var/tmp"
	exec_cmd "sudo chmod 1777 var/tmp"
	
	# 基本的配置
	init_basic_etc	
	return 1
#	exec_cmd "cp -R $SRCDIR/etc-sample/* etc/"	
}
init_rootfs()
{
	run_task "构建基本的rootfs" "construct_rootfs"	
}

echo "==========================================="
echo "+ 开始构建"
echo "+ INSTDIR=$INSTDIR"
echo "+ MY_TARGET=$MY_TARGET"
echo "==========================================="

#############################
#  加载脚本
for parts in ./functions_*.sh; do
	exec_cmd "source $parts"
done;

echo "Checking prerequist package on native environment ... $NATIVE_PREREQUIRST"
exec_cmd "sudo apt-get install -y $NATIVE_PREREQUIRST"

###########################
# file
FILEFILE=file-5.11
compile_file()
{
	prepare $FILEFILE
	PARAM="--prefix=$TEMPDIR/libfile"
	build_native $FILEFILE
	
	PATH=$TEMPDIR/libfile/bin:$PATH
	CFLAGS="$CFLAGS $CROSS_FLAGS -w"
	PARAM="--host=$MY_TARGET --prefix=$SDKDIR/libmagic --disable-shared"
	build_native $FILEFILE
}
build_file()
{
	run_task "构建$FILEFILE" "compile_file"
	CFLAGS="$CFLAGS -I$SDKDIR/libmagic/include"
	LDFLAGS="$LDFLAGS -L$SDKDIR/libmagic/lib"
}

strip_all()
{
#	echo "find $INSTDIR/ -name '*' -exec $MY_TARGET-strip {} \;"
#	find $INSTDIR/bin -name '*' -exec $MY_TARGET-strip {} \; 1>/dev/null 2>&1
#	find $INSTDIR/usr/bin -name '*' -exec $MY_TARGET-strip {} \; 1>/dev/null 2>&1
#	find $INSTDIR/lib -name '*.so*' -exec $MY_TARGET-strip {} \; 1>/dev/null 2>&1
#	find $INSTDIR/lib/udev -name '*.so*' -exec $MY_TARGET-strip {} \; 1>/dev/null 2>&1
#	find $INSTDIR/usr/lib -name '*.so*' -exec $MY_TARGET-strip {} \; 1>/dev/null 2>&1
#	find $INSTDIR/usr/local/ -name '**' -exec $MY_TARGET-strip {} \; 1>/dev/null 2>&1
	echo "Striping ..."
	find $INSTDIR/ -name '*' -exec $MY_TARGET-strip {} \; 1>/dev/null 2>&1

#	$MY_TARGET-strip --strip-unneeded $INSTDIR/etc/init.d/*
#	$MY_TARGET-strip --strip-unneeded $INSTDIR/bin/*
#	$MY_TARGET-strip --strip-unneeded $INSTDIR/sbin/*
#	$MY_TARGET-strip --strip-unneeded $INSTDIR/usr/bin/*
#	$MY_TARGET-strip --strip-unneeded $INSTDIR/usr/sbin/*
#	$MY_TARGET-strip --strip-debug $INSTDIR/lib/*.so
#	$MY_TARGET-strip --strip-debug $INSTDIR/usr/lib/*.so
}

post_install_fsl()
{
	post_install_ecs
}

post_install_ecs()
{
	exec_cmd "sudo cp $BUILDINDIR/wvdial.conf $INSTDIR/etc"
	exec_cmd "sudo cp $BUILDINDIR/ppp-options $INSTDIR/etc/ppp/options"
}

##### 执行构建任务
construct_$PLAT_ALIAS
restore_native0
strip_all
post_install_$PLAT_ALIAS

echo "所有任务成功完成！"
dist_shared_path=~/beagleboard/dist-arm
rm -rf $dist_shared_path
mkdir -p $dist_shared_path


#临时性任务
exec_cmd "sudo cp $BUILDINDIR/mount_gisserver.sh $INSTDIR/etc"
cd $INSTDIR
echo "正在打包etc.tar.bz2"
sudo rm -f $dist_shared_path/etc.tar.bz2
sudo tar jcf $dist_shared_path/etc.tar.bz2 etc


# 打包
echo "正在打包到$dist_shared_path/boot.tar.bz2"
exec_cmd "cd $BOOTDIR"
exec_cmd "sudo chown -hR root:root ."
exec_cmd "sudo rm -f $dist_shared_path/boot.tar.bz2"
exec_cmd "sudo tar jcf $dist_shared_path/boot.tar.bz2 ."

echo "正在打包到$dist_shared_path/rootfs.tar.bz2"
cd $INSTDIR
#sudo chown -hR root:root .
sudo rm -f $dist_shared_path/rootfs.tar.bz2
sudo tar jcf $dist_shared_path/rootfs.tar.bz2 .

sudo umount $TEMPDIR

beep_succ
exit;
# 1. 基本系统/驱动
#build_busybox
#strip_all


###########################
# Splashy
SPLASHYFILE=splashy-0.3.13
compile_splashy()
{
	prepare $SPLASHYFILE
	
	build_libz
	build_glib
	build_libpng
	update_pkgconfig
	build_file
	build_dvsdk
	build_directfb
	build_kernel
	CFLAGS="$CFLAGS $CROSS_FLAGS -w "
	
	#bug?
	export LDFLAGS="$LDFLAGS -L$TEMPDIR/$SPLASHYFILE/src/.libs -lz -lstdc++"
	
	cp $INSTDIR/usr/bin/directfb-config $SDKDIR/bin || exit 1;
	PATH=$SDKDIR/bin:$PATH		# 为了调用正确的directfb-config
	
	PARAM="--host=$MY_TARGET --prefix=/usr"
	build_native $SPLASHYFILE --dest DESTDIR=$INSTDIR --inside
}

build_splashy()
{
	run_task "构建$SPLASHYFILE" "compile_splashy"
}
