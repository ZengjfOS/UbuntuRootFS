target = rootfs
# distro = trusty
distro = xenial

all:
	# install host packages
	sudo apt-get install gparted git build-essential libncurses5 wget u-boot-tools zlib1g-dev ncurses-dev cmake libc-dev-armhf-cross pkg-config-arm-linux-gnueabihf build-essential checkinstall cmake pkg-config lzop libc6 libstdc++6 debootstrap qemu-user-static binfmt-support  

	# get compiler
	# wget -c https://releases.linaro.org/archive/14.09/components/toolchain/binaries/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux.tar.xz
	# tar xf gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux.tar.xz
	# export target=mx6dl
	# export board=sabresd
	# export ARCH=arm
	# export CROSS_COMPILE=`pwd`/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux/bin/arm-linux-gnueabihf-
	# unset LDFLAGS
	 
	# get first step source
	echo "start debootstrap."
	-sudo debootstrap --arch=armhf --include=ubuntu-keyring,apt-transport-https,ca-certificates,openssl --foreign  $(distro) "$(target)" http://ports.ubuntu.com
	# -sudo debootstrap --variant=minbase --arch=armhf --foreign $(distro) "$(target)" http://ports.ubuntu.com
	echo "end debootstrap."

	# auto run default script
	sudo cp -v /usr/bin/qemu-arm-static $(target)/usr/bin
	sudo cp -v /etc/resolv.conf $(target)/etc
	sudo cp -v customize/bin/${distro}/* $(target)/root/

	sudo chroot $(target) /bin/bash -c /root/second-stage

	# chroot to arm qemu and run second-stage script
	# -sudo umount -lf `pwd`/$(target)/dev/pts
	# -sudo umount -lf `pwd`/$(target)/dev
	sudo mount -v --bind /dev `pwd`/$(target)/dev
	sudo mount -v --bind /dev/pts `pwd`/$(target)/dev/pts
	sudo mount -v --bind /proc `pwd`/$(target)/proc
	sudo mount -v --bind /sys `pwd`/$(target)/sys
	sudo ls $(target)/dev
	sudo ls $(target)/dev/pts
	sudo chroot $(target) /bin/bash -c /root/third-stage
	-sudo umount `pwd`/$(target)/sys
	-sudo umount `pwd`/$(target)/proc
	-sudo umount `pwd`/$(target)/dev/pts
	-sudo umount `pwd`/$(target)/dev
	sudo ls $(target)/dev/pts
	sudo ls $(target)/dev

	# remove default script
	sudo sh -c "cd $(target)/root/ &&  rm * -r"
	sudo rm $(target)/usr/bin/qemu-arm-static

	# copy modify etc file
	sudo cp -vr customize/rootfs/${distro}/* $(target)/

qemu:
	sudo cp -v /usr/bin/qemu-arm-static $(target)/usr/bin

mnt: qemu
	sudo mount -v --bind /dev `pwd`/$(target)/dev
	sudo mount -v --bind /dev/pts `pwd`/$(target)/dev/pts
	sudo mount -v --bind /proc `pwd`/$(target)/proc
	sudo mount -v --bind /sys `pwd`/$(target)/sys

umnt:
	-sudo umount `pwd`/$(target)/sys
	-sudo umount `pwd`/$(target)/proc
	-sudo umount `pwd`/$(target)/dev/pts
	-sudo umount `pwd`/$(target)/dev

bz2: umnt
	-sudo rm rootfs/rootfs.tar.bz2
	cd rootfs && sudo fakeroot -- tar jcvf rootfs.tar.bz2 *

clean:
	sudo rm rootfs -rf
