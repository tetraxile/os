#!/bin/sh

scripts/build.sh &&
qemu-system-x86_64 -drive format=raw,file=build/os.img
