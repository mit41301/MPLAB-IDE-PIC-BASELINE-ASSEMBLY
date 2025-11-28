;************************************************************************
;                                                                       *
;   Filename:       BA_L9-Comp2_2LEDs.asm                               *
;   Date:           11/5/12                                             *
;   File Version:   3.1                                                 *
;                                                                       *
;   Author:         David Meiklejohn                                    *
;   Company:        Gooligum Electronics                                *
;                                                                       *
;************************************************************************
;                                                                       *
;   Architecture:   Baseline PIC                                        *
;   Processor:      16F506                                              *
;                                                                       *
;************************************************************************
;                                                                       *
;   Files required: none                                                *
;                                                                       *
;************************************************************************
;                                                                       *
;   Description:    Lesson 9, example 4                                 *
;                                                                       *
;   Demonstrates use of Comparator 2 and programmable voltage reference *
;                                                                       *
;   Turns on Low LED  when C2IN+ < 2.0 V (low light level)              *
;         or High LED when C2IN+ > 3.0 V (high light level)             *
;                                                                       *
;************************************************************************
;                                                                       *
;   Pin assignments:                                                    *
;       C2IN+ = voltage to be measured (LDR/resistor divider)           *
;       RC3   = "Low" LED                                               *
;       RC1   = "High" LED                                              *
;                                                                       *
;************************************************************************

    list        p=16F506 
    #include    <p16F506.inc>

    radix       dec


;***** CONFIGURATION
                ; ext reset, no code protect, no watchdog, 4 Mhz int clock
    __CONFIG    _MCLRE_ON & _CP_OFF & _WDT_OFF & _IOSCFS_OFF & _IntRC_OSC_RB4EN

; pin assignments
    constant    nLO=RC3         ; "Low" LED
    constant    nHI=RC1         ; "High" LED


;***** MACROS
; 10 us delay
;
; Assumes: 4 MHz processor clock
;
Delay10us   MACRO
            goto $+1        ; 2 us delay * 5 = 10 us
            goto $+1
            goto $+1
            goto $+1
            goto $+1
            ENDM
        

;***** VARIABLE DEFINITIONS
        UDATA_SHR
sPORTC  res 1                   ; shadow copy of PORTC


;***** RC CALIBRATION
RCCAL   CODE    0x3FF           ; processor reset vector
        res 1                   ; holds internal RC cal value, as a movlw k

;***** RESET VECTOR *****************************************************
RESET   CODE    0x000           ; effective reset vector
        movwf   OSCCAL          ; apply internal RC factory calibration

        
;***** MAIN PROGRAM *****************************************************

;***** Initialisation	
start
        ; configure ports
        movlw   ~(1<<nLO|1<<nHI)    ; configure PORTC LED pins as outputs
        tris    PORTC 
        
        ; configure comparator 2
        movlw   1<<C2PREF1|0<<C2NREF|1<<C2POL|1<<C2ON
                                    ; +ref is C2IN+ (C2PREF1 = 1)
                                    ; -ref is CVref (C2NREF = 0)
                                    ; normal polarity (C2POL = 1)
                                    ; turn comparator on (C2ON = 1)
        movwf   CM2CON0             ; -> C2OUT = 1 if C2IN+ > CVref


;***** Main loop
main_loop
        ; start with shadow PORTC clear
        clrf    sPORTC              
        
;*** Test for low illumination
        ; set low input threshold
        movlw   1<<VREN|0<<VRR|.5   ; configure voltage reference:
                                    ;   enable voltage reference (VREN = 1)
                                    ;   CVref = 0.406*Vdd (VRR = 0, VR = 5)
        movwf   VRCON               ;   -> CVref = 2.03 V
        Delay10us                   ; wait 10 us to settle
        
        ; compare with input
        btfss   CM2CON0,C2OUT       ; if C2IN+ < CVref
        bsf     sPORTC,nLO          ;   turn on Low LED
        
;*** Test for high illumination
        ; set high input threshold
        movlw   1<<VREN|0<<VRR|.11  ; configure voltage reference:
                                    ;   enable voltage reference (VREN = 1)
                                    ;   CVref = 0.594*Vdd (VRR = 0, VR = 11)
        movwf   VRCON               ;   -> CVref = 2.97 V        
        Delay10us                   ; wait 10 us to settle
        
        ; compare with input
        btfsc   CM2CON0,C2OUT       ; if C2IN+ > CVref
        bsf     sPORTC,nHI          ;   turn on High LED

;*** Display test results
        movf    sPORTC,w            ; copy shadow to PORTC
        movwf   PORTC

        ; repeat forever
        goto    main_loop        


        END

