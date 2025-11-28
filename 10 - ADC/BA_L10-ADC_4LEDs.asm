;************************************************************************
;                                                                       *
;   Filename:       BA_L10-ADC_4LEDs.asm                                *
;   Date:           23/4/12                                             *
;   File Version:   1.3                                                 *
;                                                                       *
;   Author:         David Meiklejohn                                    *
;   Company:        Gooligum Electronics                                *
;                                                                       *
;************************************************************************
;                                                                       *
;   Architecture:   Baseline PIC                                        *
;   Processor:      16F506                                              *
;                                                                       *
;************************************************************************
;                                                                       *
;   Files required: none                                                *
;                                                                       *
;************************************************************************
;                                                                       *
;   Description:    Lesson 10, example 1                                *
;                                                                       *
;   Demonstrates basic use of ADC                                       *
;                                                                       *
;   Continuously samples analog input, copying value to 4 x LEDs        *
;                                                                       *
;************************************************************************
;                                                                       *
;   Pin assignments:                                                    *
;       AN0   = voltage to be measured (e.g. pot output)                *
;       RC0-3 = output LEDs                                             *
;                                                                       *
;************************************************************************

    list        p=16F506 
    #include    <p16F506.inc>

    radix       dec


;***** CONFIGURATION
                ; ext reset, no code protect, no watchdog, 4 Mhz int clock
    __CONFIG    _MCLRE_ON & _CP_OFF & _WDT_OFF & _IOSCFS_OFF & _IntRC_OSC_RB4EN

; pin assignments
    #define LEDS    PORTC       ; output LEDs on RC0-RC3


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
        movlw   b'110000'       ; configure RC0-RC3 (only) as outputs
        tris    PORTC 
        clrf    CM2CON0         ; disable comparator 2 -> RC0, RC1 digital
        clrf    VRCON           ; disable CVref -> RC2 usable
        
        ; configure ADC
        movlw   b'10110001'     ; configure ADC:
                ; 10------          AN0, AN2 analog (ANS = 10)
                ; --11----          clock = INTOSC/4 (ADCS = 11)
                ; ----00--          select channel AN0 (CHS = 00)
                ; -------1          turn ADC on (ADON = 1)
        movwf   ADCON0          ;   -> AN0 ready for sampling


;***** Main loop
main_loop
        ; sample analog input
        bsf     ADCON0,GO       ; start conversion
w_adc   btfsc   ADCON0,NOT_DONE   ; wait until done
        goto    w_adc
        
        ; display result on 4 x LEDs
        swapf   ADRES,w         ; copy high nybble of result 
        movwf   LEDS            ;   to low nybble of output port (LEDs)

        ; repeat forever
        goto    main_loop       


        END

