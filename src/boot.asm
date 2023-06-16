use16
org 0x7c00

KERNEL_ADDR = 0x10000

start:
    mov [drive_number], dl

    cli ; disable interrupts for now
    cld ; set direction flag to auto-increment

    ; set video mode to 80x25 4-bit color text (mode 0x03)
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ; disable cursor (set bit 5 of ch)
    mov ah, 0x01
    mov ch, 00100000b
    int 0x10

    ; set up the stack and segment registers
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00

    mov es, ax
    mov bp, strings.starting_os
    call bios_print_string

    ; load kernel into memory
    mov ah, 0x42 ; extended read sectors
    mov dl, [drive_number]
    mov si, kernel_dap
    int 0x13
    jc .disk_error
    cmp ah, 0
    jnz .disk_error

    xor ax, ax
    mov es, ax
    mov bp, strings.loaded_kernel
    call bios_print_string

    jmp enter_protected_mode

.disk_error:
    xor ax, ax
    mov es, ax
    mov bp, strings.disk_error
    call bios_print_string
    hlt


; write a cp437 string to the VGA text buffer at the cursor
; and move to the next line
; * es:bp - pointer to string, prefixed with length (1 byte)
bios_print_string:
    ; get length from string
    movzx cx, byte [es:bp]
    inc bp

    mov ah, 0x13       ; print string interrupt
    mov al, 0x00       ; attribute in bl, don't move cursor
    mov bh, 0x00       ; display page 0
    mov bl, 0x0f       ; white text on black background
    mov dh, [cursor_y]
    mov dl, 0          ; move cursor to start of line
    int 0x10

    ; move the cursor to the next line
    inc byte [cursor_y]
    ret


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


cursor_y db 0
drive_number db 0

strings:
.starting_os db 11, "starting OS"
.loaded_kernel db 13, "loaded kernel"
.disk_error db 10, "disk error"

times 0x1a8-($-$$) db 0

; disk address packet for loading kernel
kernel_dap:
    db 0x10       ; size of packet
    db 0          ; unused
    dw 0x20       ; number of sectors
    dd 0x10000000 ; memory buffer (1000h:0000h)
    dd 1          ; starting LBA 0:31
    dd 0          ; starting LBA 32:47

dd 0xdead1979 ; disk signature
dw 0x0000     ; reserved

; MBR partition table

; partition entry 1
db 0x80             ; active/bootable parition
db 0x00, 0x00, 0x01 ; CHS first sector
db 0x7f             ; partition type
db 0x3f, 0xe0, 0xff ; CHS last sector
dd 0x00000800       ; LBA first sector
dd 0x01cdec00       ; number of partitions

times 16 db 0 ; partition entry 2
times 16 db 0 ; partition entry 3
times 16 db 0 ; partition entry 4

dw 0xaa55 ; boot signature
