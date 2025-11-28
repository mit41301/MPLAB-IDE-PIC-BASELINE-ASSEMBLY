;************************************************************************
;                                                                       *
;   Filename:       BA_L9-Comp1_Wakeup.asm                              *
;   Date:           6/4/12                                              *
;   File Version:   1.7                                                 *
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
;   Files required: delay10.asm         (provides W x 10 ms delay)      *
;                   stdmacros-base.inc  (provides DelayMS macro)        *
;                                                                       *
;************************************************************************
;                                                                       *
;   Description:    Lesson 9, example 2                                 *
;                                                                       *
;   Demonstrates wake-up on comparator change                           *
;                                                                       *
;   Turns on LED for 1s when comparator 1 output changes,               *
;   then sleeps until the next change                                   *
;   (internal 0.6 V reference with external hysteresis)                 *
;                                                                       *
;************************************************************************
;                                                                       *
;   Pin assignments:                                                    *
;       C1IN+ = voltage to be measured (e.g. pot output or LDR)         *
;       C1OUT = comparator output (fed back to input via resistor)      *
;       RC3   = indicator LED                                           *
;                                                                       *
;************************************************************************

    list        p=16F506 
    #include    <p16F506.inc>
    
    #include    <stdmacros-base.inc>    ; DelayMS - delay in milliseconds
                                        ;   (calls delay10)
    EXTERN      delay10_R               ; W x 10ms delay
    
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
        pagesel start
        goto    start           ; jump to main code

;***** Subroutine vectors
delay10                         ; delay W x 10 ms
        pagesel delay10_R
        goto    delay10_R


;***** MAIN PROGRAM *****************************************************
MAIN    CODE

;***** Initialisation
start
        ; configure ports
        clrf    PORTC           ; start with LED off
        movlw   ~(1<<nLED)      ; configure LED pin (only) as an output
        tris    PORTC 
        clrf    ADCON0          ; disable analog inputs -> C1OUT usable

        ; check for wake-up on comparator change
        btfsc   STATUS,CWUF     ; if wake-up on comparator change occurred,
        goto    flash           ;   flash LED then sleep

        ; else power-on reset
        movlw   b'00111010'     ; configure comparator 1:
                ; -0------          enable C1OUT pin (/C1OUTEN = 0)
                ; --1-----          normal polarity (C1POL = 1)  
                ; ----1---          turn comparator on (C1ON = 1)
                ; -----0--          -ref is 0.6 V (C1NREF = 0)
                ; ------1-          +ref is C1IN+ (C1PREF = 1)
                ; -------0          enable wake on comparator change (/C1WU = 0)  
        movwf   CM1CON0         ;   -> C1OUT = 1 if C1IN+ > 0.6V,
                                ;      C1OUT pin enabled,
                                ;      wake on comparator change enabled
                                
        DelayMS 10              ; delay 10 ms to allow comparator to settle

        goto    standby         ; sleep until comparator change
        
;***** Main code
        ; flash LED
flash   bsf     LED             ; turn on LED
        DelayMS 1000            ; delay 1 sec

        ; sleep until comparator change
standby bcf     LED             ; turn off LED
        movf    CM1CON0,w       ; read comparator to clear mismatch condition
        sleep                   ; enter sleep mode


        END

