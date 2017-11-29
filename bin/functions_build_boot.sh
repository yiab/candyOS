#!/bin/sh

FEATURE_UTILLINUX=n            # 假定没有安装utillinux包，则需要busybox提供简单命令行工具

#############################
#  引导项
compile_boot()
{	
	# 这一部分代码的编译方法来自华和公司操作指导书
	rm -rf $TEMPDIR/$UBOOTFILE
	
	if [ -n "$XLOADERFILE" ]; then
		rm -rf $TEMPDIR/$XLOADERFILE
		if [ ! -e $CACHEDIR/$XLOADERFILE.tar.gz ]; then
			prepare $XLOADERFILE
			exec_cmd "make ARCH=arm CROSS_COMPILE=$MY_TARGET- distclean"
			exec_cmd "make ARCH=arm CROSS_COMPILE=$MY_TARGET- $XLOADERCONFIG"
			exec_cmd "make ARCH=arm CROSS_COMPILE=$MY_TARGET- "
			exec_cmd "./signGP"
			exec_cmd "cp x-load.bin.ift MLO"
			exec_cmd "tar czf $CACHEDIR/$XLOADERFILE.tar.gz MLO"
		fi
		exec_cmd "tar xf $CACHEDIR/$XLOADERFILE.tar.gz -C $BOOTDIR/"
	fi

    if [ -n "$UBOOTFILE" ]; then
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
	fi
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
# 如果是ECS, 需要制作开机画面的相关包
if [ -n "$LOGOFILE" ]; then
	NATIVE_PREREQUIRST+=" netpbm"
fi;
[ -n "$KERNEL_PACK_COMMAND" ] || KERNEL_PACK_COMMAND="pack_kernel_${PRODUCT}"
build_kernel()
{
	export KERNEL_ROOT=$ROOTDIR/dist/kernel
	[ -n "$KERNELFILE" ] || fail "未设置KERNELFILE源码包名"
    [ -n "$KERNELCONFIG" ] || fail "未设置Kernel的Config名称"

	if [ ! -e $CACHEDIR/$KERNELFILE.tar.gz ]; then
	    resetenv
		dispenv
		prepare $KERNELFILE $KERNELPATCH
		
		if [ -f "$PATCHDIR/$KERNELCONFIG" ]; then
		    exec_cmd "cp $PATCHDIR/$KERNELCONFIG  $TEMPDIR/$KERNELFILE/arch/arm/configs"
		fi;
		
		_kconfig="$KERNEL_COMPILE_ARGS CROSS_COMPILE=$MY_TARGET-"
		exec_cmd "make $_kconfig $KERNELCONFIG"

		# 修改linux开机画面
		if [ -n "$LOGOFILE" ] && [ -f "$PATCHDIR/$LOGOFILE" ]; then
			echo "++++ ! 检测到$LOGOFILE，配置修改linux开机画面 ! ++++"
			check_kernel_option "CONFIG_LOGO_LINUX_CLUT224=y" || (echo "未设置CONFIG_LOGO_LINUX_CLUT224=y选项，开机画面无效！" && exit 1;)
			
			cp $PATCHDIR/$LOGOFILE ./logo.png
			pngtopnm logo.png > logo.pnm 
			check
			pnmquant 224 logo.pnm > logo_224.pnm
			check
			pnmtoplainpnm logo_224.pnm > drivers/video/logo/logo_linux_clut224.ppm
			check
			rm logo.png logo.pnm logo_224.pnm drivers/video/logo/logo_linux_clut224.c >/dev/null 2>&1
		fi;
		
		EXTRA_CFLAGS=$CROSS_FLAGS
		exec_build "$_kconfig $KERNEL_MAKE_TARGET"          # 编译
		
		if [ -n "$KERNEL_PACK_COMMAND" ]; then
		    $KERNEL_PACK_COMMAND        # 打包内核
		else
		    echo "未定义如何打包内核"
		    exit;
		fi;
        
        if [ ! -e $CACHEDIR/$KERNELFILE.tar.gz ]; then
            echo "内核编译未产生正常的输出：cachedir下的sdk, rootfs和boot应分别包含头文件／module文件和引导映像"
            exit;
        fi;
        unset _cross_prefix
	fi;
	
	deploy sdk $KERNELFILE/sdk /
	deploy rootfs $KERNELFILE/rootfs /
	deploy boot $KERNELFILE/boot /
	
	export CFLAGS="$CFLAGS -I$KERNEL_ROOT/include"
	rm -rf $INSTDIR/lib/modules/$LINUXVER/build $INSTDIR/lib/modules/$LINUXVER/source
}

###########################
# 编译BusyBox
BUSYBOXFILE=busybox-1.27.2
build_busybox()
{
	rm -rf $TEMPDIR/$BUSYBOXFILE
	if [ ! -e $CACHEDIR/$BUSYBOXFILE.tar.gz ]; then
	    unset MY_TOOLCHAIN_FLAGS
		dispenv
		
        prepare $BUSYBOXFILE
		exec_cmd "cd $TEMPDIR/$BUSYBOXFILE"
		[ -f "$PATCHDIR/$BUSYBOXFILE.config" ] || fail "不存在$BUSYBOXFILE.conf的配置，检查bin/products下的common或产品目录"
		exec_cmd "cp $PATCHDIR/$BUSYBOXFILE.config .config"
	
		changeoption .config CONFIG_PREFIX \"$cachedir\"
		changeoption .config CONFIG_SYSROOT \"$SDKDIR\"
		changeoption .config CONFIG_CROSS_COMPILER_PREFIX \"$MY_TARGET-\"
		
        if [ "$FEATURE_UTILLINUX" = "y" ]; then
            for key in $_config_keyword_utillinux; do
                disable_option .config $key
            done;
        fi;

        exec_build
		mkdir -p $cachedir
		exec_build "install"
		
		pack_cache $BUSYBOXFILE
	fi;
	
	deploy rootfs $BUSYBOXFILE /
}

_config_keyword_utillinux="CONFIG_BLOCKDEV CONFIG_MDEV CONFIG_FEATURE_MDEV_CONF CONFIG_FEATURE_MDEV_RENAME CONFIG_FEATURE_MDEV_RENAME_REGEXP CONFIG_FEATURE_MDEV_EXEC CONFIG_FEATURE_MDEV_LOAD_FIRMWARE CONFIG_REV CONFIG_ACPID CONFIG_FEATURE_ACPID_COMPAT CONFIG_BLKID CONFIG_FEATURE_BLKID_TYPE CONFIG_DMESG CONFIG_FEATURE_DMESG_PRETTY CONFIG_FBSET CONFIG_FEATURE_FBSET_FANCY CONFIG_FEATURE_FBSET_READMODE CONFIG_FDFLUSH CONFIG_FDFORMAT CONFIG_FDISK CONFIG_FDISK_SUPPORT_LARGE_DISKS CONFIG_FEATURE_FDISK_WRITABLE CONFIG_FEATURE_AIX_LABEL CONFIG_FEATURE_SGI_LABEL CONFIG_FEATURE_SUN_LABEL CONFIG_FEATURE_OSF_LABEL CONFIG_FEATURE_GPT_LABEL CONFIG_FEATURE_FDISK_ADVANCED CONFIG_FINDFS CONFIG_FLOCK CONFIG_FREERAMDISK CONFIG_FSCK_MINIX CONFIG_MKFS_EXT2 CONFIG_MKFS_MINIX CONFIG_FEATURE_MINIX2 CONFIG_MKFS_REISER CONFIG_MKFS_VFAT CONFIG_GETOPT CONFIG_FEATURE_GETOPT_LONG CONFIG_HEXDUMP CONFIG_FEATURE_HEXDUMP_REVERSE CONFIG_HD CONFIG_HWCLOCK CONFIG_FEATURE_HWCLOCK_LONG_OPTIONS CONFIG_FEATURE_HWCLOCK_ADJTIME_FHS CONFIG_IPCRM CONFIG_IPCS CONFIG_LOSETUP CONFIG_LSPCI CONFIG_LSUSB CONFIG_MKSWAP CONFIG_FEATURE_MKSWAP_UUID CONFIG_MORE CONFIG_MOUNT CONFIG_FEATURE_MOUNT_FAKE CONFIG_FEATURE_MOUNT_VERBOSE CONFIG_FEATURE_MOUNT_HELPERS CONFIG_FEATURE_MOUNT_LABEL CONFIG_FEATURE_MOUNT_NFS CONFIG_FEATURE_MOUNT_CIFS CONFIG_FEATURE_MOUNT_FLAGS CONFIG_FEATURE_MOUNT_FSTAB CONFIG_PIVOT_ROOT CONFIG_RDATE CONFIG_RDEV CONFIG_READPROFILE CONFIG_RTCWAKE CONFIG_SCRIPT CONFIG_SCRIPTREPLAY CONFIG_SETARCH CONFIG_SWAPONOFF CONFIG_FEATURE_SWAPON_PRI CONFIG_SWITCH_ROOT CONFIG_UMOUNT CONFIG_FEATURE_UMOUNT_ALL"
