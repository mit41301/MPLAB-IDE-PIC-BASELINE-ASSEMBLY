;************************************************************************
;                                                                       *
;   Filename:      BA_L8-Count_7seg_x1-dt.asm                           *
;   Date:          28/3/12                                              *
;   File Version:  1.1                                                  *
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
;   Files required: delay10.asm         (provides W x 10 ms delay)      *
;                   stdmacros-base.inc  (provides DelayMS macro)        *
;                                                                       *
;************************************************************************
;                                                                       *
;   Description:    Lesson 8, example 1b                                *
;                                                                       *
;   Demonstrates use of DT directive to define lookup tables            *
;                                                                       *
;   Single digit 7-segment LED display counts repeating 0 -> 9          *
;   1 second per count, with timing derived from int 4MHz oscillator    *
;                                                                       *
;************************************************************************
;                                                                       *
;   Pin assignments:                                                    *
;       RB0-1,RB4, RC1-4 = 7-segment display bus (common cathode)       *
;                                                                       *
;************************************************************************

    list        p=16F506 
    #include    <p16F506.inc>
    
    #include    <stdmacros-base.inc>    ; DelayMS - delay in milliseconds
                                        ;   (calls delay10)
    EXTERN      delay10_R               ; W x 10 ms delay

    radix       dec


;***** CONFIGURATION
                ; ext reset, no code protect, no watchdog, 4 MHz int clock
    __CONFIG    _MCLRE_ON & _CP_OFF & _WDT_OFF & _IOSCFS_OFF & _IntRC_OSC_RB4EN


;***** VARIABLE DEFINITIONS
        UDATA_SHR
digit   res 1                   ; digit to be displayed


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
        bcf     CM2CON0,C2ON    ; disable comparator 2 -> RC1 digital

        ; initialise variables
        clrf    digit           ; start with digit = 0

;***** Main loop
main_loop
        ; display digit
        pagesel set7seg         
        call    set7seg

        ; delay 1 sec
        DelayMS 1000            

        ; increment digit
        incf    digit,f         
        movlw   .10
        xorwf   digit,w         ; if digit = 10
        btfsc   STATUS,Z
        clrf    digit           ;   reset it to 0

        ; repeat forever
        pagesel main_loop       
        goto    main_loop


;***** LOOKUP TABLES ****************************************************
TABLES  CODE    0x200           ; locate at beginning of a page

; pattern table for 7 segment display on port B
;   RB4 = E, RB1:0 = FG
get7sB  addwf   PCL,f
        dt      0x12,0x00,0x11,0x01,0x03,0x03,0x13,0x00,0x13,0x03   ; 0-9

; pattern table for 7 segment display on port C
;   RC4:1 = CDBA
get7sC  addwf   PCL,f
        dt      0x1E,0x14,0x0E,0x1E,0x14,0x1A,0x1A,0x16,0x1E,0x1E   ; 0-9

; Display digit passed in 'digit' variable on 7-segment display
set7seg_R
        movf    digit,w         ; get digit to display
        call    get7sB          ; lookup pattern for port B
        movwf   PORTB           ;   then output it
        movf    digit,w         ; repeat for port C
        call    get7sC
        movwf   PORTC
        retlw   0


        END

