;************************************************************************
;                                                                       *
;   Filename:      BA_L7-WDTdemo+LED.asm                                *
;   Date:          20/3/12                                              *
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
;   Files required: delay10.asm         (provides W x 10 ms delay)      *
;                   stdmacros-base.inc  (provides DelayMS macro)        *
;                                                                       *
;************************************************************************
;                                                                       *
;   Description:    Lesson 7, example 3b                                *
;                                                                       *
;   Demonstrates differentiation between WDT and POR reset              *
;                                                                       *
;   Turn on LED for 1 s, turn off, then enter endless loop              *
;   If enabled, WDT timer restarts after 2.3 s -> LED flashes           *
;   Turns on WDT LED to indicate WDT reset                              *
;                                                                       *
;************************************************************************
;                                                                       *
;   Pin assignments:                                                    *
;       GP1 = flashing LED                                              *
;       GP2 = WDT-reset indicator LED                                   *
;                                                                       *
;************************************************************************

    list        p=12F509 
    #include    <p12F509.inc>
    
    #include    <stdmacros-base.inc>    ; DelayMS - delay in milliseconds
                                        ;   (calls delay10)
    EXTERN      delay10_R               ; W x 10 ms delay

    radix       dec


;***** CONFIGURATION
    #define     WATCHDOG        ; define to enable watchdog timer

    IFDEF WATCHDOG
                    ; ext reset, no code protect, watchdog, int RC clock
        __CONFIG    _MCLRE_ON & _CP_OFF & _WDT_ON & _IntRC_OSC
    ELSE
                    ; ext reset, no code protect, no watchdog, int RC clock
        __CONFIG    _MCLRE_ON & _CP_OFF & _WDT_OFF & _IntRC_OSC
    ENDIF

; pin assignments
    #define     LED     GPIO,1      ; LED to flash on GP1
    constant    nLED=1              ;   (port bit 1)
    #define     WDT     GPIO,2      ; watchdog timer reset indicator on GP2
    constant    nWDT=2              ;   (port bit 2)


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
        ; configure port
        clrf    GPIO                ; start with all LEDs off   
        movlw   ~(1<<nLED|1<<nWDT)  ; configure LED pins as outputs
        tris    GPIO
        ; configure watchdog timer
        movlw   1<<PSA | b'111'     ; prescaler assigned to WDT (PSA = 1)
                                    ; prescale = 128 (PS = 111)
        option                      ; -> WDT period = 2.3 s

;***** Main code
        ; test for WDT-timeout reset
        btfss   STATUS,NOT_TO       ; if WDT timeout has occurred,
        bsf     WDT                 ;   turn on "error" LED

        ; flash LED  
        bsf     LED                 ; turn on "flash" LED  
        DelayMS 1000                ; delay 1 sec
        bcf     LED                 ; turn off "flash" LED

        ; wait forever
        goto    $               


        END

