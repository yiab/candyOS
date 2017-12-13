#!/bin/sh

#################################
# 编译 qt
# qt的源码文件在qt网站下载，用bin/tools/create_basic_qt.sh qt-everywhere-opensource-src-5.9.2.tar.xz生成qt-everywhere-opensource-src-5.9.2-simplify压缩文件
# qt-everywhere-opensource-src-5.9.2-simplify的主要特征是删除了很多暂时不需要的部件（保存在SKIP_COMMAND文件中）
QT_SIMPLIFY_FILE=qt-everywhere-opensource-src-5.9.2-simplify

NOMAKE_COMMAND='-nomake examples -nomake tools -no-compile-examples -no-qml-debug '
COMPONENT_COMMAND='-gui -widgets -system-libjpeg -system-libpng -zlib -dbus-linked -no-openssl -fontconfig -system-freetype -system-harfbuzz -system-sqlite -opengl es2 -glib -gtk' # -directfb'
DEVICE_COMMAND='-device $QT_DEVICE_CONFIG -device-option CROSS_COMPILE=$MY_TARGET- -device-option QMAKE_PKG_CONFIG=$MY_TARGET-pkg-config'
CMD='-prefix /usr -opensource -confirm-license -release -sysroot $SDKDIR -optimize-size -strip -shared -no-static -pch -ltcg '
generate_script  qt     qt/$QT_SIMPLIFY_FILE     \
    '--prescript=set_qt_device_config'  \
    '--prescript=export SKIP_COMMAND=`cat .SKIP_COMMAND`'   \
    "--config=$CMD $COMPONENT_COMMAND $DEVICE_COMMAND $NOMAKE_COMMAND \$SKIP_COMMAND"      \
    --make-before-install   \
    '--install_target=install INSTALL_ROOT=$TEMPDIR/dist'   \
    '--depends=cross_autogen_env libz libjpeg libpng libtiff libbz2 libxml2 fontconfig freetype harfbuzz sqlite udev egl vg gles gtk3 x11_libx11 x11_libxkbfile xcb_xkb'       \
    '--deploy-rootfs=/usr/bin /usr/lib -/usr/lib/cmake -/usr/lib/pkgconfig -/usr/lib/*.la' \
    '--deploy-sdk=/usr/include /usr/lib /usr/share/aclocal'
# -openssl-runtime  QT编译最新的openssl有问题
#INSTALL_ROOT

function set_qt_device_config()
{
    if [ -z $QT_DEVICE_CONFIG ]; then
        echo "必须设置QT_DEVICE_CONFIG环境变量"
        exit;
    fi;
    
    if [ -d "qtbase/mkspecs/$QT_DEVICE_CONFIG" ] || [ -d "qtbase/mkspecs/devices/$QT_DEVICE_CONFIG" ]; then
        echo "使用内置的配置$QT_DEVICE_CONFIG";
    else
        if [ ! -f $TEMPDIR/patch/$QT_DEVICE_CONFIG.tar.* ]; then
            echo "没有找到定制的qt配置$QT_DEVICE_CONFIG"
            exit;
        fi;
        exec_cmd "mkdir -p qtbase/mkspecs/devices/$QT_DEVICE_CONFIG"
        exec_cmd "tar xf $TEMPDIR/patch/$QT_DEVICE_CONFIG.tar.* -C qtbase/mkspecs/devices/$QT_DEVICE_CONFIG"
        echo "使用外置的配置$QT_DEVICE_CONFIG";
    fi;
}
