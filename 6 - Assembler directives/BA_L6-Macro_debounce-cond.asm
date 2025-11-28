;************************************************************************
;                                                                       *
;   Filename:      BA_L6-Macro_debounce-cond.asm                        *
;   Date:          15/2/12                                              *
;   File Version:  1.5                                                  *
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
;   Description:    Lesson 6, example 5                                 *
;                   Toggles LED when button is pressed                  *
;                                                                       *
;   Demonstrates use of conditional assembly                            *
;   to select alternate configurations and pin assignments              *
;                                                                       *
;************************************************************************
;                                                                       *
;   Pin assignments:                                                    *
;       GP1 = indicator LED                                             *
;       GP3 = pushbutton switch (active low)                            *
;   Or:                                                                 *
;       GP0 = indicator LED                                             *
;       GP2 = pushbutton switch (active low)                            *
;                                                                       *
;************************************************************************

    list        p=12F509 
    #include    <p12F509.inc>


;***** CONFIGURATION
    #define     DEBUG
    constant    REV='A'             ; hardware revision

    IFDEF DEBUG
                    ; int reset, no code protect, no watchdog, int RC clock
        __CONFIG    _MCLRE_OFF & _CP_OFF & _WDT_OFF & _IntRC_OSC
    ELSE
                    ; int reset, code protect on, no watchdog, int RC clock
        __CONFIG    _MCLRE_OFF & _CP_ON & _WDT_OFF & _IntRC_OSC
    ENDIF

; pin assignments
    IF REV=='A'                         ; pin assignments for REV A:
        constant    nLED=1              ;   indicator LED on GP1
        #define     BUTTON  GPIO,3      ;   pushbutton on GP3
    ENDIF
    IF REV=='B'                         ; pin assignments for REV B:
        constant    nLED=0              ;   indicator LED on GP0
        #define     BUTTON  GPIO,2      ;   pushbutton on GP2
    ENDIF
    IF REV!='A' && REV!='B'
        ERROR "Revision must be 'A' or 'B'"
    ENDIF


;***** MACROS
; Debounce switch on given input port,pin
; Waits for switch to be 'high' continuously for 10ms
;
; Uses:	TMR0		Assumes: TMR0 running at 256us/tick
;
; Debounce switch on given input port,pin
; Waits for switch to be 'high' continuously for 10 ms
;
; Uses:	TMR0		Assumes: TMR0 running at 256 us/tick
;
DbnceHi MACRO   port,pin
    local       start,wait,DEBOUNCE
    variable    DEBOUNCE=.10*.1000/.256 ; switch debounce count = 10ms/(256us/tick)

        pagesel $               ; select current page for gotos
start   clrf    TMR0            ; button down, so reset timer (counts "up" time)
wait    btfss   port,pin        ; wait for switch to go high (=1)
        goto    start 
        movf    TMR0,w          ; has switch has been up continuously for debounce time?
        xorlw   DEBOUNCE
        btfss   STATUS,Z        ; if not, keep checking that it is still up
        goto    wait
        ENDM


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
        movlw   ~(1<<nLED)      ; configure LED pin (only) as output 
        tris    GPIO    
        ; configure timer          
        movlw   b'11010111'     ; configure Timer0:
                ; --0-----          timer mode (T0CS = 0)
                ; ----0---          prescaler assigned to Timer0 (PSA = 0)
                ; -----111          prescale = 256 (PS = 111)          
        option                  ;   -> increment every 256 us

;***** Main loop
main_loop
        ; wait for button press
wait_dn btfsc   BUTTON          ; wait until button low
        goto    wait_dn 

        ; toggle LED
        movf    sGPIO,w          
        xorlw   1<<nLED         ; toggle shadow register
        movwf   sGPIO           
        movwf   GPIO            ; write to port

        ; wait for button release
        DbnceHi BUTTON          ; wait until button high (debounced)

        ; repeat forever
        goto    main_loop        


        END

