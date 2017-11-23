#!/bin/sh

# 基本的配置文件
init_basic_etc()
{
	if [[ $INSTDIR"empty" == "empty" ]]; then
		exit 1;
	fi;
	
	mkdir -p $INSTDIR || exit 1;
	
	# /etc/inittab
	cat << _MY_EOF_ > $INSTDIR/etc/inittab
::sysinit:/etc/init.d/rcS
::restart:/sbin/init
#::askfirst:-/bin/sh
::respawn:-/bin/sh
::ctrlaltdel:/sbin/reboot
::shutdown:/etc/shutdown-task.sh
_MY_EOF_

	# /etc/shutdown-task.sh
	cat << _MY_EOF_ > $INSTDIR/etc/shutdown-task.sh
#!/bin/sh
clear
echo "Closing Services"
pkill udev
pkill syslogd
pkill pulseaudio
pkill X
pkill dbus-daemon

echo "Save sound state"
/usr/sbin/alsactl store -f /etc/asound.state

echo "Closing swap space if any..."
/sbin/swapoff -a

echo "Umount All devices..."
/bin/umount -a -n
[ -e /etc/mtab ] && /bin/rm -rf /etc/mtab
/bin/umount / -r -n

_MY_EOF_
	exec_cmd "sudo chmod a+x $INSTDIR/etc/shutdown-task.sh"

	# /etc/fstab
	cat << _MY_EOF_ > $INSTDIR/etc/fstab
#device			mount-point     type            options         dump    fsck order
#------------------------------------------------------------
/dev/mmcblk0p1  /               ext3            errors=remount-ro	0	1
#proc			/proc           proc			defaults		0		0
#sysfs			/sys            sysfs			defaults		0		0
#tmpfs			/run            tmpfs			defaults		0		0
#devtmpfs       /dev            devtmpfs		defaults		0		0
_MY_EOF_

	# /etc/group
	cat << _MY_EOF_ > $INSTDIR/etc/group
root:x:0:root
_MY_EOF_

	# /etc/passwd
	cat << _MY_EOF_ > $INSTDIR/etc/passwd
root:x:0:0:root:/home/root:/bin/sh
_MY_EOF_

#	装了udev以后，不需要mdev了	
#	# /etc/mdev.conf
#	> $INSTDIR/etc/mdev.conf
	
	# /etc/profile
	cat << _MY_EOF_ > $INSTDIR/etc/profile
# /etc/profile: system-wide .profile file for the Bourne shells
echo "Processing /etc/profile... "

# Set user path
export PATH=/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin
export LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:/lib
export HOME="/home/root"
alias ls="ls --color"
export PS1='\u@\w\\\$ '

if [ -d /etc/profile.d ]; then
	for i in /etc/profile.d/* ; do
		. \$i
	done
	unset i
fi

source /etc/default/locale
export PATH PS1 QTDIR EDITOR TERM
echo "Done"

echo "Start Application Product ... "
. /etc/autostart &

umask 022
echo
_MY_EOF_

	mkdir -p $INSTDIR/etc/profile.d
	chmod a+x $INSTDIR/etc/profile
	
	# 配置启动任务总入口 /etc/init.d/rcS
	mkdir -p $INSTDIR/etc/init.d/
	cat << _MY_EOF_ > $INSTDIR/etc/init.d/rcS
#!/bin/sh
PATH=/usr/sbin:/usr/bin:/sbin:/bin
export PATH

for i in \`ls /etc/init.d/[0-9][0-9].*\` ; do
	echo "Executing \$i..."
	/bin/sh \$i
done;
_MY_EOF_
	chmod a+x $INSTDIR/etc/init.d/rcS

	# 添加启动任务10.Mount-All
	cat << _MY_EOF_ > $INSTDIR/etc/init.d/10.SysInit
#!/bin/sh
/bin/rm -rf /etc/mtab
/bin/mount -a

echo "-------------Mounting Basic FileSystem-----------------"
mount -t tmpfs tmpfs /run
mount -t tmpfs tmpfs /tmp
mount -t sysfs sysfs /sys
mount -t proc proc /proc
#mount -t devtmpfs devtmpfs /dev

#mkdir -p /dev/pts /dev/shm
#mount -t devpts none /dev/pts
#mount -t tmpfs tmpfs /dev/shm

mkdir -p /var/run
mount -t tmpfs tmpfs /var/run

echo "Setting hostname..."
hostname ECS-Device 
echo "Starting syslogd..."
syslogd 

_MY_EOF_

#	# 添加启动任务20.Start-mdev  --->  依赖于 10.Mount-All
#	cat << _MY_EOF_ > $INSTDIR/etc/init.d/20.Start-mdev
##Start mdev
#echo "-------------Starting mdev-----------------"
##!/bin/sh
#/bin/mount -n -t tmpfs tmpfs /tmp
#[ -e /etc/mtab ] && /bin/rm /etc/mtab
#/bin/touch /etc/mtab
#/bin/mount -a
#
#/sbin/sysctl -w kernel.hotplug=/sbin/mdev
#mdev -s
#
#/bin/mkdir -p /dev/pts /dev/bus
#/bin/mount -n -t devpts devpts /dev/pts
#/bin/mount --bind /sys/bus /dev/bus
#_MY_EOF_

	# 添加启动任务30.Start-Network  --->  最好是mdev启动以后再运行
	cat << _MY_EOF_ > $INSTDIR/etc/init.d/30.Start-Network
echo "-------------Starting Network--------------"
/etc/init.d/networking restart

_MY_EOF_
	
#	cat << _MY_EOF_ > $INSTDIR/etc/init.d/99.sync-all
#sync
#_MY_EOF_

	# /etc/default/locale
	mkdir -p $INSTDIR/etc/default
	cat << _MY_EOF_ > $INSTDIR/etc/default/locale
LC_ALL="zh_CN.UTF-8"       
LANG="zh_CN.UTF-8"         
LANGUAGE="zh_CN.UTF-8" 

export LC_ALL LANG LANGUAGE
_MY_EOF_
}

busybox_init_network()
{
	if [[ $INSTDIR"empty" == "empty" ]]; then
		echo "Please set INSTDIR variable"
		exit 1;
	fi;
	echo "......0. Netbase : protocols, services, hosts, networks"
	sudo tar axf $PATCHDIR/netbase-from-ubuntu.tar* -C $INSTDIR	|| exit 1;	# /etc/protocols和services两个文件
  
  	cat  > $INSTDIR/etc/hosts <<_MY_EOF_ || exit 2;
	127.0.0.1	localhost
	::1		localhost ip6-localhost ip6-loopback
	fe00::0		ip6-localnet
	ff00::0		ip6-mcastprefix
	ff02::1		ip6-allnodes
	ff02::2		ip6-allrouters
_MY_EOF_

	cat > $INSTDIR/etc/networks <<_MY_EOF_ || exit3;
	default		0.0.0.0
	loopback	127.0.0.0
	link-local	169.254.0.0

_MY_EOF_

	if [[ $BUSYBOXFILE=="busybox-1.20.0" ]]; then
		busybox_init_network_1_20_0 || exit 4
	fi;
}

busybox_init_network_1_20_0()
{
	echo "......1. "/usr/share/udhcpc/default.script
	mkdir -p $INSTDIR/usr/share/udhcpc || exit 1;
	cat << _MY_EOF_ > $INSTDIR/usr/share/udhcpc/default.script
#!/bin/sh
exec run-parts -a "\$1" /etc/udhcpc.d
_MY_EOF_
	chmod a+x $INSTDIR/usr/share/udhcpc/default.script

	echo "......2. "/etc/udhcpc.d/50default
	mkdir -p $INSTDIR/etc/udhcpc.d || exit 2;
	cd $INSTDIR/etc/udhcpc.d
	tar jxf $PATCHDIR/etc-prg.tar.bz2 50default || exit 2;
	
	echo "......3. "/etc/init.d/network
	mkdir -p $INSTDIR/etc/init.d || exit 3;
	cd $INSTDIR/etc/init.d
	tar jxf $PATCHDIR/etc-prg.tar.bz2 networking || exit 3;
	
	echo "......4. "修改/etc/init.d/rcS
#	sed -i 's/\#\!\/bin\/sh/\#\!\/bin\/sh\necho \"-------------Starting Network--------------\"\n\/etc\/init.d\/networking restart\n/g' $INSTDIR/etc/init.d/rcS || exit 4;
	
	echo "......5. "添加network配置文件目录
	mkdir -p $INSTDIR/etc/network/if-{pre-down,down,post-down,pre-up,up,post-up}.d
	cd $INSTDIR/etc/network
	tar jxf $PATCHDIR/etc-prg.tar.bz2 interfaces || exit 4; 
}
