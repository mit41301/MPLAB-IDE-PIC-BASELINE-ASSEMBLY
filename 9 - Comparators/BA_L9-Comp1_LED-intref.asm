;************************************************************************
;                                                                       *
;   Filename:       BA_L9-Comp1_LED-intref.asm                          *
;   Date:           5/4/12                                              *
;   File Version:   1.3                                                 *
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
;   Description:    Lesson 9, example 1c                                *
;                                                                       *
;   Demonstrates use of Comparator 1 internal 0.6 V reference           *
;                                                                       *
;   Turns on LED when voltage on C1IN+ < 0.6 V                          *
;                                                                       *
;************************************************************************
;                                                                       *
;   Pin assignments:                                                    *
;       C1IN+ = voltage to be measured (e.g. pot output or LDR)         *
;       RC3   = indicator LED                                           *
;                                                                       *
;************************************************************************

    list        p=16F506 
    #include    <p16F506.inc>

    radix       dec


;***** CONFIGURATION
                ; ext reset, no code protect, no watchdog, 4 MHz int clock
    __CONFIG    _MCLRE_ON & _CP_OFF & _WDT_OFF & _IOSCFS_OFF & _IntRC_OSC_RB4EN

; pin assignments
    #define     LED     PORTC,3     ; indicator LED on RC3
    constant    nLED=3              ;   (port bit 3)


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
        movlw   ~(1<<nLED)      ; configure LED pin (only) as an output
        tris    PORTC 
        
        ; configure comparator 1
        movlw   1<<C1PREF|0<<C1NREF|0<<C1POL|1<<C1ON
                                ; +ref is C1IN+ (C1PREF = 1)
                                ; -ref is 0.6 V (C1NREF = 0)
                                ; inverted polarity (C1POL = 0)
                                ; turn comparator on (C1ON = 1)
        movwf   CM1CON0         ; -> C1OUT = 1 if C1IN+ < 0.6 V           

;***** Main loop
main_loop
        ; display comparator output
        btfsc   CM1CON0,C1OUT   ; if comparator output high
        bsf     LED             ;   turn on LED
        btfss   CM1CON0,C1OUT   ; if comparator output low
        bcf     LED             ;   turn off LED

        ; repeat forever
        goto    main_loop


        END

