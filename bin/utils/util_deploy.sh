#!/bin/sh

##########################################################################################
# deploy <type> <pkg_name> <deploy_contents...>
# 发布文件
#
# type: 只能是sdk,rootfs,dev,boot
# pkg_name: $CACHEDIR目录下的包名 (<pkg_name>.tar.gz是cache下面的一个压缩文件)
# deploy_contents:
#   "-/usr/lib/*.la"  表示去掉这个文件(目录)
#   "/usr/bin"        表示deploy这个文件(目录)
# 例如：
#	deploy rootfs $LIBALSAFILE "/"
##########################################################################################
deploy()
{
    local _original_params=$*
    
    set -f          # 关闭通配符扩展
    local _type=$1
    [ -n "$_type" ]       || fail "deploy必须带参数<type>: sdk/rootfs/target";
    
    local _pkg_name="$2"
    local _pkg_subdir=''
    local idx=`expr index $2 '/'`
    if [ $idx -ne 0 ]; then
        _pkg_name=${2:0:(($idx-1)) }
        _pkg_subdir=${2:(($idx-1))}
    fi
    [ -n "$_pkg_name" ]   || fail "deploy必须带参数<pkg_name>";
        
    [ -f $CACHEDIR/$_pkg_name.tar.gz ] || fail "Cache中不存在$_pkg_name.tar.gz";
    shift 2
    
    local _scripts=''
    local _add_list=""
    local _add_cmd=""
    local _remove_list=""
    local _remove_cmd=""
    until [ -z "$1" ]; do
        if [ "${1:0:1}" == "=" ]; then
            _scripts=$_scripts' '${1:1}
        elif [ "${1:0:2}" == "-/" ]; then
            _remove_list=$_remove_list" "${1:1}
            _remove_cmd=$_remove_cmd" ."${1:1}
        elif [ "${1:0:1}" == "/" ]; then
            _add_list=$_add_list" "${1}
            _add_cmd=$_add_cmd" ."${1}
        else
            echo "Add & Remove 的内容必须以/打头 : '$1'"
            exit;
        fi;
        shift;
    done;
    
    local _deploy_dir=""
    local _change_pc="N"
    unset _change_la1_dir;      # libtool的交叉编译BUG: 例如dependency_libs=' /usr/lib/libpam.la -ldl'，这时/usr/lib/libpam.la不会加sysroot，应该是前加等号' =/usr/lib/libpam.la'
    unset _change_la2_dir;      # libtool '-I /usr/lib/gio-2.1',这时应转换为'-I =/usr/lib/gio-2.1'才会有sysroot自动添加；'-L'同理
    case $_type in
    "sdk")  
        _deploy_dir=$SDKDIR
        local _change_la1_dir='='
        local _change_la2_dir='='
#        local _change_python='Y'
        ;;
    "rootfs")
        _deploy_dir=$INSTDIR
        ;;
    "dev")
        _deploy_dir=$DEVDIR
        #_change_pc="Y"
        #local _change_la1_dir=$DEVDIR
        #local _change_la2_dir=$DEVDIR
#        local _change_python='Y'
        ;;
    "boot")
        _deploy_dir=$BOOTDIR
        ;;
    *)
        echo "deploy <type>只能是: sdk/rootfs/dev/boot其中之一"
        exit;
    esac
    
    [ -n "$_add_list" ]     || fail "没有任何内容可以deploy: deploy $_original_params";
    echo "-----> DEPLOYING $_pkg_name to $_type, Remove {$_remove_list } and then Add {$_add_list }"
    set +f
        
    # deploy操作
	mkdir -p $TEMPDIR/.cacheout || fail "无法创建deploy临时目录"
	sudo tar xf $CACHEDIR/$_pkg_name.tar.gz -C $TEMPDIR/.cacheout 1>/dev/null 2>&1 || "无法解压$_pkg_name.tar.gz"
	cd $TEMPDIR/.cacheout/.$_pkg_subdir 1>/dev/null 2>&1 || fail "无法切换到目录$_pkg_subdir"
	if [ -n "$_remove_cmd" ]; then
        sudo rm -rf $_remove_cmd 1>/dev/null 2>&1  || fail "无法删除文件或目录, $d"
    fi;
    
    # 改变.pc和.la的sysroot
    if [ n${_change_pc} = "nY" ]; then
        for f in `find . -name *.pc`; do
            if [ ! -L $f ]; then                ## 不修改符号链接
                #printf "Changing $f ... "
                sudo sed -i -r "s#^([a-Z_]+)\=/#\1=${_deploy_dir}/#" $f || fail "修改pkg-config文件失败！"
                #echo "OK!"
            fi;
        done;
    fi;
    if [ -n "${_change_la1_dir}" ]; then
        for f in `find . -name *.la`; do
            if [ ! -L $f ]; then                ## 不修改符号链接
                sudo sed -i -r "s#\ \=?(/[^\ ]+\.la)#\ ${_change_la1_dir}\1#g" $f || fail "修改la文件失败1！"
            fi;
        done;
    fi;
    if [ -n "${_change_la2_dir}" ]; then
        for f in `find . -name *.la`; do
            if [ ! -L $f ]; then                ## 不修改符号链接
                sudo sed -i -r "s#\ -L[\ ]?/([^\ ]+)#\ -L\ ${_change_la2_dir}/\1#g" $f || fail "修改la文件失败2.1！"
                sudo sed -i -r "s#\ -I[\ ]?/([^\ ]+)#\ -I\ ${_change_la2_dir}/\1#g" $f || fail "修改la文件失败2.2！"
            fi;
        done;
    fi;
######################################################
# 有些python脚本会使用#!/usr/bin/python打头，而python会跟据可执行程序的绝对位置来决定搜索路径
# 所以会想到修改这些值，指到$SDKDIR/usr/bin/python，但这种情况太多了，所以改不过来
# 实际上，可以使用 PYTHONHOME 这个环境变量，该变量需要指向<sysroot>/usr目录
#    if [ y$_change_python = 'yY' ]; then
#        sudo find * -type f -exec sed -i "1,1s@^#\!/usr/bin/python@#\!${_deploy_dir}/usr/bin/python@" {} \; || fail "修改python引用失败！"
#    fi;
    
    if [ -n "$_deploy_dir" ]; then
        if [ -n "${_scripts}" ]; then
            for s in ${_scripts}; do
                exec_cmd "$s"
            done;
        fi;
        for d in $_add_cmd; do
            if [ -d $d ]; then
                sudo mkdir -p $_deploy_dir/$d
                sudo cp -Rdpvf $d/* $_deploy_dir/$d 1>/dev/null 2>&1 || fail "无法复制文件或目录$d"
            else
                local _subd_name=`dirname $d`
                sudo mkdir -p $_deploy_dir/$_subd_name
                sudo cp -Rdpvf $d $_deploy_dir/$_subd_name 1>/dev/null 2>&1 || fail "无法复制文件或目录$d"
            fi;
        done;
    fi;

    cd $TEMPDIR
    sudo rm -rf $TEMPDIR/.cacheout #1>/dev/null 2>&1
}


# 获取python的模块路径，例如:
#       PYMODULEDIR=`python_module_dir /usr`
function python_module_dir()
{
    local prefix=$1
    if [ -z $prefix ]; then
        prefix='/usr'
    fi;
    
    # 这一段代码，来自autotool自动生成的configure脚本
    python -c "\
import sys
# Prefer sysconfig over distutils.sysconfig, for better compatibility
# with python 3.x.  See automake bug#10227.
try:
    import sysconfig
except ImportError:
    can_use_sysconfig = 0
else:
    can_use_sysconfig = 1
# Can't use sysconfig in CPython 2.7, since it's broken in virtualenvs:
# <https://github.com/pypa/virtualenv/issues/118>
try:
    from platform import python_implementation
    if python_implementation() == 'CPython' and sys.version[:3] == '2.7':
        can_use_sysconfig = 0
except ImportError:
    pass

sitedir = sysconfig.get_path('purelib', vars={'base':'$prefix'})
if can_use_sysconfig:
    sitedir = sysconfig.get_path('purelib', vars={'base':'$prefix'})
else:
    from distutils import sysconfig
    sitedir = sysconfig.get_python_lib(0, 0, prefix='$prefix')
sys.stdout.write(sitedir)
"
}

