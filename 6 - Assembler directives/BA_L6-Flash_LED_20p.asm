;************************************************************************
;                                                                       *
;   Filename:       BA_L6-Flash_LED_20p.asm                             *
;   Date:           15/2/12                                             *
;   File Version:   1.5                                                 *
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
;   Description:    Lesson 6, example 6                                 *
;                   Flash an LED at 20% duty cycle                      *
;                                                                       *
;   Demonstrates use of simple macros                                   *
;   with conditional assembly to check macro parameter                  *
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

; pin assignments
    #define     FLASH   GPIO,1      ; flashing LED
    constant    nFLASH=1            ;   (port bit 1)


;***** MACROS
; Delay in milliseconds
;   wrapper for 'delay10' subroutine
DelayMS MACRO   ms                  ; delay time in ms
    IF ms>2550
        ERROR "Maximum delay time is 2550 ms"
    ENDIF
        movlw   ms/.10              ; divide by 10 to pass to delay10 routine
        pagesel delay10
        call    delay10
        pagesel $
        ENDM


;***** VARIABLE DEFINITIONS
        UDATA
dc1     res     1                   ; delay loop counters
dc2     res     1
dc3     res     1


;***** RC CALIBRATION
RCCAL   CODE    0x3FF           ; processor reset vector
        res 1                   ; holds internal RC cal value, as a movlw k

;***** RESET VECTOR *****************************************************
RESET   CODE    0x000           ; effective reset vector
        movwf   OSCCAL          ; apply internal RC factory calibration 
        pagesel start
        goto    start           ; jump to main code

;***** Subroutine vectors
delay10                         ; delay W x 10ms
        pagesel delay10_R
        goto    delay10_R       


;***** MAIN PROGRAM *****************************************************
MAIN    CODE

;***** Initialisation
start
        movlw   ~(1<<nFLASH)        ; configure LED pin (only) as output
        tris    GPIO

;***** Main loop
loop
        bsf     FLASH               ; turn on LED 
        DelayMS 200                 ;   for 200 ms
        bcf     FLASH               ; turn off LED
        DelayMS 800                 ;   for 800 ms

        ; repeat forever
        goto    loop   


;***** SUBROUTINES ******************************************************
SUBS    CODE

;***** Variable delay: 10 ms to 2.55 s
;
;  Delay = W x 10 ms
;
delay10_R
        banksel dc3
        movwf   dc3 

dly2    movlw   .10000/.767         ; # middle loop iterations for 10 ms
        movwf   dc2 
        clrf    dc1                 ; inner loop = 256x3-1 = 767 cycles
dly1    decfsz  dc1,f           
        goto    dly1
        decfsz  dc2,f               ; end middle loop
        goto    dly1            
        decfsz  dc3,f               ; end outer loop
        goto    dly2

        retlw   0


        END

