#!/bin/bash


##############################
# 编译 cross_autogen_env
generate_custom cross_autogen_env prepare_cross_autogen \
    '--depends=cross_autoconf  cross_automake  cross_pkgconfig  cross_gettext  cross_libtool cross_intltool'
prepare_cross_autogen()
{
    local do_nothing;
}

##############################
# 编译交叉编译使用的 autoconf
AUTOCONFFILE=autoconf-2.69
generate_script  cross_autoconf     $AUTOCONFFILE     \
    '--config=--prefix=$SDKDIR/usr --host=$MY_TARGET --disable-static'       \
    '--deploy-sdk=/'

generate_script  native_autoconf     $AUTOCONFFILE     \
    '--config=--prefix=$DEVDIR/usr'       \
    '--deploy-dev=/'
    
##############################
# 编译本机运行的 automake
AUTOMAKEFILE=automake-1.15
generate_script  cross_automake     $AUTOMAKEFILE     \
    '--config=--prefix=$SDKDIR/usr --disable-static'       \
    '--deploy-sdk=/'
    
generate_script  native_automake     $AUTOMAKEFILE     \
    '--config=--prefix=$DEVDIR/usr --disable-static'       \
    '--deploy-dev=/'

##############################
# 编译 libtool
# build_native_libtool()
LIBTOOLFILE=libtool-2.4.6
generate_script  native_libtool     $LIBTOOLFILE     \
    --build-native                  \
    '--config=--prefix=$DEVDIR/usr --disable-static'       \
    '--deploy-dev=/'
    
# --debug --show-usage 
generate_script  cross_libtool     $LIBTOOLFILE     \
    '--config=--prefix=$SDKDIR/usr --host=$MY_TARGET --disable-static'       \
    '--deploy-sdk=/'

##############################
# 编译 intltool-0.51.0
INTLTOOL=intltool-0.51.0
generate_script  native_intltool     $INTLTOOL     \
    '--config=--prefix=$DEVDIR/usr --disable-static'       \
    '--deploy-dev=/'
    
generate_script  cross_intltool     $INTLTOOL     \
    '--config=--prefix=/usr --host=$MY_TARGET --disable-static'       \
    '--deploy-sdk=/'
#NATIVE_PREREQUIRST+=" libexpat1-dev libncurses5-dev"        # 编译native gettext需要expat和ncurses

############################################
# 编译 expat
#    build_native_expat()
EXPATFILES=expat-2.2.5
generate_script  native_expat     $EXPATFILES     \
    --build-native                  \
    '--config=--prefix=$DEVDIR/usr --disable-static'       \
    '--deploy-dev=/'

generate_script  expat     $EXPATFILES     \
    '--config=--prefix=/usr --sysconfdir=/etc --host=$MY_TARGET --disable-static'       \
    '--deploy-sdk=/usr/include /usr/lib'    \
    '--deploy-rootfs=/usr/bin /usr/lib -/usr/lib/*.la -/usr/lib/pkgconfig'
    
##############################
# 编译 ncurses
#    build_native_ncurses
NCURSESFILE=ncurses-6.0
generate_script  native_ncurses     $NCURSESFILE     \
    --build-native                 \
    --make-before-install   \
    '--config=--prefix=$DEVDIR/usr --with-shared --without-normal --without-debug --enable-relocatable --without-ada --without-manpages --without-tests'       \
    '--deploy-dev=/'

generate_script  ncurses     $NCURSESFILE     \
    --make-before-install   \
    '--prescript=export CFLAGS="-fPIC -fpic"'   \
    '--config=--host=$MY_TARGET --prefix=/usr --without-cxx --without-shared --without-ada --without-manpages --without-tests --without-progs'       \
    '--deploy-sdk=/usr/include /usr/lib /usr/share'     

generate_script  ncursesw     $NCURSESFILE     \
    --make-before-install   \
    '--config=--host=$MY_TARGET --prefix=/usr --without-cxx --without-shared --enable-widec --without-ada --without-manpages --without-tests --without-progs'       \
    '--deploy-sdk=/'

##############################
# 编译 gettext-0.19.8
GETTEXT=gettext-0.19.8
# GETTEXT只会在编译的时候用到，也就是说，最多出现在sdk里面
#generate_script  gettext     $GETTEXT     \
#    '--config=--prefix=/usr --host=$MY_TARGET --with-sysroot=$SDKDIR --disable-shared --without-emacs --without-git --disable-acl --disable-openmp --disable-java'       \
#    '--depends=expat ncurses' \
#    '--deploy-sdk=/usr/lib -/usr/share -/usr/bin' --debug

generate_script cross_gettext $GETTEXT  \
    --build-native                 \
    '--config=--prefix=$SDKDIR/usr --disable-shared --without-emacs --without-git --disable-acl --disable-openmp --disable-java'       \
    '--depends=native_expat native_ncurses' \
    '--deploy-sdk=/usr/bin /usr/share -/usr/share/doc -/usr/share/man -/usr/share/locale'  
    
generate_script  native_gettext     $GETTEXT     \
    --build-native                 \
    '--config=--prefix=$DEVDIR/usr --disable-static --without-emacs --without-git --disable-acl --disable-openmp --disable-java'       \
    '--depends=native_expat native_ncurses' \
    '--deploy-dev=/ -/usr/share' 

##############################
# 编译 Python
PYTHON27FILE=Python-2.7.14
generate_script     cross_python   $PYTHON27FILE                    \
    '--patch=python-config-crosscompile.patch'    \
    '--depends=native_python expat ncursesw libbz2 openssl cross_gettext libffi'                         \
    '--script=export PKG_CONFIG_SYSROOT_DIR=$SDKDIR'       \
    '--script=autoreconf -v --install --force'  \
    '--script=./configure --host=$MY_TARGET --build=x86_64-pc-linux-gnu --target=$MY_TARGET --prefix=/usr --enable-optimizations --with-system-expat --with-system-ffi --without-pydebug --disable-profiling --disable-ipv6 ac_cv_file__dev_ptmx=yes ac_cv_file__dev_ptc=no' \
    '--script=exec_build V=1'   \
    '--script=mv Lib/compileall.py Lib/compileall.py.bak'   \
    '--script=echo > ../Python-2.7.14/Lib/compileall.py'    \
    '--script=exec_build V=1 install DESTDIR=$TEMPDIR/dist'   \
    '--script=cp Lib/compileall.py.bak $TEMPDIR/dist/usr/lib/python2.7/compileall.py'   \
    '--deploy-sdk=/usr/include -/usr/lib -/usr/bin -/usr/share'
# 交叉编译的python，不能在build机上compileall，这一步只能等到运行时才能进行了。

generate_script     native_python   $PYTHON27FILE                    \
    --build-native      \
    '--patch=python-config-crosscompile.patch'    \
    '--depends=native_expat native_gettext'                         \
    '--prescript=autoreconf -v --install --force'  \
    '--config=--prefix=/usr --enable-optimizations --with-system-expat --without-pydebug' \
    '--deploy-sdk=/usr/bin /usr/lib'    \
    '--deploy-dev=/ -/usr/share' 
    
