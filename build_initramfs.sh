#!/bin/sh
SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`
CHROOT=$SCRIPTPATH/initramfs/
LINUX=~/linux-4.17.10

function copy_binary() {
    cp -f --parents $(which $*) $CHROOT
    for i in $(ldd $(which $*)|grep -v dynamic|cut -d " " -f 3|sed 's/://'|sort|uniq)
      do
        cp --parents -L -f $i $CHROOT
      done

    # ARCH amd64
    if [ -f /lib64/ld-linux-x86-64.so.2 ]; then
       cp --parents /lib64/ld-linux-x86-64.so.2 $CHROOT
    fi

    # ARCH i386
    if [ -f  /lib/ld-linux.so.2 ]; then
       cp --parents /lib/ld-linux.so.2 $CHROOT
    fi
}

rm -rf $CHROOT 
mkdir -p $CHROOT/{bin,dev,etc,lib,proc,sbin,sys,lib/modules,mnt,mnt/root,run,usr,usr/lib,usr/bin,usr/sbin,usr/share/hwdata,var/lib/dhclient}
cp init $CHROOT/ 
cp `which sh` $CHROOT/bin
cp `which bash` $CHROOT/bin
cp --parents /usr/share/terminfo/v/vt100 $CHROOT
cp --parents /usr/share/hwdata/{pci,usb}.ids $CHROOT
copy_binary busybox 
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
cp `which dhclient-script` $CHROOT/sbin
cp `which ip` $CHROOT/sbin
make -C $LINUX modules_install INSTALL_MOD_PATH=$CHROOT -j50
cd $CHROOT
find . | cpio --quiet -R 0:0 -o -H newc | gzip > ../initrd.img
wc -c <../initrd.img > ../initramfs_size
