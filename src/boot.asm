use16
org 0x7c00

start:
    cli ; disable interrupts for now
    cld ; set direction flag to auto-increment

    ; set video mode to 80x25 4-bit color text (mode 0x03)
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ; disable cursor (set bit 5 of `ch`)
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
    mov bp, strings.hello
    call bios_print_string

    hlt


; write a cp437 string to the VGA text buffer at the cursor
; and move to the next line
; * es:bp - pointer to string, prefixed with length (1 byte)
bios_print_string:
    ; get length from string
    movzx cx, byte [es:bp]
    inc bp

    ; print string (white text on black background)
    mov ah, 0x13
    mov al, 0x00
    mov bh, 0x00
    mov bl, 0x0f
    mov dh, [cursor_y]
    mov dl, 0
    int 0x10

    ; move the cursor to the next line
    inc byte [cursor_y]
    ret

cursor_y db 0

strings:
.hello db 11, "hello world"


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
