#!/bin/sh

mkdir -p build &&
fasm src/boot.asm build/boot.bin > /dev/null
