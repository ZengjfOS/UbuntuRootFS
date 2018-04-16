#!/usr/bin/env bash

set -x

#
# dtb_list extracts the list of DTB files from BR2_LINUX_KERNEL_INTREE_DTS_NAME
# in ${BR_CONFIG}, then prints the corresponding list of file names for the
# genimage configuration file
#
dtb_list()
{
	echo -n "zImage-imx6dl-sabresd.dtb, "
}

#
# linux_image extracts the Linux image format from BR2_LINUX_KERNEL_UIMAGE in
# ${BR_CONFIG}, then prints the corresponding file name for the genimage
# configuration file
#
linux_image()
{
	echo "\"zImage\""
}

main()
{
	local FILES="$(dtb_list) $(linux_image)"
	local GENIMAGE_CFG="$(mktemp --suffix genimage.cfg)"
	local GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"
	local INPUT_DIR="images"
	local BINARIES_DIR="rootfs"
	local TARGET_DIR="rootfs"

	./customize/bin/common/mke2img -d ${TARGET_DIR} -G 2 -R 1 -B 0 -I 0 -o ${INPUT_DIR}/rootfs.ext2

	sed -e "s/%FILES%/${FILES}/" \
		customize/bin/common/genimage.cfg.template > ${GENIMAGE_CFG}

	rm -rf "${GENIMAGE_TMP}"

	# inputpath = bootloader/zImage path
	# rootpath  = root file system path
	genimage \
		--rootpath "${TARGET_DIR}" \
		--tmppath "${GENIMAGE_TMP}" \
		--inputpath "${INPUT_DIR}" \
		--outputpath "${INPUT_DIR}" \
		--config "${GENIMAGE_CFG}"

	rm -f ${GENIMAGE_CFG}

	exit $?
}

main $@
