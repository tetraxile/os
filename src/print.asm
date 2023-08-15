; write a cp437 character to the VGA text buffer at the cursor
; and update the cursor (white text, black background)
; * al - character to print
print_char:
    push edi

    cmp al, 0xa
    je .newline

    mov cl, al

    ; calculate cursor offset in VGA text buffer
    movzx eax, byte [cursor_y]
    mov edx, 160
    mul edx
    movzx edx, byte [cursor_x]
    shl edx, 1
    add eax, edx

    ; write character and color into VGA text buffer
    mov edi, 0xb8000
    add edi, eax
    mov byte [edi], cl
    mov byte [edi + 1], 0x0f

    ; update cursor horizontal position
    inc byte [cursor_x]
    cmp byte [cursor_x], 80
    jl .end

.newline:
    mov byte [cursor_x], 0
    inc byte [cursor_y]

.end:
    pop edi
    ret


; write a cp437 string to the VGA text buffer at the cursor
; and update the cursor
; * eax - pointer to null-terminated string
print_string:
    push esi
    mov esi, eax

.loop:
    cmp byte [esi], 0
    je .end

    mov al, byte [esi]
    call print_char
    inc esi
    jmp .loop

.end:
    pop esi
    ret


; write an unsigned 8-bit integer to the VGA text buffer
; in hexadecimal at the cursor and update the cursor
; * al - unsigned 8-bit integer
print_u8_hex:
    mov bl, al
    mov cl, 4

.loop:
    mov al, bl
    shr al, cl
    and al, 0x0f

    cmp al, 0x0a
    jge .alpha

    add al, '0'
    jmp .print

.alpha:
    add al, 'a' - 0xa

.print:
    push ecx
    call print_char
    pop ecx

    cmp cl, 0
    jz .end
    sub cl, 4
    jmp .loop

.end:
    ret


; write an unsigned 8-bit integer to the VGA text buffer
; in binary at the cursor and update the cursor
; * al - unsigned 8-bit integer
print_u8_binary:
    mov bl, al
    mov cl, 7

.loop:
    mov al, bl
    shr al, cl
    and al, 0x01

    add al, '0'
    jmp .print

.print:
    push ecx
    call print_char
    pop ecx

    cmp cl, 0
    jz .end
    sub cl, 1
    jmp .loop

.end:
    ret


; write an unsigned 16-bit integer to the VGA text buffer
; in hexadecimal at the cursor and update the cursor
; * ax - unsigned 16-bit integer
print_u16_hex:
    mov bx, ax
    mov cl, 12

.loop:
    mov ax, bx
    shr ax, cl
    and ax, 0x0f

    cmp ax, 0x0a
    jge .alpha

    add ax, '0'
    jmp .print

.alpha:
    add ax, 'a' - 0xa

.print:
    push ecx
    call print_char
    pop ecx

    cmp cl, 0
    jz .end
    sub cl, 4
    jmp .loop

.end:
    ret


; write an unsigned 32-bit integer to the VGA text buffer
; in hexadecimal at the cursor and update the cursor
; * eax - unsigned 32-bit integer
print_u32_hex:
    mov ebx, eax
    mov cl, 28

.loop:
    mov eax, ebx
    shr eax, cl
    and eax, 0x0f

    cmp eax, 0x0a
    jge .alpha

    add eax, '0'
    jmp .print

.alpha:
    add eax, 'a' - 0xa

.print:
    push ecx
    call print_char
    pop ecx

    cmp cl, 0
    jz .end
    sub cl, 4
    jmp .loop

.end:
    ret


cursor_x db 0
cursor_y db 0
