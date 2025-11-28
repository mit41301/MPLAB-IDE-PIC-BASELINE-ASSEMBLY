;************************************************************************
;                                                                       *
;   Filename:      BA_L9-Comp1_TMR.asm                                  *
;   Date:          6/4/12                                               *
;   File Version:  1.3                                                  *
;                                                                       *
;   Author:        David Meiklejohn                                     *
;   Company:       Gooligum Electronics                                 *
;                                                                       *
;************************************************************************
;                                                                       *
;   Architecture:  Baseline PIC                                         *
;   Processor:     16F506                                               *
;                                                                       *
;************************************************************************
;                                                                       *
;   Files required: none                                                *
;                                                                       *
;************************************************************************
;                                                                       *
;   Description:    Lesson 9, example 3                                 *
;                   Crystal-based (degraded signal) LED flasher         *
;                                                                       *
;   Demonstrates comparator 1 clocking TMR0                             *
;                                                                       *
;   LED flashes at 1 Hz (50% duty cycle),                               *
;   with timing derived from 32.768 kHz input on C1IN+                  *
;                                                                       *
;************************************************************************
;                                                                       *
;   Pin assignments:                                                    *
;       C1IN+ = 32.768 kHz signal                                       *
;       RC3   = flashing LED                                            *
;                                                                       *
;************************************************************************

    list        p=16F506 
    #include    <p16F506.inc>

    radix       dec


;***** CONFIGURATION
                ; ext reset, no code protect, no watchdog, 4 MHz int clock
    __CONFIG    _MCLRE_ON & _CP_OFF & _WDT_OFF & _IOSCFS_OFF & _IntRC_OSC_RB4EN

; pin assignments
    constant nFLASH=3               ; flashing LED on RC3
    

;***** VARIABLE DEFINITIONS
        UDATA_SHR
sPORTC  res 1                       ; shadow copy of PORTC


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
        movlw   ~(1<<nFLASH)        ; configure LED pin (only) as output
        tris    PORTC  
        
        ; configure Timer0
        movlw   1<<T0CS|0<<PSA|b'110' 
                                    ; counter mode (T0CS = 1)
                                    ; prescaler assigned to Timer0 (PSA = 0)
                                    ; prescale = 128 (PS = 110)
        option                      ; -> increment at 256 Hz with 32.768 kHz input
        
        ; configure comparator 1
        movlw   1<<C1PREF|0<<C1NREF|0<<C1POL|0<<NOT_C1T0CS|1<<C1ON
                                    ; +ref is C1IN+ (C1PREF = 1)
                                    ; -ref is 0.6 V (C1NREF = 0)
                                    ; normal polarity (C1POL = 1)
                                    ; select C1 as TMR0 clock (/C1T0CS = 0)
                                    ; turn comparator on (C1ON = 1)
        movwf   CM1CON0             ; -> C1OUT = 1 if C1IN+ > 0.6 V,
                                    ;    TMR0 clock from C1

;***** Main loop
main_loop
        ; TMR0<7> cycles at 1 Hz, so continually copy to LED (GP1)
        clrf    sPORTC              ; assume TMR0<7>=0 -> LED off
        btfsc   TMR0,7              ; if TMR0<7>=1
        bsf     sPORTC,nFLASH       ;   turn on LED

        movf    sPORTC,w            ; copy shadow to port
        movwf   PORTC

        ; repeat forever
        goto    main_loop              


        END

