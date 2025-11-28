;************************************************************************
;                                                                       *
;   Filename:       BA_L4-Toggle_LED-no_db.asm                          *
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
;   Description:    Lesson 4, example 2a                                *
;                                                                       *
;   Demonstrates the need for debouncing                                *
;                                                                       *
;   Toggles LED when pushbutton is pressed then released                *
;   (no debounce)                                                       *
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
        ; wait for button press
wait_dn btfsc   GPIO,3          ; wait until GP3 low
        goto    wait_dn

        ; toggle LED on GP1
        movf    sGPIO,w
        xorlw   b'000010'       ; toggle bit corresponding to GP1 (bit 1)
        movwf   sGPIO           ;   in shadow register
        movwf   GPIO            ; and write to GPIO

        ; wait for button release
wait_up btfss   GPIO,3          ; wait until GP3 high
        goto    wait_up      

        ; repeat forever
        goto    main_loop


        END

