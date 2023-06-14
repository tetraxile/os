#!/bin/sh

OUT_DISK=/dev/sda

if [ -f "$OUT_DISK" ]; then
    echo "error: disk $OUT_DISK not found" >&2
    exit 1
fi

scripts/build.sh &&
sudo dd if=build/boot.bin of=$OUT_DISK 2> /dev/null &&
sudo eject /dev/sda
