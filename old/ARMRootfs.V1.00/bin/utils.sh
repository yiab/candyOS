#!/bin/sh

#ROOTDIR=`(cd ".."; /bin/pwd)`
#BINDIR=$ROOTDIR/bin
#TEMPDIR=$ROOTDIR/temp
#INCDIR=$ROOTDIR/include
#mkdir -p $TEMPDIR

QUIETLY=" 1>/dev/null 2>/dev/null"

clean()
{
	cd $ROOTDIR
#	sudo umount $TEMPDIR
	rm -rf $TEMPDIR 1>$DBG
	mkdir $TEMPDIR
#	sudo mount -t tmpfs none $TEMPDIR 
}

stamp_dir=$ROOTDIR/stamps
rm -rf $stamp_dir   $QUIETLY
mkdir -p $stamp_dir
#rm -rf $stamp_dir/.tasklist 
export current_task=""

begin_task()
{
	export task_name="$1"

	if [ -e "$stamp_dir/$task_name.stamp" ]; then
#		echo " ==>任务 <$current_task> 已完成, 不予执行。如需重新运行，请删除对应stamp文件"
		return 0;
	else
		push_task $task_name
		return $?
	fi;
}

#push_task <task_name>
push_task()
{
	if [ ! -e $stamp_dir/.tasklist ]; then
		> $stamp_dir/.tasklist
	fi;
	
	task_name=$1
	grep "$task_name" $stamp_dir/.tasklist 1>/dev/null 2>/dev/null
	if [[ $? != 0 ]]; then
		echo "$task_name" >> $stamp_dir/.tasklist
		export current_task=$task_name
		return 1;
	else
		echo 不能同一任务重复运行$task_name, 当前调用栈为
		cat $stamp_dir/.tasklist
		return 0;
	fi;	
}

pop_task()
{
	# 去掉尾部空行
	grep "^[^$]" $stamp_dir/.tasklist > $stamp_dir/.tasklist.tmp 
	rm $stamp_dir/.tasklist
	mv $stamp_dir/.tasklist.tmp $stamp_dir/.tasklist

	sed -i '$d' $stamp_dir/.tasklist		# 删除最后一行	

	export current_task=`tail -n 1 $stamp_dir/.tasklist`
	#echo "current_task=$current_task"
	cat $stamp_dir/.tasklist
}

# endtask <task_name>
end_task()
{
	if [ "" != "$current_task" ]; then
		> $stamp_dir/$current_task.stamp
		echo "任务<$current_task> ==> 成功完成"
		pop_task
		return 0;
	fi;
	unset current_task
}

run_task()
{
	if [[ $# != 2 ]]; then
		echo "参数个数为$#，不符合要求"
		echo "usage: run_task <task_name>, <func_name>"
		exit -1;
	fi;
	
	TASKNAME=$1
	ROUTINNAME=$2
	
	begin_task $TASKNAME
	if [[ 0 != $? ]]; then
	
		unset CC
		unset CXX
		unset CPP
		unset ACLOCAL
		cd $ROOTDIR
		initenv
		echo "任务<$TASKNAME> ==> 开始执行"
		$ROUTINNAME
		end_task $current_task
	fi;
}

NATIVE_PREREQUIRST+=" beep"
sudo modprobe pcspkr
check()
{
	retcode=$?
	if [[ $retcode != 0 ]]; then
		
		echo "失败退出！最近一次调用的记录保存在 $DBG 文件中"
		beep -f 900 -l 500 -r 3
		#restore_native0
		
		exit $retcode
	fi
}

beep_succ()
{
	beep -f 261 -l 200
	beep -f 294 -l 200
	beep -f 330 -l 200
	beep -f 349 -l 200
	beep -f 392 -l 200 
	beep -f 440 -l 200 
	beep -f 493 -l 200 
	beep -f 523 -l 200 
	
	beep -f 523 -l 200 
	beep -f 493 -l 200 
	beep -f 440 -l 200 
	beep -f 392 -l 200 
	beep -f 349 -l 200
	beep -f 330 -l 200
	beep -f 294 -l 200
	beep -f 261 -l 200
	
	exit 0;
}

prepare()
{
	if [[ $# < 1 ]]; then
		echo "prepare [package-name] [patch-name]"
		exit;
	fi;
	FILENAME=$1
	
	if [ ! -d $TEMPDIR/$FILENAME ]; then
		FULLNAME=`(cd $DLDIR; ls -b $FILENAME.tar*)`
		echo "... 解压 $FILENAME"
		rm -rf $TEMPDIR/$FILENAME 1>$DBG 2>$DBG
		tar axf $DLDIR/$FULLNAME -C $TEMPDIR 1>$DBG 2>$DBG
		check
		
		if [[ $# == 2 ]]; then
			PATCHFILE=$2
			cd $TEMPDIR/$FILENAME
			patch -Np1 -i $ROOTDIR/patch/$PATCHFILE 1>$DBG
			check		
			echo "........ 补丁：$PATCHFILE"
		fi;
	fi;
	cd $TEMPDIR/$FILENAME
	echo "........ 当前目录是：$PWD"
}

exec_cmd()
{
	CMD="$1"
	
	if [ "z$_surpress_echo" != "zyes" ]; then
		echo "-------> $CMD"
	fi;
	
	echo "$CMD" >>$DBG
	$CMD 1>>$DBG 2>>$WARN
	check
}

##############################
# deploy <pkg_name> <nickname>
# 	DEPLOY_DIST="/usr/bin /usr/lib /usr/share/alsa"
##	DEPLOY_SDK="/usr/include"
#	PRE_REMOVE_LIST="/usr/lib/*.la"
#	REMOVE_LIST="/usr/lib/*.la"
#	deploy $LIBALSAFILE alaslib
##############################
deploy()
{
	PKGNAME=$1
	NICKNAME=$2
	
	echo "-----> DEPLOYING $NICKNAME: dist:{$DEPLOY_DIST} pre-remove:{$PRE_REMOVE_LIST} remove:{$REMOVE_LIST}"
	
	_surpress_echo="yes"
	# 1. 解压
	exec_cmd "sudo mkdir -p $CACHEDIR/$NICKNAME"
	exec_cmd "sudo tar xf $CACHEDIR/$PKGNAME.tar.gz -C $CACHEDIR/$NICKNAME"
	
	# 要删除的内容
	read -a list <<<$PRE_REMOVE_LIST
    for (( i=0; i<${#list[@]}; i++)); do
		exec_cmd "rm -rf $CACHEDIR/$NICKNAME${list[$i]}"
	done;
	
	# 2. 完整安装到SDKDIR
	exec_cmd "sudo cp -Rdpf --remove-destination $CACHEDIR/$NICKNAME/* $SDKDIR"
	
	# REMOVE_LIST
	read -a list <<<$REMOVE_LIST
    for (( i=0; i<${#list[@]}; i++)); do
		exec_cmd "sudo rm -rf $CACHEDIR/$NICKNAME${list[$i]}"
	done;
	
	# 3. 发布到dist
	read -a list <<<$DEPLOY_DIST
    for (( i=0; i<${#list[@]}; i++)); do
		exec_cmd "sudo mkdir -p $INSTDIR${list[$i]}"
		exec_cmd "sudo /bin/cp -Rdpf --remove-destination $CACHEDIR/$NICKNAME${list[$i]}/* $INSTDIR${list[$i]}"
	done;
	
#	# 3. 发布到sdk
#	if [ -n $DEPLOY_SDK ]; then
#		exec_cmd "mkdir -p $SDKDIR/include/$NICKNAME"
#		exec_cmd "cp -R $CACHEDIR/$NICKNAME/$DEPLOY_SDK/* $SDKDIR/include/$NICKNAME"
#	fi;
	exec_cmd "sudo rm -rf $CACHEDIR/$NICKNAME" 
 	unset PRE_REMOVE_LIST
	unset REMOVE_LIST
	unset DEPLOY_DIST
	unset NICKNAME
	unset PKGNAME
    unset _surpress_echo
}

build_native()
{
	needcheck=0
	instdest=""
	maketarget=""
	installtarget="install"
	continue="no"
	work="work"
	
	PKGNAME=$1
	while [ "$1" ]; do
        if [[ "$1" == "--check" ]]; then
            needcheck=1
        fi
        if [[ "$1" == "--dest" ]]; then
        	shift;
        	instdest=$1
        fi;
        if [[ "$1" == "--target" ]]; then
        	shift;
        	maketarget=$1
        fi;
        if [[ "$1" == "--installtarget" ]]; then
        	shift;
        	installtarget=$1
        fi;
        if [[ "$1" == "--continue" ]]; then
        	continue="yes"
        fi;
        if [[ "$1" == "--inside" ]]; then
        	work="."
        fi;
	    shift
	done

	echo "##### Building $PKGNAME"
	echo "CFLAGS=\"$CFLAGS\""
	echo "CXXFLAGS=\"$CXXFLAGS\""
	echo "LDFLAGS=\"$LDFLAGS\""

	if [[ $continue == "no" && $work != "." ]]; then
		rm -rf $TEMPDIR/$work/$PKGNAME 1>/dev/null 2>/dev/null
		mkdir -p $TEMPDIR/$work/$PKGNAME
	fi;
	exec_cmd "cd $TEMPDIR/$work/$PKGNAME"
	echo "当前目录是$PWD"
	if [[ $continue == "no" ]]; then	
		exec_cmd "$TEMPDIR/$PKGNAME/configure $PARAM"
	fi;
	
	echo "........ 编译$PKGNAME中 @ $PWD"
	exec_cmd "make -j 10 "$maketarget
	if [[ $needcheck"r" == "1r" ]]; then
		exec_cmd "make check"
	fi;
	exec_cmd "make $installtarget $instdest"
	echo "........ $PKGNAME 编译成功"
}

removela()
{
	DIRNAME=$1
	
	echo "+++ calling removela($DIRNAME)"
	
	if [ ! -d $DIRNAME ]; then
		echo "目录$DIRNAME不存在"
		exit 1;
	else
		echo "here"
		cd $DIRNAME
		echo "PWD=$PWD"
		find -name "*.la" -delete
	fi;
}

changeoption()
{
	if [[ $# != 3 ]]; then
		echo "Usage: $0 filename optionname newvalue"
		exit;
	else
		FILENAME=$1
		OPT=$2
		VAL=$3
		sed -i "/^\s*$OPT[[:space:]]*=/c $OPT=$VAL" $FILENAME
	fi;
}

replace_in_file()
{
	if [[ $# != 1 ]]; then
		echo "Usage: $0 filename $OLDSTR $NEWSTR"
		exit;
	else
		FILENAME=$1
		#OLDSTR=`echo $OLDSTR | sed "s/\//\\\//"`
		#NEWSTR=`echo $NEWSTR | sed "s/\//\\\//"`
		sed -i "s#$OLDSTR#$NEWSTR#" $FILENAME
	fi;
}

saveenv()
{
	temp_store_path=$PATH
	temp_store_cflags=$CFLAGS
	temp_store_ldflags=$LDFLAGS
	temp_store_cxxflags=$CXXFLAGS
}

restoreenv()
{
	PATH=${temp_store_path}
	CFLAGS=${temp_store_cflags}
	LDFLAGS=${temp_store_ldflags}
	CXXFLAGS=${temp_store_cxxflags}
}

hide_native0()
{
	echo "屏蔽主机开发环境"
#	sudo mv /usr/include /usr/include-native 1>/dev/null 2>/dev/null
#	sudo mv /usr/lib/pkgconfig /usr/lib/pkgconfig-native 1>/dev/null 2>/dev/null
	hide_native_pkgconfig
    hide_native_autoconf
    hide_native_header
    
	initenv
	hash -r
}
reset_native_env()
{
	export PATH=/usr/sbin:/usr/bin:/sbin:/bin
	export PATH=/usr/local/arm/arm-yiab-linux-gnueabi/usr/bin:$PATH
	
	unset CFLAGS
	unset CXXFLAGS
	unset LDFLAGS
	hash -r

}
restore_native0()
{
	echo "恢复主机开发环境"
#	sudo mv /usr/include-native /usr/include 1>/dev/null 2>/dev/null
	restore_native_pkgconfig
	restore_native_autoconf
	restore_native_header

#	reset_native_env
    hash -r
}

hide_native_pkgconfig()
{
	echo "屏蔽主机开发环境(ONLY PKGCONFIG)"
	sudo mv /usr/lib/pkgconfig /usr/lib/pkgconfig-native 1>/dev/null 2>/dev/null
	sudo mv /usr/share/pkgconfig /usr/share/pkgconfig-native 1>/dev/null 2>/dev/null
	
	# pkg-config设置
	export PKG_CONFIG_PATH=$SDKDIR/usr/lib/pkgconfig:$SDKDIR/usr/share/pkgconfig
	export PKG_CONFIG_SYSROOT_DIR=$SDKDIR
	export PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1
	export PKG_CONFIG_ALLOW_SYSTEM_LIBS=1
	
	hash -r
}

restore_native_pkgconfig()
{
	echo "恢复主机开发环境(ONLY PKGCONFIG)"
	sudo mv /usr/lib/pkgconfig-native /usr/lib/pkgconfig 1>/dev/null 2>/dev/null
	sudo mv /usr/share/pkgconfig-native /usr/share/pkgconfig 1>/dev/null 2>/dev/null

	unset PKG_CONFIG_PATH
	unset PKG_CONFIG_SYSROOT_DIR
	unset PKG_CONFIG_ALLOW_SYSTEM_CFLAGS
	unset PKG_CONFIG_ALLOW_SYSTEM_LIBS
	
	hash -r
}

restore_native_autoconf()
{
	_cur_autoconf=`which autoreconf`
	
	if [[ $_cur_autoconf == "$SDKDIR/usr/bin/autoreconf" ]]; then
	    echo "恢复主机开发环境(ONLY AUTOCONF)"

	    cd $SDKDIR/usr/bin
	    mv aclocal aclocal-hide 1>/dev/null 2>/dev/null
	    mv aclocal-1.12 aclocal-1.12-hide 1>/dev/null 2>/dev/null
	    mv autoconf autoconf-hide 1>/dev/null 2>/dev/null
	    mv autoheader autoheader-hide 1>/dev/null 2>/dev/null
	    mv autom4te autom4te-hide 1>/dev/null 2>/dev/null
	    mv automake automake-hide 1>/dev/null 2>/dev/null
	    mv automake-1.12 automake-1.12-hide 1>/dev/null 2>/dev/null
	    mv autoreconf autoreconf-hide 1>/dev/null 2>/dev/null
	    mv autoscan autoscan-hide 1>/dev/null 2>/dev/null
	    mv autoupdate autoupdate-hide 1>/dev/null 2>/dev/null
	    
	    mv libtool libtool-hide 1>/dev/null 2>/dev/null
	    mv libtoolize libtoolize-hide 1>/dev/null 2>/dev/null

	    cd - 1>/dev/null 2>/dev/null
	    
	    sudo mv /usr/share/native-aclocal /usr/share/aclocal 1>/dev/null 2>/dev/null
   	    unset _surpress_echo
	fi;
	unset _cur_autoconf
	
	hash -r
}
hide_native_autoconf()
{
    if [ ! -e "$SDKDIR/usr/bin/autoreconf-hide" ]; then
        echo "不存在$SDKDIR/usr/bin/autoreconf-hide"
        return;
    fi;
    
	_cur_autoconf=`which autoreconf`
	if [[ $_cur_autoconf != "$SDKDIR/usr/bin/autoreconf" ]]; then
	    echo "隐藏主机开发环境(ONLY AUTOCONF)"
	    
	    cd $SDKDIR/usr/bin
	    mv aclocal-hide aclocal 1>/dev/null 2>/dev/null
	    mv aclocal-1.12-hide aclocal-1.12 1>/dev/null 2>/dev/null
	    mv autoconf-hide autoconf 1>/dev/null 2>/dev/null
	    mv autoheader-hide autoheader 1>/dev/null 2>/dev/null
	    mv autom4te-hide autom4te 1>/dev/null 2>/dev/null
	    mv automake-hide automake 1>/dev/null 2>/dev/null
	    mv automake-1.12-hide automake-1.12 1>/dev/null 2>/dev/null
	    mv autoreconf-hide autoreconf 1>/dev/null 2>/dev/null
	    mv autoscan-hide autoscan 1>/dev/null 2>/dev/null
	    mv autoupdate-hide autoupdate 1>/dev/null 2>/dev/null
	    mv libtool-hide libtool 1>/dev/null 2>/dev/null
	    mv libtoolize-hide libtoolize 1>/dev/null 2>/dev/null
	    
	    sudo mv /usr/share/aclocal /usr/share/native-aclocal  1>/dev/null 2>/dev/null
	    cd -
   	fi;
   	unset _cur_autoconf
   	
   	hash -r
}

hide_native_header()
{
	if [ -d /usr/include ]; then
		if [ ! -d /usr/include-native ]; then
			sudo mkdir /usr/include-native
		fi;
		sudo mv /usr/include/* /usr/include-native 1>/dev/null 2>/dev/null
	fi;
#	for i in /usr/include-native/* ; do
#		filename=`basename $i`
#		if [ ! -e $NATIVETOOL/include/$filename ]; then
#			#echo "--> 链接主机文件: " $i
#			ln -s $i $NATIVETOOL/include/$filename
#		fi;
#	done
#	sudo mv /usr/lib/pkgconfig /usr/lib/pkgconfig-native 1>/dev/null 2>/dev/null
    hash -r
}

restore_native_header()
{
#	for i in $NATIVETOOL/include/* ; do
#		if [ -h $i ]; then
#			rm -rf $i
#		fi;
#	done
	if [ -d /usr/include-native ]; then
		if [ ! -d /usr/include ]; then
			sudo mkdir /usr/include
		fi;
		
		sudo mv /usr/include-native/* /usr/include
		sudo rm -rf /usr/include-native
	fi;
#	sudo mv /usr/lib/pkgconfig-native /usr/lib/pkgconfig
    hash -r
}
