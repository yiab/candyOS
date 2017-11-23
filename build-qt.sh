#!/bin/bash

QTSRC=qt-everywhere-opensource-src-5.9.2
QTFILE=/home/baiyun/git/ckOS/${QTSRC}.tar.xz


function prepare()
{
mkdir /home/baiyun/git/ckOS/temp_qt
cd /home/baiyun/git/ckOS/temp_qt

rm -rf $QTSRC
tar xf $QTFILE
}

#prepare
cd $QTSRC 

# 不编译的submodules
#qtbase
EXCLUDE_SUBMODULES='
qtsvg
qtdeclarative
qtactiveqt
qtscript
qtmultimedia
qttools
qtxmlpatterns
qttranslations
qtdoc
qtrepotools
qtqa
qtlocation
qtsensors
qtsystems
qtfeedback
qtdocgallery
qtpim
qtconnectivity
qtwayland
qt3d
qtimageformats
qtquick1
qtgraphicaleffects
qtquickcontrols
qtserialbus
qtserialport
qtx11extras
qtmacextras
qtwinextras
qtandroidextras
qtenginio
qtwebsockets
qtwebchannel
qtwebengine
qtcanvas3d
qtwebview
qtquickcontrols2
qtpurchasing
qtcharts
qtdatavis3d
qtvirtualkeyboard
qtgamepad
qtscxml
qtspeech
qtnetworkauth
qtremoteobjects'

SKIP_COMMAND=''
for d in ${EXCLUDE_SUBMODULES}; do
    rm -rf $d 1>/dev/null 2>&1
    SKIP_COMMAND+="-skip $d "
done;
rm -rf config.cache config.log config.opt 1>/dev/null 2>&1

NOMAKE_COMMAND='-nomake examples -nomake tools'
COMPONENT_COMMAND='-gui -widgets -system-libjpeg -system-libpng -glib -zlib -dbus-linked -no-openssl -fontconfig -system-freetype -system-harfbuzz -opengl es2' # -gtk -directfb'
SDKDIR='/home/baiyun/git/ckOS/dist/pi/sdk'
DEVICE_COMMAND='-device linux-rasp-pi3-g++ -device-option CROSS_COMPILE=arm-linux-gnueabihf- -device-option QMAKE_PKG_CONFIG=arm-linux-gnueabihf-pkg-config'
#$SKIP_COMMAND
CMD="./configure -prefix /usr -opensource -confirm-license -release -sysroot $SDKDIR -optimize-size -strip -shared -no-static -pch -ltcg $COMPONENT_COMMAND $DEVICE_COMMAND $NOMAKE_COMMAND $SKIP_COMMAND" 
echo $CMD
$CMD


exit;
#-ccache
#-xplatform devices/linux-rasp-pi3-g++
#atspi...
# -openssl-runtime  QT编译最新的openssl有问题
./configure -prefix /usr -opensource -confirm-license -release /home/baiyun/git/ckOS/dist/pi/sdk -optimize-size




