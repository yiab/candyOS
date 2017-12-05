#!/bin/bash

####################################
# 工具函数，返回调用点位置，用于调试
# 例如：
#       在file1:59调用some_func, some_func()中可通过loc=`callee_location`获得"file1:59"的字符串
function callee_location()
{
    echo "${BASH_SOURCE[2]}:${BASH_LINENO[1]}"
}

function check_dup()
{
    local funcName=$1
    type -t ${_BUILD_FUNC_PREFIX_}_$funcName 1>/dev/null 2>&1
    if [ $? -eq 0 ]; then
        return -1;
    fi;
    return 0;
}

#####################################################
# generate_script, 快速生成脚本
# 
# generate_script <name> <pkg_filename> --config='pass to ./configure' --install_key='pass to make install' --debug (stop when complete)
# 例如：
#    generate_script  x11_util_macros  $X11_UTIL_MACROS 
#                '--config=--prefix=/usr --host=$MY_TARGET' 
#                '--install_key=DESTDIR'
#####################################################
function generate_script()
{
#    set -f && generate_script_task "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "${8}" "${9}" "${10}" "${11}" "${12}" "${13}" &

    local funcName=$1
    local fullpkgFileName=$2
    shift 2
    local configParam=''
    local destKey='DESTDIR'
    local install_target='install'
    local isDebug=''
    local initNativeCmd=''
    local keepGenSh='N'
    local scriptFilename="$TEMPDIR/.script/_build_$funcName.gen.sh"
    local patch_file=""
    local pkgFileName=${fullpkgFileName##*/}
    local buildDir=$TEMPDIR/build
    local buildFunc="exec_build"
    unset customScript
    local loc=`callee_location`

    set -f
    until [ -z "$1" ]; do
        local _item=`echo $1`       # 去掉首部空格，如果全空格，则为空
        local _cfg_key=${_item%%=*}
        local _cfg_value=${_item#--*=};
        
        if [ -n "$_item" ]; then
            case $_cfg_key in
            "--config")
                configParam=$_cfg_value;
                ;;
            "--install_key")
                destKey=$_cfg_value;
                ;;
            "--install_target")
                install_target=$_cfg_value;
                ;;
            "--patch")
                patch_file=$patch_file' '$_cfg_value;
                ;;
            "--sudo-build")
                buildFunc="sudo_build";
                ;;
            "--inside")
                buildDir='$TEMPDIR/'$pkgFileName;
                ;;
            "--make-before-install")
                local firstMakeCmd='exec_build "V=1"';
                ;;
            "--debug")
                isDebug='exit ;'
                makeVerbos='V=1'
                ;;
            "--prescript")
                local pre_script_array;
                local len=${#pre_script_array[@]}
                pre_script_array[$len]=$_cfg_value;
                ;;
            "--postscript")
                local post_script_array;
                local len=${#post_script_array[@]}
                post_script_array[$len]=$_cfg_value;
                ;;
            "--script")
                local customScript;
                local len=${#customScript[@]}
                customScript[$len]=$_cfg_value;
                ;;
            "--keep")
                local keepGenSh='Y';
                ;;
            "--build-native")
                local initNativeCmd='init_native_env';
                ;;
            "--show-usage")
                local usageCmd='Y';
                ;;
            "--deploy-rootfs")
                local deploy_rootfs="deploy rootfs $funcName $_cfg_value"
                ;;   
            "--deploy-boot")
                local deploy_boot="deploy boot $funcName $_cfg_value"
                ;;   
            "--deploy-sdk")
                local deploy_sdk="deploy sdk $funcName $_cfg_value"
                ;;   
            "--deploy-dev")
                local deploy_dev="deploy dev $funcName $_cfg_value"
                ;;  
            "--depends")
                local dependList=$_cfg_value;
                ;;
            *)
                echo "generate_script()不可识别的参数： $1"
                exit;
            esac
        fi;
        shift;
    done;
    set +f
    
    check_dup $funcName || fail "重复定义$funcName, @`callee_location` ";
#=============================================================================================================
cat << _EOF_ > $scriptFilename
${_BUILD_FUNC_PREFIX_}_$funcName()
{
	if [ ! -f \$CACHEDIR/$funcName.tar.gz ]; then
		sudo rm -rf \$TEMPDIR/$pkgFileName \$TEMPDIR/build \$TEMPDIR/dist 1>/dev/null 2>&1
		$initNativeCmd
		prepare $fullpkgFileName $patch_file
_EOF_
#--------------------------------------------------------------------------------------------------------------
    
    local n=${#customScript[@]}
    if [ $n -gt 0 ]; then
        # 纯定制的编译脚本
        set -f
        local i=0
        for (( i=0; i<$n; i++ )) ; do
            echo "echo ++++++++ ${customScript[$i]} " >> $scriptFilename
            echo "${customScript[$i]} 1>>\$DBG 2>>\$WARN || fail '${customScript[$i]}执行失败'" >> $scriptFilename
        done
        set +f
    else
        # configure脚本
        local n=${#pre_script_array[@]}
        if [ $n -gt 0 ]; then
            set -f
            local i=0
            for (( i=0; i<$n; i++ )) ; do
                echo "echo ++++++++ ${pre_script_array[$i]} " >> $scriptFilename
                echo "${pre_script_array[$i]} 1>>\$DBG 2>>\$WARN" >> $scriptFilename
                echo '[ $? -eq 0 ] || fail '${pre_script_array[$i]} >> $scriptFilename
            done
            set +f
        fi;
        
        if [ -n "$usageCmd" ]; then
            cat << _EOF_ >> $scriptFilename
                exec_cmd "./configure --help"
                [ -f "README" ] && exec_cmd "cat README"
                [ -f "INSTALL" ] && exec_cmd "cat INSTALL"
_EOF_
        fi;
        
        #--------------------------------------------------------------------------------------------------------------
        cat << _EOF_ >> $scriptFilename
            dispenv
            exec_cmd "mkdir -p $buildDir \$TEMPDIR/dist"
            if [ -f ./configure ]; then
		        exec_cmd "cd $buildDir"
		        exec_cmd "../$pkgFileName/configure $configParam"
		    fi;
            $firstMakeCmd
		    $buildFunc "$install_target $makeVerbos $destKey=\$TEMPDIR/dist"
_EOF_
        #--------------------------------------------------------------------------------------------------------------
        
        local n=${#post_script_array[@]}
        if [ $n -gt 0 ]; then
            echo "exec_cmd \"cd \$TEMPDIR/dist\"" >> $scriptFilename
            set -f
            local i=0
            for (( i=0; i<$n; i++ )) ; do
                echo "exec_cmd \"${post_script_array[$i]}\"" >> $scriptFilename
            done
            set +f
        fi;
        
        if [ -n "$isDebug" ]; then
            echo 'echo "Build Finished! Press any key to continue!"' >> $scriptFilename
            echo 'read _any_char' >> $scriptFilename
        fi;
    fi;
    
    echo "        pack_cache $funcName" >> $scriptFilename
    if [ -z "$isDebug" ]; then
        echo "        sudo rm -rf \$TEMPDIR/$pkgFileName \$TEMPDIR/build \$TEMPDIR/dist 1>/dev/null 2>&1" >> $scriptFilename
    else
        echo "        exit" >> $scriptFilename
    fi;
	
    #--------------------------------------------------------------------------------------------------------------
    
    cat << _EOF_ >> $scriptFilename
	    fi;
	
	set -f;
	$deploy_rootfs
	$deploy_boot
	$deploy_sdk
	$deploy_dev
	$isDebug
    set +f
}

_depends_map+=( ["$funcName"]="$dependList" )
_declare_loc+=( ["$funcName"]="$loc" )
_EOF_
#--------------------------------------------------------------------------------------------------------------

    source $scriptFilename || fail "脚本$scriptFilename出错"
    [ 'Y' == "$keepGenSh" ] || rm -rf $scriptFilename
    
    set +f
}

###################################################
# 生成别名
# generate_alias <alias_name> <real_name>
# 例如： generate_alias egl egl_pi
function generate_alias()
{
    if [ $# -ne 2 ]; then
        echo "generate_alias <alias_name> <real_name>"
        exit;
    fi;
    local aliasName=$1
    local realName=$2
    local scriptFilename="$TEMPDIR/.script/_build_$aliasName.gen.sh"
    local loc=`callee_location`
    
    check_dup $aliasName || fail "重复定义$aliasName, @`callee_location` ";
    cat << _EOF_ > $scriptFilename
${_BUILD_FUNC_PREFIX_}_$aliasName()
{
	run_build $realName
}
_depends_map+=( ["$aliasName"]="$realName" )
_declare_loc+=( ["$aliasName"]="$loc" )

_EOF_
    source $scriptFilename || fail "脚本$scriptFilename出错"
    rm -rf $scriptFilename
}

###################################################
# 生成自定义的编译函数
# generate_custom <pkg_name> <real_function_name>
#       --depends=<depend list>
# 例如： generate_custom kernel build_kernel
function generate_custom()
{
    if [ $# -lt 3 ]; then
        echo "generate_custom <pkg_name> <real_function_name> --depends=<depend list>"
        exit;
    fi;
    local pkgName=$1
    local realFunction=$2
    local param=`echo $3`       # 去掉首部空格，如果全空格，则为空
    local loc=`callee_location`
    
    set -f;
    if [ -n "$param" ]; then
        local _cfg_key=${param%%=*}
        local _cfg_value=${param#--*=};
        if [ n"${_cfg_key}" == n"--depends" ]; then
            local _depList=${_cfg_value}
        fi;
    fi;
    local scriptFilename="$TEMPDIR/.script/_build_$pkgName.gen.sh"
    
    check_dup $pkgName || fail "重复定义$pkgName, @`callee_location` ";
    
    cat << _EOF_ > $scriptFilename
${_BUILD_FUNC_PREFIX_}_${pkgName}()
{
	$realFunction
}
_depends_map+=( ["$pkgName"]="$_depList" )
_declare_loc+=( ["$pkgName"]="$loc" )

_EOF_
    source $scriptFilename || fail "脚本$scriptFilename出错"
    rm -rf $scriptFilename
    set +f
}

function run_build()
{
    if [ $# -lt 1 ]; then
        echo "run_build <pkg1> <pkg2> ..."
    fi;
    
    until [ -z "$1" ]; do
        local _pkg=`echo $1`       # 去掉首部空格，如果全空格，则为空
        
        run_build0 ${_pkg}
        shift;
    done;
}

function run_build0()
{
    if [ $# -lt 1 ]; then
        echo "run_build0 <pkg_name>"
    fi;
    
    local pkgName=$1
    if [ -z ${_declare_loc[$pkgName]} ]; then
        return -1;          # 没有这个软件包
    fi;
    
    if [ y${_task_has_completed[$pkgName]} = 'yY' ]; then
        return 0;
    fi;
    
    local depList=${_depends_map[$pkgName]}
    for p in $depList; do
        local s=${_task_has_completed[$p]}
        if [ y$s != 'yY' ]; then
            run_build0 $p
        fi;
    done;
    
    # 本函数运行
    unset CC
	unset CXX
	unset CPP
	unset ACLOCAL
	cd $ROOTDIR
	CURRENT_TASK=$pkgName
	initenv
    mkdir -p $TEMPDIR/dist 1>/dev/null 2>&1
	echo "任务<$pkgName> ==> 开始执行, 定义于${_declare_loc[$pkgName]}"
	hash -r
	${_BUILD_FUNC_PREFIX_}_${pkgName}
    sudo rm -rf -p $TEMPDIR/dist 1>/dev/null 2>&1
    rm -rf $DBG $WARN
    _task_has_completed+=([$pkgName]="Y")
    unset CURRENT_TASK
}
