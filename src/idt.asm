; idt.asm - Interrupt Descriptor Table

idt_init:
    mov eax, exc_division_error_handler
    mov ecx, 0x0
    call idt_entry_init

    mov eax, exc_debug_exception_handler
    mov ecx, 0x1
    call idt_entry_init

    mov eax, exc_nmi_handler
    mov ecx, 0x2
    call idt_entry_init

    mov eax, exc_breakpoint_handler
    mov ecx, 0x3
    call idt_entry_init

    mov eax, exc_overflow_handler
    mov ecx, 0x4
    call idt_entry_init
    
    mov eax, exc_bound_range_exceeded_handler
    mov ecx, 0x5
    call idt_entry_init

    mov eax, exc_invalid_opcode_handler
    mov ecx, 0x6
    call idt_entry_init
    
    mov eax, exc_device_not_available_handler
    mov ecx, 0x7
    call idt_entry_init

    mov eax, exc_double_fault_handler
    mov ecx, 0x8
    call idt_entry_init

    mov eax, exc_invalid_tss_handler
    mov ecx, 0xa
    call idt_entry_init

    mov eax, exc_segment_not_present_handler
    mov ecx, 0xb
    call idt_entry_init

    mov eax, exc_stack_segment_fault_handler
    mov ecx, 0xc
    call idt_entry_init

    mov eax, exc_general_protection_fault_handler
    mov ecx, 0xd
    call idt_entry_init

    mov eax, exc_page_fault_handler
    mov ecx, 0xe
    call idt_entry_init

    mov eax, exc_x87_float_exception_handler
    mov ecx, 0x10
    call idt_entry_init

    mov eax, exc_alignment_check_handler
    mov ecx, 0x11
    call idt_entry_init

    mov eax, exc_machine_check_handler
    mov ecx, 0x12
    call idt_entry_init

    mov eax, exc_simd_float_exception_handler
    mov ecx, 0x13
    call idt_entry_init

    mov eax, exc_virtualisation_exception_handler
    mov ecx, 0x14
    call idt_entry_init

    mov eax, exc_control_protection_exception_handler
    mov ecx, 0x15
    call idt_entry_init

    mov eax, irq_pit_handler
    mov ecx, 0x20
    call idt_entry_init

    mov eax, irq_keyboard_handler
    mov ecx, 0x21
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


; initialise an IDT entry to point at a handler function
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

; division error - divided a number by 0 using DIV or IDIV instruction
exc_division_error_handler:
    mov eax, exc_message.division_error
    call print_string
    cli
    hlt

; debug exception - various causes
exc_debug_exception_handler:
    mov eax, exc_message.debug_exception
    call print_string
    cli
    hlt

; non-maskable interrupt - hardware failure; watchdog timer
exc_nmi_handler:
    mov eax, exc_message.nmi
    call print_string
    cli
    hlt

; breakpoint - INT3 instruction
exc_breakpoint_handler:
    mov eax, exc_message.breakpoint
    call print_string
    cli
    hlt

; overflow - INTO instruction if RFLAGS.OF = 1
exc_overflow_handler:
    mov eax, exc_message.overflow
    call print_string
    cli
    hlt

; bound range exceeded - BOUND instruction failed (input is out of provided array bounds)
exc_bound_range_exceeded_handler:
    mov eax, exc_message.bound_range_exceeded
    call print_string
    cli
    hlt

; invalid opcode - invalid/undefined opcode/prefixes (can use UD instruction)
exc_invalid_opcode_handler:
    mov eax, exc_message.invalid_opcode
    call print_string
    cli
    hlt

; device not available - FPU instruction attempted with no FPU
exc_device_not_available_handler:
    mov eax, exc_message.device_not_available
    call print_string
    cli
    hlt

; double fault - unhandled exception; exception inside exception handler
; * eax: error code (always zero)
exc_double_fault_handler:
    mov eax, exc_message.double_fault
    call print_string

    pop eax

    cli
    hlt

; invalid task state segment - invalid segment selector during task switch
; * eax: segment selector index
exc_invalid_tss_handler:
    mov eax, exc_message.invalid_tss
    call print_string

    pop eax

    cli
    hlt

; segment not present - loaded (non-stack) segment with present bit = 0
; * eax: segment selector index
exc_segment_not_present_handler:
    mov eax, exc_message.segment_not_present
    call print_string

    pop eax

    cli
    hlt

; stack segment fault - loaded stack segment with present bit = 0, or PUSH/POP with malformed stack address
; * eax: stack segment selector index
exc_stack_segment_fault_handler:
    mov eax, exc_message.stack_segment_fault
    call print_string

    pop eax

    cli
    hlt

; general protection fault - various causes
; * eax: segment selector index, if exception is segment related
exc_general_protection_fault_handler:
    mov eax, exc_message.general_protection_fault
    call print_string

    pop eax

    cli
    hlt

; page fault - page dir/table not present; protection check failed; page dir/table reserved bit = 1
; * eax: page fault error code
exc_page_fault_handler:
    mov eax, exc_message.page_fault
    call print_string

    pop eax

    cli
    hlt

; x87 floating point exception - FWAIT/WAIT executed when CR0.NE = 1 and x87 floating point exception pending
exc_x87_float_exception_handler:
    mov eax, exc_message.x87_float_exception
    call print_string
    cli
    hlt

; alignment check - unaligned memory access when alignment checking is enabled (CR0.AM and RFLAGS.AC = 1)
exc_alignment_check_handler:
    mov eax, exc_message.alignment_check
    call print_string

    pop eax

    cli
    hlt

; machine check - model specific errors if CR4.MCE = 1
exc_machine_check_handler:
    mov eax, exc_message.machine_check
    call print_string
    cli
    hlt

; SIMD float exception - unmasked 128-bit floating point exception when CR4.OSXMMEXCPT = 1
exc_simd_float_exception_handler:
    mov eax, exc_message.simd_float_exception
    call print_string
    cli
    hlt

exc_virtualisation_exception_handler:
    mov eax, exc_message.virtualisation_exception
    call print_string
    cli
    hlt

exc_control_protection_exception_handler:
    mov eax, exc_message.control_protection_exception
    call print_string

    pop eax

    cli
    hlt


; ========== IRQS ==========

; programmable interrupt timer
irq_pit_handler:
    ; mov al, '.'
    ; call print_char

    mov al, 0x0
    call pic_send_eoi
    iret

; PS/2 keyboard
irq_keyboard_handler:
    call kbd_handle_irq

    mov al, 0x1
    call pic_send_eoi
    iret

; COM2
irq_3_handler:
    mov al, 0x3
    call pic_send_eoi
    iret

; COM1
irq_4_handler:
    mov al, 0x4
    call pic_send_eoi
    iret

; LPT2
irq_5_handler:
    mov al, 0x5
    call pic_send_eoi
    iret

; floppy disk
irq_6_handler:
    mov al, 0x6
    call pic_send_eoi
    iret

; LPT1 / spurious interrupt (shouldn't send EOI!)
irq_7_handler:
    mov al, 0x7
    call pic_send_eoi
    iret

; CMOS real-time clock
irq_8_handler:
    mov al, 0x8
    call pic_send_eoi
    iret

irq_9_handler:
    mov al, 0x9
    call pic_send_eoi
    iret

irq_10_handler:
    mov al, 0xa
    call pic_send_eoi
    iret

irq_11_handler:
    mov al, 0xb
    call pic_send_eoi
    iret

; PS/2 mouse
irq_12_handler:
    mov al, 0xc
    call pic_send_eoi
    iret

; FPU / coprocessor / inter-processor
irq_13_handler:
    mov al, 0xd
    call pic_send_eoi
    iret

; primary ATA hard disk
irq_14_handler:
    mov al, 0xe
    call pic_send_eoi
    iret

; secondary ATA hard disk
irq_15_handler:
    mov al, 0xf
    call pic_send_eoi
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
.invalid_tss db "EXCEPTION: invalid tss", 0x0a, 0
.segment_not_present db "EXCEPTION: segment not present", 0x0a, 0
.stack_segment_fault db "EXCEPTION: stack segment fault", 0x0a, 0
.general_protection_fault db "EXCEPTION: general protection fault", 0x0a, 0
.page_fault db "EXCEPTION: page fault", 0x0a, 0
.x87_float_exception db "EXCEPTION: x87 float exception", 0x0a, 0
.alignment_check db "EXCEPTION: alignment check", 0x0a, 0
.machine_check db "EXCEPTION: machine check", 0x0a, 0
.simd_float_exception db "EXCEPTION: simd float exception", 0x0a, 0
.virtualisation_exception db "EXCEPTION: virtualisation exception", 0x0a, 0
.control_protection_exception db "EXCEPTION: control protection exception", 0x0a, 0
