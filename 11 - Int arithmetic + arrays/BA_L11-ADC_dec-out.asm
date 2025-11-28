;************************************************************************
;                                                                       *
;   Filename:      BA_L11-ADC_dec-out.asm                               *
;   Date:          24/2/12                                              *
;   File Version:  1.4                                                  *
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
;   Description:    Lesson 11, example 1                                *
;                                                                       *
;   Displays ADC output in decimal on 2-digit 7-segment LED display     *
;                                                                       *
;   Continuously samples analog input, scales result to 0 - 99          *
;   and displays as 2 x dec digits on multiplexed 7-seg displays        *
;                                                                       *
;************************************************************************
;                                                                       *
;   Pin assignments:                                                    *
;       AN2             = voltage to be measured (e.g. pot or LDR)      *
;       RB0-1,RB4,RC1-4 = 7-segment display bus (common cathode)        *
;       RC5             = tens digit enable (active high)               *
;       RB5             = ones digit enable                             *
;                                                                       *
;************************************************************************

    list        p=16F506 
    #include    <p16F506.inc>

    radix       dec


;***** CONFIGURATION
                ; ext reset, no code protect, no watchdog, 4 MHz int clock
    __CONFIG    _MCLRE_ON & _CP_OFF & _WDT_OFF & _IOSCFS_OFF & _IntRC_OSC_RB4EN

; pin assignments
    #define TENS_EN     PORTC,5     ; tens digit enable
    #define ONES_EN     PORTB,5     ; ones digit enable


;***** VARIABLE DEFINITIONS
        UDATA
adc_out res 1                   ; raw ADC output
adc_dec res 2                   ; scaled ADC output (LE 16 bit, 0-99 in MSB)
mpy_cnt res 1                   ; multiplier count
                                ; digits to be displayed:
tens    res 1                   ;   tens
ones    res 1                   ;   ones

temp    res 1                   ; (temp storage used by set7seg)


;***** RC CALIBRATION
RCCAL   CODE    0x3FF           ; processor reset vector
        res 1                   ; holds internal RC cal value, as a movlw k

;***** RESET VECTOR *****************************************************
RESET   CODE    0x000           ; effective reset vector
        movwf   OSCCAL          ; apply internal RC factory calibration 
        pagesel start
        goto    start           ; jump to main code

;***** SUBROUTINE VECTORS
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
        clrf    CM1CON0         ; disable comparator 1 -> RB0, RB1 digital
        clrf    CM2CON0         ; disable comparator 2 -> RC0, RC1 digital
        clrf    VRCON           ; disable CVref -> RC2 usable
        
        ; configure ADC
        movlw   b'01111001'     ; configure ADC:
                ; 01------          AN2 (only) analog (ANS = 01)
                ; --11----          clock = INTOSC/4 (ADCS = 11)
                ; ----10--          select channel AN2 (CHS = 10)
                ; -------1          turn ADC on (ADON = 1)
        movwf   ADCON0          ;   -> AN2 ready for sampling
          
        ; configure timer
        movlw   b'11010111'     ; configure Timer0:
                ; --0-----          timer mode (T0CS = 0) -> RC5 usable
                ; ----0---          prescaler assigned to Timer0 (PSA = 0)
                ; -----111          prescale = 256 (PS = 111)            
        option                  ;   -> increment every 256 us        
                                ;      (TMR0<2> cycles every 2.048ms)

;***** Main loop
main_loop
        ; sample input
        bsf     ADCON0,GO       ; start conversion
w_adc   btfsc   ADCON0,NOT_DONE ; wait until conversion complete
        goto    w_adc
        movf    ADRES,w         ; save ADC result in adc_out
        banksel adc_out
        movwf   adc_out

        ; scale to 0-99: adc_dec = adc_out * 100
        ;   -> MSB of adc_dec = adc_out * 100 / 256
        clrf    adc_dec         ; start with adc_dec = 0
        clrf    adc_dec+1
        movlw   .8              ;   count = 8
        movwf   mpy_cnt
        movlw   .100            ;   multiplicand (100) in W
        bcf     STATUS,C        ;   and carry clear
l_mpy   rrf     adc_out,f       ; right shift multiplier
        btfsc   STATUS,C        ; if low-order bit of multiplier was set
        addwf   adc_dec+1,f     ;   add multiplicand (100) to MSB of result
        rrf     adc_dec+1,f     ; right shift result
        rrf     adc_dec,f
        decfsz  mpy_cnt,f       ; repeat for all 8 bits
        goto    l_mpy

        ; extract digits of result
        movf    adc_dec+1,w     ; start with scaled result
        movwf   ones            ;   in ones digit
        clrf    tens            ; and tens clear
l_bcd   movlw   .10             ; subtract 10 from ones
        subwf   ones,w
        btfss   STATUS,C        ; (finish if < 10)
        goto    end_bcd
        movwf   ones 
        incf    tens,f          ; increment tens
        goto    l_bcd           ; repeat until ones < 10
end_bcd

        ; display tens digit for 2.048 ms
w10_hi  btfss   TMR0,2          ; wait for TMR0<2> to go high
        goto    w10_hi
        movf    tens,w          ; output tens digit
        pagesel set7seg
        call    set7seg 
        pagesel $   
        bsf     TENS_EN         ; enable tens display
w10_lo  btfsc   TMR0,2          ; wait for TMR<2> to go low
        goto    w10_lo

        ; display ones digit for 2.048 ms
w1_hi   btfss   TMR0,2          ; wait for TMR0<2> to go high
        goto    w1_hi
        banksel ones            ; output ones digit
        movf    ones,w
        pagesel set7seg
        call    set7seg  
        pagesel $    
        bsf     ONES_EN         ; enable ones display
w1_lo   btfsc   TMR0,2          ; wait for TMR<2> to go low
        goto    w1_lo

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
        banksel temp
        movwf   temp            ; save digit
        call    get7sB          ; lookup pattern for port B
        movwf   PORTB           ;   then output it
        movf    temp,w          ; get digit 
        call    get7sC          ;   then repeat for port C
        movwf   PORTC
        retlw   0


        END

