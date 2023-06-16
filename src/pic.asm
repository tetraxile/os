; http://www.brokenthorn.com/Resources/OSDevPic.html

PIC1_COMMAND = 0x20
PIC1_DATA    = 0x21
PIC2_COMMAND = 0xa0
PIC2_DATA    = 0xa1

PIC_EOI = 0x20

ICW1_ICW4 = 0x01 ; indicates that ICW4 will be present
ICW1_INIT = 0x10 ; initialization (required)

ICW4_8086 = 0x01 ; 8086/88 mode

; change the PIC interrupt vector offsets such that they
; don't conflict with the exception vectors. this involves
; reinitializing both PICs by sending them four
; initialization control words (ICWs).
remap_pic_offsets:
    ; ICW1 - both PICs
    mov al, ICW1_INIT or ICW1_ICW4
    out PIC1_COMMAND, al
    out PIC2_COMMAND, al

    ; ICW2 - primary PIC (IRQ 0..7 -> INT 32..39)
    mov al, 0x20
    out PIC1_DATA, al

    ; ICW2 - secondary PIC (IRQ 8..15 -> INT 40..47)
    mov al, 0x28
    out PIC2_DATA, al

    ; ICW3 - primary PIC (secondary PIC = IRQ 2)
    mov al, 00000100b
    out PIC1_DATA, al

    ; ICW3 - secondary PIC (primary PIC = IRQ 2)
    mov al, 0x02
    out PIC2_DATA, al

    ; ICW4 - both PICs
    mov al, ICW4_8086
    out PIC1_DATA, al
    out PIC2_DATA, al

    ; set PIC mask registers
    mov al, 11111100b
    out PIC1_DATA, al
    mov al, 11111111b
    out PIC2_DATA, al

    ret


; send an End Of Interrupt command to the PIC(s)
; * al - IRQ index (0-15)
send_eoi:
    cmp al, 8
    jl .primary_pic
    mov al, PIC_EOI
    out PIC2_COMMAND, al

.primary_pic:
    mov al, PIC_EOI
    out PIC1_COMMAND, al
    ret
