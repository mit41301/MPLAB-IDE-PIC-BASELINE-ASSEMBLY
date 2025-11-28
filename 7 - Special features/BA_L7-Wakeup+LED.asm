;************************************************************************
;                                                                       *
;   Filename:      BA_L7-Wakeup+LED.asm                                 *
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
;   Description:    Lesson 7, example 2b                                *
;                                                                       *
;   Demonstrates differentiation between wake up on change              *
;   and POR reset                                                       *
;                                                                       *
;   Turn on LED after each reset                                        *
;   Turn on WAKE LED only if reset was due to wake on change            *
;   then wait for button press, turn off LEDs, debounce, then sleep     *
;                                                                       *
;************************************************************************
;                                                                       *
;   Pin assignments:                                                    *
;       GP1 = on/off indicator LED                                      *
;       GP2 = wake-on-change indicator LED                              *
;       GP3 = pushbutton switch (active low)                            *
;                                                                       *
;************************************************************************

    list        p=12F509 
    #include    <p12F509.inc>
    
    #include    <stdmacros-base.inc>    ; DbcneHi - debounce switch, wait for high
                                        ;   (requires TMR0 running at 256 us/tick)    
    radix       dec


;***** CONFIGURATION
                ; int reset, no code protect, no watchdog, int RC clock
    __CONFIG    _MCLRE_OFF & _CP_OFF & _WDT_OFF & _IntRC_OSC

; pin assignments
    #define     LED     GPIO,1      ; on/off indicator LED on GP1
    constant    nLED=1              ;   (port bit 1)
    #define     WAKE    GPIO,2      ; wake on change indicator LED on GP2
    constant    nWAKE=2             ;   (port bit 2)
    #define     BUTTON  GPIO,3      ; pushbutton on GP3 (active low)


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
        clrf    GPIO            ; start with all LEDs off
        movlw   ~(1<<nLED|1<<nWAKE) ; configure LED pins as outputs
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

        ; test for wake-on-change reset
        btfss   STATUS,GPWUF    ; if wake-up on change has occurred,
        goto    wait_lo
        bsf     WAKE            ;   turn on wake-up indicator
        DbnceHi BUTTON          ;   wait for button to stop bouncing

        ; wait for button press                               
wait_lo btfsc   BUTTON          ; wait until button low
        goto    wait_lo

        ; go into standby (low power) mode
        clrf    GPIO            ; turn off LEDs

        DbnceHi BUTTON          ; wait for stable button release

        sleep                   ; enter sleep mode


        END

