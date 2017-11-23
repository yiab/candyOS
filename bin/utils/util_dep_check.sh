#!/bin/bash

#############################
# 增强依赖管理
# 1. 定义${_BUILD_FUNC_PREFIX_}变量
#       早期的设计是“两阶段编译”，build_xxx调用compile_xxx
#       修改为增强依赖管理后，不需要compile_xxx了，也不需要stamp文件，直接基于内存的变量即可完成
#       这样，为了避免函数命名空间冲突，定义${_BUILD_FUNC_PREFIX_}变量为代替"build"这个字眼
export _BUILD_FUNC_PREFIX_="_b_u_i_l_d_"
declare -A _depends_map         # 每个包依赖的其它包，例如_depends_map["libpng"]="libz"
declare -A _declare_loc         # 每个包的定义位置，例如_declare_loc["libpng"]="function_build_basic:51"
declare -A _task_has_completed

###################################
# 检查所有的编译设定
# 1. 是否定义了一些依赖包，但不知道怎么编译它
# 2. 依赖包之间是否有循环依赖
function check_setting()
{
    local hasError='N'
    unset _checking
    unset _deplink
    declare -A _checking
    local i
    
    jobs -l
    
    # 列出所有"build_"打头的函数
    local _flist_=(`declare -f | sed -rn "s#^${_BUILD_FUNC_PREFIX_}_([a-Z_0-9]+)[\ ]*\(\)#\1#p"`)
    local n=${#_flist_[@]}
    echo 共定义 $n 个软件包
    
    tick_start
    for (( i=0; i<$n; i++ )) ; do
        name=${_flist_[$i]}
        deps=${_depends_map[$name]}
        
        _checking["$name"]="Y"
        _deplink[0]="$name"
        for d in $deps; do
            if [ -z `type -t ${_BUILD_FUNC_PREFIX_}_$d` ]; then
                echo "未定义如何编译 $name 的依赖包 $d !!!"
                echo "....at ${_declare_loc[$name]}"
                echo 
                hasError='Y';
            fi;
            
            # 查找依赖
            #echo "checking $d"
            check_dependency $d
        done;
        unset _checking[$name]
        unset _deplink
    done
    unset _checking
    tick "检查所有函数"
    
    if [ $hasError = 'Y' ]; then
        echo "存在错误，是否继续？(Y/N)"
        read hasError
        if [ s$hasError = 'sn' ]; then
            echo "请修订后再次运行"
            exit;
        fi;
    fi;
}

function check_dependency()
{
    local name=$1
    local idx=${#_deplink[@]}
    _deplink[$idx]=$name
    _checking[$name]="Y"

    deps=${_depends_map[$name]}
    for d in $deps; do
        if [ "Y" == "${_checking[$d]}" ]; then
            echo "Dead Loop: ${_deplink[*]} $d"
            exit;
        fi;
        
        check_dependency $d
    done;
    
    unset _checking[$name]
    unset _deplink[$idx]
}

function show_all_package()
{
    local _flist_=(`declare -f | sed -rn "s#^${_BUILD_FUNC_PREFIX_}_([a-Z_0-9]+)[\ ]*\(\)#\1#p"`)
    local n=${#_flist_[@]}
    echo 共定义 $n 个软件包
    for (( i=0; i<$n; i++ )) ; do
        local name=${_flist_[$i]}
        local deps=${_depends_map[$name]}
        local locs=${_declare_loc[$name]};
        
        echo "$name    @ $locs"
        echo "----> DEPS: $deps"
    done
}
