;************************************************************************
;                                                                       *
;   Filename:      BA_L2-Flash_LED-10F200.asm                           *
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
;   Description:    Lesson 2, example 1                                 *
;                                                                       *
;   Flashes a LED at approx 1 Hz.                                       *
;   LED continues to flash until power is removed.                      *
;                                                                       *
;************************************************************************
;                                                                       *
;   Pin assignments:                                                    *
;       GP1 = flashing LED                                              *
;                                                                       *
;************************************************************************

    list        p=10F200           
    #include    <p10F200.inc>   


;***** CONFIGURATION
                ; ext reset, no code protect, no watchdog 
    __CONFIG    _MCLRE_ON & _CP_OFF & _WDT_OFF


;***** VARIABLE DEFINITIONS
        UDATA
sGPIO   res 1               ; shadow copy of GPIO
dc1     res 1               ; delay loop counters
dc2     res 1


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

        clrf    sGPIO           ; start with shadow GPIO zeroed

;***** Main loop
main_loop
        ; toggle LED on GP1
        movf    sGPIO,w         ; get shadow copy of GPIO
        xorlw   b'0010'         ; toggle bit corresponding to GP1 (bit 1)
        movwf   sGPIO           ;   in shadow register
        movwf   GPIO            ; and write to GPIO

        ; delay 500ms
        movlw   .244            ; outer loop: 244 x (1023 + 1023 + 3) + 2
        movwf   dc2             ;   = 499,958 cycles
        clrf    dc1             ; inner loop: 256 x 4 - 1
dly1    nop                     ; inner loop 1 = 1023 cycles
        decfsz  dc1,f
        goto    dly1
dly2    nop                     ; inner loop 2 = 1023 cycles
        decfsz  dc1,f
        goto    dly2
        decfsz  dc2,f
        goto    dly1

        goto    main_loop       ; repeat forever


        END               

