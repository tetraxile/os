use32
org 0x10000

jmp kernel_main

include "src/print.asm"

kernel_main:
    mov eax, strings.entered_kernel
    call print_string

    hlt

strings:
.entered_kernel db "hi from the kernel :)", 0xa, 0

times 0x4000-($-$$) db 0
