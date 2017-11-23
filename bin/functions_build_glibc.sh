
###########################
# GLIBC
GLIBC_FILE=glibc-2.24
GLIBC_PORTS_FILE=glibc-ports-2.16.0
compile_glibc()
{
    rm -rf $TEMPDIR/$GLIBC_FILE
    rm -rf $TEMPDIR/$GLIBC_PORTS_FILE
	if [ ! -e $CACHEDIR/$GLIBC_FILE.tar.gz ]; then
		dispenv
		
        prepare $GLIBC_PORTS_FILE glibc-ports-no_linux_eabi.patch
	    prepare $GLIBC_FILE
		exec_cmd "cd $TEMPDIR/$GLIBC_FILE"

	    #export CFLAGS=" -w -O2 -march=armv7-a -mtune=cortex-a8 -mfpu=neon -mthumb-interwork -mfloat-abi=softfp -fno-tree-vectorize"
	    PARAM="--prefix=/usr --host=$MY_TARGET --with-headers=$INSTDIR/usr/include --disable-profile --enable-add-ons=nptl,""$TEMPDIR/$GLIBC_PORTS_FILE"" --enable-kernel=2.4.10 --enable-multi-arch --with-tls --with-elf libc_cv_forced_unwind=yes libc_cv_c_cleanup=yes libc_cv_ctors_header=yes"
	
	    #PARAM="--prefix=/usr --host=$MY_TARGET --with-headers=$INSTDIR/usr/include --disable-profile --enable-add-ons=nptl,""$TEMPDIR/$GLIBC_PORTS_FILE"" --enable-kernel=2.4.10 --disable-multi-arch --with-tls --with-elf --with-gnu-as --with-gnu-ld"
	    build_native $GLIBC_FILE --dest DESTDIR=$INSTDIR
	
	    exit;
	    
		exec_cmd "make V=1"
		mkdir -p $CACHEDIR/$BUSYBOXFILE
		exec_cmd "make install"
		exec_cmd "cd $CACHEDIR/$BUSYBOXFILE"
		exec_cmd "tar czf $CACHEDIR/$BUSYBOXFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/$BUSYBOXFILE $TEMPDIR/$BUSYBOXFILE"
	fi;
	
    
	
	CFLAGS="$CFLAGS $CROSS_FLAGS -w "
	
	#bug?
	export LDFLAGS="$LDFLAGS -L$TEMPDIR/$SPLASHYFILE/src/.libs -lz -lstdc++"
	
	cp $INSTDIR/usr/bin/directfb-config $SDKDIR/bin || exit 1;
	PATH=$SDKDIR/bin:$PATH		# 为了调用正确的directfb-config
	
	PARAM="--host=$MY_TARGET --prefix=/usr"
	build_native $SPLASHYFILE --dest DESTDIR=$INSTDIR --inside
}
build_glibc()
{
	run_task "构建$GLIBC_FILE" "compile_glibc"
}
