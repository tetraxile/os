REG_DATA = 0x60
KEYBOARD_COMMAND_SET_LEDS         = 0xed
KEYBOARD_COMMAND_ECHO             = 0xee
KEYBOARD_COMMAND_SCANCODE_SET     = 0xf0
KEYBOARD_COMMAND_IDENTIFY         = 0xf2
KEYBOARD_COMMAND_SET_TYPEMATIC    = 0xf3
KEYBOARD_COMMAND_ENABLE_SCANNING  = 0xf4
KEYBOARD_COMMAND_DISABLE_SCANNING = 0xf5
KEYBOARD_COMMAND_DEFAULT_PARAMS   = 0xf6
KEYBOARD_RESPONSE_ACK    = 0xfa
KEYBOARD_RESPONSE_RESEND = 0xfe

REG_STATUS = 0x64
STATUS_OUTPUT_BUFFER = 00000001b
STATUS_INPUT_BUFFER  = 00000010b

REG_COMMAND = 0x64
COMMAND_READ_CONFIG_BYTE        = 0x20
COMMAND_WRITE_CONFIG_BYTE       = 0x60
COMMAND_DISABLE_PORT_2          = 0xa7
COMMAND_ENABLE_PORT_2           = 0xa8
COMMAND_TEST_PORT_2             = 0xa9
COMMAND_TEST_CONTROLLER         = 0xaa
COMMAND_TEST_PORT_1             = 0xab
COMMAND_DIAGNOSTIC_DUMP         = 0xac
COMMAND_DISABLE_PORT_1          = 0xad
COMMAND_ENABLE_PORT_1           = 0xae
COMMAND_READ_CONTROLLER_OUTPUT  = 0xd0
COMMAND_WRITE_CONTROLLER_OUTPUT = 0xd1

CONFIG_PORT_1_INTERRUPT = 00000001b
CONFIG_PORT_2_INTERRUPT = 00000010b
CONFIG_SYSTEM_FLAG      = 00000100b
CONFIG_PORT_1_DISABLE   = 00010000b
CONFIG_PORT_2_DISABLE   = 00100000b
CONFIG_PORT_1_TRANSLATE = 01000000b

OUTPUT_A20 = 00000010b

SELF_TEST_SUCCESS = 0x55
SELF_TEST_FAILURE = 0xfc

PORT_TEST_SUCCESS    = 0x00
PORT_TEST_CLOCK_LOW  = 0x01
PORT_TEST_CLOCK_HIGH = 0x02
PORT_TEST_DATA_LOW   = 0x03
PORT_TEST_DATA_HIGH  = 0x04

ps2_init:
    ; disable both devices
    mov al, COMMAND_DISABLE_PORT_1
    out REG_COMMAND, al
    mov al, COMMAND_DISABLE_PORT_2
    out REG_COMMAND, al

    ; flush the output buffer
    in al, REG_STATUS

    ; set the configuration byte
    mov al, COMMAND_READ_CONFIG_BYTE
    out REG_COMMAND, al
    in al, REG_DATA
    and al, not (CONFIG_PORT_1_INTERRUPT or CONFIG_PORT_2_INTERRUPT)
    mov bl, al

    mov al, COMMAND_WRITE_CONFIG_BYTE
    out REG_COMMAND, al
    mov al, bl
    out REG_DATA, al

    ; perform controller self test
    mov al, COMMAND_TEST_CONTROLLER
    out REG_COMMAND, al
    call ps2_wait_recv
    in al, REG_DATA
    cmp al, SELF_TEST_SUCCESS
    je .passed_self_test

    mov eax, .message_failed_self_test
    call print_string
    ; TODO: fatal error?

.passed_self_test:
    ; restore configuration byte for compatibility with hardware
    ; that resets it on a controller self-test
    mov al, COMMAND_WRITE_CONFIG_BYTE
    out REG_COMMAND, al
    mov al, bl
    out REG_DATA, al

    ; test port 1
    mov al, COMMAND_TEST_PORT_1
    out REG_COMMAND, al
    call ps2_wait_recv
    in al, REG_DATA
    cmp al, PORT_TEST_SUCCESS
    je .passed_port_test

    mov eax, .message_failed_port_1_test
    call print_string
    ; TODO: fatal error here too?

.passed_port_test:
    ; re-enable port 1 (won't be using port 2)
    mov al, COMMAND_ENABLE_PORT_1
    out REG_COMMAND, al

    call keyboard_init

    ; re-enable port interrupts
    mov al, COMMAND_READ_CONFIG_BYTE
    out REG_COMMAND, al
    in al, REG_DATA
    or al, CONFIG_PORT_1_INTERRUPT
    mov bl, al

    mov al, COMMAND_WRITE_CONFIG_BYTE
    out REG_COMMAND, al
    mov al, bl
    out REG_DATA, al

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
    mov al, COMMAND_DISABLE_PORT_1
    out REG_COMMAND, al

    call ps2_wait_send
    mov al, COMMAND_READ_CONTROLLER_OUTPUT
    out REG_COMMAND, al
    call ps2_wait_recv
    in al, REG_DATA
    push eax

    call ps2_wait_send
    mov al, COMMAND_WRITE_CONTROLLER_OUTPUT
    out REG_COMMAND, al
    call ps2_wait_send
    pop eax
    or al, OUTPUT_A20
    out REG_DATA, al

    call ps2_wait_send
    mov al, COMMAND_ENABLE_PORT_1
    out REG_COMMAND, al

    call ps2_wait_send

.end:
    ret


ps2_wait_send:
    in al, REG_STATUS
    test al, STATUS_INPUT_BUFFER
    jnz ps2_wait_send
    ret


ps2_wait_recv:
    in al, REG_STATUS
    test al, STATUS_OUTPUT_BUFFER
    jz ps2_wait_recv
    ret
