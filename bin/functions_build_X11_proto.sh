#!/bin/bash

#  All proto for X11
#  https://www.x.org/archive/individual/proto/
#
# List here:
PROTO_FILES=""
PROTO_FILES+=" x11_applewmproto=applewmproto-1.4.2"         # 1.applewmproto
PROTO_FILES+=" x11_bigreqsproto=bigreqsproto-1.1.2"         # 2.bigreqsproto
PROTO_FILES+=" x11_compositeproto=compositeproto-0.4.2"     # 3.compositeproto
PROTO_FILES+=" x11_damageproto=damageproto-1.2.1"           # 4.damageproto
PROTO_FILES+=" x11_dmxproto=dmxproto-2.3.1"                 # 5.dmxproto
PROTO_FILES+=" x11_dri2proto=dri2proto-2.8"                 # 6.dri2proto
PROTO_FILES+=" x11_dri3proto=dri3proto-1.0"                 # 7.dri3proto
PROTO_FILES+=" x11_evieext=evieext-1.1.1"                   # 8.evieext
PROTO_FILES+=" x11_fixesproto=fixesproto-5.0"               # 9.fixesproto
PROTO_FILES+=" x11_fontcacheproto=fontcacheproto-0.1.3"     # 10.fontcacheproto
PROTO_FILES+=" x11_fontsproto=fontsproto-2.1.3"             # 11.fontsproto
PROTO_FILES+=" x11_glproto=glproto-1.4.17"                  # 12.glproto
PROTO_FILES+=" x11_inputproto=inputproto-2.3.2"             # 13.inputproto
PROTO_FILES+=" x11_kbproto=kbproto-1.0.7"                   # 14.kbproto
PROTO_FILES+=" x11_presentproto=presentproto-1.1"           # 15.presentproto
PROTO_FILES+=" x11_printproto=printproto-1.0.5"             # 16.printproto
PROTO_FILES+=" x11_randrproto=randrproto-1.5.0"             # 17.randrproto
PROTO_FILES+=" x11_recordproto=recordproto-1.14.2"          # 18.recordproto
PROTO_FILES+=" x11_renderproto=renderproto-0.11.1"          # 19.renderproto
PROTO_FILES+=" x11_resourceproto=resourceproto-1.2.0"       # 20.resourceproto
PROTO_FILES+=" x11_scrnsaverproto=scrnsaverproto-1.2.2"     # 21.scrnsaverproto
PROTO_FILES+=" x11_trapproto=trapproto-3.4.3"               # 22.trapproto
PROTO_FILES+=" x11_videoproto=videoproto-2.3.3"             # 23.videoproto
PROTO_FILES+=" x11_windowswmproto=windowswmproto-1.0.4"     # 24.windowswmproto
PROTO_FILES+=" x11_xcmiscproto=xcmiscproto-1.2.2"           # 25.xcmiscproto
PROTO_FILES+=" x11_xextproto=xextproto-7.3.0"               # 26.xextproto
PROTO_FILES+=" x11_xf86bigfontproto=xf86bigfontproto-1.2.0" # 27.xf86bigfontproto
PROTO_FILES+=" x11_xf86dgaproto=xf86dgaproto-2.1"           # 28.xf86dgaproto
PROTO_FILES+=" x11_xf86driproto=xf86driproto-2.1.1"         # 29.xf86driproto
PROTO_FILES+=" x11_xf86miscproto=xf86miscproto-0.9.3"       # 30.xf86miscproto
PROTO_FILES+=" x11_xf86rushproto=xf86rushproto-1.1.2"       # 31.xf86rushproto
PROTO_FILES+=" x11_xf86vidmodeproto=xf86vidmodeproto-2.3.1" # 32.xf86vidmodeproto
PROTO_FILES+=" x11_xineramaproto=xineramaproto-1.2.1"       # 33.xineramaproto
PROTO_FILES+=" x11_xproto=xproto-7.0.31"                    # 34.xproto
PROTO_FILES+=" x11_xproxymanagementprotocol=xproxymanagementprotocol-1.0.3" # 35.xproxymanagementprotocol

for p in $PROTO_FILES; do
    pkgName=${p%%=*}
    pkgFile=${p#*=};
    generate_script  $pkgName     x11/$pkgFile           \
        '--prescript=autoreconf -v --install --force'       \
        '--config=--prefix=/usr --host=$MY_TARGET'          \
        '--deploy-sdk="/"'                                  \
        '--depends=x11_util_macros'
done;
