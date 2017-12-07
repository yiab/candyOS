# 需要主机安装的软件包
# NATIVE_PREREQUIRST

# chanp

# 指定交叉工具链
export TOOLCHAIN_FILE=arm-rpi-4.9.3-linux-gnueabihf
export TOOLCHAIN_FLAGS="-march=armv8-a -mtune=cortex-a53 -mfpu=crypto-neon-fp-armv8 -mfloat-abi=hard"

#export MY_CROSS_FLAGS=" -march=armv7-a -mtune=cortex-a8 -mfpu=neon -mfloat-abi=softfp -fno-tree-vectorize -O2"

#必须明确的内核编译变量
##KERNELPATCH="linux-ecs.patch"
#LOGOFILE="pi_logo.png"
#LOGOFILE="product/pi/logo.png"
KERNELFILE="rpi-linux"
KERNELCONFIG="bcm2709_defconfig"
KERNEL_COMPILE_ARGS="ARCH=arm KERNEL=kernel7"
KERNEL_MAKE_TARGET="zImage modules dtbs"
LINUXVER=4.9.56-v7
pack_kernel_pi()        # 在kernel源码目录下，源码编译完成后，发布到CACHEDIR，并打包为$CACHEDIR/$KERNELFILE.tar.gz
{
    # 当前目录在源码编译目录
    # cachedir, rootfs和boot应分别包含头文件／module文件和引导映像"
    #### 1. boot树莓派特有的安装内容
    exec_cmd "mkdir -p $cachedir/boot/overlays $cachedir/rootfs $cachedir/sdk"
    exec_cmd "cp -rf arch/arm/boot/dts/*.dtb $cachedir/boot"
    exec_cmd "cp -rf arch/arm/boot/dts/overlays/*.dtb* $cachedir/boot/overlays"
    exec_cmd "cp -rf arch/arm/boot/dts/overlays/README $cachedir/boot/overlays"
    exec_cmd "sudo scripts/mkknlimg arch/arm/boot/zImage $cachedir/boot/kernel7.img"
    
    #### 2. sdk, 头文件
    exec_cmd "make ARCH=arm CROSS_COMPILE=$MY_TARGET- INSTALL_HDR_PATH=$cachedir/sdk headers_install"
    
    #### 3. rootfs, lib module
    exec_cmd "make ARCH=arm CROSS_COMPILE=$MY_TARGET- INSTALL_MOD_PATH=$cachedir/rootfs modules_install"
        
    exec_cmd "cd $cachedir/rootfs/lib/modules/*"
    exec_cmd "rm -f build source"
    pack_cache $KERNELFILE
}

export PRODUCT_EGL='rpi_userland'
export PRODUCT_GLES='rpi_userland'
export PRODUCT_OPENVG='rpi_userland'

construct_pi()
{
    #准备mkimage
    #exec_cmd "tar xf $DLDIR/tools/mkimage.tar.bz2 -C $TEMPDIR"
    #exec_cmd "cp $TEMPDIR/mkimage/* $SDKDIR/bin"
    #exec_cmd "rm -rf $TEMPDIR/mkimage" 
    # 准备交叉工具链

	init_rootfs
	build_kernel
	build_busybox
	run_build rpi_userland      # GPU驱动
	
	#export ADDITION_CFLAGS="-I$SDKDIR/opt/vc/include " #-march=armv8-a -mtune=cortex-a53 -mfpu=crypto-neon-fp-armv8"
	#export ADDITION_LDFLAGS="-L$SDKDIR/opt/vc/lib"
    #export ADDITION_PKG_CONFIG_PATH="$SDKDIR/opt/vc/lib/pkgconfig:$ADDITION_PKG_CONFIG_PATH"
    
    run_build  gtk3 libnss libjpeg libpng x11_twm  x11_xinit cairo
    run_build   xf86_input_evdev xf86_video_fbturbo xf86_video_fbdev
    run_build   xorg_server shared_mime_info libtiff 
    #run_build metacity
    
    #run_build gtk3
    #run_build   directfb
    dispenv
    exit;
}

NATIVE_PREREQUIRST+=' cmake '
RPI_USERLAND=userland
generate_script     rpi_userland  $RPI_USERLAND                                   \
    '--patch=userland_no_march_flag.patch'                                        \
    '--script=./buildme $TEMPDIR/dist'                                            \
    '--script=cd $TEMPDIR/dist'                                                   \
    '--script=sudo mkdir -p usr'                                                       \
    '--script=sudo cp -Ra opt/vc/include/ opt/vc/lib usr'                              \
    '--deploy-sdk=/'                                 \
    '--deploy-rootfs=/etc /opt -/opt/vc/src/'

# 所有包编译完成
post_install_pi()
{
	exec_cmd "sudo cp $BUILDINDIR/wvdial.conf $INSTDIR/etc"
	exec_cmd "sudo cp $BUILDINDIR/ppp-options $INSTDIR/etc/ppp/options"
}

