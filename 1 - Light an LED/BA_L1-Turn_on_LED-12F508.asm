;************************************************************************
;                                                                       *
;   Filename:      BA_L1-Turn_on_LED-12F508.asm                         *
;   Date:          3/1/12                                               *
;   File Version:  1.0                                                  *
;                                                                       *
;   Author:        David Meiklejohn                                     *
;   Company:       Gooligum Electronics                                 *
;                                                                       *
;************************************************************************
;                                                                       *
;   Architecture:  Baseline PIC                                         *
;   Processor:     12F2508                                              *
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

    list        p=12F508          
    #include    <p12F508.inc>      


;***** CONFIGURATION
                ; ext reset, no code protect, no watchdog, int RC clock 
    __CONFIG    _MCLRE_ON & _CP_OFF & _WDT_OFF & _IntRC_OSC


;***** RC CALIBRATION
RCCAL   CODE    0x1FF       ; processor reset vector
        res 1               ; holds internal RC cal value, as a movlw k
        

;***** RESET VECTOR *****************************************************
RESET   CODE    0x000       ; effective reset vector
        movwf   OSCCAL      ; apply internal RC factory calibration 


;***** MAIN PROGRAM *****************************************************

;***** Initialisation
start	
        movlw   b'111101'       ; configure GP1 (only) as an output
        tris    GPIO
        movlw   b'000010'       ; set GP1 high
        movwf   GPIO

;***** Main loop        		
        goto    $               ; loop forever


        END
