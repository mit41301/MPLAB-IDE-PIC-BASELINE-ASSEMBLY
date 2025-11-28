;************************************************************************
;                                                                       *
;   Filename:       BA_L4-PB_LED-direct.asm                             *
;   Date:           29/1/12                                             *
;   File Version:   1.1                                                 *
;                                                                       *
;   Author:         David Meiklejohn                                    *
;   Company:        Gooligum Electronics                                *
;                                                                       *
;************************************************************************
;                                                                       *
;   Architecture:   Baseline PIC                                        *
;   Processor:      12F508/509                                          *
;                                                                       *
;************************************************************************
;                                                                       *
;   Files required: none                                                *
;                                                                       *
;************************************************************************
;                                                                       *
;   Description:    Lesson 4, example 1a                                *
;                                                                       *
;   Demonstrates reading a switch                                       *
;                                                                       *
;   Turns on LED when pushbutton on GP3 is pressed                      *
;                                                                       *
;************************************************************************
;                                                                       *
;   Pin assignments:                                                    *
;       GP1 = LED                                                       *
;       GP3 = pushbutton switch (active low)                            *
;                                                                       *
;************************************************************************

    list        p=12F509 
    #include    <p12F509.inc>


;***** CONFIGURATION
                ; int reset, no code protect, no watchdog, int RC clock
    __CONFIG    _MCLRE_OFF & _CP_OFF & _WDT_OFF & _IntRC_OSC


;***** RC CALIBRATION
RCCAL   CODE    0x3FF           ; processor reset vector
        res 1                   ; holds internal RC cal value, as a movlw k

;***** RESET VECTOR *****************************************************
RESET   CODE    0x000           ; effective reset vector
        movwf   OSCCAL          ; apply internal RC factory calibration 


;***** MAIN PROGRAM *****************************************************

;***** Initialisation
start			
        movlw   b'111101'       ; configure GP1 (only) as an output
        tris    GPIO            ; (GP3 is an input)
        clrf    GPIO	        ; start with GPIO clear (GP1 low)

;***** Main loop
main_loop
        ; turn on LED only if button pressed
        btfss   GPIO,3          ; if button pressed (GP3 low)
        bsf     GPIO,1          ;   turn on LED
        btfsc   GPIO,3          ; if button up (GP3 high)
        bcf     GPIO,1          ;   turn off LED

        ; repeat forever
        goto    main_loop       


        END

