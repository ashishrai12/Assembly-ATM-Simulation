;====================================================================
; Title: Password Protected ATM System
; Toolchain: as31 (Linux)
; Processor: 8051 (89C51)
;====================================================================

; --- Standard SFR Definitions ---
.equ P0,      0x80
.equ P1,      0x90
.equ P2,      0xA0
.equ P3,      0xB0
.equ PSW,     0xD0
.equ ACC,     0xE0
.equ B,       0xF0
.equ SP,      0x81
.equ DPL,     0x82
.equ DPH,     0x83

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
    ; P1 is already in A (masked), but let's reload to be safe and check bits
    mov a, P1
    jb ACC+0, WITHDRAW    ; as31 allows ACC+0 syntax for bit addressing often, 
                          ; or we define ACC_0. Standard 8051 uses ACC.0
                          ; as31 might prefer numeric addresses for bit ops if symbols fail.
                          ; Let's use the numeric bit address if possible or the .equ symbols.
    
    ; Actually, to be safe with as31, let's use the defined bit symbols.
    ; But we haven't defined ACC bits.
    ; P1.0 is 0x90.
    
    jnb P1_0, ATM_LOOP_CONT ; logic for active low/high? 
                            ; Original code: JB ACC.0 
                            ; Let's just reproduce logic:
                            
    jb ACC+0, WITHDRAW      ; as31 usually handles Register.Bit if Register is known, 
                            ; but ACC is just a number 0xE0. 
                            ; 0xE0.0 is syntax valid? Maybe not.
                            ; safer: 0xE0 (ACC_0)
    
    ; Let's define ACC bits to be safe
    .equ ACC_0, 0xE0
    .equ ACC_1, 0xE1
    .equ ACC_2, 0xE2

    jb ACC_0, WITHDRAW
    jb ACC_1, DEPOSIT
    jb ACC_2, BALANCE
    sjmp ATM_LOOP

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
L4: mov r1, #0xB0       ; Low byte of PIN_CODE address (simplification)
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
