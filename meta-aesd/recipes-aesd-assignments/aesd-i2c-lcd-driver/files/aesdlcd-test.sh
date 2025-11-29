#!/bin/sh

# Shell script to write "Hello World" to the LCD Driver
# This writes directly to the device node

DEVICE="/dev/aesdlcd"

echo "--- AESD LCD Driver Test ---"

if [ ! -c "$DEVICE" ]; then
    echo "Error: Device $DEVICE not found!"
    echo "Make sure the driver is loaded using: aesdlcd_load.sh"
    exit 1
fi

echo "Writing 'Hello World' to $DEVICE..."

# Write string to the device
# We use printf to ensure no trailing newline is sent if not desired,
# though the driver handles bytes as they come.
if printf "Hello World" > "$DEVICE"; then
    echo "SUCCESS: String written to display."
else
    echo "FAILURE: Could not write to device."
    exit 1
fi