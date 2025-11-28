;************************************************************************
;                                                                       *
;   Filename:      BA_L3-Flash_LED-sub.asm                              *
;   Date:          22/1/12                                              *
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
;   Description:    Lesson 3, example 1                                 *
;                                                                       *
;   Demonstrates simple subroutine calls with parameter passing         *
;                                                                       *
;   Flashes a LED at approx 1 Hz, with 20% duty cycle                   *
;   LED continues to flash until power is removed                       *
;                                                                       *
;************************************************************************
;                                                                       *
;   Pin assignments:                                                    *
;       GP1 = flashing LED                                              *
;                                                                       *
;************************************************************************

    list        p=12F509      
    #include    <p12F509.inc>


;***** CONFIGURATION
                ; ext reset, no code protect, no watchdog, int RC clock 
    __CONFIG    _MCLRE_ON & _CP_OFF & _WDT_OFF & _IntRC_OSC


;***** VARIABLE DEFINITIONS
        UDATA
dc1     res 1                   ; delay loop counters
dc2     res 1
dc3     res 1


;***** RC CALIBRATION
RCCAL   CODE    0x3FF       ; processor reset vector
        res 1               ; holds internal RC cal value, as a movlw k
        

;***** RESET VECTOR *****************************************************
RESET   CODE    0x000       ; effective reset vector
        movwf   OSCCAL      ; apply internal RC factory calibration 


;***** MAIN PROGRAM *****************************************************

;***** Initialisation
start		
        movlw   b'111101'       ; configure GP1 (only) as an output
        tris    GPIO

;***** Main loop
main_loop
        ; turn on LED
        movlw   b'000010'       ; set GP1 (bit 1)
        movwf   GPIO  
        ; delay 0.2 s
        movlw   .20             ; delay 20 x 10 ms = 200 ms
        call    delay10         
        ; turn off LED
        clrf    GPIO            ; (clearing GPIO clears GP1)
        ; delay 0.8 s
        movlw   .80             ; delay 80 x 10ms = 800ms
        call    delay10  
          
        ; repeat forever       
        goto    main_loop       



;***** SUBROUTINES ******************************************************

;***** Variable delay: 10 ms to 2.55 s
;
;  Delay = W x 10 ms
;
delay10                     
        movwf   dc3             ; delay = 1+Wx(3+10009+3)-1+4 = W x 10.015ms
dly2    movlw   .13             ; repeat inner loop 13 times
        movwf   dc2             ; -> 13x(767+3)-1 = 10009 cycles
        clrf    dc1             ; inner loop = 256x3-1 = 767 cycles
dly1    decfsz  dc1,f           
        goto    dly1
        decfsz  dc2,f           ; end middle loop
        goto    dly1            
        decfsz  dc3,f           ; end outer loop
        goto    dly2

        retlw   0


        END
