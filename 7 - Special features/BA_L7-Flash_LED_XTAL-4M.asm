;************************************************************************
;                                                                       *
;   Filename:       BA_L7-Flash_LED_XTAL-4M.asm                         *
;   Date:           23/3/12                                             *
;   File Version:   1.3                                                 *
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
;   Description:    Lesson 7, example 4c                                *  
;                                                                       *
;   Demonstrates PIC oscillator, using 4 MHz crystal (or resonator)     *  
;                                                                       *
;   LED on GP1 flashes at 1 Hz (50% duty cycle),                        * 
;   with timing derived from 1 MHz instruction clock                    *    
;                                                                       *
;************************************************************************
;                                                                       *
;   Pin assignments:                                                    *
;       GP1         = flashing LED                                      *
;       OSC1, OSC2  = 4.00 MHz crystal (or resonator)                   *
;                                                                       *
;************************************************************************

    list        p=12F509
    #include    <p12F509.inc>

    radix       dec


;***** CONFIGURATION
                ; ext reset, no code protect, no watchdog, XT crystal
    __CONFIG    _MCLRE_ON & _CP_OFF & _WDT_OFF & _XT_OSC

; pin assignments
    constant    nLED=1          ; flashing LED on GP1  


;***** VARIABLE DEFINITIONS
        UDATA_SHR
sGPIO   res 1                   ; shadow copy of GPIO
dc1     res 1                   ; delay loop counters
dc2     res 1


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
        clrf    GPIO            ; start with GPIO clear (LED off)
        clrf    sGPIO           ; update shadow register        
        movlw   ~(1<<nLED)      ; configure LED pin (only) as an output
        tris    GPIO

;***** Main loop
main_loop
        ; toggle LED
        movf    sGPIO,w  
        xorlw   1<<nLED         ; flip LED pin bit (shadow)
        movwf   sGPIO           
        movwf   GPIO            ; write to GPIO

        ; delay 500 ms
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
        movlw   .11             ; delay another 11 x 3 - 1 + 2 = 34 cycles
        movwf   dc2             ;  -> delay so far = 499,958 + 34 
dly3    decfsz  dc2,f           ;  = 499,992 cycles
        goto    dly3
        nop                     ; main loop overhead = 6 cycles, so add 2 nops
        nop                     ;  -> loop time = 499,992 + 6 + 2 = 500,000 cycles

        ; repeat forever
        goto    main_loop           


        END

