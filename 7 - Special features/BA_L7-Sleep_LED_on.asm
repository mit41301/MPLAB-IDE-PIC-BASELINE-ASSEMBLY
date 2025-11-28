;************************************************************************
;                                                                       *
;   Filename:      BA_L7-Sleep_LED_on.asm                               *
;   Date:          19/3/12                                              *
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
;   Description:    Lesson 7, example 1a                                *
;                                                                       *
;   Demonstrates use of sleep mode                                      *
;                                                                       *
;   Turn on LED, wait for button press, then sleep                      *
;                                                                       *
;************************************************************************
;                                                                       *
;   Pin assignments:                                                    *
;       GP1 = indicator LED                                             *
;       GP3 = pushbutton switch (active low)                            *
;                                                                       *
;************************************************************************

    list        p=12F509 
    #include    <p12F509.inc>

    radix       dec


;***** CONFIGURATION
                ; int reset, no code protect, no watchdog, int RC clock
    __CONFIG    _MCLRE_OFF & _CP_OFF & _WDT_OFF & _IntRC_OSC

; pin assignments
    #define     LED     GPIO,1      ; indicator LED on GP1
    constant    nLED=1              ;   (port bit 1)
    #define     BUTTON  GPIO,3      ; pushbutton on GP3


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
        movlw   ~(1<<nLED)      ; configure LED pin (only) as an output
        tris    GPIO

;***** Main code
        ; turn on LED
        bsf     LED      
               
        ; wait for button press
wait_lo btfsc   BUTTON          ; wait until button low
        goto    wait_lo

        ; go into standby mode
        sleep                   ; enter sleep mode

        goto    $               ; (this instruction should never run)


        END

