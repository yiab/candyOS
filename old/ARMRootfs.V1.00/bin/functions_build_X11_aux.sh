#!/bin/sh
##############################
# 编译 gsettings-desktop-schemas-3.6.1
GSETTING_DESKTOP_SCHEMAS=gsettings-desktop-schemas-3.6.1
compile_gsettings_desktop_schemas()
{
	
	if [ ! -e $CACHEDIR/$GSETTING_DESKTOP_SCHEMAS.tar.gz ]; then
		rm -rf $TEMPDIR/$GSETTING_DESKTOP_SCHEMAS
		
		dispenv
		prepare $GSETTING_DESKTOP_SCHEMAS
		PARAM="--prefix=/usr --host=$MY_TARGET --enable-nls --disable-schemas-compile"
	deploy_native_glib
		exec_cmd "./configure $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/gsettings_desktop_schemas"
	restore_cross_glib

		exec_cmd "cd $CACHEDIR/gsettings_desktop_schemas"
#		exec_cmd "mkdir -p usr/lib"
#		exec_cmd "mv usr/share/pkgconfig usr/lib"
		exec_cmd "tar czf $CACHEDIR/$GSETTING_DESKTOP_SCHEMAS.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/gsettings_desktop_schemas $TEMPDIR/$GSETTING_DESKTOP_SCHEMAS"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST="/usr/share"
	deploy $GSETTING_DESKTOP_SCHEMAS gsettings_desktop_schemas
}
build_gsettings_desktop_schemas()
{	
	build_glib
	
	run_task "构建$GSETTING_DESKTOP_SCHEMAS" "compile_gsettings_desktop_schemas"
}

##############################
# 编译 dejavu-fonts-ttf-2.33
DEJAVU_FONTS=dejavu-fonts-ttf-2.33
compile_dejavu_fonts()
{
	if [ ! -e $CACHEDIR/$DEJAVU_FONTS.tar.gz ]; then
		rm -rf $TEMPDIR/$DEJAVU_FONTS
		
		dispenv
		prepare $DEJAVU_FONTS
		exec_cmd "mkdir -p etc/fonts/conf.d usr/share/fonts"
		exec_cmd "mv fontconfig/* etc/fonts/conf.d"
		exec_cmd "mv ttf usr/share/fonts"
		exec_cmd "tar czf $CACHEDIR/$DEJAVU_FONTS.tar.gz ./usr ./etc"
exit;		
		exec_cmd "rm -rf $CACHEDIR/dejavu_fonts $TEMPDIR/$DEJAVU_FONTS"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST="/usr /etc"
	deploy $DEJAVU_FONTS dejavu_fonts
}
build_dejavu_fonts()
{	
	run_task "构建$DEJAVU_FONTS" "compile_dejavu_fonts"
}

##############################
# 编译 gnome-themes-standard-3.7.4
GNOME_THEMES_STANDARD=gnome-themes-standard-3.7.4
compile_gnome_themes_standard()
{
	if [ ! -e $CACHEDIR/$GNOME_THEMES_STANDARD.tar.gz ]; then
		rm -rf $TEMPDIR/$GNOME_THEMES_STANDARD
		
		dispenv
		prepare $GNOME_THEMES_STANDARD
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-nls --disable-gtk3-engine --disable-glibtest --disable-static"
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10 install DESTDIR=$CACHEDIR/gnome_themes_standard"

		exec_cmd "cd $CACHEDIR/gnome_themes_standard"
		exec_cmd "tar czf $CACHEDIR/$GNOME_THEMES_STANDARD.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/gnome_themes_standard $TEMPDIR/$GNOME_THEMES_STANDARD"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST="/usr/lib /usr/share"
	deploy $GNOME_THEMES_STANDARD gnome_themes_standard
}
build_gnome_themes_standard()
{	
	build_gtk2
	
	run_task "构建$GNOME_THEMES_STANDARD" "compile_gnome_themes_standard"
}

##############################
# 编译 gnome-icon-theme-2.18.0
NATIVE_PREREQUIRST+=" icon-naming-utils"
#GNOME_ICON_THEME=gnome-icon-theme-2.18.0
GNOME_ICON_THEME=gnome-icon-theme-3.7.3
compile_gnome_icon_theme()
{
	if [ ! -e $CACHEDIR/$GNOME_ICON_THEME.tar.gz ]; then
		rm -rf $TEMPDIR/$GNOME_ICON_THEME
		
		dispenv
		prepare $GNOME_ICON_THEME

restore_native0
		PARAM="--prefix=/usr --host=$MY_TARGET"
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10 install DESTDIR=$CACHEDIR/gnome_icon_theme"
hide_native0

		exec_cmd "cd $CACHEDIR/gnome_icon_theme"
		exec_cmd "tar czf $CACHEDIR/$GNOME_ICON_THEME.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/gnome_icon_theme $TEMPDIR/$GNOME_ICON_THEME"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST="/usr/lib /usr/share"
	deploy $GNOME_ICON_THEME gnome_icon_theme
}
build_gnome_icon_theme()
{	
	run_task "构建$GNOME_ICON_THEME" "compile_gnome_icon_theme"
}

#NATIVE_PREREQUIRST+=" libxml-simple-perl"
##############################
# 编译 icon-naming-utils-0.8.90
#ICON_NAMING_UTILS=icon-naming-utils-0.8.90
#compile_icon_naming_utils()
#{
#	if [ ! -e $CACHEDIR/$ICON_NAMING_UTILS.tar.gz ]; then
#		rm -rf $TEMPDIR/$ICON_NAMING_UTILS
#		
#		dispenv
#		prepare $ICON_NAMING_UTILS
#		PARAM="--prefix=/usr --host=$MY_TARGET"
#		exec_cmd "./configure $PARAM"
#		exec_cmd "make -j 10 install DESTDIR=$CACHEDIR/icon_naming_utils"

#		exec_cmd "cd $CACHEDIR/icon_naming_utils"
#		exec_cmd "tar czf $CACHEDIR/$ICON_NAMING_UTILS.tar.gz ."
#		exec_cmd "rm -rf $CACHEDIR/icon_naming_utils $TEMPDIR/$ICON_NAMING_UTILS"
#	fi;
	
#	PRE_REMOVE_LIST=""
#	REMOVE_LIST=""
#	DEPLOY_DIST="/usr/lib /usr/share"
#	deploy $ICON_NAMING_UTILS icon_naming_utils
#}
#build_icon_naming_utils()
#{
#	run_task "构建$ICON_NAMING_UTILS" "compile_icon_naming_utils"
#}

##############################
# 编译 hicolor-icon-theme-0.12
HICOLOR_ICON_THEME=hicolor-icon-theme-0.12
compile_hicolor_icon_theme()
{
	if [ ! -e $CACHEDIR/$HICOLOR_ICON_THEME.tar.gz ]; then
		rm -rf $TEMPDIR/$HICOLOR_ICON_THEME
		
		dispenv
		prepare $HICOLOR_ICON_THEME
		PARAM="--prefix=/usr --host=$MY_TARGET"
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10 install DESTDIR=$CACHEDIR/hicolor_icon_theme"

		exec_cmd "cd $CACHEDIR/hicolor_icon_theme"
		exec_cmd "tar czf $CACHEDIR/$HICOLOR_ICON_THEME.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/hicolor_icon_theme $TEMPDIR/$HICOLOR_ICON_THEME"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST="/usr/share"
	deploy $HICOLOR_ICON_THEME hicolor_icon_theme
}
build_hicolor_icon_theme()
{		
	run_task "构建$HICOLOR_ICON_THEME" "compile_hicolor_icon_theme"
}

##############################
# 编译 metacity-2.34.13
# metacity是一个比较现代的X11窗口管理器
X11_METACITY=metacity-2.34.13
compile_x11_metacity()
{
	if [ ! -e $CACHEDIR/$X11_METACITY.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_METACITY
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link ."
		dispenv
		prepare $X11_METACITY
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static --disable-themes-documentation --disable-xinerama --disable-themes-documentation  --disable-canberra --with-x --with-gnu-ld --enable-compositor --enable-render --enable-xsync --enable-shape --enable-schemas-compile --disable-sm --disable-canberra --disable-startup-notification --enable-nls --disable-verbose-mode --disable-debug"
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_metacity"
		exec_cmd "cd $CACHEDIR/x11_metacity"
		exec_cmd "tar czf $CACHEDIR/$X11_METACITY.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_metacity $TEMPDIR/$X11_METACITY"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST="/usr/share/man /usr/include"
	DEPLOY_DIST="/usr"
	deploy $X11_METACITY x11_metacity
}
build_x11_metacity()
{	
	# Package requirements (gtk+-2.0 >= 2.24.0 gio-2.0 >= 2.25.10 pango >= 1.2.0 gsettings-desktop-schemas >= 3.3.0 libcanberra-gtk xcomposite >= 0.2 xfixes xrender xdamage) 
	build_gettext
	build_gtk2
	build_glib
	build_pango
	build_x11_libxdamage
	build_x11_libxcomposite
	build_x11_libxrender
	build_x11_libxfixes
	build_x11_libxcursor
	build_gsettings_desktop_schemas
	
	# 不是必须，但gnome需要一个缺省主题Adwaita
#	build_gnome_themes_standard
	
	# metacity 的缺省图标
#	build_hicolor_icon_theme
	
	run_task "构建$X11_METACITY" "compile_x11_metacity"
}

##############################
# 编译 xinit-1.3.2
X11_XINIT=xinit-1.3.2
compile_x11_xinit()
{
	if [ ! -e $CACHEDIR/$X11_XINIT.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_XINIT
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link ."
		dispenv
		prepare $X11_XINIT
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_xinit"

		exec_cmd "cd $CACHEDIR/x11_xinit"
		
		OLDSTR="$SDKDIR/"
		NEWSTR="/"
		exec_cmd "replace_in_file usr/bin/startx"
		exec_cmd "tar czf $CACHEDIR/$X11_XINIT.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_xinit $TEMPDIR/$X11_XINIT"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/xorg/modules/drivers/*.la"
	REMOVE_LIST=""
	DEPLOY_DIST="/usr/lib /usr/bin"
	deploy $X11_XINIT x11_xinit
}
build_x11_xinit()
{	
	build_xorg_server
	
	run_task "构建$X11_XINIT" "compile_x11_xinit"
}

##############################
# 编译 xf86-video-fbdev-0.4.3
# 这是X11的软件绘制驱动，一般没有必要，可以作为对比使用
X11_XF86FBDEV=xf86-video-fbdev-0.4.3
compile_x11_xf86fbdev()
{
	
	if [ ! -e $CACHEDIR/$X11_XF86FBDEV.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_XF86FBDEV
		
		dispenv
		
		prepare $X11_XF86FBDEV
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static --disable-pciaccess"
		exec_cmd "./configure $PARAM"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_xf86fbdev"
		
		exec_cmd "cd $CACHEDIR/x11_xf86fbdev"
		exec_cmd "tar czf $CACHEDIR/$X11_XF86FBDEV.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_xf86fbdev $TEMPDIR/$X11_XF86FBDEV"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/xorg/modules/drivers/*.la"
	REMOVE_LIST=""
	DEPLOY_DIST="/usr/lib"
	deploy $X11_XF86FBDEV x11_xf86fbdev
}
build_x11_xf86fbdev()
{	
	build_x11_util_macros
	
	# Package requirements (xorg-server >= 1.0.99.901 xproto fontsproto )
	build_xorg_server
	build_x11_xproto
	build_x11_fontsproto
	
	run_task "构建$X11_XF86FBDEV" "compile_x11_xf86fbdev"
}

