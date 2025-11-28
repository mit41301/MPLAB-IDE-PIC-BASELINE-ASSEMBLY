;************************************************************************
;                                                                       *
;   Filename:      BA_L1-Turn_on_LED-10F200.asm                         *
;   Date:          19/9/12                                              *
;   File Version:  1.1                                                  *
;                                                                       *
;   Author:        David Meiklejohn                                     *
;   Company:       Gooligum Electronics                                 *
;                                                                       *
;************************************************************************
;                                                                       *
;   Architecture:  Baseline PIC                                         *
;   Processor:     10F200                                               *
;                                                                       *
;************************************************************************
;                                                                       *
;   Files required: none                                                *
;                                                                       *
;************************************************************************
;                                                                       *
;   Description:    Lesson 1, example 1                                 *
;                                                                       *
;   Turns on LED.  LED remains on until power is removed.               *
;                                                                       *
;************************************************************************
;                                                                       *
;   Pin assignments:                                                    *
;       GP1 = indicator LED                                             *
;                                                                       *
;************************************************************************

    list        p=10F200           
    #include    <p10F200.inc>   


;***** CONFIGURATION
                ; ext reset, no code protect, no watchdog 
    __CONFIG    _MCLRE_ON & _CP_OFF & _WDT_OFF


;***** RC CALIBRATION 
RCCAL   CODE    0x0FF       ; processor reset vector
        res 1               ; holds internal RC cal value, as a movlw k


;***** RESET VECTOR *****************************************************
RESET   CODE    0x000       ; effective reset vector
        movwf   OSCCAL      ; apply internal RC factory calibration 


;***** MAIN PROGRAM *****************************************************

;***** Initialisation
start	
        movlw   b'1101'         ; configure GP1 (only) as an output
        tris    GPIO
        movlw   b'0010'         ; set GP1 high
        movwf   GPIO

;***** Main loop        		
        goto    $               ; loop forever


        END               

