#!/bin/sh

scripts/build.sh &&
qemu-system-i386 -drive format=raw,file=build/os.img
