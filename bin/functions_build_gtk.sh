#!/bin/sh

###########################
# libffi 静态库
LIBFFIFILE=libffi-3.2.1
generate_script  native_libffi     $LIBFFIFILE     \
    --build-native                  \
    '--config=--prefix=$DEVDIR/usr --disable-static '          \
    '--deploy-dev=/usr'                                  \
    '--depends=native_libz'

generate_script  libffi     $LIBFFIFILE     \
    '--config=--host=$MY_TARGET --target=$MY_TARGET --prefix=/usr --disable-static' \
    '--deploy-rootfs=/usr/lib -/usr/lib/pkgconfig'                                  \
    '--deploy-sdk=/usr/lib'  \
    '--depends=libz'
  
##############################
# build_native_glib()
GLIBFILE=glib-2.54.2
# 临时使用的glib，没有必要编译libmount(在util-linux里面)
generate_script  native_glib     $GLIBFILE     \
    --build-native                  \
    '--config=--prefix=$DEVDIR/usr --disable-static --disable-libmount --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf --disable-man --disable-debug --disable-coverage --disable-dtrace --disable-selinux --disable-dtrace --disable-systemtap --without-pcre --with-python=python2 --without-libiconv --disable-fam'          \
    '--deploy-dev=/usr'                                  \
    '--deploy-sdk=/usr/bin -/usr/lib -/usr/share -/usr/include' \
    '--depends=native_libz native_libffi native_python'

PARAMS='--host=$MY_TARGET --prefix=/usr --disable-static --with-sysroot=$SDKDIR '
PARAMS+='glib_cv_stack_grows=no glib_cv_uscore=no ac_cv_func_posix_getpwuid_r=yes ac_cv_func_posix_getgrgid_r=yes ac_cv_lib_rt_clock_gettime=no glib_cv_monotonic_clock=yes '
PARAMS+='--disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf --disable-man --disable-debug --disable-coverage --disable-dtrace --disable-selinux --disable-dtrace --disable-systemtap '
PARAMS+='--with-python=python2 --without-libiconv --disable-fam --without-pcre'
generate_script  glib     $GLIBFILE     \
    "--config=$PARAMS"  \
    '--deploy-sdk=/usr/include /usr/lib /usr/share'                                  \
    '--deploy-rootfs=/usr/bin /usr/lib/*.so* /usr/share/locale' \
    '--depends=libz libffi libmount dbus cross_python native_glib' 
#libiconv libpcre

###########################
# atk
# http://ftp.gnome.org/pub/gnome/sources/atk/2.27/atk-2.27.1.tar.xz
ATKFILE=atk-2.27.1
generate_script  atk     $ATKFILE     \
    '--prescript=export PKG_CONFIG_SYSROOT_DIR=$SDKDIR'     \
    '--config=--host=$MY_TARGET --target=$MY_TARGET --prefix=/usr --disable-static --with-sysroot=$SDKDIR --disable-glibtest --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf --with-gnu-ld --disable-introspection'  \
    '--deploy-sdk=/usr/include /usr/lib'                                    \
    '--deploy-rootfs=/usr/lib /usr/share/locale -/usr/lib/pkgconfig -/usr/lib/*.la'        \
    '--depends=glib' 
#export XDG_DATA_DIRS=/home/baiyun/git/candyOS/dist/pi/sdk/usr/share

###########################
# 编译 at-spi2-core
# http://ftp.gnome.org/pub/gnome/sources/at-spi2-core/2.26/at-spi2-core-2.26.2.tar.xz
ATKSPI2FILE=at-spi2-core-2.26.2
generate_script  atk_spi2     $ATKSPI2FILE     \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--host=$MY_TARGET --target=$MY_TARGET --prefix=/usr --disable-static --with-sysroot=$SDKDIR --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf --enable-x11 --disable-introspection'  \
    '--deploy-sdk=/usr/include /usr/lib /usr/share -/usr/etc -/usr/libexec '                                                \
    '--deploy-rootfs=/usr/etc /usr/lib /usr/libexec /usr/share -/usr/lib/pkgconfig -/usr/lib/*.la'        \
    '--depends=cross_autogen_env cross_gobject_introspection atk dbus x11_libx11 x11_libxtst x11_libxi'

###########################
# 编译 at-spi2-atk
# http://ftp.gnome.org/pub/gnome/sources/at-spi2-atk/2.26/at-spi2-atk-2.26.1.tar.xz
ATKBRIDGEFILE=at-spi2-atk-2.26.1
generate_script  atk_bridge     $ATKBRIDGEFILE     \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--host=$MY_TARGET --target=$MY_TARGET --prefix=/usr --disable-static --with-sysroot=$SDKDIR --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf --disable-introspection'  \
    '--deploy-sdk=/usr/include /usr/lib'                                                \
    '--deploy-rootfs=/usr/lib -/usr/lib/pkgconfig -/usr/lib/*.la'        \
    '--depends=cross_autogen_env cross_gobject_introspection atk atk_spi2 dbus'

###########################
# cairo-1.12.8
CAIROFILE=cairo-1.14.6
generate_script  cairo     $CAIROFILE     \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--host=$MY_TARGET --prefix=/usr --sysconfdir=/etc --disable-static --with-sysroot=$SDKDIR --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf --enable-vg --enable-egl --with-x --enable-fc --enable-ft --enable-xlib --disable-xlib-xrender --enable-glesv2 --enable-png'  \
    '--deploy-sdk=/usr/include /usr/lib'                                                \
    '--deploy-rootfs=/usr/lib -/usr/bin -/usr/lib/pkgconfig -/usr/lib/cairo -/usr/lib/pkgconfig -/usr/lib/*.la'        \
    '--depends=cross_autogen_env glib libz libpng x11_pixman libfreetype fontconfig x11_xproto x11_libx11 x11_libxext x11_libxrender expat egl vg gles'

###########################
# pango
PANGOFILE=pango-1.40.1
generate_script  pango     $PANGOFILE     \
    '--config=--host=$MY_TARGET --prefix=/usr --sysconfdir=/etc --disable-static --with-sysroot=$SDKDIR --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf --disable-installed-tests --with-cairo --with-xft'  \
    '--deploy-sdk=/usr/include /usr/lib'                                                \
    '--deploy-rootfs=/usr/lib /usr/bin -/usr/lib/pkgconfig -/usr/lib/*.la'        \
    '--depends=fontconfig harfbuzz glib cairo libfreetype x11_libxft native_glib'

###########################
# desktop-file-utils-0.21
DESKTOP_FILEUTILS=desktop-file-utils-0.21
generate_script  desktop_fileutils     $DESKTOP_FILEUTILS     \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--host=$MY_TARGET --target=$MY_TARGET --prefix=/usr --disable-static'  \
    '--deploy-sdk=/'                                                \
    '--deploy-rootfs=/usr/lib /usr/bin -/usr/lib/pkgconfig'        \
    '--depends=cross_autogen_env glib' --debug --show-usage

###########################
# gdk-pixbuf
# http://ftp.gnome.org/pub/gnome/sources/gdk-pixbuf/
GDKPIXBUF=gdk-pixbuf-2.36.11
generate_script  gdkpixbuf     $GDKPIXBUF     \
    --inside        \
    '--prescript=autoreconf -v --install --force'                                \
    '--prescript=touch gdk-pixbuf/loaders.cache'                              \
    '--config=--host=$MY_TARGET --target=$MY_TARGET --prefix=/usr --sysconfdir=/etc --disable-static --with-sysroot=$SDKDIR --with-libpng --with-libjpeg --with-libtiff --with-x11 --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf --disable-man --disable-rpath --disable-debug --disable-coverage --disable-installed-tests --disable-always-build-tests --enable-nls'  \
    '--deploy-sdk=/usr/lib /usr/include'                                                \
    '--deploy-rootfs=/usr/bin /usr/lib /usr/share/locale /usr/share/thumbnailers -/usr/lib/pkgconfig -/usr/lib/*.la -/usr/lib/gdk*/*/*/*.la'        \
    '--depends=cross_autogen_env shared_mime_info glib libtiff libjpeg libpng x11_libx11'
#!!!!!!
# 这个软件包需要在运行时配置!

###########################
# dbus-glib-0.100
DBUSGLIBFILE=dbus-glib-0.100

PARAM="--host=$MY_TARGET --target=$MY_TARGET --prefix=/usr --disable-static --with-sysroot=$SDKDIR --disable-tests"
PARAM+=" --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf"
PARAM+=" --disable-tests --disable-ansi --disable-verbose-mode --disable-asserts --disable-checks --disable-gcov"
PARAM+=" --enable-bash-completion ac_cv_have_abstract_sockets=yes"
		
generate_script  dbusglib     $DBUSGLIBFILE     \
    '--prescript=cross_autogen_env autoreconf -v --install --force'                                \
    "--config=$PARAM"  \
    '--deploy-sdk=/'                                                \
    '--deploy-rootfs=/usr/bin /usr/lib /usr/libexec /usr/etc -/usr/lib/pkgconfig'        \
    '--depends=glib expat dbus' --debug --show-usage
    
#		# 禁用demo
#		printf "all:\ninstall:\n" > doc/Makefile
#		printf "all:\ninstall:\n" > test/Makefile
#		printf "all:\ninstall:\n" > dbus/examples/Makefile
#		printf "all:\ninstall:\n" > tools/Makefile

###########################
# gnome-mime-data-2.18.0
GNOME_MIME_DATA=gnome-mime-data-2.18.0
generate_script  gnome_mime_data     $GNOME_MIME_DATA     \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--host=$MY_TARGET --prefix=/usr --disable-static'  \
    '--depends=cross_autogen_env'   \
    '--deploy-sdk=/'                                                \
    '--deploy-rootfs=/usr'        \
    --debug --show-usage

###########################
# popt-1.16
POPTFILE=popt-1.16
generate_script  popt     $POPTFILE     \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--host=$MY_TARGET --prefix=/usr --disable-static --disable-rpath --enable-nls'  \
    '--depends=cross_autogen_env'   \
    '--deploy-sdk=/usr/lib -/usr/lib/pkgconfig'                                                \
    '--deploy-rootfs=/usr/lib -/usr/lib/pkgconfig'        \
    --debug --show-usage

###########################
# ORBit2-2.14.19
ORBITFILE=ORBit2-2.14.19
compile_orbit()
{
	if [ ! -e $CACHEDIR/$ORBITFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$ORBITFILE

		if [[ $PLAT_ALIAS == "ecs" || $PLAT_ALIAS == "fsl" ]]; then
		PARAM="--disable-static --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf --disable-debug ac_cv_alignof_CORBA_octet=1 ac_cv_alignof_CORBA_boolean=1 ac_cv_alignof_CORBA_char=1 ac_cv_alignof_CORBA_wchar=2 ac_cv_alignof_CORBA_short=2 ac_cv_alignof_CORBA_long=4 ac_cv_alignof_CORBA_long_long=8 ac_cv_alignof_CORBA_float=4 ac_cv_alignof_CORBA_double=8 ac_cv_alignof_CORBA_long_double=8 ac_cv_alignof_CORBA_struct=1 ac_cv_alignof_CORBA_pointer=4"
		else
			echo "Don't know how to build on other platform, yet!"
			exec_cmd "choke"
		fi;
		
		prepare $ORBITFILE
		
		if [ ! -e $CACHEDIR/native-$ORBITFILE.tar.gz ]; then
restore_native0
			exec_cmd "./configure --prefix=/usr $PARAM"
			exec_cmd "make -j 10 install DESTDIR=$CACHEDIR/native-orbit"
			exec_cmd "make clean"
hide_native0
			exec_cmd "cd $CACHEDIR/native-orbit/$SDKDIR"
			exec_cmd "tar czf $CACHEDIR/native-$ORBITFILE.tar.gz ."
			exec_cmd "rm -rf $CACHEDIR/native-orbit"
		fi;
		
		PRE_REMOVE_LIST="/usr/lib/*.la "
		REMOVE_LIST=""
		DEPLOY_DIST=""
		deploy native-$ORBITFILE native-orbit
	
		exec_cmd "cd $TEMPDIR/$ORBITFILE"		
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link ."
		export CFLAGS="$CFLAGS $CROSS_FLAGS"
		dispenv		
		
		PARAM="--host=$MY_TARGET --prefix=/usr $PARAM --with-idl-compiler=$SDKDIR/usr/bin/orbit-idl-2"
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10 install DESTDIR=$CACHEDIR/orbit "
		
		exec_cmd "cd $CACHEDIR/orbit"
		exec_cmd "tar czf $CACHEDIR/$ORBITFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/orbit $TEMPDIR/$ORBITFILE"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la "
	REMOVE_LIST="/usr/lib/pkgconfig /usr/lib/*.a"
	DEPLOY_DIST="/usr/bin /usr/lib /usr/share/idl"
	deploy $ORBITFILE orbit

	PRE_REMOVE_LIST="/usr/lib /usr/share /usr/include"
	REMOVE_LIST=""
	DEPLOY_DIST=""
	deploy native-$ORBITFILE native-orbit
}
build_orbit()
{	
	# libIDL-2.0 >= 0.8.2 	glib-2.0 >= 2.8.0 	gobject-2.0 >= 2.8.0 	gmodule-2.0 >= 2.8.0
	build_glib
	build_libidl
	
	run_task "构建$ORBITFILE" "compile_orbit"
}

###########################
# libIDL-0.8.14
LIBIDLFILE=libIDL-0.8.14
generate_script  libidl     $LIBIDLFILE     \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--host=$MY_TARGET --prefix=/usr --disable-static libIDL_cv_long_long_format=ll'  \
    '--deploy-sdk=/usr/lib -/usr/lib/pkgconfig'                                                \
    '--deploy-rootfs=/usr/lib /usr/share -/usr/lib/pkgconfig'        \
    '--depends=cross_autogen_env glib' --debug  

##############################
# 编译 gtk+-2
# http://ftp.gnome.org/pub/gnome/sources/gtk+
# gtk2慢慢开始要作废了
GTK2FILES=gtk+-2.99.3
PARAM='--prefix=/usr --host=$MY_TARGET --sysconfdir=/etc --disable-static --with-sysroot=$SDKDIR --enable-gtk2-dependency --disable-maintainer-mode --disable-glibtest  --disable-test-print-backend  --disable-glibtest --disable-debug --disable-cups'
PARAM+=' --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf --disable-man'
PARAM+=' --with-x --disable-xinerama --enable-xkb  --disable-xinerama  --enable-xinput --enable-xrandr --enable-xfixes  --enable-xcomposite  --enable-xdamage'
PARAM+=' --enable-schemas-compile --enable-x11-backend  --disable-win32-backend --disable-quartz-backend '
PARAM+=' --disable-test-print-backend --disable-papi --disable-cups'
PARAM+=' ac_cv_func_mmap_fixed_mapped=yes'
generate_script  gtk2     $GTK2FILES     \
    '--prescript=autoreconf -v --install --force'                                \
    "--config=$PARAM"  \
    '--deploy-sdk=/usr/lib -/usr/lib/pkgconfig'                                                \
    '--deploy-rootfs=/usr/lib /usr/share -/usr/lib/pkgconfig'        \
    '--depends=cross_autogen_env glib atk pango gdkpixbuf cairo' --debug  --show-usage
#    
# libIDL_cv_long_long_format=ll
	
compile_gtk2()
{
	if [ ! -e $CACHEDIR/$GTK2FILES.tar.gz ]; then
		rm -rf $TEMPDIR/$GTK2FILES
		export CFLAGS="$CFLAGS $CROSS_FLAGS "
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link . -lgmodule-2.0"
		dispenv
		
		prepare $GTK2FILES
		

		exec_cmd "./configure $PARAM"
		# 禁用demo
		printf "all:\ninstall:\n" > docs/Makefile
		printf "all:\ninstall:\n" > demos/Makefile
		printf "all:\ninstall:\n" > examples/Makefile
		printf "all:\ninstall:\n" > demos/gtk-demo/Makefile
		printf "all:\ninstall:\n" > tests/Makefile
		printf "all:\ninstall:\n" > gtk/tests/Makefile
		exec_cmd "make -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/gtk2"
			
		exec_cmd "cd $CACHEDIR/gtk2"
		exec_cmd "mkdir -p etc/profile.d"
	
		# 生成配置文件
		cat << _MY_EOF_ > etc/profile.d/setEnvGtk2
#!/bin/sh
if [ ! -f /etc/gtk-2.0/gdk-pixbuf.loaders ] ; then
	echo "Creating gdk-pixbuf.loaders for the first-time running"
	mkdir -p /etc/gtk-2.0
	/usr/bin/gdk-pixbuf-query-loaders > /etc/gtk-2.0/gdk-pixbuf.loaders
fi

if [ ! -f /usr/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache ] ; then
	echo "Creating loaders.cache for the first-time running"
	mkdir -p /usr/lib/gdk-pixbuf-2.0/2.10.0
	/usr/bin/gdk-pixbuf-query-loaders > /usr/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache
fi

if [ ! -f /etc/pango/pango.modules ] ; then
	echo "Creating pango.modules for the first-time running"
	mkdir -p /etc/pango/
	/usr/bin/pango-querymodules > /etc/pango/pango.modules
fi

if [ ! -f /usr/share/glib-2.0/schemas/gschemas.compiled ] ; then
	echo "Compile gschemas for the first-time running"
	/usr/bin/glib-compile-schemas /usr/share/glib-2.0/schemas
fi

_MY_EOF_

		exec_cmd "tar czf $CACHEDIR/$GTK2FILES.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/gtk2 $TEMPDIR/$GTK2FILES"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/share/gtk-doc /usr/share/man"
	REMOVE_LIST="/usr/lib/pkgconfig /usr/share/aclocal"
	DEPLOY_DIST="/etc /usr/bin /usr/lib /usr/share"
	deploy $GTK2FILES gtk2
}
build_gtk2()
{	
	# Package requirements (glib-2.0 >= 2.27.3  atk >= 1.29.2    pango >= 1.20    cairo >= 1.6    gdk-pixbuf-2.0 >= 2.21.0)
	build_glib
	
	build_atk
	build_pango
	build_gdkpixbuf
	build_cairo
	
#	build_xorg_server
#	build_x11_libx11
#	build_x11_libxi
#	build_x11_libxrandr
#	build_x11_libxfixes
#	build_x11_libxcomposite
#	build_x11_libxdamage
#	build_x11_xkbcomp
	
	run_task "构建$GTK2FILES" "compile_gtk2"
}

##############################
# 编译 gobject-introspection
# http://ftp.gnome.org/pub/gnome/sources/gobject-introspection/
GOBJECT_INTROSPECTION_FILE=gobject-introspection-1.54.1
generate_script  cross_gobject_introspection     $GOBJECT_INTROSPECTION_FILE     \
    --build-native              \
    '--patch=gobject-introspection-crosscompile.patch'   \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--prefix=/usr --disable-static  --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf --disable-doctool'  \
    '--install_target=install-strip'    \
    '--postscript=make_python_module_link'     \
    '--deploy-sdk=/usr/bin /usr/include /usr/lib /usr/share -/usr/share/man =cross_gobject_introspection_addlink'           \
    '--deploy-dev=/usr/lib -/usr/bin -/usr/share -/usr/include' \
    '--depends=cross_autogen_env native_glib native_python'
# 这个地方有点拧巴，gobject-introspection更多的时候只是一种编译时用到的工具而已。真正起作用，仍然是在运行时的python。所以没有必要编译native的版本。但这个库是运行在build机上的。
function cross_gobject_introspection_addlink()
{
    echo "adding link" 
}
function make_python_module_link()
{
    local PYMODULEDIR=`python_module_dir`
    cd $TEMPDIR/dist
    mkdir -p .$PYMODULEDIR  || fail "创建目录失败"
    local relname=`get_rel_dir .$PYMODULEDIR usr/lib/gobject-introspection/giscanner`
    ln -s $relname .$PYMODULEDIR/giscanner
}


##############################
# 编译 libepoxy-1.4.3
# https://github.com/anholt/libepoxy/releases
EPOXYFILES=libepoxy-1.4.3
generate_script  epoxy     $EPOXYFILES     \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--prefix=/usr --host=$MY_TARGET --disable-static --enable-egl --with-sysroot=$SDKDIR ac_cv_prog_PYTHON=python2'  \
    '--deploy-sdk=/usr/lib /usr/include'                                                \
    '--deploy-rootfs=/usr/lib -/usr/lib/pkgconfig -/usr/lib/*.la'        \
    '--depends=cross_autogen_env egl cross_python x11_libx11'

##############################
# 编译 gtk+-3.7.6
# http://ftp.gnome.org/pub/gnome/sources/gtk+/
GTK3FILES=gtk+-3.22.26
PARAM='--prefix=/usr --host=$MY_TARGET --disable-static --with-sysroot=$SDKDIR --disable-debug --disable-maintainer-mode --disable-glibtest  --disable-test-print-backend  --disable-glibtest --enable-debug=no --disable-cups --with-x --enable-x11-backend ac_cv_func_mmap_fixed_mapped=yes --disable-introspection --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf --disable-man'
generate_script  gtk3     $GTK3FILES     \
    '--prescript=autoreconf -v --install --force'                                \
    "--config=$PARAM"  \
    '--deploy-sdk=/usr/lib /usr/include /usr/share -/usr/man'                                                \
    '--deploy-rootfs=/usr/bin /usr/etc /usr/lib /usr/share -/usr/lib/pkgconfig -/usr/lib/*.la -/usr/share/aclocal -/usr/share/man'        \
    '--depends=cross_autogen_env glib cross_gobject_introspection atk pango gdkpixbuf cairo x11_libx11 x11_libxext x11_libxi x11_libxrandr x11_libxfixes epoxy atk_bridge'
# pango pangocairo gdk-pixbuf-2.0 >= 2.30.0 cairo >= 1.14.0 cairo-gobject >= 1.14.0 gio-unix-2.0 >= 2.49.4 fontconfig x11 xext xi xrandr xfixes    cairo-xlib epoxy >= 1.0
#PRE_REMOVE_LIST="/usr/lib/*.la /usr/share/gtk-doc /usr/share/man"
#REMOVE_LIST="/usr/lib/pkgconfig /usr/share/aclocal"
#DEPLOY_DIST="/etc /usr/bin /usr/lib /usr/share"
#deploy $GTK3FILES gtk3

compile_gtk3()
{
	if [ ! -e $CACHEDIR/$GTK3FILES.tar.gz ]; then
		rm -rf $TEMPDIR/$GTK3FILES
		export CFLAGS="$CFLAGS $CROSS_FLAGS "
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link . -lgmodule-2.0"
		dispenv
		
		prepare $GTK3FILES
		export PKG_CONFIG_FOR_BUILD="/usr/bin/pkg-config"
#restore_native0
		#	For Gtk3		
		
#		PARAM+=" --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf --disable-man"
#		PARAM+=" --disable-win32-backend --disable-quartz-backend" # quartz is for mac
#		PARAM+="  --disable-xinerama --enable-xinput --enable-xrandr --enable-xfixes --enable-xcomposite --enable-xdamage --enable-xkb"
#		PARAM+=" --enable-schemas-compile "
		exec_cmd "./configure $PARAM"

		# 禁用demo
		printf "all:\ninstall:\n" > docs/Makefile
		printf "all:\ninstall:\n" > demos/Makefile
		printf "all:\ninstall:\n" > examples/Makefile
		printf "all:\ninstall:\n" > demos/gtk-demo/Makefile
		printf "all:\ninstall:\n" > tests/Makefile
		printf "all:\ninstall:\n" > gtk/tests/Makefile
		exec_cmd "make -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/gtk3"
#hide_native0
#		unset PKG_CONFIG_FOR_BUILD
		
		exec_cmd "cd $CACHEDIR/gtk3"
		exec_cmd "mkdir -p etc/profile.d"
	
		# 生成配置文件
		cat << _MY_EOF_ > etc/profile.d/setEnvGtk2
#!/bin/sh
if [ ! -f /etc/gtk-2.0/gdk-pixbuf.loaders ] ; then
	echo "Creating gdk-pixbuf.loaders for the first-time running"
	mkdir -p /etc/gtk-2.0
	/usr/bin/gdk-pixbuf-query-loaders > /etc/gtk-2.0/gdk-pixbuf.loaders
fi

if [ ! -f /etc/pango/pango.modules ] ; then
	echo "Creating pango.modules for the first-time running"
	mkdir -p /etc/pango/
	/usr/bin/pango-querymodules > /etc/pango/pango.modules
fi
_MY_EOF_

		exec_cmd "tar czf $CACHEDIR/$GTK3FILES.tar.gz ."
exit
		exec_cmd "rm -rf $CACHEDIR/gtk3 $TEMPDIR/$GTK3FILES"
	fi;
	
}

###############################
## 编译 upstream
#UPSTREAM=upstream_0.26.2
#compile_upstream()
#{
#	if [ ! -e $CACHEDIR/$UPSTREAM.tar.gz ]; then
#		rm -rf $TEMPDIR/$UPSTREAM
#		
#		dispenv
#		
#		prepare $UPSTREAM
#		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static --enable-arm-neon --enable-libpng"	# --enable-gtk 自己检测
 #   restore_native_header
#		exec_cmd "./configure $PARAM"
#		exec_cmd "make -j 10"
#		exec_cmd "make install DESTDIR=$CACHEDIR/upstream"
#	hide_native_header
#				
#		exec_cmd "cd $CACHEDIR/upstream"
#		exec_cmd "tar czf $CACHEDIR/$UPSTREAM.tar.gz ."
#		exec_cmd "rm -rf $CACHEDIR/upstream $TEMPDIR/$UPSTREAM"
#	fi;
#	
# 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
#	REMOVE_LIST="/usr/lib/pkgconfig"
#	DEPLOY_DIST="/usr/lib"
#	deploy $UPSTREAM upstream
#}
#build_upstream()
#{	
#	build_x11_util_macros
#
#	# build_glib
#	# build_gtk2
#	build_libpng
#	
#	run_task "构建$UPSTREAM" "compile_upstream"
#}

