#!/bin/sh
# 编译一些主机运行的工具

##############################
# 编译 gettext-0.18.1.1
GETTEXT=gettext-0.18.1.1
compile_gettext()
{
	
	if [ ! -e $CACHEDIR/$GETTEXT.tar.gz ]; then
		rm -rf $TEMPDIR/$GETTEXT
		
		dispenv
		prepare $GETTEXT
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static --disable-native-java --enable-relocatable --with-gnu-ld --without-emacs --without-git --disable-acl --disable-openmp --disable-java --without-git --without-cvs ac_cv_func_mmap_fixed_mapped=yes "
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10 install DESTDIR=$CACHEDIR/gettext"
		
		exec_cmd "cd $CACHEDIR/gettext"
		exec_cmd "tar czf $CACHEDIR/$GETTEXT.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/gettext $TEMPDIR/$GETTEXT"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST="/usr/share/aclocal /usr/share/doc /usr/share/man"
	DEPLOY_DIST="/usr/bin /usr/lib /usr/share"
	deploy $GETTEXT gettext
	
	if [ ! -e $CACHEDIR/native-$GETTEXT.tar.gz ]; then
		rm -rf $TEMPDIR/$GETTEXT
		unset CFLAGS
		unset LDFLAGS
		hash -r
		dispenv
		prepare $GETTEXT
restore_native0
		PARAM="--prefix=$SDKDIR/usr --disable-shared --without-emacs --without-git --disable-acl --disable-openmp --disable-java"
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/native-gettext"
hide_native0	
		exec_cmd "cd $CACHEDIR/native-gettext/$SDKDIR"
		exec_cmd "sudo rm -rf usr/share usr/lib usr/include"
		exec_cmd "tar czf $CACHEDIR/native-$GETTEXT.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/native-gettext $TEMPDIR/$GETTEXT"
	fi;
	
	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy native-$GETTEXT native-gettext
}
build_gettext()
{
	build_expat
	build_ncurses
	run_task "构建$GETTEXT" "compile_gettext"
}

prepare_native_autoconf()
{
	echo "+++ 构建交叉编译环境 +++ "
	if [ ! -d $CACHEDIR ]; then
		exec_cmd "mkdir -p $CACHEDIR"
	fi;
	
	AUTOCONF=autoconf-2.69
	echo "+++ 构建 $AUTOCONF +++ "
	if [ ! -e $CACHEDIR/$AUTOCONF.tar.gz ]; then
		rm -rf $TEMPDIR/$AUTOCONF
		
		CFLAGS="$CFLAGS $CROSS_FLAGS -O2"
		dispenv
		
		prepare $AUTOCONF 
		
		PARAM="--host=$MY_TARGET --prefix=$SDKDIR/usr"
		exec_cmd "./configure $PARAM"
		exec_cmd "make "
		exec_cmd "make install DESTDIR=$CACHEDIR/autoconf"
				
		exec_cmd "cd $CACHEDIR/autoconf/$SDKDIR/"
		exec_cmd "echo CURDIR=$PWD"
		exec_cmd "tar czf $CACHEDIR/$AUTOCONF.tar.gz ."
		exec_cmd "cd $ROOTDIR"
		exec_cmd "rm -rf $CACHEDIR/autoconf $TEMPDIR/$AUTOCONF"
	fi;
	
	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $AUTOCONF autoconf
	
	AUTOMAKE=automake-1.12
	echo "+++ 构建 $AUTOMAKE +++ "
	if [ ! -e $CACHEDIR/$AUTOMAKE.tar.gz ]; then
		rm -rf $TEMPDIR/$AUTOMAKE
		
		CFLAGS="$CFLAGS $CROSS_FLAGS -O2"
		dispenv
		
		prepare $AUTOMAKE 
		
		PARAM="--host=$MY_TARGET --prefix=$SDKDIR/usr"
		exec_cmd "./configure $PARAM"
		exec_cmd "make "
		exec_cmd "make install DESTDIR=$CACHEDIR/automake"
		
		exec_cmd "cd $CACHEDIR/automake/$SDKDIR"
		exec_cmd "tar czf $CACHEDIR/$AUTOMAKE.tar.gz ."
		exec_cmd "rm -rf $AUTOMAKE/automake $TEMPDIR/$AUTOMAKE"
	fi;
	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy $AUTOMAKE automake
	
	############################
	# 升级pkg-config
	# PKGCONFIGFILE="pkg-config-0.26"
	PKGCONFIGFILE="pkg-config-0.27.1"
	echo "+++ 构建 $PKGCONFIGFILE +++ "
	if [ ! -e $CACHEDIR/$PKGCONFIGFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$PKGCONFIGFILE
		
		#CFLAGS="$CFLAGS $CROSS_FLAGS -O2"
		unset LDFLAGS
		unset CFLAGS

		dispenv
		prepare $PKGCONFIGFILE 
		
	restore_native0
		exec_cmd "./configure --prefix=$SDKDIR/usr"	# $PARAM"
		exec_cmd "make V=1 "
		exec_cmd "make install DESTDIR=$CACHEDIR/pkgconfig"
	hide_native0
		exec_cmd "cd $CACHEDIR/pkgconfig/$SDKDIR"
		exec_cmd "tar czf $CACHEDIR/$PKGCONFIGFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/pkgconfig $TEMPDIR/$PKGCONFIGFILE"
	fi;
	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST=""
	echo "deploying"
	deploy $PKGCONFIGFILE pkgconfig
	echo "deployed"
	
	##############################
	# 编译 libtool
	LIBTOOLFILE=libtool-2.4.2
	echo "+++ 构建 $LIBTOOLFILE +++ "
	if [ ! -e $CACHEDIR/$LIBTOOLFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$LIBTOOLFILE
    	dispenv
		prepare $LIBTOOLFILE
		
		PARAM="--prefix=$SDKDIR/usr --host=$MY_TARGET --disable-static"
		# build_native $LIBTOOLFILE --dest DESTDIR=$CACHEDIR/libtool --inside
		exec_cmd "./configure $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/libtool"
		
		exec_cmd "cd $CACHEDIR/libtool/$SDKDIR"
		exec_cmd "tar czf $CACHEDIR/$LIBTOOLFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/libtool $TEMPDIR/$LIBTOOLFILE"
	fi;
	
 	DEPLOY_DIST="/usr/lib"
 	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST="/usr/lib/pkgconfig"
	deploy $LIBTOOLFILE libtool
	
	
	##############################
	# 编译 intltool-0.40.6
	INTLTOOL=intltool-0.40.6
	echo "+++ 构建 $INTLTOOL +++ "
	if [ ! -e $CACHEDIR/$INTLTOOL.tar.gz ]; then
		rm -rf $TEMPDIR/$INTLTOOL
    	dispenv
		prepare $INTLTOOL
		
		PARAM="--prefix=$SDKDIR/usr --host=$MY_TARGET --disable-static"
		# build_native $LIBTOOLFILE --dest DESTDIR=$CACHEDIR/libtool --inside
		exec_cmd "./configure $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/intltool"
		
		exec_cmd "cd $CACHEDIR/intltool/$SDKDIR"
		exec_cmd "tar czf $CACHEDIR/$INTLTOOL.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/intltool $TEMPDIR/$INTLTOOL"
	fi;	
 	DEPLOY_DIST=""
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	deploy $INTLTOOL intltool
	
	build_gettext
}

build_libtool()
{
	echo "++++ 不需要单独构建libtool ++++"
}
