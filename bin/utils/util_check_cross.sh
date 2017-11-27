#!/bin/sh

# 安装交叉工具链
function check_cross_setting()
{
    # 设置交叉编译路径
    if [ -n "$TOOLCHAIN_FILE" ]; then 
        echo "检查交叉工具链 ... "
        if [ ! -d $SDKDIR/$TOOLCHAIN_FILE ]; then
            rm -rf $TEMPDIR/*
            prepare $TOOLCHAIN_FILE
            mv $TEMPDIR/$TOOLCHAIN_FILE $SDKDIR/ || fail "复制文件到$SDKDIR出错!"
        fi;
        if [ -z "$TOOLCHAIN_BIN" ]; then
            export TOOLCHAIN_BIN=$(cd $SDKDIR/$TOOLCHAIN_FILE/bin; pwd)
            [ -n $TOOLCHAIN_BIN ] || fail "无法自动查找到交叉编译器的可执行目录，product_xxx.sh脚本应设置TOOLCHAIN_BIN变量"
        fi;
        echo "export TOOLCHAIN_BIN=$TOOLCHAIN_BIN"
        export ADDITION_PATH=$ADDITION_PATH:$TOOLCHAIN_BIN
            
        if [ -z "$MY_TARGET" ]; then
            cd $TOOLCHAIN_BIN || fail "无法切换到$TOOLCHAIN_BIN目录"
            _var=`ls *-gcc`
            [ -n "$_var" ] || fail "无法自动查找到交叉编译前缀";
            export MY_TARGET=${_var:0:(-4)}
        fi;
        echo "export MY_TARGET=$MY_TARGET"
        
        # 复制自带的sysroot
        local sysroot_dir=`$TOOLCHAIN_BIN/$MY_TARGET-gcc -print-sysroot`
        if [ -d $sysroot_dir ]; then
            echo "复制交叉编译器自带的sysroot"
            mkdir -p $SDKDIR/lib $SDKDIR/usr/lib $SDKDIR/usr/include $SDKDIR/include
            cp -Ra $sysroot_dir/* $SDKDIR/ 1>/dev/null 2>&1 || fail "复制自带sysroot出错"
            #mv -f $SDKDIR/usr/include/* $SDKDIR/include 1>/dev/null 2>&1            # 系统的头文件放在/include下，避免与应用层冲突（也会存在交叉编译污染）
            
            cd $TOOLCHAIN_BIN || fail "交叉编译器的bin目录无法进入"
            sudo mv $MY_TARGET-gcc $MY_TARGET-gcc-real 1>/dev/null 2>&1
            sudo mv $MY_TARGET-g++ $MY_TARGET-g++-real 1>/dev/null 2>&1
            sudo rm $MY_TARGET-c++ 1>/dev/null 2>&1
            
            cat << _EOF_ > $MY_TARGET-gcc
#!/bin/bash
\${CCACHE} arm-linux-gnueabihf-gcc-real --sysroot=/home/baiyun/git/ckOS/dist/pi/sdk -isystem =/include \$MY_TOOLCHAIN_FLAGS "\$@" <&0
_EOF_
            chmod +x $MY_TARGET-gcc

            cat << _EOF_ > $MY_TARGET-g++
#!/bin/bash
\${CCACHE} arm-linux-gnueabihf-g++-real --sysroot=/home/baiyun/git/ckOS/dist/pi/sdk -isystem =/include \$MY_TOOLCHAIN_FLAGS "\$@" <&0
_EOF_
            chmod +x $MY_TARGET-g++
            ln -s $MY_TARGET-g++ $MY_TARGET-c++
            
            cd $ROOTDIR
        fi;
    else
         echo "没有指定交叉工具链！如果要进行交叉编译, product_xxx.sh脚本应设置TOOLCHAIN_FILE变量!"
    fi;
}
