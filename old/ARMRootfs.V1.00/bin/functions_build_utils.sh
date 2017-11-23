#!/bin/sh

##############################
# 编译 libgeos
LIBGEOSFILE=geos-3.3.5
compile_libgeos()
{
	if [ ! -e $CACHEDIR/$LIBGEOSFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$LIBGEOSFILE
		prepare $LIBGEOSFILE
		
		export CFLAGS="$CFLAGS $CROSS_FLAGS"
		dispenv
		
		PARAM="--prefix=/usr --host=$MY_TARGET --enable-inline --disable-cassert --disable-glibcxx-debug --disable-python --disable-ruby --disable-php --disable-static"
		exec_cmd "./configure $PARAM"
		exec_cmd "make -j 10"
		exec_cmd "make install DESTDIR=$CACHEDIR/libgeos"

		exec_cmd "cd $CACHEDIR/libgeos"
		exec_cmd "tar czf $CACHEDIR/$LIBGEOSFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/libgeos $TEMPDIR/$LIBGEOSFILE"
	fi;
	
	DEPLOY_DIST="/usr/lib"
	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST="/usr/lib/*.a /usr/lib/pkgconfig"	
	deploy $LIBGEOSFILE libgeos
}
build_libgeos()
{
	run_task "编译$LIBGEOSFILE" "compile_libgeos"
}

