#!/bin/sh

# 关键变量1. ROOTDIR
ROOTDIR=`(cd ".."; /bin/pwd)`

# 关键变量2. PRODUCT
KNOWN_PRODUCT="fids pi"
for i in $KNOWN_PRODUCT; do
	if [ "$i" = "$1" ]; then
		PRODUCT=$1
		break;
	fi;
done;
if [ -z $PRODUCT ]; then
	echo "Usage:	./burn_image.sh [Platform-alias]"
	echo "All Known products are :"
	echo "    $KNOWN_PRODUCT"
	exit;
fi;
echo "======TO BURN: $PRODUCT"

export PATH=$ROOTDIR/dist/$PRODUCT/tools/usr/bin:$ROOTDIR/dist/$PRODUCT/tools/bin:$PATH

cd $ROOTDIR/dist/$PRODUCT/out
./burn.sh
