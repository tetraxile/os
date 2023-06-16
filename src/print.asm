; write a cp437 character to the VGA text buffer at the cursor
; and update the cursor (white text, black background)
; * al - character to print
print_char:
    push edi

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

    ; update cursor vertical position
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

    cmp byte [esi], 0xa
    je .newline

    mov al, byte [esi]
    call print_char
    inc esi
    jmp .loop

.newline:
    mov byte [cursor_x], 0
    inc byte [cursor_y]

.end:
    pop esi
    ret


cursor_x db 0
cursor_y db 2
