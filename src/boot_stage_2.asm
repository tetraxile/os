KERNEL_ADDR = 0x10000

start_stage_2:
    ; check if cpuid is supported
    pushfd
    pushfd
    xor dword [esp], 0x00200000
    popfd
    pushfd
    pop eax
    xor eax, [esp]
    popfd
    and eax, 0x00200000
    jz .no_cpuid

    ; check if cpuid 0x80000001 is available
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb .no_long_mode

    ; check if cpuid.LM (flag 29) is set 
    mov eax, 0x80000001
    cpuid
    test edx, 0x20000000 ; 1 << 29
    jz .no_long_mode

    jmp enter_protected_mode

.no_cpuid:
    mov bp, strings.no_cpuid
    call bios_print_string
    hlt

.no_long_mode:
    mov bp, strings.no_long_mode
    call bios_print_string
    hlt


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


times 0x600-($-$$) db 0
