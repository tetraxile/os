use32
org 0x10000

jmp kernel_main

include "src/print.asm"
include "src/idt.asm"
include "src/pic.asm"

kernel_main:
    call idt_init
    mov eax, notification.initialized_idt
    call print_string

    call remap_pic_offsets

    int 0x3

    hlt

notification:
.initialized_idt db "initialized IDT", 0xa, 0

times 0x4000-($-$$) db 0
