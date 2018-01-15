target = rootfs
distro = trusty

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
	-sudo debootstrap --arch=armhf --foreign --include=ubuntu-keyring,apt-transport-https,ca-certificates,openssl $(distro) "$(target)" http://ports.ubuntu.com
	echo "end debootstrap."

	# auto run default script
	sudo cp -v /usr/bin/qemu-arm-static $(target)/usr/bin
	sudo cp -v /etc/resolv.conf $(target)/etc
	sudo cp -v customize/second-stage $(target)/root/second-stage
	sudo cp -v customize/install_packages $(target)/root/install_packages

	# chroot to arm qemu and run second-stage script
	# -sudo umount -lf `pwd`/$(target)/dev/pts
	# -sudo umount -lf `pwd`/$(target)/dev
	sudo mount -v --bind /dev $(target)/dev
	sudo mount -vt devpts devpts $(target)/dev/pts
	sudo ls $(target)/dev
	sudo chroot $(target) /bin/bash -c /root/second-stage
	-sudo umount -lf `pwd`/$(target)/dev/pts
	-sudo umount -lf `pwd`/$(target)/dev
	sudo ls $(target)/dev

	# default config
	sudo cp -v customize/passwd $(target)/etc/passwd

	# remove default script
	sudo rm $(target)/root/second-stage
	sudo rm $(target)/root/install_packages
	sudo rm $(target)/etc/resolv.conf
	sudo rm $(target)/usr/bin/qemu-arm-static

clean:
	sudo rm rootfs -rf
