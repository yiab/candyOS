#!/bin/sh

##############################
# 编译 e2fsprogs
E2FSPROGSFILE=e2fsprogs-1.43.3
compile_e2fsprogs()
{
	if [ ! -e $CACHEDIR/$E2FSPROGSFILE.tar.gz ]; then
		rm -rf $TEMPDIR/$E2FSPROGSFILE
		export CFLAGS="$CFLAGS $CROSS_FLAGS "
		dispenv	
	
		prepare $E2FSPROGSFILE
		
		exec_cmd "./configure --host=$MY_TARGET --enable-symlink-install --disable-profile --disable-gcov --disable-hardening --disable-jbd-debug --disable-blkid-debug --disable-testio-debug"
		exec_cmd "make -j 10"
		exec_cmd "make install root_prefix=$CACHEDIR/e2fsprogs prefix=$CACHEDIR/e2fsprogs"

		exec_cmd "cd $CACHEDIR/e2fsprogs"
		exec_cmd "tar czf $CACHEDIR/$E2FSPROGSFILE.tar.gz ."
		exec_cmd "rm -rf $TEMPDIR/$E2FSPROGSFILE $CACHEDIR/e2fsprogs"
	fi;

	DEPLOY_DIST="/bin /etc /lib /sbin"
	PRE_REMOVE_LIST="/usr/lib/*.la"
	REMOVE_LIST=""	
	deploy $E2FSPROGSFILE e2fsprogs
}
build_e2fsprogs()
{
	run_task "构建$E2FSPROGSFILE" "compile_e2fsprogs"
}
