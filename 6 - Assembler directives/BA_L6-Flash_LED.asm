;************************************************************************
;                                                                       *
;   Filename:      BA_L6-Flash_LED.asm                                  *
;   Date:          15/2/12                                              *
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
;   Description:    Lesson 6, example 1                                 *
;                                                                       *
;   Demonstrates use of arithmetic operators in constant expresssion    *
;                                                                       *
;   LED flashes at 1 Hz (50% duty cycle),                               *
;   with timing derived from internal 4 MHz oscillator                  *
;                                                                       *
;************************************************************************
;                                                                       *
;   Pin assignments:                                                    *
;       GP1 = flashing LED                                              *
;                                                                       *
;************************************************************************

    list        p=12F509 
    #include    <p12F509.inc>

    radix       dec


;***** CONFIGURATION
                ; ext reset, no code protect, no watchdog, int RC clock 
    __CONFIG    _MCLRE_ON & _CP_OFF & _WDT_OFF & _IntRC_OSC


;***** VARIABLE DEFINITIONS
        UDATA
sGPIO   res 1               ; shadow copy of GPIO
dc1     res 1               ; delay loop counters
dc2     res 1


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

        pagesel sGPIO           ; start with shadow GPIO clear (LED off)
        clrf    sGPIO           

;***** Main loop
main_loop
        ; toggle LED on GP1
        movf    sGPIO,w         ; get shadow copy of GPIO
        xorlw   b'000010'       ; toggle bit corresponding to GP1 (bit 1)
        movwf   sGPIO           ;   in shadow register
        movwf   GPIO            ; and write to GPIO

        ; delay 500 ms
        movlw   500000/(1023+1023+3) ; # outer loop iterations for 500 ms
        movwf   dc2 
        clrf    dc1             ; inner loop: 256 x 4 - 1
dly1    nop                     ; inner loop 1 = 1023 cycles
        decfsz  dc1,f
        goto    dly1
dly2    nop                     ; inner loop 2 = 1023 cycles
        decfsz  dc1,f
        goto    dly2
        decfsz  dc2,f
        goto    dly1

        ; repeat forever
        goto    main_loop           


        END

