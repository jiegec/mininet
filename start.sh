#!/bin/bash
LINUX=~/linux-4.17.6

MACSTR=("`printf 'DE:AD:BE:EF:%02X:%02X\n' $((RANDOM%256)) $((RANDOM%256))`")
qemu-system-x86_64 -kernel $LINUX/arch/x86/boot/bzImage -initrd initrd.img -nographic -append 'console=ttyS1' \
	-m 512m -no-reboot \
	-fsdev local,security_model=passthrough,id=fsdev-root,path=/,readonly \
	-device virtio-9p-pci,id=fs-root,fsdev=fsdev-root,mount_tag=rootshare \
	-net nic,vlan=0,model=e1000,macaddr=$MACSTR \
	-net vde,sock=vde.sock

