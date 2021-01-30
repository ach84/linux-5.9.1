#!/bin/bash

[ -e "env" ] && . ./env
[ -z "$ARCH" ] && ARCH="x86_64"

KBUILD_BUILD_USER=ach
KBUILD_BUILD_VERSION=2
KBUILD_BUILD_TIMESTAMP=`date +%Y%m%d%H%M%S`

export ARCH
export KBUILD_BUILD_USER
export KBUILD_BUILD_VERSION
export KBUILD_BUILD_TIMESTAMP

build_deb ()
{
	local LOG=./log/build-$( date +%Y%m%d%H%M%S ).log
	mkdir -p ./log && echo -n > $LOG
	rm -f .config.old
	echo > .scmversion
	echo $KBUILD_BUILD_VERSION > .version
	fakeroot make-kpkg \
		--overlay-dir scripts/deb \
		--jobs 4 --initrd --arch=$ARCH kernel_image | tee -a $LOG
}

case $1 in
  clean)
	make clean
	;;
  lenovo)
	cp arch/x86/configs/lenovo.config .config
	ARCH=x86_64 make olddefconfig
	echo "ARCH=x86_64" > ./env
	;;
  esther)
	cp arch/x86/configs/esther.config .config
	ARCH=i386 make olddefconfig
	echo "ARCH=i386" > ./env
	;;
  menu)
	make menuconfig
	;;
  ver)
	VER=$2
	[ -z "$VER" ] && VER=1
	echo > .scmversion
	echo $VER > .version
	;;
  image)
	make bzImage
	;;
  modules)
	make modules
	;;
  all)
	make bzImage
	make modules
	;;
  deb)
	build_deb
	;;
  *)
	echo "Usage: $0 {clean|lenovo|menu|ver|image|modules|all|deb}"
	exit 2
	;;
esac
