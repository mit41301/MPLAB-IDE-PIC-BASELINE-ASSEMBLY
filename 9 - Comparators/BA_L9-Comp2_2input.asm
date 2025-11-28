;************************************************************************
;                                                                       *
;   Filename:       BA_L9-Comp2_2input.asm                              *
;   Date:           9/6/12                                              *
;   File Version:   1.4                                                 *
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
;   Description:    Lesson 9, example 5                                 *
;                                                                       *
;   Demonstrates use of comparators 1 and 2                             *
;   with the programmable voltage reference                             *
;                                                                       *
;   Turns on: LED 1 when C1IN+ > 2.5 V                                  *
;         and LED 2 when C2IN+ > 2.5 V                                  *
;                                                                       *
;************************************************************************
;                                                                       *
;   Pin assignments:                                                    *
;       C1IN+ = input 1 (LDR/resistor divider)                          *
;       C1IN- = connected to CVref                                      *
;       C2IN+ = input 2 (LDR/resistor divider)                          *
;       CVref = connected to C1IN-                                      *
;       RC1   = indicator LED 2                                         *
;       RC3   = indicator LED 1                                         *
;                                                                       *
;************************************************************************

    list        p=16F506 
    #include    <p16F506.inc>

    radix       dec


;***** CONFIGURATION
                ; ext reset, no code protect, no watchdog, 4 Mhz int clock
    __CONFIG    _MCLRE_ON & _CP_OFF & _WDT_OFF & _IOSCFS_OFF & _IntRC_OSC_RB4EN

; pin assignments
    constant    nLED1=RC3       ; indicator LED 1
    constant    nLED2=RC1       ; indicator LED 2


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
        movlw   ~(1<<nLED1|1<<nLED2)    ; configure PORTC LED pins as outputs
        tris    PORTC 
        
        ; configure comparator 1
        movlw   1<<C1PREF|1<<C1NREF|1<<C1POL|1<<C1ON
                                    ; +ref is C1IN+ (C1PREF = 1)
                                    ; -ref is C1IN- (C1NREF = 1)
                                    ; normal polarity (C1POL = 1)
                                    ; comparator on (C1ON = 1)
        movwf   CM1CON0             ; -> C1OUT = 1 if C1IN+ > C1IN- (= CVref)
        
        ; configure comparator 2
        movlw   1<<C2PREF1|0<<C2NREF|1<<C2POL|1<<C2ON
                                    ; +ref is C2IN+ (C2PREF1 = 1)
                                    ; -ref is CVref (C2NREF = 0)
                                    ; normal polarity (C2POL = 1)
                                    ; comparator on (C2ON = 1)
        movwf   CM2CON0             ; -> C2OUT = 1 if C2IN+ > CVref
        
        ; configure voltage reference
        movlw   1<<VREN|1<<VROE|1<<VRR|.12
                                    ; CVref = 0.500*Vdd (VRR = 1, VR = 12)
                                    ; enable CVref output pin (VROE = 1)
                                    ; enable voltage reference (VREN = 1)
        movwf   VRCON               ; -> CVref = 2.50 V,
                                    ;    CVref output pin enabled               


;***** Main loop
main_loop
        ; start with shadow PORTC clear
        clrf    sPORTC              
        
        ; test input 1
        btfsc   CM1CON0,C1OUT       ; if C1IN+ > CVref
        bsf     sPORTC,nLED1        ;   turn on LED 1
        
        ; test input 2
        btfsc   CM2CON0,C2OUT       ; if C2IN+ > CVref
        bsf     sPORTC,nLED2        ;   turn on LED 2

        ; display test results
        movf    sPORTC,w            ; copy shadow to PORTC
        movwf   PORTC

        ; repeat forever
        goto    main_loop        


        END

