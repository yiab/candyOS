#!/bin/sh
##############################
# 编译 libsound
LIBSOUNDFILE=libsndfile-1.0.25
compile_libsndfile()
{
	rm -rf $TEMPDIR/$LIBSOUNDFILE
	if [ ! -e $CACHEDIR/$LIBSOUNDFILE.tar.gz ]; then
		export CFLAGS="$CFLAGS $CROSS_FLAGS "
		dispenv
		
		prepare $LIBSOUNDFILE libsndfile.patch
		
		PARAM="--prefix=/usr --exec-prefix=/usr --host=$MY_TARGET --disable-largefile --disable-static --disable-external-libs --with-sysroot=$INSTDIR --disable-sqlite"
		build_native $LIBSOUNDFILE --dest DESTDIR=$CACHEDIR/libsndfile --inside
		
		exec_cmd "cd $CACHEDIR/libsndfile"
		exec_cmd "tar czf $CACHEDIR/$LIBSOUNDFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/libsndfile $TEMPDIR/$LIBSOUNDFILE"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST="/usr/lib/*.a /usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib /usr/bin"
	deploy $LIBSOUNDFILE libsndfile
}
build_libsndfile()
{
	build_libogg
	build_alaslib
	run_task "构建$LIBSOUNDFILE" "compile_libsndfile"
}

##############################
# 编译 libjson
LIBJSONFILE=json-c-0.9
compile_libjson()
{
	rm -rf $TEMPDIR/$LIBJSONFILE
	if [ ! -e $CACHEDIR/$LIBJSONFILE.tar.gz ]; then
		dispenv
		export CFLAGS="$CFLAGS $CROSS_FLAGS "
		prepare $LIBJSONFILE
		
		printf "ac_cv_func_malloc_0_nonnull=yes \nac_cv_func_realloc_0_nonnull=yes\n" > baiyun.config.cache
		PARAM="--prefix=/usr --exec-prefix=/usr --host=$MY_TARGET --disable-static --cache-file=baiyun.config.cache"
		build_native $LIBJSONFILE --dest DESTDIR=$CACHEDIR/libjson --inside
		
		exec_cmd "cd $CACHEDIR/libjson"
		exec_cmd "tar czf $CACHEDIR/$LIBJSONFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/libjson $TEMPDIR/$LIBJSONFILE"
	fi;

 	DEPLOY_DIST="/usr/lib"
 	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST="/usr/lib/pkgconfig"
	deploy $LIBJSONFILE libjson
}
build_libjson()
{	
	run_task "构建$LIBJSONFILE" "compile_libjson"
}


##############################
# 编译 libogg
LIBOGGFILE=libogg-1.3.0
compile_libogg()
{
	rm -rf $TEMPDIR/$LIBOGGFILE
	if [ ! -e $CACHEDIR/$LIBOGGFILE.tar.gz ]; then
		dispenv
		export CFLAGS="$CFLAGS $CROSS_FLAGS "
		prepare $LIBOGGFILE
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		build_native $LIBOGGFILE --dest DESTDIR=$CACHEDIR/libogg --inside
		
		exec_cmd "cd $CACHEDIR/libogg"
		exec_cmd "tar czf $CACHEDIR/$LIBOGGFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/libogg $TEMPDIR/$LIBOGGFILE"
	fi;
	
	DEPLOY_DIST="/usr/lib"
 	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST="/usr/lib/pkgconfig"
	deploy $LIBOGGFILE libogg
}
build_libogg()
{	
	run_task "构建$LIBOGGFILE" "compile_libogg"
}

##############################
# 编译 speex
SPEEXFILE=speex-1.2rc1
compile_speex()
{
	rm -rf $TEMPDIR/$SPEEXFILE
	if [ ! -e $CACHEDIR/$SPEEXFILE.tar.gz ]; then
		dispenv
		export CFLAGS="$CFLAGS $CROSS_FLAGS "
		
		prepare $SPEEXFILE
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		build_native $SPEEXFILE --dest DESTDIR=$CACHEDIR/speex --inside
		
		exec_cmd "cd $CACHEDIR/speex"
		exec_cmd "tar czf $CACHEDIR/$SPEEXFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/speex $TEMPDIR/$SPEEXFILE"
	fi;
	DEPLOY_DIST="/usr/lib /usr/bin"
 	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST="/usr/lib/pkgconfig"
	deploy $SPEEXFILE speex
}
build_speex()
{
	build_libogg
	
	run_task "构建$SPEEXFILE" "compile_speex"
}


# NATIVE_PREREQUIRST+=" xmlto"
##############################
# 编译 alsa-utilspulseaudio --system --log-target=stderr --log-level=info
ALSAUTILFILE=alsa-utils-1.0.25
compile_alsautils()
{
	rm -rf $TEMPDIR/$ALSAUTILFILE
	if [ ! -e $CACHEDIR/$ALSAUTILFILE.tar.gz ]; then	
		
		export CFLAGS="$CFLAGS $CROSS_FLAGS "
		export LDFLAGS="$LDFLAGS "
		dispenv


		prepare $ALSAUTILFILE
		PARAM="--prefix=/usr --host=$MY_TARGET --enable-nls --disable-largefile --disable-xmlto --with-curses=ncursesw" #xmlto is toooooo big! : baiyun --disable-rpath
		#build_native $ALSAUTILFILE --dest DESTDIR=$CACHEDIR/alsautils --inside
		exec_cmd "./configure $PARAM"
		exec_cmd "make"
		exec_cmd "make install DESTDIR=$CACHEDIR/alsautils"
		
		exec_cmd "cd $CACHEDIR/alsautils"
		exec_cmd "tar czf $CACHEDIR/$ALSAUTILFILE.tar.gz ."
		
		exec_cmd "rm -rf $CACHEDIR/alsautils $TEMPDIR/$ALSAUTILFILE"
	fi;
	
	DEPLOY_DIST="/lib /var /usr/bin /usr/sbin /usr/share/alsa /usr/share/sounds"
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	deploy $ALSAUTILFILE alsautils
}
build_alsautils()
{
	build_alaslib
	build_ncurses
	
	run_task "构建$ALSAUTILFILE" "compile_alsautils"
}

##############################
# 编译 alas-plugins
ALSAPLUGINFILE=alsa-plugins-1.0.25
compile_alasplugin()
{
	if [ ! -e $CACHEDIR/$ALSAPLUGINFILE.tar.gz ]; then
		export CFLAGS="$CFLAGS $CROSS_FLAGS -D_GNU_SOURCE"
		dispenv

		rm -rf $TEMPDIR/$ALSAPLUGINFILE
		prepare $ALSAPLUGINFILE
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static --enable-pulseaudio" # --disable-jack
		exec_cmd "./configure $PARAM"
		exec_cmd "make"
		exec_cmd "make install DESTDIR=$CACHEDIR/alasplugin"
		exec_cmd "cd $CACHEDIR/alasplugin"
		exec_cmd "tar czf $CACHEDIR/$ALSAPLUGINFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/alasplugin $TEMPDIR/$ALSAPLUGINFILE"
	fi;
	
	DEPLOY_DIST="/usr"
 	PRE_REMOVE_LIST="/usr/lib/alsa-lib/*.la"
	REMOVE_LIST=""
	deploy $ALSAPLUGINFILE alasplugin
}
build_alasplugin()
{		
	build_alaslib
	build_pulseaudio
	
	run_task "构建$ALSAPLUGINFILE" "compile_alasplugin"
}

##############################
# 编译 alas-lib
LIBALSAFILE=alsa-lib-1.0.25
compile_alaslib()
{
	if [ ! -e $CACHEDIR/$LIBALSAFILE.tar.gz ]; then		
		export CFLAGS="$CFLAGS $CROSS_FLAGS -ldl -fPIC -DPIC"
		dispenv

		rm -rf $TEMPDIR/$LIBALSAFILE
		case $PLAT_ALIAS in
		"ti" )
			prepare $LIBALSAFILE alsa-lib-mypatch.patch
			;;
		"fsl" )
			prepare $LIBALSAFILE alsa-lib-fsl-nommu.patch
			;;
		"ecs" )
			prepare $LIBALSAFILE alsa-lib-fsl-nommu.patch
			;;
		esac
		
		PARAM="--prefix=/usr --host=$MY_TARGET --localstatedir=/var --sysconfdir=/etc --disable-python --with-alsa-devdir=/dev/snd --disable-old-symbols" #  --disable-rawmidi --disable-maintainer-mode  --with-librt --with-pthread --without-libdl --with-gnu-ld --with-pic --enable-symbolic-functions
		# build_native $LIBALSAFILE --dest DESTDIR=$CACHEDIR/alaslib --inside
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/alaslib"
		
		exec_cmd "cd $CACHEDIR/alaslib"
		exec_cmd "tar czf $CACHEDIR/$LIBALSAFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/alaslib $TEMPDIR/$LIBALSAFILE"
	fi;

	DEPLOY_DIST="/usr/bin /usr/lib /usr/share/alsa"
 	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST="/usr/lib/pkgconfig"
	deploy $LIBALSAFILE alaslib
					
	############### 1. 添加ALSA配置项 asound.conf ###################
	cat << _MY_EOF_ > $INSTDIR/etc/asound.conf
pcm.pulse {
       type pulse
}

ctl.pulse {
       type pulse
}
_MY_EOF_
############### 编译了pulseaudio后应该修改这个配置文件为如下：???
#pcm.!default {
#        type pulse
#        hint.description "Default Audio Device"
#}
#
#ctl.!default {
#        type pulse
#}

	############### 2. 添加启动任务，恢复系统音量 ###########################
	exec_cmd "sudo cp $BUILDINDIR/asound.state $INSTDIR/etc"
	cat << _MY_EOF_ > $INSTDIR/etc/init.d/30.asound-init
echo "-------------Resetting ALSA Status--------------"
/usr/sbin/alsactl restore -f /etc/asound.state
_MY_EOF_

}
build_alaslib()
{	
	build_utillinux		# 需要支持mount
	
	run_task "构建$LIBALSAFILE" "compile_alaslib"
}
#setenv_alaslib()
#{
#	export CFLAGS="$CFLAGS -I$SDKDIR/include/alaslib/alsa -I$SDKDIR/include/alaslib"
#	export LDFLAGS="$LDFLAGS -lm -ldl -lpthread -lrt"
#}

##############################
# 编译pulseaudio
PULSEAUDIOFILE=pulseaudio-2.0
compile_pulseaudio()
{
	rm -rf $TEMPDIR/$PULSEAUDIOFILE
	if [ ! -e $CACHEDIR/$PULSEAUDIOFILE.tar.gz ]; then
		prepare $PULSEAUDIOFILE 		# pulseaudio-xcb-pkgconfig.patch  # 传LDFLAGS动态链接

		export CFLAGS="$CFLAGS $CROSS_FLAGS"
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link ."
		dispenv
		
		PARAM="--prefix=/usr --localstatedir=/var --sysconfdir=/etc --host=$MY_TARGET --disable-static --enable-tcpwrap --enable-dbus --disable-static --enable-nls  --with-speex --enable-glib2  --enable-libtool-lock --enable-alsa --with-database=simple" #--with-sysroot=$INSTDIR  --disable-polkit  --disable-xmltoman --enable-ltdl-install=no  ]
		PARAM+=" --disable-hal --disable-hal-compat --disable-bluez --disable-samplerate --disable-solaris --disable-largefile --disable-openssl --disable-ipv6 --disable-systemd --disable-manpages"
		PARAM+=" --disable-esound --disable-avahi --disable-jack --disable-lirc --disable-asyncns --disable-per-user-esound-socket --disable-oss-output --disable-oss-wrapper"
		PARAM+=" --with-system-user=pulse --with-system-group=pulse --with-access-group=pulse-access --enable-udev --with-udev-rules-dir=/etc/udev/rules.d"
		export LIBS=""
		PARAM+=" --enable-x11 --disable-gtk2 --disable-gconf" # 
	restore_native_header
		exec_cmd "./configure $PARAM"
		
    hide_native_header
		exec_cmd "make V=1 -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/pulseaudio"
				
		exec_cmd "cd $CACHEDIR/pulseaudio"
		exec_cmd "tar czf $CACHEDIR/$PULSEAUDIOFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/pulseaudio $TEMPDIR/$PULSEAUDIOFILE"
	fi;
	
	DEPLOY_DIST="/usr/bin /etc /usr/lib /usr/libexec /usr/share/vala /usr/share/pulseaudio"
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/pulseaudio/*.la"
	REMOVE_LIST="/usr/lib/pkgconfig"
	deploy $PULSEAUDIOFILE pulseaudio
	
	## 1. 设置启动pulseaudio脚本/etc/init.d/start-pulseaudio.sh
	cat << _MY_EOF_ > $INSTDIR/etc/init.d/80.start-pulseaudio
echo "-------------Starting PulseAudio--------------"
/bin/rm -rf /var/run/pulse 1>/dev/null 2>/dev/null
/bin/mkdir /var/run/pulse
/bin/chown pulse:pulse /var/run/pulse /dev/snd/*

/usr/bin/pulseaudio --system  --log-target=stderr --disallow-exit --disallow-module-loading --daemon # --log-level=info
_MY_EOF_
	
	cat << _MY_EOF_ > $INSTDIR/etc/profile.d/pulseaudio.sh
#!/bin/sh
export LD_LIBRARY_PATH=/usr/lib/pulse-2.0:/usr/lib/pulseaudio:\$LD_LIBRARY_PATH
_MY_EOF_
	exec_cmd "sudo chmod a+x $INSTDIR/etc/profile.d/pulseaudio.sh"
	
	
	## 2. 添加pulse用户和pulse组。配置项 /etc/group和/etc/passwd
	# root组里面要包括pulse才行，这个很关键
	sed "s/^root:x:0:/root:x:0:pulse,/" -i $INSTDIR/etc/group
	cat << _MY_EOF_ >> $INSTDIR/etc/group
pulse:x:100:pulse
pulse-access:x:101:pulse,root
_MY_EOF_
	# /etc/passwd
	cat << _MY_EOF_ >> $INSTDIR/etc/passwd
pulse:x:100:100:Linux User,,,:/var/run/pulse:/bin/sh
_MY_EOF_
	mkdir -p $INSTDIR/var/run/pulse
	exec_cmd "sudo chown 100:100 $INSTDIR/var/run/pulse"
	
	## 4. 修改/etc/pulse/system.pa		#module-detect没法传入更多参数
	exec_cmd "sudo cp $BUILDINDIR/system.pa $INSTDIR/etc/pulse/"
}

build_pulseaudio()
{	
	build_libjson
	build_speex
	build_alaslib
	build_libsndfile
	build_udev
	build_dbus
#	build_openssl

	build_libwrap
    build_glib
#    build_gtk2

    # $PKG_CONFIG --exists --print-errors " x11-xcb xcb >= 1.6 ice sm xtst "
    build_x11_libxcb
    build_x11_libice
    build_x11_libsm
    build_x11_libxtst
	
	run_task "构建$PULSEAUDIOFILE" "compile_pulseaudio"
}

##############################
# 编译 ekho
EKHOFILE=ekho-4.12
compile_ekho()
{
	if [ ! -e $CACHEDIR/$EKHOFILE.tar.gz ]; then

		prepare $EKHOFILE

		export CFLAGS="$CFLAGS $CROSS_FLAGS -DNO_SSE -fPIC `pkg-config --cflags libpulse sndfile`"
		export CXXFLAGS=$CFLAGS
		export LDFLAGS="$LDFLAGS -Wl,--rpath-link $SDKDIR/usr/lib -Wl,--rpath-link $SDKDIR/usr/lib/pulseaudio -Wl,--rpath-link ."
		dispenv
		
		printf "ac_cv_func_malloc_0_nonnull=yes \nac_cv_func_realloc_0_nonnull=yes\n" > baiyun.config.cache		
		PARAM="--prefix=/usr --without-mp3lame --without-gtk2 --host=$MY_TARGET --cache-file=baiyun.config.cache"
	restore_native_header
		exec_cmd "./configure $PARAM"
	hide_native_header
		exec_cmd "make -j 10"
		
		# 制作ekho的动态链接库
		exec_cmd "$MY_TARGET-gcc -fPIC -shared libekho.a libekho_a-libekho.o libekho_a-ekho_dict.o libekho_a-dsp.o libekho_a-zhy_symbol_map.o libekho_a-zh_symbol_map.o libekho_a-symbol_array.o sonic.o -Wall -o libekho.so"
		exec_cmd "$MY_TARGET-strip libekho.so"
		exec_cmd "$MY_TARGET-g++ src/ekho.cpp -o ekho $CXXFLAGS -I. -L. -lekho -Iutfcpp/source -Isonic $LDFLAGS -lpulse-simple -lpulse"
		exec_cmd "$MY_TARGET-g++ src/test_ekho.cpp -o test_ekho $CXXFLAGS -I. -L. -lekho -Iutfcpp/source -Isonic $LDFLAGS -lpulse-simple -lpulse"
		exec_cmd "make install DESTDIR=$CACHEDIR/ekho"
		exec_cmd "mkdir -p $CACHEDIR/ekho/usr/lib"
		exec_cmd "cp libekho.so $CACHEDIR/ekho/usr/lib"
		
		exec_cmd "cd $CACHEDIR/ekho"
		exec_cmd "rm -rf usr/share/ekho-data/hakka usr/share/ekho-data/jyutping"
		exec_cmd "tar czf $CACHEDIR/$EKHOFILE.tar.gz ."
		exec_cmd "sudo rm -rf $CACHEDIR/ekho $TEMPDIR/$EKHOFILE"
	fi;
	
 	PRE_REMOVE_LIST=""
	REMOVE_LIST=""
	DEPLOY_DIST="/usr/bin /usr/lib /usr/share"
	deploy $EKHOFILE ekho
}
build_ekho()
{	
	build_libsndfile
	build_pulseaudio
	build_alasplugin
	#alsautil用于调节音量
	build_alsautils
	
	run_task "构建$EKHOFILE" "compile_ekho"
}

