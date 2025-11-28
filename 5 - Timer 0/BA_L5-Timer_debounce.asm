;************************************************************************
;                                                                       *
;   Filename:      BA_L5-Timer_debounce.asm                             *
;   Date:          13/2/12                                              *
;   File Version:  1.1                                                  *
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
;   Description:    Lesson 5, example 3                                 *
;                                                                       *
;   Demonstrates use of Timer0 to implement debounce counting algorithm *
;                                                                       *
;   Toggles LED when pushbutton is pressed then released                *
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
        ; configure ports
        clrf    GPIO            ; start with LED off
        clrf    sGPIO           ;   update shadow        
        movlw   b'111101'       ; configure GP1 (only) as an output
        tris    GPIO 
        ; configure timer   
        movlw   b'11010101'     ; configure Timer0:
                ; --0-----          timer mode (T0CS = 0)
                ; ----0---          prescaler assigned to Timer0 (PSA = 0)
                ; -----101          prescale = 64 (PS = 101)          
        option                  ;   -> increment every 64 us

;***** Main loop
main_loop
        ; wait for button press, debounce using timer0:
wait_dn clrf    TMR0            ; reset timer
chk_dn  btfsc   GPIO,3          ; check for button press (GP3 low)
        goto    wait_dn         ;   continue to reset timer until button down
        movf    TMR0,w          ; has 10ms debounce time elapsed?
        xorlw   .157            ;   (157=10ms/64us)
        btfss   STATUS,Z        ; if not, continue checking button
        goto    chk_dn

        ; toggle LED on GP1
        movf    sGPIO,w
        xorlw   b'000010'       ; toggle shadow register
        movwf   sGPIO           
        movwf   GPIO            ; write to port

        ; wait for button release, debounce using timer0:
wait_up clrf    TMR0            ; reset timer
chk_up  btfss   GPIO,3          ; check for button release (GP3 high)
        goto    wait_up         ;   continue to reset timer until button up
        movf    TMR0,w          ; has 10ms debounce time elapsed?
        xorlw   .157            ;   (157=10ms/64us)
        btfss   STATUS,Z        ; if not, continue checking button
        goto    chk_up

        ; repeat forever
        goto    main_loop        


        END

