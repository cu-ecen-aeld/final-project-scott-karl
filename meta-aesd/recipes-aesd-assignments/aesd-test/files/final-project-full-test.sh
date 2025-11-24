#!/bin/sh
# Test script for final project running on target

echo "Checking aesdchar driver loading"
if lsmod | grep "aesdchar" > /dev/null; then
    echo "aesdchar driver is loaded"
else
    echo "FAIL: aesdchar driver is NOT loaded"
    exit 1
fi

echo "Running drivertest.sh"
if [ -f /usr/bin/drivertest.sh ]; then
    /usr/bin/drivertest.sh
    if [ $? -ne 0 ]; then
        echo "FAIL: drivertest.sh failed"
        exit 1
    fi
else
    echo "FAIL: drivertest.sh not found"
    exit 1
fi

# Clean up before sockettest
if [ "$1" = "clean" ]; then
    echo "Restarting aesdsocket and reloading driver to clear buffer"
    /etc/init.d/aesdsocket-start-stop stop
    /usr/bin/aesdchar_unload
    /usr/bin/aesdchar_load
    /etc/init.d/aesdsocket-start-stop start
    sleep 1 # Give it a moment to start
fi

echo "Checking aesdsocket"
if ps | grep -v grep | grep -q /usr/bin/aesdsocket; then
    echo "aesdsocket is running"
else
    echo "FAIL: aesdsocket is NOT running"
    exit 1
fi

echo "Running sockettest.sh"
if [ -f /usr/bin/sockettest.sh ]; then
    /usr/bin/sockettest.sh
    if [ $? -ne 0 ]; then
        echo "FAIL: sockettest.sh failed"
        exit 1
    fi
else
    echo "FAIL: sockettest.sh not found"
    exit 1
fi

echo "All tests passed"
exit 0
