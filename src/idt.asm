idt_init:
    mov eax, division_error_handler
    mov ecx, 0x0
    call idt_entry_init

    mov eax, debug_exception_handler
    mov ecx, 0x1
    call idt_entry_init

    mov eax, nmi_handler
    mov ecx, 0x2
    call idt_entry_init

    mov eax, breakpoint_handler
    mov ecx, 0x3
    call idt_entry_init

    mov eax, overflow_handler
    mov ecx, 0x4
    call idt_entry_init
    
    mov eax, bound_range_exceeded_handler
    mov ecx, 0x5
    call idt_entry_init

    mov eax, invalid_opcode_handler
    mov ecx, 0x6
    call idt_entry_init
    
    mov eax, device_not_available_handler
    mov ecx, 0x7
    call idt_entry_init

    mov eax, double_fault_handler
    mov ecx, 0x8
    call idt_entry_init

    mov eax, coprocessor_segment_overrun_handler
    mov ecx, 0x9
    call idt_entry_init

    mov eax, invalid_tss_handler
    mov ecx, 0xa
    call idt_entry_init

    mov eax, segment_not_present_handler
    mov ecx, 0xb
    call idt_entry_init

    mov eax, stack_segment_fault_handler
    mov ecx, 0xc
    call idt_entry_init

    mov eax, general_protection_fault_handler
    mov ecx, 0xd
    call idt_entry_init

    mov eax, page_fault_handler
    mov ecx, 0xe
    call idt_entry_init

    mov eax, int_15_handler
    mov ecx, 0xf
    call idt_entry_init

    mov eax, x87_float_exception_handler
    mov ecx, 0x10
    call idt_entry_init

    mov eax, alignment_check_handler
    mov ecx, 0x11
    call idt_entry_init

    mov eax, machine_check_handler
    mov ecx, 0x12
    call idt_entry_init

    mov eax, simd_float_exception_handler
    mov ecx, 0x13
    call idt_entry_init

    mov eax, virtualization_exception_handler
    mov ecx, 0x14
    call idt_entry_init

    mov eax, control_protection_exception_handler
    mov ecx, 0x15
    call idt_entry_init

    mov eax, pit_irq_handler
    mov ecx, 0x20
    call idt_entry_init

    mov eax, keyboard_irq_handler
    mov ecx, 0x21
    call idt_entry_init

    mov eax, irq_2_handler
    mov ecx, 0x22
    call idt_entry_init

    mov eax, irq_3_handler
    mov ecx, 0x23
    call idt_entry_init

    mov eax, irq_4_handler
    mov ecx, 0x24
    call idt_entry_init

    mov eax, irq_5_handler
    mov ecx, 0x25
    call idt_entry_init

    mov eax, irq_6_handler
    mov ecx, 0x26
    call idt_entry_init

    mov eax, irq_7_handler
    mov ecx, 0x27
    call idt_entry_init

    mov eax, irq_8_handler
    mov ecx, 0x28
    call idt_entry_init

    mov eax, irq_9_handler
    mov ecx, 0x29
    call idt_entry_init

    mov eax, irq_10_handler
    mov ecx, 0x2a
    call idt_entry_init

    mov eax, irq_11_handler
    mov ecx, 0x2b
    call idt_entry_init

    mov eax, irq_12_handler
    mov ecx, 0x2c
    call idt_entry_init

    mov eax, irq_13_handler
    mov ecx, 0x2d
    call idt_entry_init

    mov eax, irq_14_handler
    mov ecx, 0x2e
    call idt_entry_init

    mov eax, irq_15_handler
    mov ecx, 0x2f
    call idt_entry_init

    ret


; initialize an IDT entry to point at a handler function
; * eax - pointer to handler function
; * ecx - IDT index
idt_entry_init:
    shl ecx, 3

    mov edx, eax
    and edx, 0x0000ffff
    or  edx, 0x00080000
    mov [ecx], edx

    and eax, 0xffff0000
    or  eax, 0x00008e00
    mov [ecx + 4], eax

    ret


; ========== EXCEPTIONS ==========

division_error_handler:
    mov eax, exc_message.division_error
    call print_string
    cli
    hlt

debug_exception_handler:
    mov eax, exc_message.debug_exception
    call print_string
    cli
    hlt

nmi_handler:
    mov eax, exc_message.nmi
    call print_string
    cli
    hlt

breakpoint_handler:
    mov eax, exc_message.breakpoint
    call print_string
    cli
    hlt

overflow_handler:
    mov eax, exc_message.overflow
    call print_string
    cli
    hlt

bound_range_exceeded_handler:
    mov eax, exc_message.bound_range_exceeded
    call print_string
    cli
    hlt

invalid_opcode_handler:
    mov eax, exc_message.invalid_opcode
    call print_string
    cli
    hlt

device_not_available_handler:
    mov eax, exc_message.device_not_available
    call print_string
    cli
    hlt

double_fault_handler:
    mov eax, exc_message.double_fault
    call print_string

    pop eax

    cli
    hlt

coprocessor_segment_overrun_handler:
    mov eax, exc_message.coprocessor_segment_overrun
    call print_string
    cli
    hlt

invalid_tss_handler:
    mov eax, exc_message.invalid_tss
    call print_string

    pop eax

    cli
    hlt

segment_not_present_handler:
    mov eax, exc_message.segment_not_present
    call print_string

    pop eax

    cli
    hlt

stack_segment_fault_handler:
    mov eax, exc_message.stack_segment_fault
    call print_string

    pop eax

    cli
    hlt

general_protection_fault_handler:
    mov eax, exc_message.general_protection_fault
    call print_string

    pop eax

    cli
    hlt

page_fault_handler:
    mov eax, exc_message.page_fault
    call print_string

    pop eax

    cli
    hlt

int_15_handler:
    mov eax, exc_message.int_15
    call print_string
    cli
    hlt

x87_float_exception_handler:
    mov eax, exc_message.x87_float_exception
    call print_string
    cli
    hlt

alignment_check_handler:
    mov eax, exc_message.alignment_check
    call print_string

    pop eax

    cli
    hlt

machine_check_handler:
    mov eax, exc_message.machine_check
    call print_string
    cli
    hlt

simd_float_exception_handler:
    mov eax, exc_message.simd_float_exception
    call print_string
    cli
    hlt

virtualization_exception_handler:
    mov eax, exc_message.virtualization_exception
    call print_string
    cli
    hlt

control_protection_exception_handler:
    mov eax, exc_message.control_protection_exception
    call print_string

    pop eax

    cli
    hlt


; ========== IRQS ==========

pit_irq_handler:
    ; mov al, '.'
    ; call print_char

    mov al, 0x0
    call send_eoi
    iret

; assumes scancode set 1 (XT)
keyboard_irq_handler:
    push eax
    push edx
    
    xor eax, eax
    in al, 0x60
    mov edx, eax

    jmp .use_keycode
    
    test eax, 0x80
    setnz byte [.is_released]

    and eax, 0x7f

    cmp byte [.pause_break], 1
    je .pause_break_byte_1

    cmp byte [.pause_break], 2
    je .pause_break_byte_2

    cmp byte [.is_extended], 1
    je .read_extended_scancode

    cmp edx, 0xe1
    je .set_pause_break

    cmp edx, 0xe0
    je .set_extended

    mov edx, standard_scancode_map
    mov al, [edx + eax]
    jmp .use_keycode

.set_extended:
    mov byte [.is_extended], 1
    jmp .end

.read_extended_scancode:
    cmp eax, 0x2a
    je .set_prtsc

    cmp eax, 0x37
    je .prtsc_byte_2

    mov edx, extended_scancode_map
    mov al, [edx + eax]
    jmp .use_keycode

.set_prtsc:
    mov al, [.is_released]
    xor al, 1
    mov byte [.is_prtsc_pressed], al
    mov byte [.is_extended], 0
    jmp .end

.prtsc_byte_2:
    mov edx, 0x0d
    mov eax, 0xff
    cmp byte [.is_prtsc_pressed], 1
    cmove eax, edx
    jmp .use_keycode

.set_pause_break:
    mov byte [.pause_break], 1
    jmp .end

.pause_break_byte_1:
    cmp eax, 0x1d
    je .inc_pause_break
    
    mov al, 0xff
    jmp .use_keycode

.inc_pause_break:
    inc byte [.pause_break]
    jmp .end

.pause_break_byte_2:
    mov edx, 0x0f
    cmp eax, 0x45
    mov eax, 0xff
    cmove eax, edx
    jmp .use_keycode

.use_keycode:
    call print_u8_hex

    mov al, ' '
    call print_char

    ; make sure not to clear `is_prtsc_pressed`!
    ; releasing the prtsc key relies on it keeping its value.
    mov word [.is_extended], 0
    mov byte [.pause_break], 0

.end:
    mov al, 1
    call send_eoi

    pop edx
    pop eax
    iret

.is_extended      db 0
.is_released      db 0
.pause_break      db 0
.is_prtsc_pressed db 0

irq_2_handler:
    mov al, 0x2
    call send_eoi
    iret

irq_3_handler:
    mov al, 0x3
    call send_eoi
    iret

irq_4_handler:
    mov al, 0x4
    call send_eoi
    iret

irq_5_handler:
    mov al, 0x5
    call send_eoi
    iret

irq_6_handler:
    mov al, 0x6
    call send_eoi
    iret

irq_7_handler:
    mov al, 0x7
    call send_eoi
    iret

irq_8_handler:
    mov al, 0x8
    call send_eoi
    iret

irq_9_handler:
    mov al, 0x9
    call send_eoi
    iret

irq_10_handler:
    mov al, 0xa
    call send_eoi
    iret

irq_11_handler:
    mov al, 0xb
    call send_eoi
    iret

irq_12_handler:
    mov al, 0xc
    call send_eoi
    iret

irq_13_handler:
    mov al, 0xd
    call send_eoi
    iret

irq_14_handler:
    mov al, 0xe
    call send_eoi
    iret

irq_15_handler:
    mov al, 0xf
    call send_eoi
    iret


exc_message:
.division_error db "EXCEPTION: division error", 0x0a, 0
.debug_exception db "EXCEPTION: debug exception", 0x0a, 0
.nmi db "EXCEPTION: nmi", 0x0a, 0
.breakpoint db "EXCEPTION: breakpoint", 0x0a, 0
.overflow db "EXCEPTION: overflow", 0x0a, 0
.bound_range_exceeded db "EXCEPTION: bound range exceeded", 0x0a, 0
.invalid_opcode db "EXCEPTION: invalid opcode", 0x0a, 0
.device_not_available db "EXCEPTION: device not available", 0x0a, 0
.double_fault db "EXCEPTION: double fault", 0x0a, 0
.coprocessor_segment_overrun db "EXCEPTION: coprocessor segment overrun", 0x0a, 0
.invalid_tss db "EXCEPTION: invalid tss", 0x0a, 0
.segment_not_present db "EXCEPTION: segment not present", 0x0a, 0
.stack_segment_fault db "EXCEPTION: stack segment fault", 0x0a, 0
.general_protection_fault db "EXCEPTION: general protection fault", 0x0a, 0
.page_fault db "EXCEPTION: page fault", 0x0a, 0
.int_15 db "EXCEPTION: int 15", 0x0a, 0
.x87_float_exception db "EXCEPTION: x87 float exception", 0x0a, 0
.alignment_check db "EXCEPTION: alignment check", 0x0a, 0
.machine_check db "EXCEPTION: machine check", 0x0a, 0
.simd_float_exception db "EXCEPTION: simd float exception", 0x0a, 0
.virtualization_exception db "EXCEPTION: virtualization exception", 0x0a, 0
.control_protection_exception db "EXCEPTION: control protection exception", 0x0a, 0


; PS/2 scancode set 1 -> OS keycodes
standard_scancode_map:
    ;    _0    _1    _2    _3    _4    _5    _6    _7    _8    _9    _a    _b    _c    _d    _e    _f
    db 0xff, 0x00, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x40 ; 0_
    db 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0xa0, 0x61, 0x62 ; 1_
    db 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6a, 0x6b, 0x20, 0x80, 0x6c, 0x82, 0x83, 0x84, 0x85 ; 2_
    db 0x86, 0x87, 0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x33, 0xa2, 0xa3, 0x60, 0x01, 0x02, 0x03, 0x04, 0x05 ; 3_
    db 0x06, 0x07, 0x08, 0x09, 0x0a, 0x31, 0x0e, 0x51, 0x52, 0x53, 0x34, 0x6d, 0x6e, 0x6f, 0x54, 0x0e ; 4_
    db 0x8f, 0x90, 0xab, 0xac, 0xff, 0xff, 0x81, 0x0b, 0x0c, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; 5_
    db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; 6_
    db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; 7_

extended_scancode_map:
    ;    _0    _1    _2    _3    _4    _5    _6    _7    _8    _9    _a    _b    _c    _d    _e    _f
    db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; 0_
    db 0xc3, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc4, 0xff, 0xff, 0x91, 0xa7, 0xff, 0xff ; 1_
    db 0xc5, 0xcd, 0xc6, 0xff, 0xc7, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc8, 0xff ; 2_
    db 0xc9, 0xff, 0xce, 0xff, 0xff, 0x32, 0xff, 0xff, 0xa4, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; 3_
    db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x2f, 0x8d, 0x30, 0xff, 0xa8, 0xff, 0xaa, 0xff, 0x4f ; 4_
    db 0xa9, 0x50, 0x2e, 0x4e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xa1, 0xa5, 0xa6, 0xc0, 0xc1 ; 5_
    db 0xff, 0xff, 0xff, 0xc2, 0xff, 0xcf, 0xd0, 0xd1, 0xd2, 0xd3, 0xd4, 0xca, 0xcb, 0xcc, 0xff, 0xff ; 6_
    db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; 7_