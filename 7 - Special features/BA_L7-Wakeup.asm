;************************************************************************
;                                                                       *
;   Filename:      BA_L7-Wakeup.asm                                     *
;   Date:          19/3/12                                              *
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
;   Files required: stdmacros-base.inc   (provides DbnceHi macro)       *
;                                                                       *
;************************************************************************
;                                                                       *
;   Description:    Lesson 7, example 2a                                *
;                                                                       *
;   Demonstrates wake up on change                                      *
;                                                                       *
;   Turn on LED, debounce then wait for button press                    *
;   turn off LED, debounce, then sleep                                  *
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
    
    #include    <stdmacros-base.inc>    ; DbnceHi - debounce switch, wait for high
                                        ;   (requires TMR0 running at 256 us/tick)
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
        ; configure wake-on-change and Timer0
        movlw   b'01000111'     ; configure wake-up on change and Timer0:
                ; 0-------          enable wake-up on change (/GPWU = 0)
                ; --0-----          timer mode (T0CS = 0)
                ; ----0---          prescaler assigned to Timer0 (PSA = 0)
                ; -----111          prescale = 256 (PS = 111)
        option                  ;   -> increment every 256 us

;***** Main code
        ; turn on LED
        bsf     LED             

        ; wait for stable button high (in case it is still bouncing)
        DbnceHi BUTTON          
 
        ; wait for button press                               
wait_lo btfsc   BUTTON          ; wait until button low
        goto    wait_lo

        ; go into standby (low power) mode
        bcf     LED             ; turn off LED

        DbnceHi BUTTON          ; wait for stable button release

        sleep                   ; enter sleep mode


        END