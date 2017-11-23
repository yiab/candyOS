#!/bin/sh

mkdir -p /mnt/share
mount -t nfs 192.168.8.31:/home/baiyun/beagleboard /mnt/share -o nolock -o vers=3 &
