#!/bin/sh

_subdir=`dirname $0`/utils
source $_subdir/util_tick.sh
source $_subdir/util_dep_check.sh
source $_subdir/util_gen_script.sh
source $_subdir/util_deploy.sh
source $_subdir/util_check_cross.sh

# QUIETLY='1>/dev/null 2>/dev/null'
concurrent_make=""

clean()
{
	cd $ROOTDIR
#	sudo umount $TEMPDIR
	rm -rf $TEMPDIR 1>$DBG
	mkdir $TEMPDIR
#	sudo mount -t tmpfs none $TEMPDIR 
}

mount_temp()
{
	df | grep -q "$TEMPDIR"
	if [ "$?" == "0" ]; then
	    sudo umount $TEMPDIR 1>/dev/null 2>&1
	fi;
	
	df | grep -q "$TEMPDIR"
	if [ "$?" == "0" ]; then
	    sudo rm -rf $TEMPDIR/* 1>/dev/null 2>&1 || fail "无法umount temp并且无法清空其中内容!"
	else
	    echo "MOUNT $TEMPDIR to Memory Disk"
	    mkdir -p $TEMPDIR
	    sudo mount -t tmpfs tmpfs $TEMPDIR -o size=4096M            # mount一个4G的内存盘
	fi;
	
	mkdir -p $TEMPDIR/.script
}

NATIVE_PREREQUIRST+=" beep"
sudo modprobe pcspkr
check()
{
	if [ $? -ne 0 ]; then
		fail "失败退出！最近一次调用的记录保存在 $DBG 文件中"
	fi
}
fail()
{
    echo $*;
	if [ -n "$CURRENT_TASK" ]; then
    	local locInfo=${_declare_loc[$CURRENT_TASK]}
		echo "最近一次编译任务：$CURRENT_TASK，定义于$locInfo"
		
		local fileName=${locInfo%:*}
        local line=${locInfo##*:}; 
		gedit $fileName +$line
    fi;
    
    beep -f 900 -l 500 -r 3
    exit;
}
beep_succ()
{
	beep -f 261 -l 200
	beep -f 294 -l 200
	beep -f 330 -l 200
	beep -f 349 -l 200
	beep -f 392 -l 200 
	beep -f 440 -l 200 
	beep -f 493 -l 200 
	beep -f 523 -l 200 
	
	beep -f 523 -l 200 
	beep -f 493 -l 200 
	beep -f 440 -l 200 
	beep -f 392 -l 200 
	beep -f 349 -l 200
	beep -f 330 -l 200
	beep -f 294 -l 200
	beep -f 261 -l 200
	
	exit 0;
}

prepare()
{
	if [[ $# < 1 ]]; then
		echo "prepare [package-name] [patch-name]"
		exit;
	fi;
	FILENAME=$1
	
	if [ ! -d $TEMPDIR/$FILENAME ]; then
	    # 先在产品自己的目录下面找源码包，/package/product/<product>/xxx
	    # 然后再在公共目录下找, /package/common/xxx
	    # 最后在工具目录下找, /package/tools/xxx
	    _try_list="product/$PRODUCT common tools"
	    echo $_try_list
	    for d in $_try_list; do
	        FULLNAME=`ls -b $SRCDIR/$d/$FILENAME.tar* 2>/dev/null`
	        if [ -n "$FULLNAME" ]; then
	            FILENAME=`basename $FULLNAME`
                FILENAME=${FILENAME%.tar.*}
	            break;      # 找到了
	        fi;
	    done;
		if [ -z "$FULLNAME" ]; then
		    fail "找不到$FILENAME软件包"
		fi;
		
		echo "... 解压 $FILENAME"
		[ ! -d $TEMPDIR/$FILENAME ] || rm -rf $TEMPDIR/$FILENAME 1>$DBG 2>$DBG
		tar axf $FULLNAME -C $TEMPDIR 1>$DBG 2>$DBG
		check
		
		while [ -n "$2" ]; do
            PATCHFILE=$2
            cd $TEMPDIR/$FILENAME
			patch -Np1 -i $PATCHDIR/$PATCHFILE 1>$DBG
			check
			echo "........ 补丁：$PATCHFILE"
            shift
        done
	fi;
	cd $TEMPDIR/`basename $FILENAME`
	echo "........ 当前目录是：$PWD"
}

exec_cmd()
{
	CMD="$1"
	
	if [ "z$_surpress_echo" != "zyes" ]; then
		echo "-------> $CMD"
	fi;
	
	echo "===================================================================================================================" >>$DBG
	echo "$CMD" >>$DBG
	echo "-------------------------------------------------------------------------------------------------------------------" >>$DBG
	$CMD 1>>$DBG 2>>$WARN
	check
}

run_cmd()
{
    $1
}

export concurrent_make=`nproc`
exec_build()
{
    exec_cmd "make -j $concurrent_make $*"
}
sudo_build()
{
	exec_cmd "sudo -E make -j $concurrent_make $*"
}

pack_cache()
{
    printf "%s packing $1 ... " "------->"
    [ -d $TEMPDIR/dist ] || fail "$TEMPDIR/dist目录不存在"
    [ -f $CACHEDIR/$1.tar.gz ] && rm -rf $CACHEDIR/$1.tar.gz
    cd $TEMPDIR/dist || fail "无法进入$TEMPDIR/dist"
    
    cd .$DEVDIR 1>/dev/null 2>&1
    cd .$SDKDIR 1>/dev/null 2>&1
    
    tar czf $CACHEDIR/$1.tar.gz . || fail "压缩失败！"
    cd $CACHEDIR/ || fail "切换目录失败!"
    sudo rm -rf $TEMPDIR/dist $TEMPDIR/build $TEMPDIR/$1 1>/dev/null 2>&1 &
    echo "OK!"
}


build_native()
{
	needcheck=0
	instdest=""
	maketarget=""
	installtarget="install"
	continue="no"
	work="work"
	
	PKGNAME=$1
	while [ "$1" ]; do
        if [[ "$1" == "--check" ]]; then
            needcheck=1
        fi
        if [[ "$1" == "--dest" ]]; then
        	shift;
        	instdest=$1
        fi;
        if [[ "$1" == "--target" ]]; then
        	shift;
        	maketarget=$1
        fi;
        if [[ "$1" == "--installtarget" ]]; then
        	shift;
        	installtarget=$1
        fi;
        if [[ "$1" == "--continue" ]]; then
        	continue="yes"
        fi;
        if [[ "$1" == "--inside" ]]; then
        	work="."
        fi;
	    shift
	done

	echo "##### Building $PKGNAME"
	echo "CFLAGS=\"$CFLAGS\""
	echo "CXXFLAGS=\"$CXXFLAGS\""
	echo "LDFLAGS=\"$LDFLAGS\""

	if [[ $continue == "no" && $work != "." ]]; then
		rm -rf $TEMPDIR/$work/$PKGNAME 1>/dev/null 2>/dev/null
		mkdir -p $TEMPDIR/$work/$PKGNAME
	fi;
	exec_cmd "cd $TEMPDIR/$work/$PKGNAME"
	echo "当前目录是$PWD"
	if [[ $continue == "no" ]]; then	
		exec_cmd "$TEMPDIR/$PKGNAME/configure $PARAM"
	fi;
	
	echo "........ 编译$PKGNAME中 @ $PWD"
	exec_cmd "make -j 10 "$maketarget
	if [[ $needcheck"r" == "1r" ]]; then
		exec_cmd "make check"
	fi;
	exec_cmd "make $installtarget $instdest"
	echo "........ $PKGNAME 编译成功"
}

changeoption()
{
	if [[ $# != 3 ]]; then
		echo "Usage: changeoption filename optionname newvalue"
		exit;
	else
		FILENAME=$1
		OPT=$2
		VAL=$3
		sed -i "/^\s*$OPT[[:space:]]*=/c $OPT=$VAL" $FILENAME
	fi;
}

replace_in_file()
{
    _filename=$1
    _oldstr=$2
    _newstr=$3
    _splittor=$4
    
    if [ -z "$_filename" ] || [ -z "_oldstr" ] || [ -z "_newstr" ]; then
		echo "Usage: replace_in_file <filename> <oldstr> <newstr> [splittor, default: #]"
		exit;
    fi;
    if [ -z "$_splittor" ]; then
        _splittor="#"
    fi;
    
    if [ ! -f "$_filename" ]; then
        echo "$_filename, File not exists! "
        exit;
    fi;

	sed -i "s$_splittor$_oldstr$_splittor$_newstr$_splittor" $_filename
	unset _filename
	unset _oldstr
    unset _newstr
    unset _splittor
}

disable_option()
{
    _file=$1
    _keyword=$2
    if [ -z "$_file" ] || [ -z "_keyword" ]; then
		echo "Usage: disable_option <filename> <keyword>"
		exit;
    fi;
    replace_in_file $_file "$_keyword=y" "#\ $_keyword\ is\ not\ set" "/"
    
    unset _file
    unset _keyword
}

saveenv()
{
	temp_store_path=$PATH
	temp_store_cflags=$CFLAGS
	temp_store_ldflags=$LDFLAGS
	temp_store_cxxflags=$CXXFLAGS
}

restoreenv()
{
	PATH=${temp_store_path}
	CFLAGS=${temp_store_cflags}
	LDFLAGS=${temp_store_ldflags}
	CXXFLAGS=${temp_store_cxxflags}
}

set_ccache_config()
{
  if [ -f $SDKDIR/usr/bin/ccache ]; then
        $SDKDIR/usr/bin/ccache --set-config=cache_dir=$TEMPDIR/.ccache || fail "无法设置ccache!"
        CCACHE=ccache
        alias gcc='ccache gcc'
        alias g++='ccache g++'
    else
        unset CCACHE
        unalias gcc
        unalias g++
    fi;
}
#####################################################
# initenv，交叉编译时的环境变量
initenv()
{
	export PATH=$ADDITION_PATH:$SDKDIR/usr/sbin:$SDKDIR/usr/bin:$SDKDIR/sbin:$SDKDIR/bin
	export PATH=$PATH:/usr/sbin:/usr/bin:/sbin:/bin
	export LD_LIBRARY_PATH=$DEVDIR/usr/lib:$DEVDIR/lib

    export MY_TOOLCHAIN_FLAGS="$TOOLCHAIN_FLAGS"
	export CFLAGS="$ADDITION_CFLAGS" 
	export CXXFLAGS=$CFLAGS
	export CPPFLAGS=$CFLAGS
	export LDFLAGS="$ADDITION_LDFLAGS"
	export LIBS=""
	
    unset_pkgconfig_env
    export PKG_CONFIG_PATH=$ADDITION_PKG_CONFIG_PATH:$SDKDIR/usr/lib/pkgconfig:$SDKDIR/usr/share/pkgconfig
    export PKG_CONFIG_LIBDIR="yes"             # 避免系统库污染?
    export PKG_CONFIG_SYSROOT_DIR='='
  
    set_ccache_config
    
    # python脚本
    unset PYTHONPATH            # PYTHONPATH, ubuntu定制的路径在dist-packages，否则缺省在site-packages
    local TDIR=`ls -d $SDKDIR/usr/lib/python2*/dist-packages 2>/dev/null`
    if [ -n $TDIR ]; then
        export PYTHONPATH=$PYTHONPATH:$TDIR
    fi;
    TDIR=`ls -d $SDKDIR/usr/lib/python2*/site-packages 2>/dev/null`
    if [ -n $TDIR ]; then
        export PYTHONPATH=$PYTHONPATH:$TDIR
    fi;
    
    unset PYTHONHOME            # PYTHONHOME, 应指定为<sysroot>/usr路径(即编译时的prefix)
    if [ -f $SDKDIR/usr/bin/python ]; then
        export PYTHONHOME=$SDKDIR/usr
    fi;
    hash -r
}

dispenv()
{
	echo "==============================================================================="
	echo "export PATH=$PATH"
	echo "export MY_TARGET=$MY_TARGET"
	echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
    echo "export MY_TOOLCHAIN_FLAGS=\"$TOOLCHAIN_FLAGS\""
	echo "export CFLAGS=\"$CFLAGS\""
	echo "export LDFLAGS=\"$LDFLAGS\""
	echo "export CXXFLAGS=\"$CXXFLAGS\""
	echo "export CPPFLAGS=\"$CPPFLAGS\""
	echo "export PKG_CONFIG_PATH=$PKG_CONFIG_PATH"
	echo "export PKG_CONFIG_SYSROOT_DIR=$PKG_CONFIG_SYSROOT_DIR"
#	echo "export PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=$PKG_CONFIG_ALLOW_SYSTEM_CFLAGS"
#	echo "export PKG_CONFIG_ALLOW_SYSTEM_LIBS=$PKG_CONFIG_ALLOW_SYSTEM_LIBS"
	if [ t"$PKG_CONFIG_LIBDIR" != "t" ]; then
	    echo "export PKG_CONFIG_LIBDIR=$PKG_CONFIG_LIBDIR"
	else
	    echo "unset PKG_CONFIG_LIBDIR"
	fi
	if [ t"$PYTHONPATH" != "t" ]; then
	    echo "export PYTHONPATH=$PYTHONPATH"
	else
	    echo "unset PYTHONPATH"
	fi
	if [ t"$PYTHONHOME" != "t" ]; then
	    echo "export PYTHONHOME=$PYTHONHOME"
	else
	    echo "unset PYTHONHOME"
	fi
	echo "export CCACHE=$CCACHE"
	echo "==============================================================================="
}

resetenv()
{
    # 基本的交叉编译路径
    export PATH=$TOOLCHAIN_BIN:$SDKDIR/usr/sbin:$SDKDIR/usr/bin:$SDKDIR/sbin:$SDKDIR/bin
	export PATH=$PATH:/usr/sbin:/usr/bin:/sbin:/bin
	
	unset MY_TOOLCHAIN_FLAGS
	unset CFLAGS
	unset CXXFLAGS
	unset LDFLAGS
	unset LIBS
}
reset_env()
{
	# 基本的路径
	export PATH=$SDKDIR/sbin:$SDKDIR/bin:$SDKDIR/usr/bin:/usr/sbin:/usr/bin:/sbin:/bin	# SDK　可执行路径
	
	unset CFLAGS 
	unset CXXFLAGS 
	unset LDFLAGS 
	unset LIBS 
}
init_native_env()
{
	# 基本的路径
	export PATH=$DEVDIR/usr/sbin:$DEVDIR/usr/bin:$DEVDIR/sbin:$DEVDIR/bin:/usr/sbin:/usr/bin:/sbin:/bin
	export LD_LIBRARY_PATH=$DEVDIR/usr/lib:$DEVDIR/lib
	
	export CFLAGS="-I$DEVDIR/include -I$DEVDIR/usr/include"
	export CXXFLAGS=$CFLAGS
	export CPPFLAGS=$CFLAGS
	export LDFLAGS="-L$DEVDIR/usr/lib -L$DEVDIR/lib"
	export LIBS=""

    set_ccache_config
    
    unset_pkgconfig_env	
    export PKG_CONFIG_PATH=$DEVDIR/usr/lib/pkgconfig:$DEVDIR/usr/share/pkgconfig
#	export PKG_CONFIG_SYSROOT_DIR=$DEVDIR
#	export PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1
#	export PKG_CONFIG_ALLOW_SYSTEM_LIBS=1
	unset PKG_CONFIG_LIBDIR

    unset PYTHONPATH            # PYTHONPATH, ubuntu定制的路径在dist-packages，否则缺省在site-packages
    local TDIR=`ls -d $DEVDIR/usr/lib/python2*/dist-packages 2>/dev/null`
    if [ -n $TDIR ]; then
        export PYTHONPATH=$PYTHONPATH:$TDIR
    fi;
    TDIR=`ls -d $DEVDIR/usr/lib/python2*/site-packages 2>/dev/null`
    if [ -n $TDIR ]; then
        export PYTHONPATH=$PYTHONPATH:$TDIR
    fi;
    
    unset PYTHONHOME            # PYTHONHOME, 应指定为<sysroot>/usr路径(即编译时的prefix)
    if [ -f $DEVDIR/usr/bin/python ]; then
        export PYTHONHOME=$DEVDIR/usr
    fi;
    
    hash -r
}
unset_pkgconfig_env()
{
    unset PKG_CONFIG_PATH
	unset PKG_CONFIG_SYSROOT_DIR
	unset PKG_CONFIG_ALLOW_SYSTEM_CFLAGS
	unset PKG_CONFIG_ALLOW_SYSTEM_LIBS
	unset PKG_CONFIG_LIBDIR
}

# 获取相对路径
# 例如： 
#    dir1='/home/baiyun/git/candyOS/temp/dist0/usr/lib/python2.7/site-packages'
#    dir2='/home/baiyun/git/candyOS/temp/dist0/usr/lib/gobject-introspection/giscanner'
#    get_rel_dir $dir1 $dir2
# 返回"../../gobject-introspection/giscanner"
# 各个参数可以使用相对路径，目录可以不存在
function get_rel_dir()
{
    local dir1=`readlink -m $1`
    local dir2=`readlink -m $2`
    if [ -z $dir1 ] || [ -z $dir2 ]; then
        echo "Usage: get_rel_dir <current_dir> <target_dir>"
        exit 1;
    fi;
    
    # 去掉前缀
    local prefix=$dir1
    local rel0=''
    local plen=${#prefix}
    until [ -z ${prefix} ] || [ ${prefix} = ${dir2:0:$plen} ]; do
        prefix=${prefix%/*}
        rel0=$rel0'../'
        plen=${#prefix}
    done;
    local relpath=$rel0${dir2:$plen+1}
    echo $relpath
}

