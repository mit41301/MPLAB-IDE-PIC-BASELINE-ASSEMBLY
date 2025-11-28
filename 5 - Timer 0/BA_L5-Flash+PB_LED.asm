;************************************************************************
;                                                                       *
;   Filename:      BA_L5-Flash+PB_LED.asm                               *
;   Date:          13/2/12                                              *
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
;   Description:    Lesson 5, example 2                                 *
;                                                                       *
;   Demonstrates use of Timer0 to maintain timing of background actions *
;   while performing other actions in response to changing inputs       *
;                                                                       *
;   One LED simply flashes at 1 Hz (50% duty cycle).                    *
;   The other LED is only lit when the pushbutton is pressed            *
;                                                                       *
;************************************************************************
;                                                                       *
;   Pin assignments:                                                    *
;       GP1 = "button pressed" indicator LED                            *
;       GP2 = flashing LED                                              *
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
dly_cnt res 1                   ; delay counter


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
        clrf    sGPIO           ;   update shadow        
        movlw   b'111001'       ; configure GP1 and GP2 (only) as outputs
        tris    GPIO 
        ; configure timer
        movlw   b'11010100'     ; configure Timer0:
                ; --0-----          timer mode (T0CS = 0)
                ; ----0---          prescaler assigned to Timer0 (PSA = 0)
                ; -----100          prescale = 32 (PS = 100)            
        option                  ;   -> increment every 32 us

;***** Main loop
main_loop    
        ; delay 500 ms while responding to button press
        banksel dly_cnt
        movlw   .125            ; repeat 125 times (125 x 4 ms = 500 ms)
        movwf   dly_cnt     
dly500  clrf    TMR0            ;   clear timer0 
w_tmr0                          ;   repeat for 4 ms:
                                ;     check and respond to button press      
        bcf     sGPIO,1         ;       assume button up -> indicator LED off
        btfss   GPIO,3          ;       if button pressed (GP3 low)
        bsf     sGPIO,1         ;         turn on indicator LED
        movf    sGPIO,w         ;     update port (copy shadow to GPIO)
        movwf   GPIO
        movf    TMR0,w     
        xorlw   .125            ;   (125 ticks x 32 us/tick = 4 ms)            
        btfss   STATUS,Z
        goto    w_tmr0
        decfsz  dly_cnt,f       ; end 500 ms delay loop
        goto    dly500

        ; toggle flashing LED       
        movf    sGPIO,w
        xorlw   b'000100'       ; toggle LED on GP2
        movwf   sGPIO           ;   using shadow register

        ; repeat forever
        goto    main_loop           


        END

