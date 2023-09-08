# os

this is an (as yet unnamed) x86-64 operating system (bootloader and kernel) made with the main purpose of learning how operating systems work.
i wrote it in assembly but i would like to make a programming language to go along with the OS once it's self-hosted, if i get to that point.

specs-wise i'm not totally sure what you'd need but for reference i'm testing it on Lenovo Ideapad S540 with an AMD CPU.
at the very least, your processor must be 64-bit and support the `cpuid` instruction.
i've only tested booting off of USB but hopefully other boot methods would work too (with maybe a little change to the MBR partition table).
