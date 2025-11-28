;************************************************************************
;                                                                       *
;   Filename:      BA_L6-Reaction_timer.asm                             *
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
;   Description:    Lesson 6, example 2                                 *
;                   Reaction Timer game.                                *
;                                                                       *
;   Demonstrates use of arithmetic expressions, constants and           *
;   text substitution definitions.                                      *
;                                                                       *
;   User must attempt to press button within defined reaction time      *
;   after "start" LED lights.  Success is indicated by "success" LED.   *
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

    radix       dec

    EXTERN      delay10_R           ; W x 10 ms delay


;***** CONFIGURATION
                ; int reset, no code protect, no watchdog, 4 MHz int clock
    __CONFIG    _MCLRE_OFF & _CP_OFF & _WDT_OFF & _IntRC_OSC

; pin assignments
    #define START       GPIO,2      ; LEDs
    #define SUCCESS     GPIO,1

    #define BUTTON      GPIO,3      ; pushbutton


;***** CONSTANTS
    constant MAXRT=200              ; Maximum reaction time (in ms)


;***** VARIABLE DEFINITIONS
        UDATA
cnt_8ms res 1                       ; counter: increments every 8 ms


;***** RC CALIBRATION
RCCAL   CODE    0x3FF               ; processor reset vector
        res 1                       ; holds internal RC cal value, as a movlw k

;***** RESET VECTOR *****************************************************
RESET   CODE    0x000               ; effective reset vector
        movwf   OSCCAL              ; apply internal RC factory calibration 
        pagesel start
        goto    start               ; jump to main code

;***** Subroutine vectors
delay10                             ; delay W x 10 ms
        pagesel delay10_R
        goto    delay10_R       


;***** MAIN PROGRAM *****************************************************
MAIN    CODE

;***** Initialisation
start
        ; configure ports
        movlw   b'111001'           ; configure GP1 and GP2 (only) as outputs
        tris    GPIO
        ; configure timer
        movlw   b'11010100'         ; configure Timer0:
                ; --0-----              timer mode (T0CS = 0)
                ; ----0---              prescaler assigned to Timer0 (PSA = 0)
                ; -----100              prescale = 32 (PS = 100)            
        option                      ;   -> increment every 32 us

;***** Main loop
main_loop
        ; turn off both LEDs
        clrf    GPIO   
                 
        ; delay 2 sec
        movlw   2000/10             ; (delay is multiple of 10 ms)
        pagesel delay10
        call    delay10 
        pagesel $
              
        ; indicate start
        bsf     START               ; turn on start LED
        
        ; wait up to 1 sec for button press
        banksel cnt_8ms             ; clear timer (8 ms counter)
        clrf    cnt_8ms             ; repeat for 1 sec:
wait1s  clrf    TMR0                ;   clear Timer0        
w_tmr0                              ;   repeat for 8 ms:         
        btfss   BUTTON              ;     if button pressed (low)
        goto    wait1s_end          ;       finish delay loop immediately 
        movf    TMR0,w
        xorlw   8000/32             ;   (8 ms at 32 us/tick)
        btfss   STATUS,Z
        goto    w_tmr0
        incf    cnt_8ms,f           ;   increment 8 ms counter
        movlw   1000/8              ; (1 sec at 8 ms/count)
        xorwf   cnt_8ms,w
        btfss   STATUS,Z
        goto    wait1s
wait1s_end        
        
        ; check elapsed time       
        movlw   MAXRT/8             ; if time < max reaction time (8 ms/count)
        subwf   cnt_8ms,w
        btfss   STATUS,C
        bsf     SUCCESS             ;   turn on success LED

        ; delay 1 sec 
        movlw   1000/10             ; (delay is multiple of 10 ms)  
        pagesel delay10
        call    delay10   
        pagesel $     

        ; repeat forever
        goto    main_loop           


        END

