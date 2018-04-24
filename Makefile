# system_type=debian
 system_type=ubuntu

# ftp_url = http://ftp.debian.org/debian/
ftp_url = http://ports.ubuntu.com

# distro = wheezy
distro = xenial
# distro = stretch

target = rootfs

packages_path = $(shell pwd)/$(target)/root/packages
manifest_git = https://github.com/ZengjfOS/UbuntuRootFS.git
branch_git = Manifest

ifeq ($(system_type), debian)
ifeq ($(distro), stretch)
include_package = "sysvinit-core"
endif
endif

ifeq ($(system_type), ubuntu)
include_package = $(system_type)-keyring,apt-transport-https,ca-certificates,openssl
endif

all: debootstrap secondstage factory package
	echo "End Of All."

debootstrap:
	# install host packages
	sudo apt-get install gparted git build-essential libncurses5 wget u-boot-tools zlib1g-dev ncurses-dev cmake libc-dev-armhf-cross pkg-config-arm-linux-gnueabihf build-essential checkinstall cmake pkg-config lzop libc6 libstdc++6 debootstrap qemu-user-static binfmt-support debian-archive-keyring

	# get first step source
	echo "start debootstrap."
ifeq ($(system_type), debian)
	-sudo mkdir -p "${target}/usr/share/keyrings"
	-sudo cp -v /usr/share/keyrings/debian-archive-keyring.gpg "${target}/usr/share/keyrings/debian-archive-keyring.gpg"
endif
	-sudo debootstrap --arch=armhf --include=$(include_package) --foreign  $(distro) "$(target)" $(ftp_url)
	echo "end debootstrap."

secondstage:

	# auto run default script
	sudo cp -v /usr/bin/qemu-arm-static $(target)/usr/bin
	sudo cp -v /etc/resolv.conf $(target)/etc
	sudo cp -v customize/bin/${distro}/* $(target)/root/

	sudo mount -v --bind /dev `pwd`/$(target)/dev
	sudo mount -v --bind /dev/pts `pwd`/$(target)/dev/pts
	sudo mount -v --bind /proc `pwd`/$(target)/proc
	sudo mount -v --bind /sys `pwd`/$(target)/sys

ifeq ($(system_type), debian)
	sudo DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true LC_ALL=C LANGUAGE=C LANG=C chroot $(target) /bin/bash -c /root/second-stage
else
	sudo chroot $(target) /bin/bash -c /root/second-stage
endif

	-sudo umount `pwd`/$(target)/sys
	-sudo umount `pwd`/$(target)/proc
	-sudo umount `pwd`/$(target)/dev/pts
	-sudo umount `pwd`/$(target)/dev

factory:
	# auto run default script
	sudo cp -v /usr/bin/qemu-arm-static $(target)/usr/bin
	sudo cp -v /etc/resolv.conf $(target)/etc
	sudo cp -v customize/bin/${distro}/* $(target)/root/

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
	# copy modify etc file
	sudo cp -vr customize/rootfs/${distro}/* $(target)/
	sudo chroot $(target) /bin/bash -c /root/fourth-stage

	-sudo umount `pwd`/$(target)/sys
	-sudo umount `pwd`/$(target)/proc
	-sudo umount `pwd`/$(target)/dev/pts
	-sudo umount `pwd`/$(target)/dev
	-sudo ls $(target)/dev/pts
	-sudo ls $(target)/dev

	# remove default script
	sudo sh -c "cd $(target)/root/ &&  rm * -r"
	sudo rm $(target)/usr/bin/qemu-arm-static

package:
	-sudo cp -v /usr/bin/qemu-arm-static $(target)/usr/bin
	sudo cp -v customize/bin/${distro}/packages-stage $(target)/root/packages-stage
	echo $(packages_path)
	-sudo mkdir $(packages_path)
	-sudo sh -c "cd $(packages_path) && sudo git clone git://git.omapzoom.org/git-repo.git"
	-sudo sh -c "cd $(packages_path) && ./git-repo/repo init -u $(manifest_git) -b $(branch_git) -c"
	-sudo sh -c "cd $(packages_path) && ./git-repo/repo sync --no-tags"

	sudo chroot $(target) /bin/bash -c /root/packages-stage
	sudo sh -c "cd $(target)/root/ &&  rm * -r"

qemu:
	-sudo cp -v /usr/bin/qemu-arm-static $(target)/usr/bin

sdimg:
	-sudo rm images -rf
	-mkdir images
	sudo cp customize/prebuild/* images
	sudo fakeroot ./customize/bin/common/post-image.sh

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
	sudo rm rootfs/root/packages -rf
	sudo rm images -rf
