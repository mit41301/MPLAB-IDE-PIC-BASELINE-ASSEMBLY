;************************************************************************
;                                                                       *
;   Filename:      BA_L6-Flash_LED_XTAL.asm                             *
;   Date:          15/2/12                                              *
;   File Version:  1.4                                                  *
;                                                                       *
;   Author:        David Meiklejohn                                     *
;   Company:       Gooligum Electronics                                 *
;                                                                       *
;************************************************************************
;                                                                       *
;   Architecture:  Baseline PIC                                         *
;   Processor:     12F508/509                                           *
;                                                                       *
;************************************************************************
;                                                                       *
;   Files required: none                                                *
;                                                                       *
;************************************************************************
;                                                                       *
;   Description:    Lesson 6, example 3                                 *
;                   Crystal-based LED flasher                           *
;                                                                       *
;   Demonstates use symbols and bitwise operators in setting OPTION     *
;                                                                       *
;   LED flashes at 1 Hz (50% duty cycle),                               *
;   with timing derived from 32.768 kHz input on T0CKI                  *
;                                                                       *
;************************************************************************
;                                                                       *
;   Pin assignments:                                                    *
;       GP1   = flashing LED                                            *
;       T0CKI = 32.768 kHz signal                                       *
;                                                                       *
;************************************************************************

    list        p=12F509 
    #include    <p12F509.inc>

    radix       dec


;***** CONFIGURATION
                ; ext reset, no code protect, no watchdog, int RC clock
    __CONFIG    _MCLRE_ON & _CP_OFF & _WDT_OFF & _IntRC_OSC

; pin assignments
    constant nFLASH=1           ; flashing LED on GP1


;***** VARIABLE DEFINITIONS
        UDATA_SHR
sGPIO   res 1                   ; shadow copy of GPIO


;***** RC CALIBRATION
RCCAL   CODE    0x3FF           ; processor reset vector
        res 1                   ; holds internal RC cal value, as a movlw k

;***** RESET VECTOR *****************************************************
RESET   CODE    0x000           ; effective reset vector
        movwf   OSCCAL          ; apply internal RC factory calibration 


;***** MAIN PROGRAM *****************************************************

;***** Initialisation
start
        ; configure port
        movlw   ~(1<<nFLASH)        ; configure LED pin (only) as output
        tris    GPIO   
        ; configure Timer0
        movlw   1<<T0CS|0<<PSA|b'110' 
                                    ; counter mode (T0CS = 1)
                                    ; prescaler assigned to Timer0 (PSA = 0)
                                    ; prescale = 128 (PS = 110)
        option                      ; -> increment at 256 Hz with 32.768 kHz input     


;***** Main loop
main_loop
        ; TMR0<7> cycles at 1 Hz, so continually copy to LED (GP1)
        clrf    sGPIO               ; assume TMR0<7>=0 -> LED off
        btfsc   TMR0,7              ; if TMR0<7>=1
        bsf     sGPIO,nFLASH        ;   turn on LED

        movf    sGPIO,w             ; copy shadow to GPIO
        movwf   GPIO

        ; repeat forever
        goto    main_loop           


        END

