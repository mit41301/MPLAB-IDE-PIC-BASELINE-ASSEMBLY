;************************************************************************
;                                                                       *
;   Filename:      BA_L7-Flash_LED_XTAL-32k.asm                         *
;   Date:          17/6/12                                              *
;   File Version:  1.1                                                  *
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
;   Description:    Lesson 7, example 4b                                *
;                                                                       *
;   Demonstrates PIC oscillator, using 32.768 kHz crystal               *
;                                                                       *
;   LED flashes at 1 Hz (50% duty cycle),                               *
;   with timing derived from 32.768 kHz processor clock                 *
;                                                                       *
;************************************************************************
;                                                                       *
;   Pin assignments:                                                    *
;       GP1         = flashing LED                                      *
;       OSC1, OSC2  = 32.768 kHz crystal                                *
;                                                                       *
;************************************************************************

    list        p=12F509       
    #include    <p12F509.inc>

    radix       dec


;***** CONFIGURATION
                ; ext reset, no code protect, no watchdog, LP crystal
    __CONFIG    _MCLRE_ON & _CP_OFF & _WDT_OFF & _LP_OSC


;***** VARIABLE DEFINITIONS
        UDATA_SHR
temp    res 1                   ; temp register used for rotates


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
        movlw   b'11010100'     ; configure Timer0:
                ; --0-----          timer mode (T0CS = 0)
                ; ----0---          prescaler assigned to Timer0 (PSA = 0)
                ; -----100          prescale = 32 (PS = 100) 
        option                  ;   -> increment at 256 Hz with 32.768 kHz clock

;***** Main loop
main_loop
        ; TMR0<7> cycles at 1Hz, so continually copy to LED (GP1) 
        rlf     TMR0,w          ; copy TMR0<7> to C
        clrf    temp
        rlf     temp,f          ; rotate C into temp
        rlf     temp,w          ; rotate once more into W (-> W<1> = TMR0<7>)
        movwf   GPIO            ; update GPIO with result (-> GP1 = TMR0<7>)

        ; repeat forever
        goto    main_loop            


        END