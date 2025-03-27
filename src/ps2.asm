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

include "src/keyboard.asm"
