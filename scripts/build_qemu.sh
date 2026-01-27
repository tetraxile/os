#!/bin/sh

# -device isa-debug-exit,iobase=0xf4,iosize=0x04
#     lets you exit the emulator from the os by writing a value to I/O port 0xf4 (actual exit code is `input * 2 + 1`)

scripts/build.sh &&
qemu-system-x86_64 -drive format=raw,file=build/os.img -device isa-debug-exit,iobase=0xf4,iosize=0x04
