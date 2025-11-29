#!/bin/bash
# Script to build image for Raspberry Pi 5 hardware.
# Author: Siddhant Jajoo and modified by Scott Karl.

# Usage: ./build.sh          (builds from git/remote)
#        ./build.sh local    (builds from local source dir)

MACHINE_TYPE="raspberrypi5"
BUILD_DIR="build-rpi5"

# Absolute path to the local development directory
LOCAL_SOURCE_DIR="/home/skarl/MSEE/ECEA5305-6-7/final/assignments-skarl1192"

echo "Building for Raspberry Pi 5 hardware in ${BUILD_DIR}/"

git submodule init
git submodule sync
git submodule update

# This command changes the current working directory to ${BUILD_DIR}
source poky/oe-init-build-env ${BUILD_DIR}

CONFLINE="MACHINE = \"${MACHINE_TYPE}\""

# Check if MACHINE is already set in local.conf and update if different
if grep -q "^MACHINE = " conf/local.conf; then
    current_machine=$(grep "^MACHINE = " conf/local.conf | head -1)
    if [ "$current_machine" != "$CONFLINE" ]; then
        echo "Updating MACHINE from ${current_machine} to ${CONFLINE}"
        sed -i "s/^MACHINE = .*/${CONFLINE}/" conf/local.conf
    else
        echo "${CONFLINE} already exists in the local.conf file"
    fi
else
    echo "Append ${CONFLINE} in the local.conf file"
    echo ${CONFLINE} >> conf/local.conf
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

# --- Layer Additions ---

add_layer_if_missing() {
    layer_name=$1
    layer_path=$2
    if ! bitbake-layers show-layers | grep -q "$layer_name"; then
        echo "Adding $layer_name layer"
        bitbake-layers add-layer "$layer_path"
    else
        echo "$layer_name layer already exists"
    fi
}

# Note path is ../ because we are inside the build dir now
add_layer_if_missing "meta-raspberrypi" "../meta-raspberrypi"
add_layer_if_missing "meta-oe" "../meta-openembedded/meta-oe"
add_layer_if_missing "meta-python" "../meta-openembedded/meta-python"
add_layer_if_missing "meta-networking" "../meta-openembedded/meta-networking"
add_layer_if_missing "meta-aesd" "../meta-aesd"

# --- Devtool Configuration ---

if [ "$1" = "local" ]; then
    echo "Configuring for local development..."
    echo "Using source from: $LOCAL_SOURCE_DIR"
    
    # Clean up previous devtool state
    devtool reset aesd-char-driver 2>/dev/null || true
    devtool reset aesd-socket-server-app 2>/dev/null || true
    devtool reset aesd-i2c-lcd-driver 2>/dev/null || true
    
    # Modify with -n (no-extract) and the specific path
    devtool modify -n aesd-char-driver "$LOCAL_SOURCE_DIR"
    devtool modify -n aesd-socket-server-app "$LOCAL_SOURCE_DIR"
    devtool modify -n aesd-i2c-lcd-driver "$LOCAL_SOURCE_DIR"
else
    echo "Configuring for standard build (remote sources)..."
    devtool reset aesd-char-driver 2>/dev/null || true
    devtool reset aesd-socket-server-app 2>/dev/null || true
    devtool reset aesd-i2c-lcd-driver 2>/dev/null || true
fi

set -e
bitbake core-image-aesd
