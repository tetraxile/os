; ps2.asm - PS/2 controller

PS2_DATA = 0x60
PS2_KBD_CMD_SET_LEDS         = 0xed
PS2_KBD_CMD_ECHO             = 0xee
PS2_KBD_CMD_SCANCODE_SET     = 0xf0
PS2_KBD_CMD_IDENTIFY         = 0xf2
PS2_KBD_CMD_SET_TYPEMATIC    = 0xf3
PS2_KBD_CMD_ENABLE_SCANNING  = 0xf4
PS2_KBD_CMD_DISABLE_SCANNING = 0xf5
PS2_KBD_CMD_DEFAULT_PARAMS   = 0xf6
PS2_KBD_RESPONSE_ACK         = 0xfa
PS2_KBD_RESPONSE_RESEND      = 0xfe

PS2_STATUS = 0x64
PS2_STATUS_OUTPUT_BUFFER = 00000001b
PS2_STATUS_INPUT_BUFFER  = 00000010b

PS2_COMMAND = 0x64
PS2_CMD_READ_CONFIG_BYTE        = 0x20
PS2_CMD_WRITE_CONFIG_BYTE       = 0x60
PS2_CMD_DISABLE_PORT_2          = 0xa7
PS2_CMD_ENABLE_PORT_2           = 0xa8
PS2_CMD_TEST_PORT_2             = 0xa9
PS2_CMD_TEST_CONTROLLER         = 0xaa
PS2_CMD_TEST_PORT_1             = 0xab
PS2_CMD_DIAGNOSTIC_DUMP         = 0xac
PS2_CMD_DISABLE_PORT_1          = 0xad
PS2_CMD_ENABLE_PORT_1           = 0xae
PS2_CMD_READ_CONTROLLER_OUTPUT  = 0xd0
PS2_CMD_WRITE_CONTROLLER_OUTPUT = 0xd1

PS2_CFG_PORT_1_INTERRUPT = 00000001b
PS2_CFG_PORT_2_INTERRUPT = 00000010b
PS2_CFG_SYSTEM_FLAG      = 00000100b
PS2_CFG_PORT_1_DISABLE   = 00010000b
PS2_CFG_PORT_2_DISABLE   = 00100000b
PS2_CFG_PORT_1_TRANSLATE = 01000000b

PS2_OUTPUT_A20 = 00000010b

PS2_SELF_TEST_SUCCESS = 0x55
PS2_SELF_TEST_FAILURE = 0xfc

PS2_PORT_TEST_SUCCESS    = 0x00
PS2_PORT_TEST_CLOCK_LOW  = 0x01
PS2_PORT_TEST_CLOCK_HIGH = 0x02
PS2_PORT_TEST_DATA_LOW   = 0x03
PS2_PORT_TEST_DATA_HIGH  = 0x04

ps2_init:
    push ebx

    ; disable both devices
    mov al, PS2_CMD_DISABLE_PORT_1
    out PS2_COMMAND, al
    mov al, PS2_CMD_DISABLE_PORT_2
    out PS2_COMMAND, al

    ; flush the output buffer
    in al, PS2_STATUS

    ; set the configuration byte
    mov al, PS2_CMD_READ_CONFIG_BYTE
    out PS2_COMMAND, al
    in al, PS2_DATA
    and al, not (PS2_CFG_PORT_1_INTERRUPT or PS2_CFG_PORT_2_INTERRUPT)
    mov bl, al

    mov al, PS2_CMD_WRITE_CONFIG_BYTE
    out PS2_COMMAND, al
    mov al, bl
    out PS2_DATA, al

    ; perform controller self test
    mov al, PS2_CMD_TEST_CONTROLLER
    out PS2_COMMAND, al
    call ps2_wait_recv
    in al, PS2_DATA
    cmp al, PS2_SELF_TEST_SUCCESS
    je .passed_self_test

    mov eax, .message_failed_self_test
    call print_string
    ; TODO: fatal error?

.passed_self_test:
    ; restore configuration byte for compatibility with hardware
    ; that resets it on a controller self-test
    mov al, PS2_CMD_WRITE_CONFIG_BYTE
    out PS2_COMMAND, al
    mov al, bl
    out PS2_DATA, al

    ; test port 1
    mov al, PS2_CMD_TEST_PORT_1
    out PS2_COMMAND, al
    call ps2_wait_recv
    in al, PS2_DATA
    cmp al, PS2_PORT_TEST_SUCCESS
    je .passed_port_test

    mov eax, .message_failed_port_1_test
    call print_string
    ; TODO: fatal error here too?

.passed_port_test:
    ; re-enable port 1 (won't be using port 2)
    mov al, PS2_CMD_ENABLE_PORT_1
    out PS2_COMMAND, al

    call keyboard_init

    ; re-enable port interrupts
    mov al, PS2_CMD_READ_CONFIG_BYTE
    out PS2_COMMAND, al
    in al, PS2_DATA
    or al, PS2_CFG_PORT_1_INTERRUPT
    mov bl, al

    mov al, PS2_CMD_WRITE_CONFIG_BYTE
    out PS2_COMMAND, al
    mov al, bl
    out PS2_DATA, al

    pop ebx
    ret

.message_failed_self_test:
    db "PS/2 controller failed self-test", 0xa, 0

.message_failed_port_1_test:
    db "PS/2 port 1 failed test", 0xa, 0


; currently unused but might be useful
keyboard_init:
    ret


enable_a20:
    ; check if a20 line is enabled; if a20 line is
    ; disabled, addresses 0x012345 and 0x112345 should
    ; point to the same place in memory.
    mov eax, 0x20040729
    mov edx, 0x20221101
    mov dword [0x012345], eax
    mov dword [0x112345], edx
    cmp dword [0x012345], edx
    jne .end

    call ps2_wait_send
    mov al, PS2_CMD_DISABLE_PORT_1
    out PS2_COMMAND, al

    call ps2_wait_send
    mov al, PS2_CMD_READ_CONTROLLER_OUTPUT
    out PS2_COMMAND, al
    call ps2_wait_recv
    in al, PS2_DATA
    push eax

    call ps2_wait_send
    mov al, PS2_CMD_WRITE_CONTROLLER_OUTPUT
    out PS2_COMMAND, al
    call ps2_wait_send
    pop eax
    or al, PS2_OUTPUT_A20
    out PS2_DATA, al

    call ps2_wait_send
    mov al, PS2_CMD_ENABLE_PORT_1
    out PS2_COMMAND, al

    call ps2_wait_send

.end:
    ret


ps2_wait_send:
    in al, PS2_STATUS
    test al, PS2_STATUS_INPUT_BUFFER
    jnz ps2_wait_send
    ret


ps2_wait_recv:
    in al, PS2_STATUS
    test al, PS2_STATUS_OUTPUT_BUFFER
    jz ps2_wait_recv
    ret


; assumes scancode set 1 (XT)
ps2_kbd_handler:
    push eax
    push edx

    ; read byte from keyboard controller    
    xor eax, eax
    in al, PS2_DATA
    mov edx, eax

    test eax, 0x80 ; bit 7 is press/release flag
    setnz byte [.is_released]

    and eax, 0x7f ; mask out press/release flag

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

.use_keycode:
    call print_u8_hex

    mov al, ' '
    call print_char

    ; make sure not to clear `is_prtsc_pressed`!
    ; releasing the prtsc key relies on it keeping its value.
    mov word [.is_extended], 0
    mov byte [.pause_break], 0

.end:
    pop edx
    pop eax
    ret

.is_extended      db 0
.is_released      db 0
.pause_break      db 0
.is_prtsc_pressed db 0


; PS/2 scancode set 1 -> OS keycodes
standard_scancode_map:
    ;    _0    _1    _2    _3    _4    _5    _6    _7    _8    _9    _a    _b    _c    _d    _e    _f
    db 0xff, 0x00, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x40 ; 0_
    db 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0xa0, 0x61, 0x62 ; 1_
    db 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6a, 0x6b, 0x20, 0x80, 0x6c, 0x82, 0x83, 0x84, 0x85 ; 2_
    db 0x86, 0x87, 0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x33, 0xa2, 0xa3, 0x60, 0x01, 0x02, 0x03, 0x04, 0x05 ; 3_
    db 0x06, 0x07, 0x08, 0x09, 0x0a, 0x31, 0x0e, 0x51, 0x52, 0x53, 0x34, 0x6d, 0x6e, 0x6f, 0x54, 0x8e ; 4_
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
