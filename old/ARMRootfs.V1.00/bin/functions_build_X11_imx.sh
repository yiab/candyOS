#!/bin/sh
construct_fsl()
{
	construct_ecs
}

construct_ecs()
{
restore_native0
	init_rootfs
	build_kernel
	build_busybox
	
	prepare_native_autoconf
hide_native0
##################################
#  clean enviornment
	######################
	# 声音和TTS框架
	build_pulseaudio
	build_ekho

	######################
	# 网络拨号
	build_udev
	#	build_openssl
	build_ppp
	build_usbmodeswitch
	#	#build_usbutils
	build_wvdial
	#	build_wvstreams

	######################
	# X11
	build_xorg_server
	# 显示
	build_x11_video_$PLAT_ALIAS
	build_x11_xf86fbdev	
	# 鼠标
	build_x11_inputevdev
	# 窗口管理器
	build_x11_metacity
	build_x11_xinit

	######################
	# ecs需要的库
	build_qt_x11
	build_libgeos

	################
	# nfs for debug
	build_nfsutil
	
	#####################
	# 发布前的配置
	final_setting_ecs
	
	# 非常基础的库
	#build_directfb
#	build_libz
#	build_libpng
#	build_libjpeg
#	build_libfreetype

# 	#build_gnome_icon_theme
#	build_gnome_setting_daemon
#	build_clearlooks_theme
}

final_setting_ecs()
{
	echo "Removing Useless file ... "
	cd $TEMPDIR
	sudo rm -rf $INSTDIR/usr/share/man
	sudo rm -rf $INSTDIR/usr/share/gtk-doc
	sudo rm -rf $INSTDIR/usr/share/pkgconfig
	sudo rm -rf $INSTDIR/usr/share/fonts/X11
	sudo rm -rf $INSTDIR/usr/share/GConf
	sudo rm -rf $INSTDIR/usr/share/gettext
	sudo rm -rf $INSTDIR/usr/share/glib-2.0/codegen
	sudo rm -rf $INSTDIR/usr/share/glib-2.0/gdb
	sudo rm -rf $INSTDIR/usr/share/glib-2.0/gettext
	sudo rm -rf $INSTDIR/usr/share/info
	sudo mv $INSTDIR/usr/share/locale/zh_CN $TEMPDIR/
	sudo rm -rf $INSTDIR/usr/share/locale/*
	sudo mv $TEMPDIR/zh_CN $INSTDIR/usr/share/locale
	
	sudo rm -rf $INSTDIR/usr/share/sounds
	sudo rm -rf $INSTDIR/usr/share/terminfo
	
	
	
########################################################
	echo "安装设置字体和区位的脚本"
	mkdir -p $INSTDIR/etc/profile.d/
	cat << _MY_EOF_ > $INSTDIR/etc/profile.d/prepLocale
# prepare font	
changed='no'
for ftname in simhei.ttf simsunb.ttf simsun.ttf; do
	if [ ! -f /usr/share/fonts/truetype/\$ftname ] ; then
		echo "Linking font \$ftname ... "
		mkdir -p /usr/share/fonts/truetype/
		ln -s /home/root/ECS2012-X11/do-font/\$ftname /usr/share/fonts/truetype/\$ftname
		changed="yes"
	fi
done;

if test \$changed = 'yes' ; then
	echo "Creating font cache ... "
	/usr/bin/fc-cache -fr
fi;

# setting locale
if [ ! -f /usr/lib/locale/locale-archive ] ; then
	echo "Generating Locale for the first-time running"

	mkdir -p /usr/lib/locale
	
	echo "... generating zh_CN.UTF-8"
	localedef -i zh_CN -f UTF-8 zh_CN.UTF-8
	
	echo "... generating zh_CN.GBK"
	localedef -i zh_CN -f GBK zh_CN.GBK
	#localedef -i zh_CN -f GB2312 zh_CN.GB2312
	#localedef -i zh_CN -f GB18030 zh_CN.GB18030
fi
_MY_EOF_
########################################################

	
########################################################
	echo "安装设置QT的脚本"
	cat << _MY_EOF_ > $INSTDIR/etc/profile.d/setQtEnv

export LD_LIBRARY_PATH=$QT_X11_PREFIX/lib:\$LD_LIBRARY_PATH
export DISPLAY=:0.0

_MY_EOF_
########################################################

	echo "安装ubuntu主题 ... "	
	sudo rm -rf $INSTDIR/usr/share/themes/*
	tar axf $BUILDINDIR/Ambiance-ubuntu.tar.bz2 -C $INSTDIR/usr/share/themes/
	
	echo "安装GTK设置 ... "
	sudo rm -rf $INSTDIR/usr/share/glib-2.0/schemas/*
	mkdir -p $INSTDIR/usr/share/glib-2.0/schemas
	tar axf $BUILDINDIR/schemas.tar.bz2 -C $INSTDIR/usr/share/glib-2.0/schemas
	
	# 准备启动ECS-X11
	mkdir -p $INSTDIR/home/root
	cat << _MY_EOF_ > $INSTDIR/home/root/.xinitrc
# Start the D-Bus session daemon
eval \`dbus-launch\`
export DBUS_SESSION_BUS_ADDRESS

umount /mnt/share
ifdown eth0 

echo "启动桌面管理器 ... "
metacity &

cd /home/root/ECS2012-X11
echo "启动拨号管理器 ... "
./diald &

echo "启动ECS主程序 ... "
./ECS2012
_MY_EOF_
	
	# 准备启动ECS-X11
	mkdir -p $INSTDIR/etc
	cat << _MY_EOF_ > $INSTDIR/etc/autostart
xinit &
_MY_EOF_
	chmod 755 $INSTDIR/etc/autostart
	
	find $INSTDIR/ -name '*.la' -exec sudo rm {} \; 1>/dev/null 2>&1
}

##############################
# 编译 xserver-xorg-video-imx-11.09.01
X11_VIDEOFSL=xserver-xorg-video-imx-11.09.01
#X11_VIDEOFSL=xserver-xorg-video-imx-2.0.1
compile_x11_video_fsl()
{
	dispenv
	if [ ! -e $CACHEDIR/$X11_VIDEOFSL.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_VIDEOFSL
		export CFLAGS="$CFLAGS $CROSS_FLAGS -I$SDKDIR/usr/include/xorg"
		dispenv
		
		# prepare $X11_VIDEOFSL								# 对xorg-server-1.7.6
		
		prepare $X11_VIDEOFSL xorg-imx-oldapi.patch 		# 对xorg-server-12.4以前版本都不需要修改
#		exec_cmd "patch -Np1 -i $PATCHDIR/xorg-imx-enable-video.patch"
		
		# prepare $X11_VIDEOFSL xorg-imx-newapi.patch 		# 对xorg-server-13.1以后版本都不需要修改
		# prepare $X11_VIDEOFSL								# 网上下载的xserver-xorg-video-new什么都不用改
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static --disable-pciaccess --enable-neon"

#		exec_cmd "autoreconf -v --install --force"
		exec_cmd "./configure $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_video_fsl"
		exec_cmd "mkdir -p $CACHEDIR/x11_video_fsl/etc/X11"
		exec_cmd "cp $BUILDINDIR/xorg.conf $CACHEDIR/x11_video_fsl/etc/X11"
				
		exec_cmd "cd $CACHEDIR/x11_video_fsl"
		exec_cmd "tar czf $CACHEDIR/$X11_VIDEOFSL.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_video_fsl $TEMPDIR/$X11_VIDEOFSL"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/xorg/modules/drivers/*.la"
	REMOVE_LIST=""
	DEPLOY_DIST="/usr/lib /etc/X11"
	deploy $X11_VIDEOFSL x11_video_fsl
}
build_x11_video_fsl()
{	
	 # Package requirements (xorg-server >= 1.0.99.901 xproto fontsproto ) were not met
	build_xorg_server
	build_x11_xproto
	build_x11_fontsproto
	
	# checking if RANDR is defined... no
	build_x11_randrproto
	build_x11_libxrandr
	
	build_x11_libpciaccess
	
	build_dvsdk_x11
	
	# 其它配置文件中要求的内容
	# 1. 键盘
	build_x11_xkeyboardconfig
	build_x11_xkbcomp
	build_x11_inputevdev	
	build_x11_xrandr
	build_fbset
		
	run_task "构建$X11_VIDEOFSL" "compile_x11_video_fsl"
}
build_x11_video_ecs()
{
    build_x11_video_fsl
}



###########################
# dvsdk 输出DVSDK_HOME
DVSDKFILE=DVSDK-dist.4.05
GRAPHICSSDKFILE=
copy_dvsdk_ti()
{
	exec_cmd "tar axf $BUILDINDIR/$DVSDKFILE.tar.bz2 -C $SDKDIR"
	LIB_INSTALL_PATH=$SDKDIR/$DVSDKFILE/opt/gfxlibraries/gfx_rel_es3.x
	
	exec_cmd "cd $LIB_INSTALL_PATH"
	sed -i "s/\$(uname \-r)/$LINUXVER/g" install.sh || exit 1;			# 把所有的$(uname -r)替换为linux版本号
	sed -i "s/bc_example.ko/bufferclass_ti.ko/g" install.sh || exit 1;	# 没有bc_example.ko这个文件，替换为bufferclass_ti.ko
	exec_cmd "./install.sh --no-x --root $INSTDIR"
	exec_cmd "mkdir -p $DVSDK_HOME/lib/modules/$LINUXVER"	# 建一个假的库文件目录，骗过DVSDK的安装程序
	exec_cmd "./install.sh --no-x --root $DVSDK_HOME"
	exec_cmd "cp -R $DVSDK_HOME/etc $INSTDIR/"
	cd $INSTDIR/etc/init.d
	sed -i "s/bc_example.ko/bufferclass_ti.ko/g" rc.pvr || exit 1;	# 没有bc_example.ko这个文件，替换为bufferclass_ti.ko
	exec_cmd "rm -rf $DVSDK_HOME/lib $INSTDIR/etc/powervr_ddk_install.log $INSTDIR/etc/init.d/omap-demo"	
	
	cat << _MY_EOF_ >> $INSTDIR/etc/init.d/rcS
#
# powervr-ddk-startup
echo "-------------Starting PowerVR--------------"
#/etc/init.d/rc.pvr start
/etc/init.d/pvr-init start

_MY_EOF_
	
	cd $INSTDIR/etc/init.d
	tar jxf $BUILDINDIR/etc-prg.tar.bz2 pvr-init || exit 3;
	
	cd $INSTDIR/usr/sbin
	rm -r fbset
	tar jxf $BUILDINDIR/etc-prg.tar.bz2 fbset || exit 3;
	
	mv $INSTDIR/ect/init.d/devmem2 $INSTDIR/usr/sbin
}
copy_dvsdk_fsl()
{
exec_cmd "choke"
	export FSL_GPULIB_FILE="amd-gpu-bin-mx51-11.09.01_201112"

	prepare $FSL_GPULIB_FILE
	exec_cmd "cp -Ra . $SDKDIR/"
	
	exec_cmd "mkdir -p $SDKDIR/include/gpusdk $INSTDIR/usr/lib "

	exec_cmd "cp -Ra usr/lib/*.so* 	$INSTDIR/usr/lib"
#	exec_cmd "cp -R usr/lib/*.a 	$SDKDIR/lib"
#	exec_cmd "cp -R usr/include/* $SDKDIR/include/gpusdk"
	
	exec_cmd "rm -rf $TEMPDIR/$FSL_GPULIB_FILE"	
}
copy_dvsdk_fsl_x11()
{
	export FSL_GPULIB_FILE="amd-gpu-x11-bin-mx51-11.09.01_201112"
	#export FSL_GPULIB_FILE="amd-gpu-x11-bin-mx51-new"
	
	prepare $FSL_GPULIB_FILE
	exec_cmd "cp -Ra * $SDKDIR/"
	
	exec_cmd "mkdir -p $INSTDIR/usr/lib $INSTDIR/usr/bin"
	exec_cmd "cp -Ra usr/lib/*.so* 	$INSTDIR/usr/lib"
	exec_cmd "cp -Ra usr/bin/*	$INSTDIR/usr/bin"
	exec_cmd "cd $INSTDIR/lib"
	exec_cmd "sudo ln -s ld-linux.so.3  ld-linux-armhf.so.3"
	
	exec_cmd "rm -rf $TEMPDIR/$FSL_GPULIB_FILE"	
	
	export LIBZ160_FILE="libz160-bin-11.09.01"
	prepare $LIBZ160_FILE
	exec_cmd "cp -Ra * $SDKDIR/"	
	exec_cmd "mkdir -p $INSTDIR/usr/lib "
	exec_cmd "cp -Ra usr/lib/*.so* 	$INSTDIR/usr/lib"
	exec_cmd "rm -rf $TEMPDIR/$LIBZ160_FILE"	
}
copy_dvsdk_ecs()
{
	copy_dvsdk_fsl
}
copy_dvsdk_ecs_x11()
{
	copy_dvsdk_fsl_x11
}
build_dvsdk()
{
exec_cmd "choke"
	run_task "解压$DVSDKFILE" "copy_dvsdk_$PLAT_ALIAS"
}
build_dvsdk_x11()
{
	run_task "解压$DVSDKFILE" "copy_dvsdk_${PLAT_ALIAS}_x11"
}
setenv_dvsdk()
{
case $PLAT_ALIAS in
"ti" )
	export DVSDK_HOME="$SDKDIR/$DVSDKFILE"
	export DVSDK_INC=$DVSDK_HOME/usr/include
	export DVSDK_LIB=$DVSDK_HOME/usr/lib
	export CFLAGS="$CFLAGS -I$DVSDK_INC"
	export LDFLAGS="$LDFLAGS -L$DVSDK_LIB"
	;;
"fsl" )
	export CFLAGS="$CFLAGS -I$SDKDIR/include/gpusdk"
	export LDFLAGS="$LDFLAGS -L$SDKDIR/lib -lgsl-fsl "
	;;
"ecs" )
	export CFLAGS="$CFLAGS -I$SDKDIR/include/gpusdk"
	export LDFLAGS="$LDFLAGS -L$SDKDIR/lib"
	;;
esac	

}

#############################################3
# wasted !
##############################
# 编译 imx-lib-11.09.01_201112
IMXLIBFILE=imx-lib-11.09.01_201112
compile_imxlib()
{
	if [ ! -e $CACHEDIR/$IMXLIBFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$IMXLIBFILE
		
		dispenv
        
		prepare $IMXLIBFILE
		
		echo "建立目录"
		exec_cmd "mkdir -p $CACHEDIR/imxlib/usr/lib"
		exec_cmd "mkdir -p $CACHEDIR/imxlib/usr/include"
		
		echo "编译libipu.so..."
		exec_cmd "cd ipu"
		exec_cmd "make PLATFORM=IMX53 CROSS_COMPILE=${MY_TARGET}- INCLUDE='-I$SDKDIR/include'"
		exec_cmd "make install DEST_DIR=$CACHEDIR/imxlib"
		exec_cmd "cd .."
		
		echo "编译libvpu.so..."
		exec_cmd "cd vpu"
		exec_cmd "make PLATFORM=IMX53 CROSS_COMPILE=${MY_TARGET}- INCLUDE='-I$SDKDIR/include'"
		exec_cmd "make install DEST_DIR=$CACHEDIR/imxlib"
		exec_cmd "cd .."
		
		echo "打包..."
		exec_cmd "cd $CACHEDIR/imxlib"
		exec_cmd "rm usr/lib/*.a"
		exec_cmd "${MY_TARGET}-strip usr/lib/*.so*"
		exec_cmd "tar czf $CACHEDIR/$IMXLIBFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/imxlib $TEMPDIR/$IMXLIBFILE"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST="/usr/lib"
	deploy $IMXLIBFILE fbset
}
build_imxlib()
{		
	run_task "构建$IMXLIBFILE" "compile_imxlib"
}
