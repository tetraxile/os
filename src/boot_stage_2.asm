use32
org 0x7e00

KERNEL_ADDR = 0x10000

start_stage_2:
    jmp KERNEL_ADDR


times 0x400-($-$$) db 0