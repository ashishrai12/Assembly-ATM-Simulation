;====================================================================
; Title: Password Protected ATM System
; Toolchain: as31 (Linux)
; Processor: 8051 (89C51)
;====================================================================

; --- Bit Definitions ---
.equ P1_0,    0x90
.equ P1_1,    0x91
.equ P1_2,    0x92
.equ P1_6,    0x96
.equ P1_7,    0x97
.equ P3_6,    0xB6

; --- Reset Vector ---
.org 0x0000
    ljmp MAIN

; --- Data Constants ---
.org 0x0050
STR_ACCESS:
    .byte "ACCESS", 0

.org 0x0095
STR_PIN:
    .byte "PIN:   ", 0

.org 0x00B0
PIN_CODE:
    .byte '1','2','3','4'

; --- Main Program ---
.org 0x0100
MAIN:
    mov P1, #0xFF       ; Set P1 for input
    mov P2, #0x07       ; Initialize Keypad Columns
    mov P0, #0x00       ; Clear LCD Data Port

    ; Display "PIN: "
    mov dptr, #STR_PIN
    acall UPDATE_LCD
    
    ; Perform PIN Authentication
    acall PIN_CHECK
    
    ; If PIN correct, display "ACCESS"
    mov dptr, #STR_ACCESS
    acall UPDATE_LCD
    
ATM_LOOP:
    mov a, P1
    anl a, #0x07         ; Mask lower 3 bits
    jz ATM_LOOP          ; Wait for input
    
    ; Check individual bits
    mov a, P1
    
    ; Check Bit 0 (Active High logic assumed)
    jnb ACC.0, CHECK_DEP 
    ljmp WITHDRAW        ; Use ljmp to avoid range issues if code grows

CHECK_DEP:
    jnb ACC.1, CHECK_BAL
    ljmp DEPOSIT

CHECK_BAL:
    jnb ACC.2, ATM_LOOP_CONT
    ljmp BALANCE

ATM_LOOP_CONT:
    sjmp ATM_LOOP

WITHDRAW:
    inc r2
    acall DELAY_SUCCESS
    sjmp ATM_LOOP

DEPOSIT:
    inc r3
    acall DELAY_SUCCESS
    sjmp ATM_LOOP

BALANCE:
    inc r4
    acall DELAY_SUCCESS
    sjmp ATM_LOOP

; --- Subroutines ---

PIN_CHECK:
L4: mov r1, #0xB0       ; Low byte of PIN_CODE address
    mov r2, #4
L2: acall KEY_QUERY
    mov a, r0
    jz L2
    
    ; Compare with stored PIN
    mov a, r1
    mov dptr, #0x0000
    movc a, @a+dptr
    
    clr c
    subb a, r0
    jnz L4
    
    inc r1
    djnz r2, L2
    ret

KEY_QUERY:
    mov r0, #'1'
    acall DELAY
    ret

UPDATE_LCD:
    mov r6, #8
    acall LCD_INIT
L1_LCD:
    clr a
    movc a, @a+dptr
    jz LCD_DONE
    acall LDATA
    inc dptr
    djnz r6, L1_LCD
LCD_DONE:
    ret

LCD_INIT:
    mov a, #0x38
    acall CMD
    mov a, #0x06
    acall CMD
    mov a, #0x01
    acall CMD
    mov a, #0xE0
    acall CMD
    mov a, #0x80
    acall CMD
    ret

CMD:
    clr P1_7
    mov P0, a
    setb P3_6
    acall DELAY
    clr P3_6
    ret

LDATA:
    setb P1_7
    mov P0, a
    setb P1_6
    acall DELAY
    clr P1_6
    ret

DELAY:
    mov r7, #0xFF
DL1: djnz r7, DL1
    ret

DELAY_SUCCESS:
    acall DELAY
    acall DELAY
    ret
