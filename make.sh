#!/bin/bash

[ -e "env" ] && . ./env
[ -z "$ARCH" ] && ARCH="x86_64"

[ -z "$NICE" ] && NICE=19
[ -z "$JOBS" ] && JOBS=4

KBUILD_BUILD_USER=ach
KBUILD_BUILD_VERSION=5
KBUILD_BUILD_TIMESTAMP=`date +%Y%m%d%H%M%S`

[ $ARCH = i386 ] && CROSS_COMPILE=i686-linux-gnu-
[ $ARCH = i386 ] && CC=i686-linux-gnu-gcc

[ $ARCH = x86_64 ] && CROSS_COMPILE=x86_64-linux-gnu-
[ $ARCH = x86_64 ] && CC=x86_64-linux-gnu-gcc

export ARCH
export KBUILD_BUILD_USER
export KBUILD_BUILD_VERSION
export KBUILD_BUILD_TIMESTAMP
export CROSS_COMPILE
export CC

build_deb ()
{
	local LOG=./log/build-$( date +%Y%m%d%H%M%S ).log
	local OPT=
	mkdir -p ./log && echo -n > $LOG
	rm -f .config.old
	echo > .scmversion
	echo $KBUILD_BUILD_VERSION > .version
	[ -z "$CROSS_COMPILE" ] || OPT="--cross_compile $CROSS_COMPILE"
	fakeroot make-kpkg \
		--overlay-dir scripts/deb \
		--jobs $JOBS --initrd --arch=$ARCH $OPT \
		kernel_image | tee -a $LOG
}

build_nice ()
{
	local LOG=./log/build-$( date +%Y%m%d%H%M%S ).log
	mkdir -p ./log && echo -n > $LOG
	[ -f .version ] && rm -f .version
	time nice -n $NICE make $1 | tee -a $LOG
}

case $1 in
  clean)
	make clean
	;;
  lenovo)
	cp arch/x86/configs/lenovo.config .config
	ARCH=x86_64 make olddefconfig
	echo > .scmversion
	echo "ARCH=x86_64" > ./env
	;;
  esther)
	cp arch/x86/configs/esther.config .config
	ARCH=i386 make olddefconfig
	echo > .scmversion
	echo "ARCH=i386" > ./env
	;;
  menu)
	make menuconfig
	;;
  image)
	build_nice bzImage
	;;
  modules)
	build_nice modules
	;;
  all)
	build_nice bzImage
	build_nice modules
	;;
  install)
	export INSTALL_MOD_STRIP=1
	make modules_install
	make install
	rm -f /boot/*.old
	;;
  deb)
	time build_deb
	;;
  *)
	echo "Usage: $0 {clean|lenovo|menu|image|modules|all|deb}"
	exit 2
	;;
esac
