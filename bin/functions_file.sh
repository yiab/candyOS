###########################
# file
FILEFILE=file-5.11
compile_file()
{
	prepare $FILEFILE
	PARAM="--prefix=$TEMPDIR/libfile"
	build_native $FILEFILE
	
	PATH=$TEMPDIR/libfile/bin:$PATH
	CFLAGS="$CFLAGS $CROSS_FLAGS -w"
	PARAM="--host=$MY_TARGET --prefix=$SDKDIR/libmagic --disable-shared"
	build_native $FILEFILE
}
build_file()
{
	run_task "构建$FILEFILE" "compile_file"
	CFLAGS="$CFLAGS -I$SDKDIR/libmagic/include"
	LDFLAGS="$LDFLAGS -L$SDKDIR/libmagic/lib"
}



###########################
# Splashy
SPLASHYFILE=splashy-0.3.13
compile_splashy()
{
	prepare $SPLASHYFILE
	
	build_libz
	build_glib
	build_libpng
	update_pkgconfig
	build_file
	build_dvsdk
	build_directfb
	CFLAGS="$CFLAGS $CROSS_FLAGS -w "
	
	#bug?
	export LDFLAGS="$LDFLAGS -L$TEMPDIR/$SPLASHYFILE/src/.libs -lz -lstdc++"
	
	cp $INSTDIR/usr/bin/directfb-config $SDKDIR/bin || exit 1;
	PATH=$SDKDIR/bin:$PATH		# 为了调用正确的directfb-config
	
	PARAM="--host=$MY_TARGET --prefix=/usr"
	build_native $SPLASHYFILE --dest DESTDIR=$INSTDIR --inside
}

build_splashy()
{
	run_task "构建$SPLASHYFILE" "compile_splashy"
}
