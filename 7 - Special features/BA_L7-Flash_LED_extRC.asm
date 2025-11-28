;************************************************************************
;                                                                       *
;   Filename:      BA_L7-Flash_LED_extRC.asm                            *
;   Date:          23/3/12                                              *
;   File Version:  1.3                                                  *
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
;   Description:    Lesson 7, example 4d                                *
;                                                                       *
;   Demonstrates use of PIC oscillator in external RC mode (~1 kHz)     *
;                                                                       *
;   LED on GP1 flashes at approx 1 Hz (50% duty cycle),                 *
;   with timing derived from instruction clock                          *
;                                                                       *
;************************************************************************
;                                                                       *
;   Pin assignments:                                                    *
;       GP1  = flashing LED                                             *
;       OSC1 = R (10k) / C (82n)                                        *
;                                                                       *
;************************************************************************

    list        p=12F509       
    #include    <p12F509.inc>

    radix       dec


;***** CONFIGURATION
                ; ext reset, no code protect, no watchdog, external RC osc
    __CONFIG    _MCLRE_ON & _CP_OFF & _WDT_OFF & _ExtRC_OSC


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
        movlw   b'111101'       ; configure GP1 (only) as output
        tris    GPIO   
        ; configure timer
        movlw   b'11010101'     ; configure Timer0:
                ; --0-----          timer mode (T0CS = 0)
                ; ----0---          prescaler assigned to Timer0 (PSA = 0)
                ; -----101          prescale = 64 (PS = 101) 
        option                  ;   -> increment at 4 Hz with 1 kHz clock

;***** Main loop
main_loop    
        ; TMR0<1> cycles at 1 Hz, so continually copy to LED (GP1)
        movf    TMR0,w          ; copy TMR0 to GPIO
        movwf   GPIO 

        ; repeat forever
        goto    main_loop           


        END

