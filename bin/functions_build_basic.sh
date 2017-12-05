
#############################################################################
# build_libz()
# build_native_libz()
#----------------------------------------------------------------------------
ZLIBFILE="zlib-1.2.11"
generate_script  native_libz     $ZLIBFILE     \
    --build-native                  \
    '--config=--prefix=$DEVDIR/usr '       \
    '--deploy-dev=/ -/usr/lib/*.a'

generate_script  libz     $ZLIBFILE     \
    '--prescript=export CC=$MY_TARGET-gcc'  \
    '--config=--prefix=/usr'       \
    '--deploy-rootfs=/usr/lib -/usr/lib/*.a -/usr/lib/*.la -/usr/lib/pkgconfig' \
    '--deploy-sdk=/usr -/usr/lib/*.a'

#####################
# libpng
PNGFILE="libpng-1.6.32"
generate_script  libpng     $PNGFILE     \
    "--prescript=CPPFLAGS+=' -mfpu=neon -DPNG_ARM_NEON'"     \
    '--config=--host=$MY_TARGET --prefix=/usr --disable-static --enable-arm-neon=yes'       \
    '--deploy-rootfs=/usr/lib -/usr/lib/*.la -/usr/lib/pkgconfig' \
    '--deploy-sdk=/usr/include /usr/lib'   \
    '--depends=cross_autogen_env libz '
    
########################
# libjpeg
JPEGFILE="jpeg-9b"
generate_script  libjpeg     $JPEGFILE     \
    '--config=--host=$MY_TARGET --prefix=/usr --disable-static'       \
    '--deploy-rootfs=/usr/lib -/usr/lib/*.la' \
    '--deploy-sdk=/usr/include /usr/lib'

###########################
# tiff-4.0.8
LIBTIFF=tiff-4.0.8
generate_script  libtiff     $LIBTIFF     \
    '--config=--host=$MY_TARGET --prefix=/usr --disable-static --enable-ccitt --enable-packbits --enable-lzw --enable-thunder --enable-next --enable-logluv --enable-zlib --enable-jpeg --with-x'       \
    '--depends=libz libjpeg'    \
    '--deploy-rootfs=/usr/bin /usr/lib -/usr/lib/*.la -/usr/lib/pkgconfig' \
    '--deploy-sdk=/usr/include /usr/lib'

#################################
# bzip2-1.0.6.tar.gz
BZ2FILE="bzip2-1.0.6"
generate_script  libbz2     $BZ2FILE     \
    '--patch=bzip2-shared-build.patch'  \
    '--install_target=install CC=$MY_TARGET-gcc PREFIX=$cachedir/usr'  \
    '--deploy-rootfs=/usr/bin /usr/lib' \
    '--deploy-sdk=/usr/include /usr/lib'

#################################
# 编译libxml2
# https://git.gnome.org//browse/libxml2/
LIBXML2FILE=libxml2-2.9.7
generate_script  libxml2     $LIBXML2FILE     \
    '--prescript=autoreconf -v --install --force'                                \
    '--config=--host=$MY_TARGET --prefix=/usr --disable-static --without-debug --without-python --without-mem-debug --without-icu --without-html --without-http --without-run-debug --without-coverage --without-history --without-ftp --disable-rpath'      \
    '--depends=cross_autogen_env libz'       \
    '--deploy-rootfs=/usr/bin /usr/lib -/usr/lib/cmake -/usr/lib/pkgconfig -/usr/lib/*.la' \
    '--deploy-sdk=/usr/include /usr/lib /usr/share/aclocal'
    
##############################
# 编译 openssl
OPENSSLFILE=openssl-1.1.0g
generate_script  openssl     $OPENSSLFILE     \
    '--prescript=./Configure linux-armv4 --cross-compile-prefix=${MY_TARGET}- --prefix=/usr --release threads zlib-dynamic shared $CFLAGS $LDFLAGS -lz' \
    --inside  --make-before-install \
    '--depends=libz'    \
    '--deploy-rootfs=/usr/bin /usr/lib  /usr/ssl -/usr/lib/*.a -/usr/lib/pkgconfig -/usr/lib/*.la' \
    '--deploy-sdk=/usr/include /usr/lib -/usr/lib/*.a'

generate_alias libcrypto openssl
generate_alias libssl openssl

#################################
# Linux-PAM-1.3.0
LIBPAMFILE="Linux-PAM-1.3.0"
generate_script  libpam     $LIBPAMFILE     \
    '--config=-host=$MY_TARGET --prefix=/usr --libdir=/usr/lib --sysconfdir=/usr/etc --sbindir=/usr/sbin --includedir=/usr/include/security --disable-static --enable-shared'        \
    '--deploy-rootfs=/usr -/usr/include -/usr/share/doc -/usr/share/man -/usr/lib/*.la -/usr/lib/security/*.la'     \
    '--deploy-sdk=/usr -/usr/etc -/usr/share -/usr/sbin -/usr/lib/security/*.la'

#################################
# libcap-2.25.tar.gz
LIBCAP2FILE="libcap-2.25"
generate_script  libcap2     $LIBCAP2FILE     \
    '--depends=libpam'              \
    '--prescript=make CC=${MY_TARGET}-gcc BUILD_CC=gcc'  \
    '--install_target=install RAISE_SETFCAP=no prefix=/usr lib=lib'  \
    '--deploy-rootfs=/usr/sbin /usr/lib -/usr/lib/*.a ' \
    '--deploy-sdk=/usr/include /usr/lib -/usr/lib/*.a'
    
