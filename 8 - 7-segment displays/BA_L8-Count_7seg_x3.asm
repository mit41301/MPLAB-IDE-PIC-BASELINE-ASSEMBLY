;************************************************************************
;                                                                       *
;   Filename:      BA_L8-Count_7seg_x3.asm                              *
;   Date:          3/4/12                                               *
;   File Version:  1.3                                                  *
;                                                                       *
;   Author:        David Meiklejohn                                     *
;   Company:       Gooligum Electronics                                 *
;                                                                       *
;************************************************************************
;                                                                       *
;   Architecture:  Baseline PIC                                         *
;   Processor:     16F506                                               *
;                                                                       *
;************************************************************************
;                                                                       *
;   Files required: none                                                *
;                                                                       *
;************************************************************************
;                                                                       *
;   Description:    Lesson 8, example 2                                 *
;                                                                       *
;   Demonstrates use of multiplexing to drive multiple 7-seg displays   *
;                                                                       *
;   3 digit 7-segment LED display: 1 digit minutes, 2 digit seconds     *
;   counts in seconds 0:00 to 9:59 then repeats,                        *
;   with timing derived from int 4 MHz oscillator                       *
;                                                                       *
;************************************************************************
;                                                                       *
;   Pin assignments:                                                    *
;       RB0-1,RB4,RC1-4 = 7-segment display bus (common cathode)        *
;       RC5             = minutes enable (active high)                  *
;       RB5             = tens enable                                   *
;       RC0             = ones enable                                   *
;                                                                       *
;************************************************************************

    list        p=16F506 
    #include    <p16F506.inc>

    radix       dec


;***** CONFIGURATION
                ; ext reset, no code protect, no watchdog, 4 MHz int clock
    __CONFIG    _MCLRE_ON & _CP_OFF & _WDT_OFF & _IOSCFS_OFF & _IntRC_OSC_RB4EN

; pin assignments
    #define MINUTES PORTC,5     ; minutes enable
    #define TENS    PORTB,5     ; tens enable
    #define ONES    PORTC,0     ; ones enable


;***** VARIABLE DEFINITIONS
        UDATA_SHR
temp    res 1                   ; used by set7seg routine (temp digit store)

        UDATA
mpx_cnt res 1                   ; multiplex counter
mins    res 1                   ; current count: minutes
tens    res 1                   ;   tens
ones    res 1                   ;   ones


;***** RC CALIBRATION
RCCAL   CODE    0x3FF           ; processor reset vector
        res 1                   ; holds internal RC cal value, as a movlw k
        

;***** RESET VECTOR *****************************************************
RESET   CODE    0x000           ; effective reset vector
        movwf   OSCCAL          ; apply internal RC factory calibration 
        pagesel start
        goto    start           ; jump to main code

;***** Subroutine vectors
set7seg                         ; display digit on 7-segment display
        pagesel set7seg_R       
        goto    set7seg_R


;***** MAIN PROGRAM *****************************************************
MAIN    CODE

;***** Initialisation
start  
        ; configure ports
        clrw                    ; configure PORTB and PORTC as all outputs
        tris    PORTB
        tris    PORTC
        clrf    ADCON0          ; disable AN0, AN1, AN2 inputs 
        bcf     CM1CON0,C1ON    ;     and comparator 1 -> RB0,RB1 digital
        bcf     CM2CON0,C2ON    ; disable comparator 2 -> RC0,RC1 digital
        
        ; configure timer
        movlw   b'11010111'     ; configure Timer0:
                ; --0-----          timer mode (T0CS = 0) -> RC5 usable
                ; ----0---          prescaler assigned to Timer0 (PSA = 0)
                ; -----111          prescale = 256 (PS = 111)            
        option                  ;   -> increment every 256 us        
                                ;      (TMR0<2> cycles every 2.048 ms)
        ; initialise variables
        banksel mins            ; start with count = 0:00
        clrf    mins
        clrf    tens
        clrf    ones

;***** Main loop
main_loop

; multiplex display for 1 sec
        movlw   1000000/2048/3  ; display each of 3 digits for 2.048 ms each
        movwf   mpx_cnt         ;   repeat multiplex loop for approx 1 second
        
mplex_loop
        ; display minutes for 2.048 ms
w60_hi  btfss   TMR0,2          ; wait for TMR0<2> to go high
        goto    w60_hi
        movf    mins,w          ; output minutes digit
        pagesel set7seg
        call    set7seg  
        pagesel $      
        bsf     MINUTES         ; enable minutes display
w60_lo  btfsc   TMR0,2          ; wait for TMR<2> to go low
        goto    w60_lo

        ; display tens for 2.048 ms
w10_hi  btfss   TMR0,2          ; wait for TMR0<2> to go high
        goto    w10_hi
        movf    tens,w          ; output tens digit
        pagesel set7seg
        call    set7seg     
        pagesel $   
        bsf     TENS            ; enable tens display
w10_lo  btfsc   TMR0,2          ; wait for TMR<2> to go low
        goto    w10_lo

        ; display ones for 2.048 ms
w1_hi   btfss   TMR0,2          ; wait for TMR0<2> to go high
        goto    w1_hi
        movf    ones,w          ; output ones digit
        pagesel set7seg
        call    set7seg    
        pagesel $    
        bsf     ONES            ; enable ones display
w1_lo   btfsc   TMR0,2          ; wait for TMR<2> to go low
        goto    w1_lo

        decfsz  mpx_cnt,f       ; continue to multiplex display
        goto    mplex_loop      ;   until 1 sec has elapsed

; increment time counters
        incf    ones,f          ; increment ones
        movlw   .10
        xorwf   ones,w          ; if ones overflow,
        btfss   STATUS,Z
        goto    end_inc  
        clrf    ones            ;   reset ones to 0
        incf    tens,f          ;   and increment tens
        movlw   .6
        xorwf   tens,w          ;   if tens overflow,
        btfss   STATUS,Z
        goto    end_inc  
        clrf    tens            ;       reset tens to 0
        incf    mins,f          ;       and increment minutes
        movlw   .10
        xorwf   mins,w          ;       if minutes overflow,
        btfsc   STATUS,Z
        clrf    mins            ;           reset minutes to 0
end_inc 

; repeat forever
        goto    main_loop       


;***** LOOKUP TABLES ****************************************************
TABLES  CODE    0x200           ; locate at beginning of a page

; pattern table for 7 segment display on port B
;   RB4 = E, RB1:0 = FG
get7sB  addwf   PCL,f
        retlw   b'010010'       ; 0
        retlw   b'000000'       ; 1
        retlw   b'010001'       ; 2
        retlw   b'000001'       ; 3
        retlw   b'000011'       ; 4
        retlw   b'000011'       ; 5
        retlw   b'010011'       ; 6
        retlw   b'000000'       ; 7
        retlw   b'010011'       ; 8
        retlw   b'000011'       ; 9

; pattern table for 7 segment display on port C
;   RC4:1 = CDBA
get7sC  addwf   PCL,f
        retlw   b'011110'       ; 0
        retlw   b'010100'       ; 1
        retlw   b'001110'       ; 2
        retlw   b'011110'       ; 3
        retlw   b'010100'       ; 4
        retlw   b'011010'       ; 5
        retlw   b'011010'       ; 6
        retlw   b'010110'       ; 7
        retlw   b'011110'       ; 8
        retlw   b'011110'       ; 9

; Display digit passed in W on 7-segment display
set7seg_R
        ; disable displays
        clrf    PORTB           ; clear all digit enable lines on PORTB
        clrf    PORTC           ;   and PORTC
        
        ; output digit pattern
        movwf   temp            ; save digit
        call    get7sB          ; lookup pattern for port B
        movwf   PORTB           ;   then output it
        movf    temp,w          ; get digit 
        call    get7sC          ;   then repeat for port C
        movwf   PORTC
        retlw   0


        END

