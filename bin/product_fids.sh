################################################################################
# PRODUCT NAME        : fids
# PRODUCT DESCRIPTION : 5G航显板载设备，使用rk3288开发板
################################################################################

# 需要主机安装的软件包
NATIVE_PREREQUIRST+=" libssl-dev "

#必须明确的内核编译变量
#XLOADERFILE=" "
#XLOADERCONFIG=""
#UBOOTFILE=""
#UBOOTCONFIG=""
#UBOOTPATCH=""
KERNELFILE="firefly-rk3288-kernel-RELOAD"
KERNELCONFIG="cking-fids_defconfig"
#KERNELCONFIG="firefly-rk3288-reload-linux_defconfig"
KERNEL_MAKE_TARGET="firefly-rk3288-reload.img"
KERNEL_PACK_COMMAND="pack_kernel_fids"
#KERNELPATCH=""
#LOGOFILE="pi_logo.png"
LINUXVER=3.10.0
#LOGOFILE="product/pi/logo.png"
BUSYBOXCONFIG="Busybox-1.21.1-config"
concurrent_make="-j 20"

FEATURE_UTILLINUX=y         # 包含utillinux，可以裁剪busybox

source ./init_etc.sh

##########################################################################################
# 每个product必须定义的内容
##########################################################################################

construct_fids()
{
    build_native_rockchiptools           # 准备rockchip提供的工具
    build_cross_toolchain       # 准备交叉编译器
    
	init_rootfs
	build_kernel
	
	prepare_glibc               # 准备一个新的含glibc的编译器
	export MY_TARGET=arm-linux-gnueabihf
	build_busybox
	prepare_native_autoconf
#	prepare_native_python2_7        # python编译还没有完成

    # Mali Graphics SDK
    build_mali_graphics_sdk
    build_mali_graphics_driver
    
	# e2fs
	build_e2fsprogs
	build_systemd       # 原来的udev，动态管理设备(即插即用)
	
	# X11
	
	restore_native0
}

# 所有包编译完成
post_install_fids()
{
    # strip all
    echo "Strip all ... "
    find $INSTDIR/bin -name '*' -exec $MY_TARGET-strip {} \; 1>/dev/null 2>&1
    
    # 后处理
	echo "Generating linuxroot.img!"
	
	# 获得rootfs总大小
	exec_cmd "cd $INSTDIR"
	rootfs_size_1k=`du -sk | awk '{print $1;}'`
	echo "ROOTFS Size: $rootfs_size_1k KB"
	check
    let rootfs_size_1k=rootfs_size_1k+1000*50                   #　最少50M剩余空间
	let rootfs_size_1k=(rootfs_size_1k/4000+1)*4000             # 4M取整
	
	_out=$ROOTDIR/dist/$PRODUCT/out
	
	####################创建initrd.img############
    # 引用官方Ubuntu image的布局，使用boot分区启动
    sudo rm -rf $_out 1>/dev/null 2>&1
    exec_cmd "mkdir -p $_out"
    prepare initrd-better
    exec_cmd "sudo chown -R root:root ."
    exec_cmd "sudo make"
    exec_cmd "cp ../initrd.img $BOOTDIR"
    exec_cmd "cd $BOOTDIR"
    exec_cmd "mkbootimg --kernel zImage --ramdisk initrd.img --second resource.img -o $_out/boot.img"       
   
	# 产生image
	export PATH=/sbin:$PATH
	exec_cmd "dd if=/dev/zero of=$TEMPDIR/linuxroot.img bs=1K count=$rootfs_size_1k"
	exec_cmd "mkfs.ext4 -F -L linuxroot $TEMPDIR/linuxroot.img"
	exec_cmd "tune2fs -c -1 -i 0 $TEMPDIR/linuxroot.img"            # 关闭定时文件检查
	exec_cmd "mkdir $TEMPDIR/mountpoint"
	exec_cmd "sudo mount -t ext4 $TEMPDIR/linuxroot.img $TEMPDIR/mountpoint"
	exec_cmd "sudo cp -Ra $INSTDIR/* $TEMPDIR/mountpoint"
#	exec_cmd "sync"
	exec_cmd "sudo umount $TEMPDIR/mountpoint"
	exec_cmd "mv $TEMPDIR/linuxroot.img $_out"
	
	# 产生parameter文件
    cat << _MY_EOF_ > $_out/parameter	
FIRMWARE_VER:5.0.0
MACHINE_MODEL:rk3288
MACHINE_ID:007
MANUFACTURER:RK3288
MAGIC: 0x5041524B
ATAG: 0x60000800
MACHINE: 3288
CHECK_MASK: 0x80
PWR_HLD: 0,0,A,0,1
#KERNEL_IMG: 0x62008000
#FDT_NAME: rk-kernel.dtb
#RECOVER_KEY: 1,1,0,20,0
CMDLINE:console=tty0 console=ttyS2 androidboot.selinux=permissive androidboot.hardware=rk30board androidboot.console=ttyS2 root=/dev/block/mtd/by-name/linuxroot rw rootfstype=ext4 init=/sbin/init  mtdparts=rk29xxnand:0x00008000@0x00002000(resource),0x00008000@0x0000A000(boot),0x00002000@0x00012000(misc),0x0001a000@0x00014000(backup),-@0x0002e000(linuxroot)
_MY_EOF_

    cat << _MY_EOF_ > $_out/burn.sh

# 老的parameter
#CMDLINE:console=tty0 console=ttyS2 androidboot.selinux=permissive androidboot.hardware=rk30board androidboot.console=ttyS2 root=/dev/block/mtd/by-name/linuxroot rw rootfstype=ext4 init=/sbin/init initrd=0x62000000,0x00800000 mtdparts=rk29xxnand:0x00008000@0x00002000(resource),0x00008000@0x0000A000(boot),0x00002000@0x00012000(misc),0x0001a000@0x00014000(backup),-@0x0002e000(linuxroot)

    
#!/bin/sh
    # 老的烧写脚本
    #sudo rkflashkit flash @boot boot.img @linuxroot linuxroot.img reboot
    echo "Flashing <parameter>..."
    upgrade_tool DI -p parameter
    
    echo "Flashing <boot.img>..."
    upgrade_tool DI -b boot.img
    
#    echo "Flashing <linuxroot.img>..."
#    upgrade_tool DI -s linuxroot.img
_MY_EOF_
    chmod +x $_out/burn.sh
    
    unset _out
}

########################################################################
# 以下是内部函数
ROCKCHIP_MKBOOTIMG_FILE=rockchip-mkbootimg
ROCKCHIP_AFPTOOLS_FILE=rk2918_tools
ROCKCHIP_LINUXTOOLS_FILE=Linux_Upgrade_Tool_v1.2
ROCKCHIP_FLASHTOOL_FILE=rkflashtool_rk3066
compile_native_rockchiptools()
{
    reset_env
	if [ ! -e $CACHEDIR/native_rockchiptools.tar.gz ]; then
		rm -rf $TEMPDIR/$ROCKCHIP_MKBOOTIMG_FILE $TEMPDIR/$ROCKCHIP_AFPTOOLS_FILE $TEMPDIR/$ROCKCHIP_LINUXTOOLS_FILE 1>/dev/null 2>&1
		
		# mkbootimg用于编译内核的时候，生成img
        prepare $ROCKCHIP_MKBOOTIMG_FILE
        exec_build
        strip * 1>/dev/null 2>/dev/null
		exec_cmd "make install PREFIX=usr DESTDIR=$CACHEDIR/native_rockchip"
		
		# afptool用于生成/解压统一镜像upgrade.img
        prepare $ROCKCHIP_AFPTOOLS_FILE
        exec_build
        strip * 1>/dev/null 2>/dev/null
		exec_cmd "cp afptool img_maker img_unpack mkkrnlimg pack_all.sh $CACHEDIR/native_rockchip/usr/bin"
		
		# upgrade_tool用于烧写统一镜像(没有源码! FROM: http://wiki.t-firefly.com/index.php/Firefly-RK3288/Flash_image 该链接中的百度网盘 http://pan.baidu.com/s/1mgmlMQ0)
		# 烧写统一固件 update.img：
		#   sudo upgrade_tool uf update.img
		# 烧写分区镜像：
		#   sudo upgrade_tool di -b /path/to/boot.img
		#   sudo upgrade_tool di -k /path/to/kernel.img
		#   sudo upgrade_tool di -s /path/to/system.img
		#   sudo upgrade_tool di -r /path/to/recovery.img
		#   sudo upgrade_tool di -m /path/to/misc.img
		#   sudo upgrade_tool di resource /path/to/resource.img
		#   sudo upgrade_tool di -p paramater   #烧写 parameter
		#   sudo upgrade_tool ul bootloader.bin # 烧写 bootloader
        prepare $ROCKCHIP_LINUXTOOLS_FILE
        strip * 1>/dev/null 2>/dev/null
        exec_cmd "cp upgrade_tool config.ini $CACHEDIR/native_rockchip/usr/bin"

        # rkflashtool用于烧写镜像(FROM:  https://github.com/Galland/rkflashtool_rk3066)
        prepare $ROCKCHIP_FLASHTOOL_FILE
        exec_build
        strip * 1>/dev/null 2>/dev/null
		exec_cmd "cp rkflashtool flash_kernel.sh $CACHEDIR/native_rockchip/usr/bin"
        
        # 还有一个rkflashtool (https://github.com/cyteen/rk3066-rkflashtool) ，好看，但是不好用（速度太慢）
        
		exec_cmd "cd $CACHEDIR/native_rockchip"
		exec_cmd "tar czf $CACHEDIR/native_rockchiptools.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/native_rockchip $TEMPDIR/$ROCKCHIP_MKBOOTIMG_FILE $TEMPDIR/$ROCKCHIP_AFPTOOLS_FILE $TEMPDIR/$ROCKCHIP_LINUXTOOLS_FILE $TEMPDIR/$ROCKCHIP_FLASHTOOL_FILE"
	fi;
	
	DEPLOY_DIST=""
	PRE_REMOVE_LIST=""
	REMOVE_LIST=""	
	deploy_tools native_rockchiptools
}
build_native_rockchiptools()
{
	run_task "构建Native_rockchiptools" "compile_native_rockchiptools"
}

MALI_SDK_FILE=Mali_OpenGL_ES_SDK_v2.4.4
compile_mali_graphics_sdk()
{
	if [ ! -e $CACHEDIR/$MALI_SDK_FILE.tar.gz ]; then
		rm -rf $TEMPDIR/$MALI_SDK_FILE
		prepare $MALI_SDK_FILE
		
		mkdir -p build
		exec_cmd "cd build"
		export TARGET=arm
		export TOOLCHAIN_ROOT=$MY_TARGET-

		exec_cmd "cmake .."
		exec_build "install"

        # Mali SDK 完全要自己打包
        export SDK_ROOT="$TEMPDIR/$MALI_SDK_FILE"
        exec_cmd "mkdir -p $CACHEDIR/mali_sdk"
        exec_cmd "cd $CACHEDIR/mali_sdk"
        exec_cmd "mkdir -p opt/mali usr/include"
        exec_cmd "cp -Ra $SDK_ROOT/bin_arm/* $CACHEDIR/mali_sdk/opt/mali"
        exec_cmd "cp -Ra $SDK_ROOT/inc/* $CACHEDIR/mali_sdk/usr/include"

		exec_cmd "cd $CACHEDIR/mali_sdk"
		exec_cmd "tar czf $CACHEDIR/$MALI_SDK_FILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/mali_sdk $TEMPDIR/$MALI_SDK_FILE"
		
		unset TARGET
		unset TOOLCHAIN_ROOT
		unset SDK_ROOT
	fi;
	
	DEPLOY_DIST="/opt"
	PRE_REMOVE_LIST=""
	REMOVE_LIST=""	
	deploy_tools $MALI_SDK_FILE
}
build_mali_graphics_sdk()
{
	run_task "构建$MALI_SDK_FILE" "compile_mali_graphics_sdk"
}

#MALI_DRIVER_FILE=mali-t76x_r12p0_linux     # 这个版本需要升级glibc
MALI_DRIVER_FILE=mali-t76x_r6p0_linux
compile_mali_graphics_driver()
{
	if [ ! -e $CACHEDIR/$MALI_DRIVER_FILE.tar.gz ]; then
		rm -rf $TEMPDIR/$MALI_DRIVER_FILE
		prepare $MALI_DRIVER_FILE
		
		# 选择某个版本的EGL Driver
		export EGL_VERSION=fbdev

        # Mali Driver 打包
        exec_cmd "mkdir -p $CACHEDIR/mali_driver/usr/lib"
        exec_cmd "cp -Ra $TEMPDIR/$MALI_DRIVER_FILE/$EGL_VERSION/* $CACHEDIR/mali_driver/usr/lib"

		exec_cmd "cd $CACHEDIR/mali_driver"
		exec_cmd "tar czf $CACHEDIR/$MALI_DRIVER_FILE.tar.gz ."
		exec_cmd "rm -rf $CACHEDIR/mali_driver $TEMPDIR/$MALI_DRIVER_FILE"
	fi;
	
	DEPLOY_DIST="/usr/lib"
	PRE_REMOVE_LIST=""
	REMOVE_LIST=""	
	deploy_tools $MALI_DRIVER_FILE
}
build_mali_graphics_driver()
{
	run_task "构建$MALI_DRIVER_FILE" "compile_mali_graphics_driver"
}

CROSSTOOLCHAIN_FILE=arm-eabi-4.8
compile_cross_toolchain()
{
	if [ ! -e $CACHEDIR/$CROSSTOOLCHAIN_FILE.tar.gz ]; then
		rm -rf $TEMPDIR/$CROSSTOOLCHAIN_FILE
		prepare $CROSSTOOLCHAIN_FILE
		
		exec_cmd "tar czf $CACHEDIR/$CROSSTOOLCHAIN_FILE.tar.gz ."
		exec_cmd "rm -rf $TEMPDIR/$CROSSTOOLCHAIN_FILE"
	fi;
	
	deploy_tools $CROSSTOOLCHAIN_FILE
	
	export MY_TARGET=arm-eabi
}
build_cross_toolchain()
{
	run_task "复制toolchain-$CROSSTOOLCHAIN_FILE" "compile_cross_toolchain"
}

# 在kernel源码目录下，源码编译完成后，发布到CACHEDIR，并打包为$CACHEDIR/$KERNELFILE.tar.gz
pack_kernel_fids()             
{
    # 当前目录在源码编译目录
    ####################提取modules############
    exec_cmd "make ARCH=arm CROSS_COMPILE=$MY_TARGET- modules"
    exec_cmd "make ARCH=arm CROSS_COMPILE=$MY_TARGET- INSTALL_MOD_PATH=$CACHEDIR/$KERNELFILE/rootfs modules_install"
    exec_cmd "rm -f $CACHEDIR/$KERNELFILE/rootfs/lib/modules/$LINUXVER/build $CACHEDIR/$KERNELFILE/rootfs/lib/modules/$LINUXVER/source" 

    ####################提取header############
    exec_cmd "make ARCH=arm CROSS_COMPILE=$MY_TARGET- INSTALL_HDR_PATH=$CACHEDIR/$KERNELFILE/sdk headers_install"
    
    ####################创建initrd.img############
    # 引用官方Ubuntu image的布局，使用boot分区启动
    exec_cmd "mkdir $CACHEDIR/$KERNELFILE/boot"
    exec_cmd "cp arch/arm/boot/zImage resource.img $CACHEDIR/$KERNELFILE/boot"
    exec_cmd "cd $CACHEDIR/$KERNELFILE/boot"
     
    ####################cache 打包############
    exec_cmd "cd $CACHEDIR/$KERNELFILE"
    exec_cmd "tar czf $CACHEDIR/$KERNELFILE.tar.gz ."
    exec_cmd "cd $CACHEDIR/"
    exec_cmd "rm -rf $CACHEDIR/$KERNELFILE"
}

PRECOMP_GLIBC_FILE=arm-linux-gnueabihf-libc
copy_glibc()
{
    if [ ! -e $CACHEDIR/$PRECOMP_GLIBC_FILE.tar.gz ]; then
		rm -rf $TEMPDIR/$PRECOMP_GLIBC_FILE
		prepare $PRECOMP_GLIBC_FILE
		
		exec_cmd "tar czf $CACHEDIR/$PRECOMP_GLIBC_FILE.tar.gz ."
		exec_cmd "rm -rf $TEMPDIR/$PRECOMP_GLIBC_FILE"
	fi;
	
	DEPLOY_DIST="/lib"
	PRE_REMOVE_LIST=""
	REMOVE_LIST="/lib/*.o /lib/*.a"	
	deploy $PRECOMP_GLIBC_FILE
}
prepare_glibc()
{
	run_task "复制预编译的glibc_$PRECOMP_GLIBC_FILE" "copy_glibc"
}

strip_all()
{
	echo "Striping ..."
	find $INSTDIR/ -name '*' -exec $MY_TARGET-strip --strip-unneeded --strip-debug {} \; 1>/dev/null 2>&1
}
