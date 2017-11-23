#!/bin/sh
##############################
# 将glibc/rpcsvc底下的.x文件生成相应的.h文件
#compile_rpcheader()
#{
#	exec_cmd "cd $CROSSTOOL/usr/include/rpcsvc"
	
#	mv $CROSSTOOL/usr/bin/rpcgen $CROSSTOOL/usr/bin/rpcgen-arm
#	echo " ===> rpcgen is '`which rpcgen`'"
#	for x in *.x ; do
##		header=`basename $x .x`
##		header="$header.h"
		
#		exec_cmd "rpcgen $x "
#	done;
#	echo
#}
#build_rpcheader()
#{	
#	run_task "编译CrossGlibc_RpcHeader" "compile_rpcheader"
#}


##############################
# 编译 libtirpc
LIBTIRPCFILE=libtirpc-0.2.2
compile_libtirpc()
{
	if [ ! -e $CACHEDIR/$LIBTIRPCFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$LIBTIRPCFILE
		export CFLAGS="$CFLAGS $CROSS_FLAGS "
		dispenv	
	
		prepare $LIBTIRPCFILE libtirpc-from-ubuntu.patch # libtirpc-0.2.2-remove-nis-2.patch
		PARAM="--host=$MY_TARGET --prefix=/usr --disable-static --disable-gss" #"
		exec_cmd "autoreconf --install -v"
		build_native $LIBTIRPCFILE --dest DESTDIR=$CACHEDIR/libtirpc --inside

		exec_cmd "cd $CACHEDIR/libtirpc"
		exec_cmd "tar czf $CACHEDIR/$LIBTIRPCFILE.tar.gz ."
		exec_cmd "rm -rf $TEMPDIR/$LIBTIRPCFILE $CACHEDIR/libtirpc"
	fi;

	DEPLOY_DIST="/etc /usr/lib"
	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST="/usr/lib/*.a /usr/lib/pkgconfig"	
	deploy $LIBTIRPCFILE libtirpc
}
build_libtirpc()
{
	run_task "构建$LIBTIRPCFILE" "compile_libtirpc"
}

##############################
# 编译libwrap
LIBWRAPFILE=tcp_wrappers_7.6
compile_libwrap()
{
	rm -rf $TEMPDIR/$LIBWRAPFILE
	if [ ! -e $CACHEDIR/$LIBWRAPFILE.tar.gz ]; then
		prepare $LIBWRAPFILE libwrapper.patch #tcp_wrappers-7.6-shared_lib_plus_plus-1.patch 
		export CFLAGS="$CFLAGS $CROSS_FLAGS -fPIC"
		dispenv
		exec_cmd "make CC=$MY_TARGET-gcc AR=$MY_TARGET-ar RANLIB=$MY_TARGET-ranlib REAL_DAEMON_DIR=/usr/sbin ARFLAGS=rv linux"
		mkdir -p $CACHEDIR/libwrap/usr/{sbin,lib,share/man/man{3,5,8},include}
		exec_cmd "sudo make install DESTDIR=$CACHEDIR/libwrap"
		exec_cmd "cd $CACHEDIR/libwrap"
		
		exec_cmd "tar czf $CACHEDIR/$LIBWRAPFILE.tar.gz ."
		exec_cmd "sudo rm -rf $CACHEDIR/libwrap $TEMPDIR/$LIBWRAPFILE"
	fi;
	
	DEPLOY_DIST="/usr/lib /usr/sbin"
	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	deploy $LIBWRAPFILE libwrap
}
build_libwrap()
{	
	run_task "构建$LIBWRAPFILE" "compile_libwrap"
}

##############################
# 编译 rpcbind
#RPCBINDFILE=rpcbind-0.2.0
RPCBINDFILE=rpcbind-0.2.0-dbg
compile_rpcbind()
{
	rm -rf $TEMPDIR/$RPCBINDFILE
	if [ ! -e $CACHEDIR/$RPCBINDFILE.tar.gz ]; then
		export CFLAGS="$CFLAGS $CROSS_FLAGS -I$SDKDIR/usr/include/tirpc"
    	#export LDFLAGS="$LDFLAGS -ltirpc -lnsl -lpthread -lgssglue"
    	
		dispenv
	
		prepare $RPCBINDFILE
		PARAM="--host=$MY_TARGET --prefix=/usr --with-statedir=/var/run/rpcbind --disable-libwrap"
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10"
		exec_cmd "mkdir -p $CACHEDIR/rpcbind"
		exec_cmd "make install DESTDIR=$CACHEDIR/rpcbind"
		
		exec_cmd "cd $CACHEDIR/rpcbind"
		exec_cmd "mkdir sbin usr/sbin"
		exec_cmd "cd sbin"
		exec_cmd "ln -s ../usr/bin/rpcbind portmap"
		exec_cmd "cd ../usr/sbin"
		exec_cmd "ln -s ../bin/rpcinfo rpcinfo"
		exec_cmd "cd $CACHEDIR/rpcbind"
		exec_cmd "tar czf $CACHEDIR/$RPCBINDFILE.tar.gz ."
		exec_cmd "sudo rm -rf $CACHEDIR/rpcbind $TEMPDIR/$RPCBINDFILE"
	fi;
	
	DEPLOY_DIST="/usr/bin /sbin /usr/sbin"
	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	deploy $RPCBINDFILE rpcbind
	
#	exec_cmd "rm -rf $CACHEDIR/rpcbind"
#	exec_cmd "mkdir -p $CACHEDIR/rpcbind  $INSTDIR/usr/bin"
#	exec_cmd "tar xf $CACHEDIR/$RPCBINDFILE.tar.gz -C $CACHEDIR/rpcbind"
#	exec_cmd "cp -R $CACHEDIR/rpcbind/usr/bin/* $INSTDIR/usr/bin"
#	exec_cmd "rm -rf $CACHEDIR/rpcbind"
}

build_rpcbind()
{	
	build_libtirpc
#	build_libwrap
#	build_rpcheader
	
	run_task "构建$RPCBINDFILE" "compile_rpcbind"
}

##############################
# 编译 libevent
LIBEVENTFILE=libevent-2.0.19-stable
compile_libevent()
{
	rm -rf $TEMPDIR/$LIBEVENTFILE
	if [ ! -e $CACHEDIR/$LIBEVENTFILE.tar.gz ]; then
		dispenv
		
		prepare $LIBEVENTFILE
		PARAM="--host=$MY_TARGET --prefix=/usr --disable-static "
		build_native $LIBEVENTFILE --dest DESTDIR=$CACHEDIR/libevent --inside
		
		exec_cmd "cd $CACHEDIR/libevent"
		exec_cmd "tar czf $CACHEDIR/$LIBEVENTFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/libevent $TEMPDIR/$LIBEVENTFILE"
	fi;
	
	DEPLOY_DIST="/usr/lib /usr/bin"
	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST="/usr/lib/*.a /usr/lib/pkgconfig"	
	deploy $LIBEVENTFILE libevent
	
#	exec_cmd "rm -rf $SDKDIR/include/libevent $CACHEDIR/libevent"
#	exec_cmd "mkdir -p $CACHEDIR/libevent $SDKDIR/include/libevent $INSTDIR/usr/bin $INSTDIR/usr/lib"
#	exec_cmd "tar xf $CACHEDIR/$LIBEVENTFILE.tar.gz -C $CACHEDIR/libevent"
#	exec_cmd "cp -R $CACHEDIR/libevent/usr/bin/* $INSTDIR/usr/bin"
#	exec_cmd "cp -R $CACHEDIR/libevent/usr/lib/* $INSTDIR/usr/lib"
#	exec_cmd "cp -R $CACHEDIR/libevent/usr/include/* $SDKDIR/include/libevent"
#	exec_cmd "rm -rf $CACHEDIR/libevent"
}
build_libevent()
{	
	run_task "构建$LIBEVENTFILE" "compile_libevent"
}

##############################
# 编译 libnfsidmap
LIBNFSIDMAPFILE=libnfsidmap-0.25
compile_libnfsidmap()
{
	rm -rf $TEMPDIR/$LIBNFSIDMAPFILE
	if [ ! -e $CACHEDIR/$LIBNFSIDMAPFILE.tar.gz ]; then
		dispenv
		
		prepare $LIBNFSIDMAPFILE
		PARAM="--host=$MY_TARGET --prefix=/usr --disable-static --cache-file=baiyun.config.cache"
		printf "ac_cv_func_malloc_0_nonnull=yes \nac_cv_func_realloc_0_nonnull=yes\n" > baiyun.config.cache
		build_native $LIBNFSIDMAPFILE --dest DESTDIR=$CACHEDIR/libnfsidmap --inside
		exec_cmd "rm $CACHEDIR/libnfsidmap/usr/lib/*.la $CACHEDIR/libnfsidmap/usr/lib/libnfsidmap/*.la"
		exec_cmd "cd $CACHEDIR/libnfsidmap"
		exec_cmd "tar czf $CACHEDIR/$LIBNFSIDMAPFILE.tar.gz ."
		
		exec_cmd "rm -rf $CACHEDIR/libnfsidmap $TEMPDIR/$LIBNFSIDMAPFILE"
	fi;
	
	DEPLOY_DIST="/usr/lib"
	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST="/usr/lib/*.a /usr/lib/pkgconfig"	
	deploy $LIBNFSIDMAPFILE libnfsidmap
	
#	exec_cmd "rm -rf $SDKDIR/include/libnfsidmap $CACHEDIR/libnfsidmap"
#	exec_cmd "mkdir -p $CACHEDIR/libnfsidmap $SDKDIR/include/libnfsidmap $INSTDIR/usr/lib"
#	exec_cmd "tar xf $CACHEDIR/$LIBNFSIDMAPFILE.tar.gz -C $CACHEDIR/libnfsidmap"
#	exec_cmd "cp -R $CACHEDIR/libnfsidmap/usr/lib/* $INSTDIR/usr/lib"
#	exec_cmd "cp -R $CACHEDIR/libnfsidmap/usr/include/* $SDKDIR/include/libnfsidmap"
#	exec_cmd "rm -rf $CACHEDIR/libnfsidmap"
}
build_libnfsidmap()
{	
	run_task "构建$LIBNFSIDMAPFILE" "compile_libnfsidmap"
}

##############################
# 编译 libgssglue
GSSGLUEFILE=libgssglue-0.4
compile_libgssglue()
{
exec_cmd "choke"
	rm -rf $TEMPDIR/$GSSGLUEFILE
	if [ ! -e $CACHEDIR/$GSSGLUEFILE.tar.gz ]; then
		dispenv
		prepare $GSSGLUEFILE
		printf "ac_cv_func_malloc_0_nonnull=yes \nac_cv_func_realloc_0_nonnull=yes\n" > baiyun.config.cache
		PARAM="--host=$MY_TARGET --prefix=/usr --disable-static --cache-file=baiyun.config.cache"
		build_native $GSSGLUEFILE --dest DESTDIR=$CACHEDIR/libgssglue --inside

		exec_cmd "rm $CACHEDIR/libgssglue/usr/lib/libgssglue.la"
		exec_cmd "cd $CACHEDIR/libgssglue"
		exec_cmd "tar czf $CACHEDIR/$GSSGLUEFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/libgssglue $TEMPDIR/$GSSGLUEFILE"
	fi;
	
	DEPLOY_DIST="/usr/lib"
	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST="/usr/lib/*.a /usr/lib/pkgconfig"	
	deploy $GSSGLUEFILE libgssglue
	
#	exec_cmd "rm -rf $SDKDIR/include/gssglue $CACHEDIR/libgssglue"
#	exec_cmd "mkdir -p $CACHEDIR/libgssglue $SDKDIR/include/ $INSTDIR/usr/lib"
#	exec_cmd "tar xf $CACHEDIR/$GSSGLUEFILE.tar.gz -C $CACHEDIR/libgssglue"
#	exec_cmd "cp -R $CACHEDIR/libgssglue/usr/lib/* $INSTDIR/usr/lib"
#	exec_cmd "cp -R $CACHEDIR/libgssglue/usr/include/* $SDKDIR/include/"
#	exec_cmd "rm -rf $CACHEDIR/libgssglue"
}
build_libgssglue()
{	
	run_task "构建$GSSGLUEFILE" "compile_libgssglue"
}

##############################
# 编译 librpcsecgss
LIBRPCSECGSSFILE=librpcsecgss-0.19
compile_librpcsecgss()
{
exec_cmd "choke"
	rm -rf $TEMPDIR/$LIBRPCSECGSSFILE
	if [ ! -e $CACHEDIR/$LIBRPCSECGSSFILE.tar.gz ]; then
		prepare $LIBRPCSECGSSFILE
		
		dispenv
		
		printf "ac_cv_func_malloc_0_nonnull=yes \nac_cv_func_realloc_0_nonnull=yes\n" > baiyun.config.cache
		PARAM="--host=$MY_TARGET --prefix=/usr --disable-static --cache-file=baiyun.config.cache"
		build_native $LIBRPCSECGSSFILE --dest DESTDIR=$CACHEDIR/librpcsecgss --inside

		exec_cmd "rm $CACHEDIR/librpcsecgss/usr/lib/*.la"
		exec_cmd "cd $CACHEDIR/librpcsecgss"
		exec_cmd "tar czf $CACHEDIR/$LIBRPCSECGSSFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/librpcsecgss $TEMPDIR/$LIBRPCSECGSSFILE"
	fi;
	
	DEPLOY_DIST="/usr/lib"
	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST="/usr/lib/*.a /usr/lib/pkgconfig"	
	deploy $LIBRPCSECGSSFILE librpcsecgss
	
#	exec_cmd "rm -rf $SDKDIR/include/rpcsecgss $CACHEDIR/librpcsecgss"
#	exec_cmd "mkdir -p $CACHEDIR/librpcsecgss $SDKDIR/include $INSTDIR/usr/lib"
#	exec_cmd "tar xf $CACHEDIR/$LIBRPCSECGSSFILE.tar.gz -C $CACHEDIR/librpcsecgss"
#	exec_cmd "cp -R $CACHEDIR/librpcsecgss/usr/lib/* $INSTDIR/usr/lib"
#	exec_cmd "cp -R $CACHEDIR/librpcsecgss/usr/include/* $SDKDIR/include"
#	exec_cmd "rm -rf $CACHEDIR/librpcsecgss"
}
build_librpcsecgss()
{	
	build_libgssglue
	
	run_task "构建$LIBRPCSECGSSFILE" "compile_librpcsecgss"
}

##############################
# 编译 libdevmapper
LIBDEVMAPPERFILE=LVM2.2.02.96
compile_libdevmapper()
{
	rm -rf $TEMPDIR/$LIBDEVMAPPERFILE
	if [ ! -e $CACHEDIR/$LIBDEVMAPPERFILE.tar.gz ]; then
		prepare $LIBDEVMAPPERFILE
		dispenv
		
		PARAM="--host=$MY_TARGET --prefix=/usr --cache-file=baiyun.config.cache"
		printf "ac_cv_func_malloc_0_nonnull=yes \nac_cv_func_realloc_0_nonnull=yes\n" > baiyun.config.cache
		export CC=$MY_TARGET-gcc
		build_native $LIBDEVMAPPERFILE --target device-mapper --installtarget install_device-mapper --dest DESTDIR=$CACHEDIR/libdevmapper --inside
		unset CC

		exec_cmd "cd $CACHEDIR/libdevmapper"
		exec_cmd "tar czf $CACHEDIR/$LIBDEVMAPPERFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/libdevmapper $TEMPDIR/$LIBDEVMAPPERFILE"
	fi;
	
	DEPLOY_DIST="/usr/lib /usr/sbin"
	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST="/usr/lib/*.a /usr/lib/pkgconfig"	
	deploy $LIBDEVMAPPERFILE libdevmapper
	
#	exec_cmd "rm -rf $SDKDIR/include/libdevmapper $CACHEDIR/libdevmapper"
#	exec_cmd "mkdir -p $CACHEDIR/libdevmapper $SDKDIR/include/libdevmapper $INSTDIR/usr/lib $INSTDIR/usr/sbin"
#	exec_cmd "tar xf $CACHEDIR/$LIBDEVMAPPERFILE.tar.gz -C $CACHEDIR/libdevmapper"
#	exec_cmd "cp -R $CACHEDIR/libdevmapper/usr/lib/* $INSTDIR/usr/lib"
#	exec_cmd "cp -R $CACHEDIR/libdevmapper/usr/sbin/* $INSTDIR/usr/sbin"
#	exec_cmd "cp -R $CACHEDIR/libdevmapper/usr/include/* $SDKDIR/include/libdevmapper"
#	exec_cmd "rm -rf $CACHEDIR/libdevmapper"
}
build_libdevmapper()
{	
	run_task "构建$LIBDEVMAPPERFILE" "compile_libdevmapper"
}

##############################
# 编译 ncurses
NCURSESFILE=ncurses-5.9
compile_ncurses()
{
	if [ ! -e $CACHEDIR/$NCURSESFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$NCURSESFILE
		prepare $NCURSESFILE
		
		dispenv
		PARAM="--host=$MY_TARGET --prefix=/usr --disable-static --without-ada --without-manpages --without-tests --with-sysmouse --disable-rpath --disable-big-core --disable-big-strings --enable-bsdpad --enable-widec --with-rcs-ids --enable-sp-funcs --enable-ext-colors --enable-ext-mouse --enable-term-driver --enable-sp-funcs --enable-tcap-names"

        exec_cmd "./configure $PARAM"
        
        restore_native0
        exec_cmd "make -j 10"
        exec_cmd "make install DESTDIR=$CACHEDIR/ncurses"
        hide_native0
		#build_native $NCURSESFILE --dest DESTDIR=$CACHEDIR/ncurses --inside

		exec_cmd "cd $CACHEDIR/ncurses"
		exec_cmd "tar czf $CACHEDIR/$NCURSESFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/ncurses $TEMPDIR/$NCURSESFILE"
	fi;
	
	DEPLOY_DIST="/usr/bin /usr/share"
	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	deploy $NCURSESFILE ncurses
	
#	exec_cmd "rm -rf $SDKDIR/include/ncurses $CACHEDIR/ncurses"
#	exec_cmd "mkdir -p $CACHEDIR/ncurses $SDKDIR/include/ncurses $SDKDIR/lib $INSTDIR/usr/bin $INSTDIR/usr/share"
#	exec_cmd "tar xf $CACHEDIR/$NCURSESFILE.tar.gz -C $CACHEDIR/ncurses"
	
#	exec_cmd "cp -R $CACHEDIR/ncurses/usr/bin/* 	$INSTDIR/usr/bin"
#	exec_cmd "cp -R $CACHEDIR/ncurses/usr/share/* 	$INSTDIR/usr/share"
#	exec_cmd "cp -R $CACHEDIR/ncurses/usr/lib/* 	$SDKDIR/lib"
#	exec_cmd "cp -R $CACHEDIR/ncurses/usr/include/* $SDKDIR/include/ncurses"
#	exec_cmd "rm -rf $CACHEDIR/ncurses"
}
build_ncurses()
{	
	run_task "构建$NCURSESFILE" "compile_ncurses"
}

##############################
# 编译 libblkid
UTILLINUXFILE=util-linux-2.21.2
compile_utillinux()
{
	rm -rf $TEMPDIR/$UTILLINUXFILE
	if [ ! -e $CACHEDIR/$UTILLINUXFILE.tar.gz ]; then
    	dispenv
    	
		prepare $UTILLINUXFILE
#		export CFLAGS="-I$SDKDIR/include/ncurses"
#		export LDFLAGS="-L$SDKDIR/lib"
		PARAM="--host=$MY_TARGET --prefix=/usr --libdir=/usr/lib --disable-static --disable-nls --without-ncurses --disable-largefile --disable-losetup --disable-fsck --disable-partx --disable-fallocate  --disable-unshare --disable-arch --disable-ddate --disable-agetty --disable-cramfs --disable-switch_root --disable-pivot_root --disable-elvtune --disable-kill --disable-last --disable-line --disable-mesg  --disable-raw --disable-rename --disable-reset --disable-login-utils --disable-schedutils --disable-wall --disable-write --disable-chsh-only-listed --disable-login-chown-vcs --disable-login-stat-mail --disable-pg-bell --disable-require-password --disable-use-tty-group --disable-libuuid " # --disable-new-mount
#		PARAM+="--with-udev  --enable-mount --enable-libmount --enable-libmount-mount --enable-new-mount" 
		
		# --disable-makeinstall-chown --disable-makeinstall-setuid --disable-tls  --enable-libblkid --disable-libmount --disable-mount --disable-losetup --disable-libmount-mount  --disable-fsck --disable-partx --disable-uuidd --disable-mountpoint  "
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10"
		exec_cmd "mkdir -p $CACHEDIR/utillinux"
		exec_cmd "sudo make install DESTDIR=$CACHEDIR/utillinux PATH=$PATH"
		exec_cmd "cd $CACHEDIR/utillinux"
		exec_cmd "sudo rm usr/lib/*.la"
		exec_cmd "sudo tar czf $CACHEDIR/$UTILLINUXFILE.tar.gz ."
		exec_cmd "sudo rm -rf $CACHEDIR/utillinux $TEMPDIR/$UTILLINUXFILE"
	fi;
	
	# mount 用 deploy有权限问题
	DEPLOY_DIST="/bin /sbin /usr/bin /usr/lib /usr/sbin"
	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST="/usr/lib/*.a /usr/lib/pkgconfig"	
	deploy $UTILLINUXFILE utillinux
}
build_utillinux()
{
#	build_udev
#	build_ncurses
	
	run_task "构建$UTILLINUXFILE" "compile_utillinux"
}

###########################
# 编译NFS
NFSUTILFILE=nfs-utils-1.2.6
compile_nfsutil()
{

	if [ ! -e $CACHEDIR/$NFSUTILFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$NFSUTILFILE	
		
#		export CFLAGS="-I$SDKDIR/include"
#		export LDFLAGS="-L$INSTDIR/usr/lib "
		#export LIBS="-lgssglue"

		dispenv
		
		prepare $NFSUTILFILE nfs-util.patch
#		PARAM="--host=$MY_TARGET --prefix=/usr --disable-static --cache-file=baiyun.config.cache"
#		printf "ac_cv_func_malloc_0_nonnull=yes \nac_cv_func_realloc_0_nonnull=yes\n" > baiyun.config.cache
#		build_native $NFSUTILFILE --dest DESTDIR=$CACHEDIR/nfsutil --inside
 
		printf "libblkid_cv_is_recent=yes \n CONFIG_SQLITE3_FALSE='#' \n" > baiyun.config.cache
		PARAM="--host=$MY_TARGET --prefix=/usr --sysconfdir=/etc --disable-static --disable-maintainer-mode --disable-ipv6 --disable-uuid --enable-tirpc --with-tirpcinclude=$SDKDIR/usr/include/tirpc --disable-gss --enable-mount --cache-file=baiyun.config.cache " # --disable-nfsv4 --disable-nfsv41
#		exec_cmd "./autogen.sh"
		#build_native $NFSUTILFILE --dest DESTDIR=$CACHEDIR/nfsutil --inside
#	make clean
#		exec_cmd "autoreconf --install -v" 
		exec_cmd "./configure $PARAM"
		exec_cmd "make CC=$MY_TARGET-gcc -j 10"
		exec_cmd "mkdir -p $CACHEDIR/nfsutil/sbin"
		exec_cmd "sudo make install DESTDIR=$CACHEDIR/nfsutil"
			
		exec_cmd "cd $CACHEDIR/nfsutil"
		exec_cmd "sudo tar czf $CACHEDIR/$NFSUTILFILE.tar.gz ."		
		exec_cmd "sudo rm -rf $CACHEDIR/nfsutil $TEMPDIR/$NFSUTILFILE"
	fi;
	
	DEPLOY_DIST="/sbin /usr/sbin /var"
	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	deploy $NFSUTILFILE nfsutil
	
#	exec_cmd "rm -rf $CACHEDIR/nfsutil "
#	exec_cmd "mkdir -p $CACHEDIR/nfsutil $INSTDIR/sbin $INSTDIR/usr/sbin $INSTDIR/var"
#	exec_cmd "tar xf $CACHEDIR/$NFSUTILFILE.tar.gz -C $CACHEDIR/nfsutil"
#	exec_cmd "cp -R $CACHEDIR/nfsutil/sbin/* 		$INSTDIR/sbin"
#	exec_cmd "cp -R $CACHEDIR/nfsutil/usr/sbin/* 	$INSTDIR/usr/sbin"
#	exec_cmd "cp -R $CACHEDIR/nfsutil/var/* 	$INSTDIR/var"
#	exec_cmd "rm -rf $CACHEDIR/nfsutil"
}
build_nfsutil()
{
	# "portmap" must be running
	build_rpcbind

	build_libwrap
	
	build_libevent
	build_libnfsidmap
##	build_libgssglue
##	build_librpcsecgss
	build_libdevmapper
	build_utillinux
	
	run_task "构建$NFSUTILFILE" "compile_nfsutil"
}


