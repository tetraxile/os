use16
org 0x7c00

BOOT_STAGE_2_ADDR = 0x7e00

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

    call generate_memory_map

    ; load bootloader stage 2 and kernel into memory
    mov si, dap.boot_stage_2
    call read_sectors_from_disk

    mov si, dap.kernel
    call read_sectors_from_disk

    jmp BOOT_STAGE_2_ADDR


; read a contiguous group of sectors from the boot drive
; * si - pointer to disk address packet (DAP)
read_sectors_from_disk:
    mov ah, 0x42 ; extended read sectors
    mov dl, [drive_number]
    int 0x13
    jc .disk_error
    cmp ah, 0
    jnz .disk_error
    ret

.disk_error:
    mov bp, strings.disk_error
    call bios_print_string
    hlt


; generate a map of the available memory using BIOS interrupt 15h/ax=e820h
; and store it at address 0x2000, prefixed by the number of map entries (u32)
generate_memory_map:
    push edi
    push ebx
    push ebp

    mov di, 0x2004
    xor ebx, ebx
    xor ebp, ebp

    mov dword [es:di + 20], 1
    mov eax, 0xe820
    mov ecx, 24
    mov edx, 0x534d4150
    int 0x15

    jc .failed
    mov edx, 0x534d4150
    cmp eax, edx
    jne .failed
    test ebx, ebx
    jz .failed
    jmp .check_skip

.loop:
    mov dword [es:di + 20], 1
    mov eax, 0xe820
    mov ecx, 24
    int 0x15

    jc .end
    mov edx, 0x534d4150

.check_skip:
    jcxz .skip_entry
    cmp cl, 20
    jbe .no_acpi
    test byte [es:di + 20], 1
    je .skip_entry

.no_acpi:
    mov ecx, [es:di + 8]
    or ecx, [es:di + 12]
    jz .skip_entry
    inc ebp
    add di, 24

.skip_entry:
    test ebx, ebx
    jnz .loop

.end:
    mov [0x2000], ebp

    pop ebp
    pop ebx
    pop edi
    cli
    ret

.failed:
    mov bp, strings.memory_map_error
    call bios_print_string
    hlt


; write a cp437 string to the VGA text buffer at the cursor
; and move to the next line
; * bp - pointer to string, prefixed with length (1 byte)
bios_print_string:
    xor ax, ax
    mov es, ax

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


cursor_y db 0
drive_number db 0

strings:
.disk_error db 10, "disk error"
.memory_map_error db 16, "memory map error"
.no_cpuid db 8, "no CPUID"
.no_long_mode db 12, "no long mode"

times 0x198-($-$$) db 0

; disk address packets (https://en.wikipedia.org/wiki/INT_13H#INT_13h_AH=42h:_Extended_Read_Sectors_From_Drive)
dap:
.boot_stage_2:
    db 0x10       ; size of packet
    db 0          ; unused
    dw 0x2        ; number of sectors
    dd 0x00007e00 ; memory buffer (0000h:7e00h)
    dd 1          ; starting LBA 0:31
    dd 0          ; starting LBA 32:47

.kernel:
    db 0x10       ; size of packet
    db 0          ; unused
    dw 0x20       ; number of sectors
    dd 0x10000000 ; memory buffer (1000h:0000h)
    dd 3          ; starting LBA 0:31
    dd 0          ; starting LBA 32:47

times 0x1b8-($-$$) db 0

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

include "src/boot_stage_2.asm"
