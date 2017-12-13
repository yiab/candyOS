#!/bin/bash
clear

# 关键变量1. ROOTDIR
ROOTDIR=$(cd `dirname $0`/..; pwd)

# 关键变量2. PRODUCT
KNOWN_PRODUCT="fids pi"
for i in $KNOWN_PRODUCT; do
	if [ "$i" = "$1" ]; then
		PRODUCT=$1
		break;
	fi;
done;
if [ -z $PRODUCT ]; then
	echo "Usage:	./build_all.sh [Platform-alias]"
	echo "All Known products are :"
	echo "    $KNOWN_PRODUCT"
	exit;
fi;
echo "======TO BUILD: $PRODUCT"

# 关键变量3:
BINDIR=$ROOTDIR/bin                             # bin目录
CACHEDIR=$ROOTDIR/cache/$PRODUCT                # cache/${PRODUCT}, 本产品对应的cache目录
DISTDIR=$ROOTDIR/dist/$PRODUCT                  # dist/${PRODUCT}
SDKDIR=$DISTDIR/sdk                             # dist/${PRODUCT}/sdk, 编译时才需要用到的内容(可执行), x64架构，典型的是交叉工具链
DEVDIR=$SDKDIR/native                           # dist/${PRODUCT}/sdk/native, 编译交叉工具时所需的中间内容
BOOTDIR=$DISTDIR/boot                           # dist/${PRODUCT}/boot, 开发板启动时所需的内容
INSTDIR=$DISTDIR/rootfs                         # dist/${PRODUCT}/rootfs, 开发板的根目录内容
SRCDIR=$ROOTDIR/packages                        # package, nfs映射的源码包存储
TEMPDIR=$ROOTDIR/temp                           # temp目录，是内存映像文件系统，为了提高编译源码的效率
PATCHDIR=$TEMPDIR/patch                         # patch，补丁目录

export cachedir=$TEMPDIR/dist

#让cp命令保持符号链接
alias cp="cp -a"
alias install="install -D"

DBG="$TEMPDIR/log"
WARN="$TEMPDIR/warn"
NATIVE_PREREQUIRST='ccache autoconf automake pkgconfig  gettext libtool intltool'

sudo rm -rf $DISTDIR $DBG $WARN 1>/dev/null 2>&1 1>/dev/null 2>&1
mkdir -p $SDKDIR/usr/sbin $SDKDIR/usr/bin $SDKDIR/sbin $SDKDIR/bin $SDKDIR/usr/lib $SDKDIR/lib
mkdir -p $DEVDIR/include $DEVDIR/usr/include $DEVDIR/usr/lib $DEVDIR/lib $DEVDIR/usr/lib/pkgconfig $DEVDIR/usr/share/pkgconfig
mkdir -p $BOOTDIR $CACHEDIR $INSTDIR
cd $BINDIR/
source utils.sh
mount_temp
cd $ROOTDIR/

#############################
#  加载脚本
#############################
_surpress_echo=yes
tick_start
source $BINDIR/product_${PRODUCT}.sh || fail "product_${PRODUCT}.sh脚本错误！"
for parts in $BINDIR/functions_*.sh; do
	source $parts
done;
tick "引入并生成所有脚本"

echo $2
if [ "n$2" == 'n--list' ]; then
    show_all_package
    exit;
fi;
check_setting               # 检查编译依赖
check_cross_setting         # 检查交叉编译器
tick "代码检查"
unset _surpress_echo

#####################################
# 复制所有产品文件
mkdir -p $PATCHDIR
if [ -d $BINDIR/products/common ]; then
    exec_cmd "cp -fR $BINDIR/products/common/* $PATCHDIR"
fi;
if [ -d $BINDIR/products/$PRODUCT ]; then
    exec_cmd "cp -fR $BINDIR/products/$PRODUCT/* $PATCHDIR"
fi;

#############################
#  加载主机所需安装的软件包
#############################
init_rootfs()
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
	# init_basic_etc	
	# return 1
    #	exec_cmd "cp -R $SRCDIR/etc-sample/* etc/"	
}

# 主机环境
echo "==========================================="
echo "+ 开始构建主机环境"
echo "==========================================="
_need_apt_install=''
echo "Checking prerequist package on native environment ... $NATIVE_PREREQUIRST"
for ntv_pkg in $NATIVE_PREREQUIRST; do
    run_build0 native_${ntv_pkg}
    if [ $? -ne 0 ]; then
        _need_apt_install="${_need_apt_install} ${ntv_pkg}"
    fi;
done;
_need_apt_install=`echo $_need_apt_install`
if [ -n "$_need_apt_install" ]; then
    exec_cmd "sudo apt-get install -y $_need_apt_install"
fi;

echo ""
echo "==========================================="
echo "+ 开始构建"
echo "==========================================="

##### 执行构建任务
construct_$PRODUCT
post_install_$PRODUCT

echo "所有任务成功完成！"
