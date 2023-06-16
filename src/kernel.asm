use32
org 0x10000

jmp kernel_main

include "src/print.asm"

kernel_main:
    mov eax, strings.entered_kernel
    call print_string

    mov al, 0x55
    call print_u8_binary

    mov al, 0xa
    call print_char

    mov al, 0xcd
    call print_u8_hex

    mov al, 0xa
    call print_char

    mov ax, 0xdead
    call print_u16_hex

    mov al, 0xa
    call print_char
    
    mov eax, 0x12345678
    call print_u32_hex

    hlt

strings:
.entered_kernel db "hi from the kernel :)", 0xa, 0

times 0x4000-($-$$) db 0
