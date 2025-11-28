;************************************************************************
;                                                                       *
;   Filename:      BA_L3-Flash_LED-main.asm                             *
;   Date:          26/1/12                                              *
;   File Version:  1.2                                                  *
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
;   Files required: delay10.asm     (provides W x 10 ms delay)          *
;                                                                       *
;************************************************************************
;                                                                       *
;   Description:    Lesson 3, example 3                                 *
;                                                                       *
;   Demonstrates how to call external modules                           *
;                                                                       *
;   Flashes a LED at approx 1 Hz                                        *
;   LED continues to flash until power is removed                       *
;                                                                       *
;************************************************************************
;                                                                       *
;   Pin assignments:                                                    *
;       GP1 = flashing LED                                              *
;                                                                       *
;************************************************************************

    list        p=12F509      
    #include    <p12F509.inc>

    EXTERN      delay10_R       ; W x 10 ms delay
    

;***** CONFIGURATION
                ; ext reset, no code protect, no watchdog, int RC clock 
    __CONFIG    _MCLRE_ON & _CP_OFF & _WDT_OFF & _IntRC_OSC


;***** VARIABLE DEFINITIONS
        UDATA_SHR
sGPIO   res     1               ; shadow copy of GPIO


;***** RC CALIBRATION
RCCAL   CODE    0x3FF           ; processor reset vector
        res 1                   ; holds internal RC cal value, as a movlw k
        

;***** RESET VECTOR *****************************************************
RESET   CODE    0x000           ; effective reset vector
        movwf   OSCCAL          ; apply internal RC factory calibration 
        pagesel start
        goto    start           ; jump to main code

;***** Subroutine vectors
delay10                         ; delay W x 10 ms
        pagesel delay10_R
        goto    delay10_R       


;***** MAIN PROGRAM *****************************************************
MAIN    CODE

;***** Initialisation
start		
        movlw   b'111101'       ; configure GP1 (only) as an output
        tris    GPIO

        clrf    sGPIO           ; start with shadow GPIO zeroed

;***** Main loop
main_loop
        ; toggle LED on GP1
        movf    sGPIO,w         ; get shadow copy of GPIO
        xorlw   b'000010'       ; toggle bit corresponding to GP1 (bit 1)
        movwf   sGPIO           ;   in shadow register
        movwf   GPIO            ; and write to GPIO
        ; delay 0.5 s
        movlw   .50             ; delay 50 x 10 ms = 500 ms
        pagesel delay10         ;   -> 1 Hz flashing at 50% duty cycle
        call    delay10         
          
        ; repeat forever  
        pagesel main_loop     
        goto    main_loop   


        END
