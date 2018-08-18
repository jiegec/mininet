#!/bin/sh
SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`
ROOTFS=$SCRIPTPATH/rootfs/
INITRAMFS=$SCRIPTPATH/initramfs/
LINUX=~/linux-4.18.2

function copy_binary() {
    cp -f --parents $(which $*) $ROOTFS
    for i in $(ldd $(which $*)|grep -v dynamic|cut -d " " -f 3|sed 's/://'|sort|uniq)
      do
        cp --parents -L -f $i $ROOTFS
      done

    # ARCH amd64
    if [ -f /lib64/ld-linux-x86-64.so.2 ]; then
       cp --parents /lib64/ld-linux-x86-64.so.2 $ROOTFS
    fi

    # ARCH i386
    if [ -f  /lib/ld-linux.so.2 ]; then
       cp --parents /lib/ld-linux.so.2 $ROOTFS
    fi
}

rm -rf $ROOTFS 
mkdir -p $ROOTFS/{bin,dev,etc,lib,proc,sbin,sys,lib/modules,mnt,mnt/root,run,usr,usr/lib,usr/bin,usr/sbin,usr/share/hwdata,var/lib/dhclient}
cp early_init $ROOTFS/init
cp init $ROOTFS/sbin/init
cp `which sh` $ROOTFS/bin
cp `which bash` $ROOTFS/bin
cp --parents /usr/share/terminfo/v/vt100 $ROOTFS
cp --parents /usr/share/hwdata/{pci,usb}.ids $ROOTFS
copy_binary busybox 
copy_binary switch_root 
copy_binary iptables
copy_binary iptables-save
copy_binary brctl
copy_binary lscpu
copy_binary lshw
copy_binary lspci
copy_binary lsusb
copy_binary update-pciids
copy_binary wget
copy_binary sh
copy_binary bash
copy_binary ls
copy_binary cat 
copy_binary which
copy_binary ip
copy_binary uptime
copy_binary stty
copy_binary vim
copy_binary rm
copy_binary touch
copy_binary wget
copy_binary ping
copy_binary traceroute
copy_binary tcpdump
copy_binary strace
copy_binary lsmod
copy_binary modprobe
copy_binary modinfo
copy_binary find
copy_binary mv 
copy_binary grep
copy_binary mount
copy_binary lsblk
copy_binary lsof
copy_binary ps
copy_binary id
copy_binary dhclient
copy_binary dhclient-script
copy_binary chown
copy_binary chmod
copy_binary dmesg
copy_binary uname
cp `which dhclient-script` $ROOTFS/sbin
cp `which ip` $ROOTFS/sbin
make -C $LINUX modules_install INSTALL_MOD_PATH=$ROOTFS -j50

rm -rf $INITRAMFS
mkdir -p $INITRAMFS
pushd $ROOTFS
for file in $(cat $SCRIPTPATH/initramfs.txt)
  do
    cp --parents -r -f $file $INITRAMFS
  done
popd

pushd $INITRAMFS
find . | cpio --quiet -R 0:0 -o -H newc | gzip > $SCRIPTPATH/initrd.img
wc -c < $SCRIPTPATH/initrd.img > $SCRIPTPATH/initramfs_size
