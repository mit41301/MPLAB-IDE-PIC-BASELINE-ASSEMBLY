;************************************************************************
;                                                                       *
;   Filename:      BA_L5-Reaction_timer.asm                             *
;   Date:          22/9/13                                              *
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
;   Files required: delay10.asm        (provides W x 10 ms delay)       *
;                                                                       *
;************************************************************************
;                                                                       *
;   Description:    Lesson 5, example 1                                 *    
;                   Reaction Timer game.                                *
;                                                                       *
;   Demonstrates use of Timer0 to time real-world events                *
;                                                                       *
;   User must attempt to press button within 200 ms of "start" LED      *
;   lighting.  If and only if successful, "success" LED is lit.         *
;                                                                       *
;       Starts with both LEDs unlit.                                    *
;       2 sec delay before lighting "start"                             *
;       Waits up to 1 sec for button press                              *
;       (only) on button press, lights "success"                        *
;       1 sec delay before repeating from start                         *
;                                                                       *
;************************************************************************
;                                                                       *
;   Pin assignments:                                                    *
;       GP1 = success LED                                               *
;       GP2 = start LED                                                 *
;       GP3 = pushbutton switch (active low)                            *
;                                                                       *
;************************************************************************

    list        p=12F509   
    #include    <p12F509.inc>

    EXTERN  delay10_R       ; W x 10 ms delay

        
;***** CONFIGURATION
                ; int reset, no code protect, no watchdog, int RC clock
    __CONFIG    _MCLRE_OFF & _CP_OFF & _WDT_OFF & _IntRC_OSC


;***** VARIABLE DEFINITIONS
        UDATA
cnt_8ms res 1                   ; counter: increments every 8 ms


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
        ; turn off both LEDs
        clrf    GPIO   
                 
        ; delay 2 sec
        movlw   .200            ; 200 x 10 ms = 2 sec
        pagesel delay10
        call    delay10
        pagesel $           
        
        ; indicate start
        bsf     GPIO,2          ; turn on start LED     
           
        ; wait up to 1 sec for button press
        banksel cnt_8ms         ; clear timer (8 ms counter)
        clrf    cnt_8ms         ; repeat for 1 sec:
wait1s  clrf    TMR0            ;   clear Timer0        
w_tmr0                          ;   repeat for 8 ms:
        btfss   GPIO,3          ;     if button pressed (GP3 low)
        goto    wait1s_end      ;       finish delay loop immediately 
        movf    TMR0,w        
        xorlw   .250            ;   (250 ticks x 32 us/tick = 8 ms)
        btfss   STATUS,Z        
        goto    w_tmr0
        incf    cnt_8ms,f       ;   increment 8 ms counter
        movlw   .125            ; (125 x 8 ms = 1 sec) 
        xorwf   cnt_8ms,w
        btfss   STATUS,Z
        goto    wait1s
wait1s_end
        
        ; indicate success if elapsed time < 200 ms       
        movlw   .25             ; if time < 200 ms (25 x 8 ms)
        subwf   cnt_8ms,w
        btfss   STATUS,C
        bsf     GPIO,1          ;   turn on success LED
        
        ; delay 1 sec
        movlw   .100            ; 100 x 10 ms = 1 sec
        pagesel delay10
        call    delay10
        pagesel $        

        ; repeat forever
        goto    main_loop            


        END

