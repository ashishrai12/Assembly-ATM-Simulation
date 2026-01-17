;====================================================================
; Title: Password Protected ATM System
; Toolchain: SDCC (sdas8051)
; Processor: 8051 (89C51)
;====================================================================

.module ATM_SYSTEM
.optsdcc -mmcs51 --model-small

; --- SFR Definitions ---
P0      = 0x80
P1      = 0x90
P2      = 0xA0
P3      = 0xB0
PSW     = 0xD0
ACC     = 0xE0
B       = 0xF0
SP      = 0x81
DPL     = 0x82
DPH     = 0x83

; --- Bit Definitions ---
; Port 1 Bits
P1_0    = 0x90
P1_1    = 0x91
P1_2    = 0x92
P1_6    = 0x96
P1_7    = 0x97

; Port 3 Bits
P3_6    = 0xB6

; Accumulator Bits
ACC_0   = 0xE0
ACC_1   = 0xE1
ACC_2   = 0xE2

; Code Segment at 0x0000 (Reset Vector)
.area BOOT (ABS,CODE)
.org 0x0000
    ljmp MAIN

; --- Data Constants (ASCII Strings) ---
.area CONST (ABS,CODE)
.org 0x0050
    .ascii "ACCESS  "
    .db 0x00

.org 0x0095
    .ascii "PIN:    "
    .db 0x00

.org 0x00B0
    .ascii "1234"

; --- Main Program ---
.area CSEG (ABS,CODE)
.org 0x0100
MAIN:
    mov P1, #0xFF       ; Set P1 for input
    mov P2, #0x07       ; Initialize Keypad Columns
    mov P0, #0x00       ; Clear LCD Data Port

    ; Display "PIN: "
    mov dptr, #0x0095
    lcall UPDATE_LCD
    
    ; Perform PIN Authentication
    lcall PIN_CHECK
    
    ; If PIN correct, display "ACCESS"
    mov dptr, #0x0050
    lcall UPDATE_LCD
    
ATM_LOOP:
    mov a, P1
    anl a, #0x07         ; Mask lower 3 bits for ATM functions
    jz ATM_LOOP          ; Wait for input
    
    ; Jump to respective functions
    jb ACC_0, WITHDRAW
    jb ACC_1, DEPOSIT
    jb ACC_2, BALANCE
    sjmp ATM_LOOP

WITHDRAW:
    inc r2              ; Simulate withdrawal (increment counter)
    lcall DELAY_SUCCESS ; Visual feedback
    sjmp ATM_LOOP

DEPOSIT:
    inc r3              ; Simulate deposit (increment counter)
    lcall DELAY_SUCCESS
    sjmp ATM_LOOP

BALANCE:
    inc r4              ; Simulate balance check (increment counter)
    lcall DELAY_SUCCESS
    sjmp ATM_LOOP

; --- Subroutines ---

PIN_CHECK:
L4: mov r1, #0xB0       ; Pointer to correct PIN (low byte)
    mov r2, #4          ; 4 digits to check
L2: lcall KEY_QUERY     ; Wait for key press
    mov a, r0           ; R0 contains the pressed key
    jz L2               ; If no key, keep waiting
    
    ; Compare with stored PIN
    mov a, r1           ; Move offset
    mov dptr, #0x0000   
    movc a, @a+dptr     ; Read PIN byte
    
    clr c
    subb a, r0          ; Compare with input
    jnz L4              ; Incorrect digit -> Restart check
    
    inc r1
    djnz r2, L2
    ret

KEY_QUERY:
    ; Placeholder for keypad scanning
    mov r0, #0x31       ; Simulate key '1' for test
    lcall DELAY
    ret

UPDATE_LCD:
    mov r6, #8          ; Character count
    lcall LCD_INIT
L1_LCD:
    inc dptr
    clr a
    movc a, @a+dptr
    lcall LDATA
    djnz r6, L1_LCD
    ret

LCD_INIT:
    mov a, #0x38
    lcall CMD
    mov a, #0x06
    lcall CMD
    mov a, #0x01
    lcall CMD
    mov a, #0xE0
    lcall CMD
    mov a, #0x80
    lcall CMD
    ret

CMD:
    clr P1_7            ; RS=0 for command
    mov P0, a           ; Put command on P0
    setb P3_6           ; EN=1
    lcall DELAY
    clr P3_6            ; EN=0
    ret

LDATA:
    setb P1_7           ; RS=1 for data
    mov P0, a           ; Put data on P0
    setb P1_6           ; EN=1
    lcall DELAY
    clr P1_6            ; EN=0
    ret

DELAY:
    mov r7, #255
D1: djnz r7, D1
    ret

DELAY_SUCCESS:
    lcall DELAY
    lcall DELAY
    ret
