#!/bin/sh

set -eu

BUSYBOX="/usr/bin/busybox.static"
PREFIX="/static"
WD="`pwd`"

# require root privilege
if [ $(id -r -u) != 0 ]; then
    echo "Please run as root. aborted" > /dev/stderr
    exit 1
fi


if [ ! -e "$BUSYBOX" ]; then
    echo "Please install busybox-static into $BUSYBOX . aborted" > /dev/stderr
    exit 1
fi


mkdir $PREFIX
cd $PREFIX

cp $BUSYBOX ./
for i in "[" "[[" arch ascii ash awk base32 base64 basename blkdiscard blkid brctl bunzip2 bzcat bzip2 cat chattr chgrp chmod chown chpst chroot chvt clear cmp comm cp crc32 cttyhack cut date dc dd depmod df diff dirname dmesg dnsdomainname du dumpkmap echo ed egrep eject env expand expr factor fallocate false fatattr fbset fdisk fgrep find findfs flock fold free fsfreeze fstrim fsync fuser getopt getty grep groups gunzip gzip head hexdump hexedit hostname hwclock i2cdetect i2cdump i2cget i2cset i2ctransfer id ifconfig ifenslave insmod install ionice iostat ip ipaddr ipcrm ipcs iplink ipneigh iproute iprule iptunnel kbd_mode kill killall killall5 less link linux32 linux64 ln loadkmap logger losetup ls lsmod lsof lspci lsscsi lsusb lzcat md5sum mkdir mkfifo mknod mkswap mktemp modinfo modprobe more mount mpstat mv nc netstat nice nl nohup nproc nsenter nslookup ntpd od partprobe paste patch pgrep pidof ping ping6 pipe_progress pivot_root pkill pmap powertop printenv printf ps pstree pwd readlink realpath renice reset rfkill rm rmdir rmmod run-parts sed seq setarch setfattr setpriv setsid sh sha1sum sha256sum sha3sum sha512sum shred shuf sleep sort split ssl_client stat strings stty sum sv svok swapoff swapon switch_root sync sysctl tac tail tar tc tee telnet test time top touch tr true truncate ts tty udhcpc uevent umount uname unexpand uniq unlink unshare unxz unzip uptime uudecode uuencode vi wc wget which whoami whois xargs xxd xz xzcat yes zcat; do ln busybox.static ${i}; done

echo "busybox-static shell environment has installed into $PREFIX ."
cd "$WD"
