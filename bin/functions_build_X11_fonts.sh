#!/bin/bash

##############################
# 编译 x11fonts
X11_FONTS=x11fonts
compile_x11_fonts()
{
	if [ ! -e $CACHEDIR/$X11_FONTS.tar.gz ]; then
		rm -rf $TEMPDIR/$X11_FONTS
		dispenv
		prepare $X11_FONTS
		
		LIST='font-util-1.3.0.tar.bz2 encodings-1.0.4.tar.bz2 font-adobe-100dpi-1.0.3.tar.bz2 font-adobe-75dpi-1.0.3.tar.bz2 font-adobe-utopia-100dpi-1.0.4.tar.bz2 font-adobe-utopia-75dpi-1.0.4.tar.bz2 font-adobe-utopia-type1-1.0.4.tar.bz2 font-alias-1.0.3.tar.bz2 font-arabic-misc-1.0.3.tar.bz2 font-bh-100dpi-1.0.3.tar.bz2 font-bh-75dpi-1.0.3.tar.bz2 font-bh-lucidatypewriter-100dpi-1.0.3.tar.bz2 font-bh-lucidatypewriter-75dpi-1.0.3.tar.bz2 font-bh-ttf-1.0.3.tar.bz2 font-bh-type1-1.0.3.tar.bz2 font-bitstream-100dpi-1.0.3.tar.bz2 font-bitstream-75dpi-1.0.3.tar.bz2 font-bitstream-speedo-1.0.2.tar.bz2 font-bitstream-type1-1.0.3.tar.bz2 font-cronyx-cyrillic-1.0.3.tar.bz2 font-cursor-misc-1.0.3.tar.bz2 font-daewoo-misc-1.0.3.tar.bz2 font-dec-misc-1.0.3.tar.bz2 font-ibm-type1-1.0.3.tar.bz2 font-isas-misc-1.0.3.tar.bz2 font-jis-misc-1.0.3.tar.bz2 font-micro-misc-1.0.3.tar.bz2 font-misc-cyrillic-1.0.3.tar.bz2 font-misc-ethiopic-1.0.3.tar.bz2 font-misc-meltho-1.0.3.tar.bz2 font-misc-misc-1.1.2.tar.bz2 font-mutt-misc-1.0.3.tar.bz2 font-schumacher-misc-1.1.2.tar.bz2 font-screen-cyrillic-1.0.4.tar.bz2 font-sony-misc-1.0.3.tar.bz2 font-sun-misc-1.0.3.tar.bz2 font-winitzki-cyrillic-1.0.3.tar.bz2 font-xfree86-type1-1.0.4.tar.bz2'
		
		for pkg in $LIST ; do
			echo "编译 $pkg ... "
			exec_cmd "tar axf $pkg"
			export DIRNAME=`basename $pkg .tar.bz2`
			exec_cmd "cd $DIRNAME"
			exec_cmd "./configure --prefix=/usr --host=$MY_TARGET"
			exec_cmd "make install DESTDIR=$CACHEDIR/x11_fonts"
			exec_cmd "cp $CACHEDIR/x11_fonts/usr/lib/pkgconfig/* $SDKDIR/usr/lib/pkgconfig"
			exec_cmd "cd .."
			exec_cmd "rm -rf $DIRNAME"			
		done;
		unset LIST;
exit;
		PARAM="--prefix=/usr --host=$MY_TARGET --disable-static"
		exec_cmd "./configure $PARAM"
		exec_cmd "make V=1"
		exec_cmd "make install DESTDIR=$CACHEDIR/x11_libfontenc"
				
		exec_cmd "cd $CACHEDIR/x11_libfontenc"
		exec_cmd "tar czf $CACHEDIR/$X11_LIBFONTENC.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/x11_libfontenc $TEMPDIR/$X11_LIBFONTENC"
	fi;
	
 	PRE_REMOVE_LIST="/usr/lib/*.la /usr/lib/*.a"
	REMOVE_LIST="/usr/lib/pkgconfig"
	DEPLOY_DIST="/usr/lib"
	deploy $X11_FONTS x11_fonts
}
build_x11_fonts()
{	
	build_x11_util_macros
	
	run_task "构建$X11_FONTS" "compile_x11_fonts"
}
