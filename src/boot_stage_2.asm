use16
org 0x7e00

KERNEL_ADDR = 0x10000

start_stage_2:
    jmp enter_protected_mode


include "src/gdt.asm"

GDT_descriptor:
    dw GDT_SIZE - 1 ; size
    dd 0x800        ; offset

IDT_descriptor:
    dw 0x800 ; size
    dd 0x0   ; offset

enter_protected_mode:
    ; copy the GDT to address 0x800
    mov si, GDT_start
    mov di, 0x800
    mov cx, GDT_SIZE
    rep movsb

    lgdt [GDT_descriptor]
    lidt [IDT_descriptor]

    ; set cr0.PE (bit 0)
    mov eax, cr0
    or eax, 0x0001
    mov cr0, eax

    ; far jump to reload cs register
    jmp CODE_SEGMENT:.reload_cs

use32
.reload_cs:
    mov ax, DATA_SEGMENT
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; set up kernel stack
    mov ebp, 0x90000
    mov esp, ebp

    jmp KERNEL_ADDR


times 0x400-($-$$) db 0
