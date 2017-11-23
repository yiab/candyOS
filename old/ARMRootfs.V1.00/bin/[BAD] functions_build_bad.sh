#!/bin/sh
###########################
# gnome-vfs-2.24.4
GNOME_VFS=gnome-vfs-2.24.4
compile_gnome_vfs()
{
	if [ ! -e $CACHEDIR/$GNOME_VFS.tar.gz ]; then
		rm -rf $TEMPDIR/$GNOME_VFS
		export CFLAGS="$CFLAGS $CROSS_FLAGS"
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link ."
		dispenv
		
		prepare $GNOME_VFS 
		
		PARAM="--host=$MY_TARGET --prefix=/usr --disable-static --disable-fam --disable-ipv6 --disable-openssl --disable-http-debug --disable-nls --disable-selinux --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf --disable-hal --with-zlib --disable-howl "
		exec_cmd "./configure $PARAM ac_cv_path_KRB5_CONFIG='none'"
		exec_cmd "make -j 10 install DESTDIR=$CACHEDIR/gnome_vfs"
		
		exec_cmd "cd $CACHEDIR/gnome_vfs"
		exec_cmd "tar czf $CACHEDIR/$GNOME_VFS.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/gnome_vfs $TEMPDIR/$GNOME_VFS"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/share/gtk-doc"
	REMOVE_LIST="/usr/include /usr/lib/pkgconfig"
	DEPLOY_DIST="/usr"
	deploy $GNOME_VFS gnome_vfs
}
build_gnome_vfs()
{
	build_gnome_mime_data
	build_dbusglib
	build_glib
	build_libxml2
	build_libz
	build_gconf
	run_task "构建$GNOME_VFS" "compile_gnome_vfs"
}
###########################
# libbonobo-2.32.1
LIBBONOBO=libbonobo-2.32.1
compile_libbonobo()
{
	if [ ! -e $CACHEDIR/$LIBBONOBO.tar.gz ]; then
		rm -rf $TEMPDIR/$LIBBONOBO
		export CFLAGS="$CFLAGS $CROSS_FLAGS"
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link ."
		dispenv
		
		prepare $LIBBONOBO 
		
		export ORBIT_IDL="$SDKDIR/usr/bin/orbit-idl-2"
		PARAM="--host=$MY_TARGET --prefix=/usr --disable-static --disable-nls --disable-debug --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf --disable-bonobo-activation-debug"
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10 install DESTDIR=$CACHEDIR/libbonobo"
		
		exec_cmd "cd $CACHEDIR/libbonobo"
		exec_cmd "tar czf $CACHEDIR/$LIBBONOBO.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/libbonobo $TEMPDIR/$LIBBONOBO"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/share/man /usr/share/gtk-doc"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr"
	deploy $LIBBONOBO libbonobo
}
build_libbonobo()
{
	build_glib
	build_orbit
	build_libxml2
	build_popt
	
	run_task "构建$LIBBONOBO" "compile_libbonobo"
}

###########################
# libgnome-2.32.1
LIBGNOME=libgnome-2.32.1
compile_libgnome()
{
	if [ ! -e $CACHEDIR/$LIBGNOME.tar.gz ]; then
		rm -rf $TEMPDIR/$LIBGNOME
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link ."
		export CFLAGS="$CFLAGS $CROSS_FLAGS"
		dispenv
		
		prepare $LIBGNOME 
		
		PARAM="--host=$MY_TARGET --prefix=/usr --disable-static --disable-debug --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf --disable-documentation --disable-esd --disable-canberra"
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10 install DESTDIR=$CACHEDIR/libgnome"
		
		exec_cmd "cd $CACHEDIR/libgnome"
		exec_cmd "tar czf $CACHEDIR/$LIBGNOME.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/libgnome $TEMPDIR/$LIBGNOME"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/share/man /usr/share/gtk-doc"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr"
	deploy $LIBGNOME libgnome
}
build_libgnome()
{
	build_libbonobo
	build_gnome_vfs
	build_glib
	build_gconf
	run_task "构建$LIBGNOME" "compile_libgnome"
}

###########################
# clearlooks-0.6.2
CLEARLOOKS_THEME=clearlooks-0.6.2
compile_clearlooks_theme()
{
	if [ ! -e $CACHEDIR/$CLEARLOOKS_THEME.tar.gz ]; then
		rm -rf $TEMPDIR/$CLEARLOOKS_THEME
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link ."
		export CFLAGS="$CFLAGS $CROSS_FLAGS"
		dispenv
		
		prepare $CLEARLOOKS_THEME 
		
		PARAM="--host=$MY_TARGET --prefix=/usr --disable-static --enable-animation --with-x"
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10 install DESTDIR=$CACHEDIR/clearlooks_theme"
		
		exec_cmd "cd $CACHEDIR/clearlooks_theme"
		exec_cmd "tar czf $CACHEDIR/$CLEARLOOKS_THEME.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/clearlooks_theme $TEMPDIR/$CLEARLOOKS_THEME"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST="/usr"
	deploy $CLEARLOOKS_THEME clearlooks_theme
}
build_clearlooks_theme()
{
	build_gtk2
	run_task "构建$CLEARLOOKS_THEME" "compile_clearlooks_theme"
}

###########################
# fam-2.6.10 
LIBFAMFILE=fam-2.6.10
compile_libfam()
{	
	if [ ! -e $CACHEDIR/$LIBFAMFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$LIBFAMFILE
		
		CFLAGS="$CFLAGS $CROSS_FLAGS -O3"
		dispenv
		
		prepare $LIBFAMFILE fam-cpp-newfeature.patch
		PARAM="--host=$MY_TARGET --prefix=/usr --disable-static"
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10 "
		exec_cmd "make install DESTDIR=$CACHEDIR/libfam"
		
		exec_cmd "cd $CACHEDIR/libfam"
		exec_cmd "tar czf $CACHEDIR/$LIBFAMFILE.tar.gz ."
exit;
		exec_cmd "rm -rf $CACHEDIR/libfam $TEMPDIR/$LIBFAMFILE"
	fi;
	
	DEPLOY_DIST=""
	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	deploy $LIBFAMFILE libfam
}
build_libfam()
{	
	run_task "鏋勫缓$LIBFAMFILE" "compile_libfam"
}

###########################
# gtk-theme-switch-1.0.1
GTK_THEME_SWITCH=gtk-theme-switch-1.0.1
compile_gtk_theme_switch()
{
	if [ ! -e $CACHEDIR/$GTK_THEME_SWITCH.tar.gz ]; then
		rm -rf $TEMPDIR/$GTK_THEME_SWITCH
		export CFLAGS="$CFLAGS $CROSS_FLAGS"
		dispenv
		
		prepare $GTK_THEME_SWITCH 
		
		exec_cmd "make GCC=$MY_TARGET-gcc CFLAGS='$CFLAGS'"
		
		exec_cmd "mkdir -p $CACHEDIR/gtk_theme_switch/usr/bin"
		exec_cmd "cp switch $CACHEDIR/gtk_theme_switch/usr/bin"
		exec_cmd "cd $CACHEDIR/gtk_theme_switch"
		exec_cmd "tar czf $CACHEDIR/$GTK_THEME_SWITCH.tar.gz ."
exit;
		exec_cmd "rm -rf $CACHEDIR/gtk_theme_switch $TEMPDIR/$GTK_THEME_SWITCH"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la "
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib"
	deploy $GTK_THEME_SWITCH gtk_theme_switch
}
build_gtk_theme_switch()
{
	build_gtk2
	run_task "构建$GTK_THEME_SWITCH" "compile_gtk_theme_switch"
}

##############################
# 编译 gnome-settings-daemon-3.7.4
#GNOME_SETTINGS_DAEMON=gnome-settings-daemon-3.7.4
#GNOME_SETTINGS_DAEMON=gnome-settings-daemon-2.91.93
GNOME_SETTINGS_DAEMON=gnome-settings-daemon-2.24.1
compile_gnome_setting_daemon()
{
	if [ ! -e $CACHEDIR/$GNOME_SETTINGS_DAEMON.tar.gz ]; then
		rm -rf $TEMPDIR/$GNOME_SETTINGS_DAEMON
		
		dispenv
		prepare $GNOME_SETTINGS_DAEMON
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static --disable-man --with-x --disable-esd --disable-alsa --disable-gstreamer --disable-nls --disable-debug"
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10 install DESTDIR=$CACHEDIR/gnome_setting_daemon"

		exec_cmd "cd $CACHEDIR/gnome_setting_daemon"
		exec_cmd "tar czf $CACHEDIR/$GNOME_SETTINGS_DAEMON.tar.gz ."
exit;
		exec_cmd "rm -rf $CACHEDIR/gnome_setting_daemon $TEMPDIR/$GNOME_SETTINGS_DAEMON"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST="/usr/share"
	deploy $GNOME_SETTINGS_DAEMON gnome_setting_daemon
}
build_gnome_setting_daemon()
{
	build_libgnome
	build_glib
	build_gtk2
	build_gsettings_desktop_schemas
	build_gconf
	
	run_task "构建$GNOME_SETTINGS_DAEMON" "compile_gnome_setting_daemon"
}

####
# 暂不使用gconf配置
###########################
# GConf-2.9.91
#GCONFFILE=GConf-3.2.5
GCONFFILE=GConf-2.8.1
compile_gconf()
{
	if [ ! -e $CACHEDIR/$GCONFFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$GCONFFILE
		
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link ."
		export CFLAGS="$CFLAGS $CROSS_FLAGS"
		export CPPFLAGS="$CFLAGS $CROSS_FLAGS"
		dispenv
		
		prepare $GCONFFILE gconf-gtk-deprecate.patch
		
		export SDKDIR
		changeoption configure ORBIT_IDL '$SDKDIR/usr/bin/orbit-idl-2'
		PARAM="--host=$MY_TARGET --target=$MY_TARGET --prefix=/usr --disable-static --disable-debug --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf --disable-documentation --enable-gtk"
		
		exec_cmd "./configure enable_gio_sniffing=no $PARAM "
		exec_cmd "make "		# 不能多线程编译
		exec_cmd "make install DESTDIR=$CACHEDIR/gconf"
		
		exec_cmd "cd $CACHEDIR/gconf"
		exec_cmd "tar czf $CACHEDIR/$GCONFFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/gconf $TEMPDIR/$GCONFFILE"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la "
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/bin /usr/etc /usr/lib /usr/libexec /usr/share/locale /usr/share/sgml"
	deploy $GCONFFILE gconf
}
build_gconf()
{	
	# Package requirements (gmodule-2.0 >= 2.0.1 gobject-2.0 >= 2.0.1 ORBit-2.0 >= 2.4.0)
	build_popt
	build_orbit
	build_glib
	build_gtk2
	build_libxml2
	
	run_task "构建$GCONFFILE" "compile_gconf"
}

###########################
# libxml2-2.9.0 使用expat而不使用libxml2
LIBXML2FILE=libxml2-2.9.0
compile_libxml2()
{
	if [ ! -e $CACHEDIR/$LIBXML2FILE.tar.gz ]; then
		rm -rf $TEMPDIR/$LIBXML2FILE
		
		#export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link ."
		export CFLAGS="$CFLAGS $CROSS_FLAGS"
		export CPPFLAGS="$CFLAGS $CROSS_FLAGS"
		dispenv
		
		prepare $LIBXML2FILE 
		
		PARAM="--host=$MY_TARGET --target=$MY_TARGET --prefix=/usr --disable-static --without-debug --disable-ipv6 --enable-rebuild-docs=no --with-iconv --with-libz"

		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/libxml2"
		
		exec_cmd "cd $CACHEDIR/libxml2"
		exec_cmd "tar czf $CACHEDIR/$LIBXML2FILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/libxml2 $TEMPDIR/$LIBXML2FILE"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/share/doc /usr/share/gtk-doc /usr/share/man"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/bin /usr/lib"
	deploy $LIBXML2FILE libxml2
}
build_libxml2()
{
	build_libz
# TODO: 没有必要使用libxml
	run_task "构建$LIBXML2FILE" "compile_libxml2"
}

############################################
# 编译 libiconv-1.14 ，最新的libc里面已经有iconv了，没有必要使用这个包
#LIBICONV=libiconv-1.14
#compile_libiconv()
#{
#	if [ ! -e $CACHEDIR/$LIBICONV.tar.gz ]; then
#		rm -rf $TEMPDIR/$LIBICONV
#		dispenv
#		prepare $LIBICONV

#		PARAM="--prefix=/usr --sysconfdir=/etc --host=$MY_TARGET --disable-static --disable-rpath --disable-nls --disable-extra-encodings"
##		exec_cmd "./autogen.sh --skip-gnulib"
#		exec_cmd "./configure $PARAM"
#		exec_cmd "make -j 10"
#		exec_cmd "make install DESTDIR=$CACHEDIR/libiconv"
#				
#		exec_cmd "cd $CACHEDIR/libiconv"
#		exec_cmd "tar czf $CACHEDIR/$LIBICONV.tar.gz ."
#		exec_cmd "rm -rf $CACHEDIR/libiconv $TEMPDIR/$LIBICONV"
#	fi;
#	
#	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
#	REMOVE_LIST="/usr/lib/pkgconfig"
#	DEPLOY_DIST="/usr/lib /usr/bin"
#	deploy $LIBICONV libiconv
#}
#build_libiconv()
#{
#	run_task "构建$LIBICONV" "compile_libiconv"
#}

################################################################################3
#  Useless
# portmap被rpcbind取代了
###############################
## 编译 portmap
#PORTMAPFILE=portmap_6.0
#compile_portmap()
#{
#	rm -rf $TEMPDIR/$PORTMAPFILE
#	if [ ! -e $CACHEDIR/$PORTMAPFILE.tar.gz ]; then
#		setenv_libwrap
#		CFLAGS+=" $CROSS_FLAGS"
#		dispenv
#
#		prepare $PORTMAPFILE
#		exec_cmd "make CC=$MY_TARGET-gcc"
#		exec_cmd "mkdir -p $CACHEDIR/portmap/sbin"
#		exec_cmd "sudo make install BASEDIR=$CACHEDIR/portmap"
#		
#		exec_cmd "cd $CACHEDIR/portmap"
#		exec_cmd "tar czf $CACHEDIR/$PORTMAPFILE.tar.gz ."
#		exec_cmd "sudo rm -rf $CACHEDIR/portmap $TEMPDIR/$PORTMAPFILE"
#	fi;
#	
#	DEPLOY_DIST="/sbin"
#	PRE_REMOVE_LIST=""
#	REMOVE_LIST=""
#	deploy $PORTMAPFILE portmap
#}
#build_portmap()
#{
#	build_libwrap
##	build_rpcheader
	
#	run_task "构建$PORTMAPFILE" "compile_portmap"
#}
