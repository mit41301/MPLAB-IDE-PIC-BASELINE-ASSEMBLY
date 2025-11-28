;************************************************************************
;                                                                       *
;   Filename:       BA_L4-Toggle_LED-count.asm                          *
;   Date:           30/1/12                                             *
;   File Version:   1.1                                                 *
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
;   Description:    Lesson 4, example 2c                                *
;                                                                       *
;   Demonstrates use of counting algorithm for debouncing               *
;                                                                       *
;   Toggles LED when pushbutton is pressed then released,               *
;   using a counting algorithm to debounce switch                       *
;                                                                       *
;************************************************************************
;                                                                       *
;   Pin assignments:                                                    *
;       GP1 = LED                                                       *
;       GP3 = pushbutton switch (active low)                            *
;                                                                       *
;************************************************************************

    list        p=12F509       
    #include    <p12F509.inc>  


;***** CONFIGURATION
                ; int reset, no code protect, no watchdog, int RC clock
    __CONFIG    _MCLRE_OFF & _CP_OFF & _WDT_OFF & _IntRC_OSC


;***** VARIABLE DEFINITIONS
        UDATA_SHR
sGPIO   res 1                   ; shadow copy of GPIO

        UDATA
db_cnt  res 1                   ; debounce counter
dc1     res 1                   ; delay counter


;***** RC CALIBRATION
RCCAL   CODE    0x3FF           ; processor reset vector
        res 1                   ; holds internal RC cal value, as a movlw k

;***** RESET VECTOR *****************************************************
RESET   CODE    0x000           ; effective reset vector
        movwf   OSCCAL          ; apply internal RC factory calibration 


;***** MAIN PROGRAM *****************************************************

;***** Initialisation
start
        clrf    GPIO            ; start with LED off
        clrf    sGPIO           ;   update shadow	
        movlw   b'111101'       ; configure GP1 (only) as an output
        tris    GPIO            ; (GP3 is an input)

;***** Main loop
main_loop
        banksel db_cnt          ; select data bank for this section

        ; wait for button press 
db_dn   clrf    db_cnt          ; wait until button pressed (GP3 low)
        clrf    dc1             ; debounce by counting:
dn_dly  incfsz  dc1,f           ;   delay 256x3 = 768 us.
        goto    dn_dly
        btfsc   GPIO,3          ;   if button up (GP3 high),
        goto    db_dn           ;       restart count
        incf    db_cnt,f        ;   else increment count
        movlw   .13             ;   max count = 10ms/768us = 13
        xorwf   db_cnt,w        ;   repeat until max count reached
        btfss   STATUS,Z
        goto    dn_dly

        ; toggle LED on GP1
        movf    sGPIO,w
        xorlw   b'000010'       ; toggle bit corresponding to GP1 (bit 1)
        movwf   sGPIO           ;   in shadow register
        movwf   GPIO            ; and write to GPIO

        ; wait for button release
db_up   clrf    db_cnt          ; wait until button released (GP3 high)
        clrf    dc1             ; debounce by counting:
up_dly  incfsz  dc1,f           ;   delay 256x3 = 768 us.
        goto    up_dly
        btfss   GPIO,3          ;   if button down (GP3 low),
        goto    db_up           ;       restart count
        incf    db_cnt,f        ;   else increment count
        movlw   .13             ;   max count = 10ms/768us = 13
        xorwf   db_cnt,w        ;   repeat until max count reached
        btfss   STATUS,Z
        goto    up_dly

        ; repeat forever  
        goto    main_loop 


        END

