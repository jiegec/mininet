#!/bin/sh
LINUX=~/linux-4.18.2
cp $LINUX/.config kernel_config
make -C $LINUX -j50
make -C $LINUX modules -j50
wc -c <$LINUX/arch/x86/boot/bzImage > kernel_size
source ./build_initramfs.sh
