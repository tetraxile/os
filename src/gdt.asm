GDT_start:

GDT_null:
    dq 0

GDT_code:
; base address = 0x00000000
; limit = 0x0fffff (4GiB)
; access byte = 0b10011010
;   P   | Present                    |  1
;   DPL | Descriptor Privilege Level | 00
;   S   | System                     |  1
;   E   | Executable                 |  1
;   DC  | Direction/Conforming       |  0
;   RW  | Read/Write access          |  1
;   A   | Accessed                   |  0
; flags = 0b1100
;   G  | Granularity | 1
;   DB | size flag   | 1
;   L  | Long mode   | 0
;   -- | reserved    | 0
    dw 0xffff    ; limit 0:15
    dw 0         ; base 0:15
    db 0         ; base 16:23
    db 10011010b ; access byte
    db 11001111b ; flags / limit 16:19
    db 0         ; base 24:31

GDT_data:
; base address = 0x00000000
; limit = 0x0fffff (4GiB)
; access byte = 0b10010010
;   P   | Present                    |  1
;   DPL | Descriptor Privilege Level | 00
;   S   | System                     |  1
;   E   | Executable                 |  0
;   DC  | Direction/Conforming       |  0
;   RW  | Read/Write access          |  1
;   A   | Accessed                   |  0
; flags = 0b1100
;   G  | Granularity | 1
;   DB | size flag   | 1
;   L  | Long mode   | 0
;   -- | reserved    | 0
    dw 0xffff    ; limit 0:15
    dw 0         ; base 0:15
    db 0         ; base 16:23
    db 10010010b ; access byte
    db 11001111b ; flags / limit 16:19
    db 0         ; base 24:31

GDT_end:

GDT_SIZE = GDT_end - GDT_start - 1
CODE_SEGMENT = GDT_code - GDT_start
DATA_SEGMENT = GDT_data - GDT_start

GDT_descriptor:
    dw GDT_SIZE  ; size
    dd GDT_start ; offset
