;====================================================================
; Title: Password Protected ATM System
; Toolchain: as31 (Standard 8051 Assembler)
; Processor: 8051 (89C51)
;====================================================================

; --- Standard SFR Definitions for 89C51 ---
P0      EQU 080H
P1      EQU 090H
P2      EQU 0A0H
P3      EQU 0B0H
PSW     EQU 0D0H
ACC     EQU 0E0H
B       EQU 0F0H
SP      EQU 081H
DPL     EQU 082H
DPH     EQU 083H

; --- Bit Definitions ---
P1_0    EQU 090H
P1_1    EQU 091H
P1_2    EQU 092H
P1_6    EQU 096H
P1_7    EQU 097H
P3_6    EQU 0B6H

; --- Reset Vector ---
ORG 0000H
    LJMP MAIN

; --- Data Constants (ASCII Strings) ---
ORG 0050H
STR_ACCESS:
    DB 'ACCESS', 0    ; String for successful login

ORG 0095H
STR_PIN:
    DB 'PIN:   ', 0    ; Prompt for PIN

ORG 00B0H
PIN_CODE:
    DB '1','2','3','4' ; Correct PIN

; --- Main Program ---
ORG 0100H
MAIN:
    MOV P1, #0FFH       ; Set P1 for input
    MOV P2, #007H       ; Initialize Keypad Columns
    MOV P0, #000H       ; Clear LCD Data Port

    ; Display "PIN: "
    MOV DPTR, #STR_PIN
    ACALL UPDATE_LCD
    
    ; Perform PIN Authentication
    ACALL PIN_CHECK
    
    ; If PIN correct, display "ACCESS"
    MOV DPTR, #STR_ACCESS
    ACALL UPDATE_LCD
    
ATM_LOOP:
    MOV A, P1
    ANL A, #07H         ; Mask lower 3 bits (P1.0-P1.2)
    JZ ATM_LOOP         ; Wait for input
    
    ; Check individual bits
    JNB P1.0, CHECK_DEP ; If P1.0 is 0? Wait, schematic implies Active Low or High? 
                        ; The original code used JB ACC.0, assuming P1 was read into A. 
                        ; Let's stick to reading A.
    
    MOV A, P1
    JB ACC.0, WITHDRAW
    JB ACC.1, DEPOSIT
    JB ACC.2, BALANCE
    SJMP ATM_LOOP

CHECK_DEP:
    SJMP ATM_LOOP

WITHDRAW:
    INC R2              ; Simulate withdrawal
    ACALL DELAY_SUCCESS
    SJMP ATM_LOOP

DEPOSIT:
    INC R3              ; Simulate deposit
    ACALL DELAY_SUCCESS
    SJMP ATM_LOOP

BALANCE:
    INC R4              ; Simulate balance check
    ACALL DELAY_SUCCESS
    SJMP ATM_LOOP

; --- Subroutines ---

PIN_CHECK:
    ; R0 would typically be set by KEY_QUERY (mocked)
L4: MOV R1, #LOW(PIN_CODE) ; Load low byte of PIN address
    MOV R2, #4      ; 4 digits to check
L2: ACALL KEY_QUERY ; Wait for key press
    MOV A, R0       ; R0 contains pressed key
    JZ L2           ; Retry if no key
    
    ; Compare with stored PIN
    ; Fetch from CODE memory
    MOV A, R1       ; Simplification: assume R1 holds offset 
    MOV DPTR, #0000H 
    MOVC A, @A+DPTR ; Read from code at R1
    
    CLR C
    SUBB A, R0      ; Compare A (PIN digit) with R0 (Input)
    JNZ L4          ; If wrong, restart
    
    INC R1          ; Next digit
    DJNZ R2, L2
    RET

KEY_QUERY:
    ; Placeholder for scan
    MOV R0, #'1'    ; Mock input constant '1'
    ACALL DELAY
    RET

UPDATE_LCD:
    MOV R6, #8      ; Count
    ACALL LCD_INIT
L1_LCD:
    CLR A
    MOVC A, @A+DPTR
    JZ LCD_DONE     ; Stop on null terminator? Original code used loop count.
                    ; Original code used DJNZ R6. We'll stick to that.
    ACALL LDATA
    INC DPTR
    DJNZ R6, L1_LCD
LCD_DONE:
    RET

LCD_INIT:
    MOV A, #38H
    ACALL CMD
    MOV A, #06H
    ACALL CMD
    MOV A, #01H
    ACALL CMD
    MOV A, #0E0H
    ACALL CMD
    MOV A, #80H
    ACALL CMD
    RET

CMD:
    CLR P1_7            ; RS=0
    MOV P0, A           ; Data
    SETB P3_6           ; EN=1
    ACALL DELAY
    CLR P3_6            ; EN=0
    RET

LDATA:
    SETB P1_7           ; RS=1
    MOV P0, A           ; Data
    SETB P1_6           ; EN=1
    ACALL DELAY
    CLR P1_6            ; EN=0
    RET

DELAY:
    MOV R7, #255
DL1: DJNZ R7, DL1
    RET

DELAY_SUCCESS:
    ACALL DELAY
    ACALL DELAY
    RET

END
