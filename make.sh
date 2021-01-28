#!/bin/bash

[ -e "env" ] && . ./env
[ -z "$ARCH" ] && ARCH="x86_64"

case $1 in
  clean)
	ARCH=$ARCH make clean
	;;
  lenovo)
	cp arch/x86/configs/lenovo.config .config
	ARCH=x86_64 make silentoldconfig
	echo "ARCH=x86_64" > ./env
	;;
  menu)
	ARCH=$ARCH make menuconfig
	;;
  ver)
	VER=$2
	[ -z "$VER" ] && VER=1
	echo > .scmversion
	echo $VER > .version
	;;
  prep)
	mkdir debian
	sudo mount tmpfs ./debian -t tmpfs
	sudo chown ach:ach debian
	;;
  all)
	ARCH=$ARCH make bzImage
	ARCH=$ARCH make modules
	;;
  deb)
	#ARCH=$ARCH make silentoldconfig
	#rm -f .config.old
	fakeroot make-kpkg --jobs 8 --initrd --arch=$ARCH $OPTS kernel_image
	;;
  *)
	echo "Usage: $0 {clean|lenovo|menu|ver|prep|all|deb}"
	exit 2
	;;
esac
