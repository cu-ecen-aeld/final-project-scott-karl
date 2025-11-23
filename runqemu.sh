#!/bin/bash
# Script to start QEMU for testing
# Note: QEMU only supports raspberrypi4 and earlier.
# This script uses the build-rpi4 directory for QEMU testing.

# Use the QEMU build directory
source poky/oe-init-build-env build-rpi4

# Verify the build directory exists
if [ ! -f conf/local.conf ]; then
    echo "ERROR: build-rpi4 directory not found or not initialized"
    echo "Please build for QEMU first with: ./build.sh qemu"
    exit 1
fi

# Check which MACHINE is configured
MACHINE=$(grep "^MACHINE = " conf/local.conf | head -1 | sed 's/MACHINE = "\(.*\)"/\1/')

if [ "$MACHINE" != "raspberrypi4" ]; then
    echo "ERROR: build-rpi4 is configured for ${MACHINE}, expected raspberrypi4"
    echo "Please rebuild for QEMU testing with: ./build.sh qemu"
    exit 1
fi

echo "Starting QEMU for ${MACHINE}"
export QB_SLIRP_OPT="-netdev user,id=net0,hostfwd=tcp::10022-:22,hostfwd=tcp::9000-:9000"
runqemu slirp nographic
