#!/bin/sh

#############################
#  引导项
case $PLAT_ALIAS in
"ti" )
	XLOADERFILE="x-loader"
	UBOOTFILE="u-boot-release"
	UBOOTCONFIG="sbc3530_rev_a_config"
	UBOOTPATCH=""
	;;
"fsl" )
#	UBOOTFILE="u-boot-2009.08-fsl-loco"
	UBOOTFILE="u-boot-2009.08-fsl-loco-V2"
	UBOOTCONFIG="mx53_loco_config"
#	UBOOTPATCH="uboot-fsl-mx53-use-DCD-mode.patch"
	;;
"ecs" )
#	UBOOTFILE="u-boot-2009.08-ecs-V2"
	UBOOTFILE="u-boot-ecs"
	UBOOTCONFIG="mx53_loco_config"
	UBOOTPATCH="uboot-ecs-bootarg.patch"
	;;
esac
compile_boot()
{	
	# 这一部分代码的编译方法来自华和公司操作指导书

	rm -rf $TEMPDIR/$UBOOTFILE
	
	if [ -n "$XLOADERFILE" ]; then
		rm -rf $TEMPDIR/$XLOADERFILE
		if [ ! -e $CACHEDIR/$XLOADERFILE.tar.gz ]; then
			prepare $XLOADERFILE
			exec_cmd "make ARCH=arm CROSS_COMPILE=$MY_TARGET- distclean"
			exec_cmd "make ARCH=arm CROSS_COMPILE=$MY_TARGET- omap3530beagle_config"
			exec_cmd "make ARCH=arm CROSS_COMPILE=$MY_TARGET- "
			exec_cmd "./signGP"
			exec_cmd "cp x-load.bin.ift MLO"
			exec_cmd "tar czf $CACHEDIR/$XLOADERFILE.tar.gz MLO"
		fi
		exec_cmd "tar xf $CACHEDIR/$XLOADERFILE.tar.gz -C $BOOTDIR/"
	fi

		
	if [ ! -e $CACHEDIR/$UBOOTFILE.tar.gz ]; then
    	dispenv
    	
		prepare $UBOOTFILE $UBOOTPATCH
		exec_cmd "make ARCH=arm CROSS_COMPILE=$MY_TARGET- distclean"
		exec_cmd "make ARCH=arm CROSS_COMPILE=$MY_TARGET- $UBOOTCONFIG"
	#	changeoption config.mk PLATFORM_CPPFLAGS "-march=armv7-a -mtune=cortex-a8 -mfpu=neon -mthumb-interwork -mfloat-abi=softfp -fno-tree-vectorize -Os"
		exec_cmd "make ARCH=arm CROSS_COMPILE=$MY_TARGET- -j 10"
		cp tools/mkimage .
		exec_cmd "tar czf $CACHEDIR/$UBOOTFILE.tar.gz mkimage u-boot.bin"
	fi
	exec_cmd "tar xf $CACHEDIR/$UBOOTFILE.tar.gz -C $BOOTDIR/"
	exec_cmd "mv $BOOTDIR/mkimage $SDKDIR/bin"
	
	if [ -n "$XLOADERFILE" ]; then
		rm -rf $TEMPDIR/$XLOADERFILE
	fi
	rm -rf $TEMPDIR/$UBOOTFILE
}
build_boot()
{
	run_task "编译u-boot" "compile_boot"
}

check_kernel_option()
{
	grep "$1" $ROOTDIR/patch/$KERNELCONFIG -m 1 -s -q
	return $?
}

############################
# linux_header: 输出KERNEL_ROOT
case $PLAT_ALIAS in
"ti" )
	KERNELFILE="linux-03.00.01.06"
	KERNELCONFIG="baiyun_ti_defconfig"
	LINUXVER=2.6.35
	;;
"fsl" )
	KERNELFILE="linux-2.6.35.3-fsl-loco-v2"
	KERNELCONFIG="baiyun_fsl_defconfig"
	KERNELPATCH="linux-fsl-devtmpfs.patch"
	LOGOFILE="ECS_BOOTLOGO.png"
	LINUXVER=2.6.35
	;;
"ecs" )
	KERNELFILE="linux-2.6.35.3-ecs-v2"
	KERNELCONFIG="baiyun_ecs_defconfig"
	KERNELPATCH="linux-ecs.patch"
	LOGOFILE="ECS_BOOTLOGO.png"
	LINUXVER=2.6.35
	;;
esac
# 如果是ECS, 需要制作开机画面的相关包
if [ -n "$LOGOFILE" ]; then
	sudo apt-get -y install netpbm
fi;
compile_kernel()
{
	if [ ! -e $CACHEDIR/$KERNELFILE.tar.gz ]; then
		dispenv
		rm -rf $TEMPDIR/$KERNELFILE
		prepare $KERNELFILE $KERNELPATCH
		exec_cmd "cd $TEMPDIR/$KERNELFILE"
		
#		exec_cmd "make ARCH=arm CROSS_COMPILE=$MY_TARGET- omap3_stalker_defconfig"
		exec_cmd "cp $ROOTDIR/patch/$KERNELCONFIG  $TEMPDIR/$KERNELFILE/arch/arm/configs"
		exec_cmd "make ARCH=arm CROSS_COMPILE=$MY_TARGET- $KERNELCONFIG"
		
		# 修改linux开机画面
		if [ -e $ROOTDIR/patch/$LOGOFILE ]; then
			echo "++++ ! 检测到$LOGOFILE，配置修改linux开机画面 ! ++++"
			check_kernel_option "CONFIG_LOGO_LINUX_CLUT224=y" || (echo "未设置CONFIG_LOGO_LINUX_CLUT224=y选项，开机画面无效！" && exit 1;)
			
			cp $ROOTDIR/patch/$LOGOFILE ./logo.png
			pngtopnm logo.png > logo.pnm 
			check
			pnmquant 224 logo.pnm > logo_224.pnm
			check
			pnmtoplainpnm logo_224.pnm > drivers/video/logo/logo_linux_clut224.ppm
			check
			rm logo.png logo.pnm logo_224.pnm drivers/video/logo/logo_linux_clut224.c >/dev/null 2>&1
		fi;
		
		EXTRA_CFLAGS=$CROSS_FLAGS
		exec_cmd "make ARCH=arm CROSS_COMPILE=$MY_TARGET-  -j 10" # 内核编译选项的开关会使多线程编译失败 -j 10"		# 多线程编译必须和uImage分开
		exec_cmd "make ARCH=arm CROSS_COMPILE=$MY_TARGET- uImage"
		exec_cmd "make ARCH=arm CROSS_COMPILE=$MY_TARGET- modules"

		exec_cmd "mkdir -p $CACHEDIR/$KERNELFILE"
		exec_cmd "cp arch/arm/boot/uImage $CACHEDIR/$KERNELFILE"
		exec_cmd "make ARCH=arm CROSS_COMPILE=$MY_TARGET- INSTALL_MOD_PATH=$CACHEDIR/$KERNELFILE modules_install"
		exec_cmd "make ARCH=arm CROSS_COMPILE=$MY_TARGET- INSTALL_HDR_PATH=$CACHEDIR/$KERNELFILE headers_install"
		exec_cmd "cd $CACHEDIR/$KERNELFILE"
		exec_cmd "rm -f lib/modules/2.6.*/build lib/modules/2.6.*/source" 
		exec_cmd "tar czf $CACHEDIR/$KERNELFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/$KERNELFILE"
	fi;
	exec_cmd "mkdir -p $CACHEDIR/$KERNELFILE"
	exec_cmd "cd $CACHEDIR/$KERNELFILE"
	exec_cmd "tar xf $CACHEDIR/$KERNELFILE.tar.gz"
	exec_cmd "mv uImage $BOOTDIR"
	exec_cmd "cp -R include $SDKDIR"
	exec_cmd "cp -R lib $INSTDIR"
	exec_cmd "rm -rf $CACHEDIR/$KERNELFILE"

#	exec_cmd "cd $SDKDIR/include/scsi"
#	exec_cmd "patch -Np1 -i $ROOTDIR/patch/kernel-scsi-header.patch"
	
	rm -rf $TEMPDIR/$KERNELFILE
}
build_kernel()
{
	build_boot
	
	if [[ ! -e $SDKDIR/bin/mkimage ]]; then
		echo "ERROR: missing mkimage! check u-boot"
		exit -1;
	fi;
	export KERNEL_ROOT=$ROOTDIR/dist/kernel
	run_task "解压$KERNELFILE" "compile_kernel"
	
	export CFLAGS="$CFLAGS -I$KERNEL_ROOT/include"
	rm -rf $INSTDIR/lib/modules/$LINUXVER/build $INSTDIR/lib/modules/$LINUXVER/source
}

###########################
# 编译BusyBox
#BUSYBOXFILE=busybox-1.19.4
BUSYBOXFILE=busybox-1.20.2
compile_busybox()
{	
    restore_native0
	
	rm -rf $TEMPDIR/$BUSYBOXFILE
	if [ ! -e $CACHEDIR/$BUSYBOXFILE.tar.gz ]; then
#		export CFLAGS="$CFLAGS -I$SDKDIR/include -I$SDKDIR/include/linux"
		dispenv
		
		prepare $BUSYBOXFILE busybox-1.20.2-rlimit_fsize.patch
		cd $TEMPDIR/$BUSYBOXFILE
		cp $ROOTDIR/patch/MyBusybox.config-1.20.0 .config
	
		changeoption .config CONFIG_PREFIX \"$CACHEDIR/$BUSYBOXFILE\"
		changeoption .config CONFIG_SYSROOT \"$CROSSTOOL\"
		changeoption .config CONFIG_CROSS_COMPILER_PREFIX \"$MY_TARGET-\"

		exec_cmd "make V=1 -j 10"
		mkdir -p $CACHEDIR/$BUSYBOXFILE
		exec_cmd "make install"
		exec_cmd "cd $CACHEDIR/$BUSYBOXFILE"
		exec_cmd "tar czf $CACHEDIR/$BUSYBOXFILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/$BUSYBOXFILE $TEMPDIR/$BUSYBOXFILE"
	fi;
	exec_cmd "tar xf $CACHEDIR/$BUSYBOXFILE.tar.gz -C $INSTDIR"
	busybox_init_network
	
	hide_native0
}
build_busybox()
{
	run_task "构建$BUSYBOXFILE" "compile_busybox"
}
