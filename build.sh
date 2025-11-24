#!/bin/bash
# Script to build image for Raspberry Pi 5 hardware.
# Author: Siddhant Jajoo and modified by Scott Karl.

# Usage: ./build.sh               (builds for raspberrypi5 in build-rpi5/)

MACHINE_TYPE="raspberrypi5"
BUILD_DIR="build-rpi5"
echo "Building for Raspberry Pi 5 hardware in ${BUILD_DIR}/"

git submodule init
git submodule sync
git submodule update

# Pass the build directory to oe-init-build-env to keep builds separate
source poky/oe-init-build-env ${BUILD_DIR}

CONFLINE="MACHINE = \"${MACHINE_TYPE}\""

# Check if MACHINE is already set in local.conf and update if different
cat conf/local.conf | grep "^MACHINE = " > /dev/null
local_conf_info=$?

if [ $local_conf_info -ne 0 ];then
	echo "Append ${CONFLINE} in the local.conf file"
	echo ${CONFLINE} >> conf/local.conf
else
	# Check if the existing MACHINE matches what we want
	current_machine=$(grep "^MACHINE = " conf/local.conf | head -1)
	if [ "$current_machine" != "$CONFLINE" ]; then
		echo "Updating MACHINE from ${current_machine} to ${CONFLINE}"
		sed -i "s/^MACHINE = .*/${CONFLINE}/" conf/local.conf
	else
		echo "${CONFLINE} already exists in the local.conf file"
	fi
fi

# Accept required firmware licenses for Raspberry Pi
if ! grep -q "^LICENSE_FLAGS_ACCEPTED" conf/local.conf; then
	echo "Adding LICENSE_FLAGS_ACCEPTED for Raspberry Pi firmware"
	echo 'LICENSE_FLAGS_ACCEPTED = "synaptics-killswitch"' >> conf/local.conf
fi

# Enable I2C
if ! grep -q "^ENABLE_I2C" conf/local.conf; then
	echo "Enabling I2C"
	echo 'ENABLE_I2C = "1"' >> conf/local.conf
	echo 'KERNEL_MODULE_AUTOLOAD += "i2c-dev"' >> conf/local.conf
fi

# Add meta-raspberrypi layer
bitbake-layers show-layers | grep "meta-raspberrypi" > /dev/null
layer_info=$?

if [ $layer_info -ne 0 ];then
	echo "Adding meta-raspberrypi layer"
	bitbake-layers add-layer ../meta-raspberrypi
else
	echo "meta-raspberrypi layer already exists"
fi

# Add meta-oe layer (from meta-openembedded)
bitbake-layers show-layers | grep "meta-oe" > /dev/null
layer_info=$?

if [ $layer_info -ne 0 ];then
	echo "Adding meta-oe layer"
	bitbake-layers add-layer ../meta-openembedded/meta-oe
else
	echo "meta-oe layer already exists"
fi

# Add meta-python layer (from meta-openembedded)
bitbake-layers show-layers | grep "meta-python" > /dev/null
layer_info=$?

if [ $layer_info -ne 0 ];then
	echo "Adding meta-python layer"
	bitbake-layers add-layer ../meta-openembedded/meta-python
else
	echo "meta-python layer already exists"
fi

# Add meta-networking layer (from meta-openembedded)
bitbake-layers show-layers | grep "meta-networking" > /dev/null
layer_info=$?

if [ $layer_info -ne 0 ];then
	echo "Adding meta-networking layer"
	bitbake-layers add-layer ../meta-openembedded/meta-networking
else
	echo "meta-networking layer already exists"
fi

# Add meta-aesd layer
bitbake-layers show-layers | grep "meta-aesd" > /dev/null
layer_info=$?

if [ $layer_info -ne 0 ];then
	echo "Adding meta-aesd layer"
	bitbake-layers add-layer ../meta-aesd
else
	echo "meta-aesd layer already exists"
fi

set -e
bitbake core-image-aesd
