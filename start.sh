#!/bin/bash
source common.sh

MACSTR=("`printf 'DE:AD:BE:EF:%02X:%02X\n' $((RANDOM%256)) $((RANDOM%256))`")
qemu-system-x86_64 -kernel $LINUX/arch/x86/boot/bzImage -initrd initrd.img -nographic \
	-append 'console=ttyS1 pti=off spectre_v2=off spectre_v1=off' \
	-m 512m -no-reboot \
	-fsdev local,security_model=passthrough,id=fsdev-root,path=./rootfs/ \
	-device virtio-9p-pci,id=fs-root,fsdev=fsdev-root,mount_tag=rootshare \
	-net nic,vlan=0,model=e1000,macaddr=$MACSTR

