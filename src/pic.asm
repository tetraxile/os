; pic.asm - Programmable Interrupt Controller
; http://www.brokenthorn.com/Resources/OSDevPic.html

; I/O ports for interacting with both PICs
PIC1_COMMAND = 0x20
PIC1_DATA    = 0x21
PIC2_COMMAND = 0xa0
PIC2_DATA    = 0xa1

; operation control words (OCWs)
PIC_EOI = 0x20

; initialise both PICs. after entering protected mode the PICs expect to be initialised.
; this involves sending both of them four initialisation control words (ICWs).
; in protected mode, the PICs' default IRQ vectors are mapped from 0x0 to 0xf.
; this conflicts with the CPU's exception vectors, so this subroutine changes them to 0x20 - 0x2f.
pic_init:
    ; ICW1 - sent to both PICs
    ; bit 4 sets the PIC to initialisation mode
    ; bit 0 indicates that ICW4 will be present
    mov al, 00010001b
    out PIC1_COMMAND, al
    out PIC2_COMMAND, al

    ; ICW2 - sets the base address of the IRQ vector tables.
    ; each of the control words after the first one use the PICs' data registers, instead of the command registers.
    ; primary PIC (IRQ 0x0..0x7 -> int 0x20..0x27)
    mov al, 0x20
    out PIC1_DATA, al

    ; secondary PIC (IRQ 0x8..0xf -> int 0x28..0x2f)
    mov al, 0x28
    out PIC2_DATA, al

    ; ICW3 - tells the PICs what IRQ lines to use when communicating with each other.
    ; here they are set to use IRQ 2.
    ; primary PIC - set bit 2, meaning IRQ 2
    mov al, 00000100b
    out PIC1_DATA, al

    ; secondary PIC - send the value 2, meaning primary PIC's IRQ 2
    mov al, 0x02
    out PIC2_DATA, al

    ; ICW4 - sent to both PICs
    ; here only bit 0 is set, telling the PIC to use 80x86 mode
    mov al, 00000001b
    out PIC1_DATA, al
    out PIC2_DATA, al

    ; set PIC mask registers to zero, enabling all IRQs
    mov al, 00000000b
    out PIC1_DATA, al
    out PIC2_DATA, al

    ret


; send an End Of Interrupt command to the PIC(s).
; if the IRQ is on the secondary PIC, the EOI must be sent to the primary PIC as well.
; * al - IRQ index (0-15)
pic_send_eoi:
    cmp al, 8
    jl .primary_pic
    mov al, PIC_EOI
    out PIC2_COMMAND, al

.primary_pic:
    mov al, PIC_EOI
    out PIC1_COMMAND, al
    ret
