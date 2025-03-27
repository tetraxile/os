; kernel.asm - protected mode kernel

use32
org 0x10000

jmp kernel_main

include "src/print.asm"
include "src/idt.asm"
include "src/pic.asm"
include "src/ps2.asm"

kernel_main:
    call enable_a20
    call pic_init

    call ps2_init
    mov eax, notification.initialised_ps2
    call print_string

    call idt_init
    mov eax, notification.initialised_idt
    call print_string

    sti

.halt:
    hlt
    jmp .halt


notification:
.initialised_idt db "initialised IDT", 0xa, 0
.initialised_ps2 db "initialised PS/2 controller", 0xa, 0

times 0x4000-($-$$) db 0
