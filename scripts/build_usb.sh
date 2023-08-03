#!/bin/sh

OUT_DEVICE=$1

if [ -z "$1" ]; then
    echo "error: no disk entered" >&2
    exit 1
elif [ ! -b "$1" ]; then
    echo "error: device $OUT_DEVICE not found" >&2
    exit 1
fi

scripts/build.sh &&
sudo dd if=build/os.img of="$OUT_DEVICE" 2> /dev/null &&
sudo eject "$OUT_DEVICE"
