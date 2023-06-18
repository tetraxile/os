use32
org 0x10000

jmp kernel_main

include "src/print.asm"
include "src/idt.asm"
include "src/pic.asm"
include "src/ps2.asm"

kernel_main:
    call enable_a20
    call remap_pic_offsets

    call idt_init
    mov eax, notification.initialized_idt
    call print_string

    sti

.halt:
    hlt
    jmp .halt


notification:
.initialized_idt db "initialized IDT", 0xa, 0

times 0x4000-($-$$) db 0
