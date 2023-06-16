#!/bin/sh

mkdir -p build &&
fasm src/boot.asm build/boot.bin > /dev/null &&
fasm src/kernel.asm build/kernel.bin > /dev/null &&
cat build/boot.bin build/kernel.bin > build/os.img
