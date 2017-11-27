#!/bin/bash

generate_custom native_autogen_env prepare_native_autogen \
    '--depends=native_autoconf  native_automake  native_pkgconfig  native_gettext  native_libtool native_intltool'
function prepare_native_autogen()
{
    local t='nothing'
}

##############################
# 编译 ccache
CCACHEFILE=ccache-3.3.4
generate_script  native_ccache     $CCACHEFILE     \
    --build-native                  \
    '--config=--prefix=$DEVDIR/usr --disable-static'       \
    '--deploy-sdk=/usr/bin'                 \
    '--deploy-dev=/usr/bin'                 \
    '--depends=native_libz'
    
##############################
# 编译 beep 
# http://www.johnath.com/beep/
BEEPFILE=beep-1.3
generate_script  native_beep     $BEEPFILE     \
    --build-native   --make-before-install     \
    '--prescript=mkdir -p $TEMPDIR/dist/usr/bin $TEMPDIR/dist/usr/man/man1'     \
    '--install_target=install INSTALL_DIR=$TEMPDIR/dist/usr/bin MAN_DIR=$TEMPDIR/dist/usr/man/man1'     \
    '--deploy-sdk=/usr/bin'                 \
    '--deploy-dev=/usr/bin' 

##############################
# 编译 flex
# https://github.com/westes/flex/releases
#FLEXFILE=flex-2.6.4
#generate_script  native_flex     $FLEXFILE     \
#    --build-native                  \
#    '--prescript=./autogen.sh'     \
#    '--config=--prefix=$DEVDIR/usr --disable-static'       \
#    '--deploy-sdk=/usr/bin'                 \
#    '--deploy-dev=/usr/bin'                 \
#    '--depends=native_autogen_env' --debug
    

