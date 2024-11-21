ORG 0000H
LJMP START
  
  
 ORG 001BH
 INC A; increments A for every timer1 overflow
 JNZ EXIT 
 MOV R2, #0FFH ; Accumulator overflow check value
 EXIT: RETI
 
 
 
 ORG 0030H
 START:MOV P1,#00000000B   ; sets P1 as output port
 CLR P3.0                  ; sets P3.0 as output for sending trigger
 SETB P3.1                 ; sets P3.1 as input for receiving echo
 MOV TMOD,#00100000B       ; sets timer1 as mode 2 auto reload timer
 MOV IE, #10001000B        ; timer 1 overflow interrupt active
 
 ACALL INIT
 
 ACALL Disp_MSG1
 ACALL DELAY2
 ACALL Disp_MSG2
 ACALL DELAY4
 
 ACALL CLSCR
 
 ACALL Disp_MSG3
 ACALL DELAY2
 ACALL Disp_MSG4
 ACALL DELAY4
 
 ACALL CLSCR
 
 
 
 
 MAIN:  
 MOV TL1,#-53     ; loads the initial value to start counting from (54 count = 1cm)
                  ; reduced to 50 to account for processing cycles
 MOV TH1,#-53     ; loads the reload value
                  ; use maximum 54 for 11.0592 MHZ and 58 for 12MHZ
 MOV A,#00000000B ; clears accumulator
 
 SETB P3.0        ; starts the trigger pulse
 ACALL DELAY1     ; gives 10uS width for the trigger pulse
 CLR P3.0         ; ends the trigger pulse
 
 HERE:JNB P3.1,HERE ; loops here until echo is received
 BACK:SETB TR1      ; starts the timer1
 HERE1:JNB TF1,HERE1 ; loops here until timer overflows (54 count = 1cm)
 JB P3.1,BACK     ; jumps to BACK if echo is still available.
 CLR TR1          ; stops timer
 MOV R0,A         ; saves the value of A to R0
 
 
 ACALL CLSCR
 ACALL Disp_MSG5
 ACALL DELAY2
 ACALL DISLOOP    ; calls the display loop
 ACALL DELAY3          
 
 SJMP MAIN        ; jumps to MAIN loop 
 
 
 
 
 DISLOOP:
 MOV A, #0C0H        ; force cursor to second line 
 ACALL initial
 
 ACALL DELAY2   
 MOV DPTR, #VALUE    ;value lut location
 
 MOV A,R0            ; set A to value in R0


 CJNE R2, #0FFH, NORMAL; for values over 255
 ;Isolating Hundreds
 MOV B, #100D
 DIV AB
 MOV R2, A
 ;Isolating tens
 MOV A, B
 MOV B, #10D
 DIV AB
 MOV R3, A
 MOV R4, B

 MOV A, R4
 ADD A, #5D
 MOV B, #10D
 DIV AB
 MOV R4, B

 ADD A, R3
 ADD A, #5D
 MOV B, #10D
 DIV AB
 MOV R3, B

 ADD A, R2
 ADD A, #2D
 MOV R2, A


 ;Display Values
 MOV A, R2
 ACALL Digit_display
 MOV A, R3
 ACALL Digit_display
 MOV A, R4
 ACALL Digit_display
 
 MOV R2, #0000H

 SJMP UD ; jump to display cm

 NORMAL: ; values below 255
 MOV B, #100D
 DIV AB
 JZ TENS
 ACALL Digit_display   
 ;Isolating tens
 TENS: MOV A, B
 MOV B, #10D
 DIV AB
 ACALL Digit_display
 ;Isolating ones
 MOV A, B
 ACALL Digit_display     
 
 UD: MOV DPTR ,#UNITS    ; display cm routine
 MOV A,#0D       
 ACALL Digit_display 
 MOV A,#1D       
 ACALL Digit_display       
 
 RET
 
 Initial: ACALL DELAY2 ; initialization subroutines
 MOV P1, A   
 CLR P2.0    
 SETB P2.1
 ACALL DELAY2
 CLR P2.1
 RET    
 
 Digit_display: ACALL DELAY2 
 MOVC A,@A+DPTR   ; gets the digit drive pattern for the content in A
 MOV P1, A      
 SETB P2.0     
 SETB P2.1     
 CLR P2.1     
 RET 
 
 DELAY1: MOV R6,#4D     ;~10uS delay
 L: DJNZ R6,L
 RET 
 
 
 DELAY2: MOV R6, #4D  ;~1 ms delay 
 L1: MOV R7, #125D  
 L2: DJNZ R7, L2    
 DJNZ R6, L1     
 RET
 
 
 DELAY3:MOV R5, #125D   ; ~10 sec delay 
 D1: MOV R6, #200D  
 D2: MOV R7, #200D 
 INNER: DJNZ R7,INNER   
 DJNZ R6, D2
 DJNZ R5, D1
 RET
 
 
 
 DELAY4:MOV R5, #150D   ; ~ 3 sec delay 
 D14: MOV R6, #100D  
 D24: MOV R7, #100D 
 INNER4: DJNZ R7,INNER4    
 DJNZ R6, D24
 DJNZ R5, D14
 RET 
 
 
 
 Disp_MSG1:
 MOV A, #080H
 ACALL Initial
 
 
 MOV DPTR, #MESSAGE1
 MOV R1, #15D
 
 MSG1: MOV A,#00H
 ACALL Digit_display
 INC DPTR
 DJNZ R1, MSG1
 
 RET
 
 
 Disp_MSG2:
 MOV A, #0C0H
 ACALL Initial
 
 
 MOV DPTR, #MESSAGE2
 MOV R1, #11D
 
 MSG2: MOV A,#00H
 ACALL Digit_display
 INC DPTR
 DJNZ R1, MSG2
 
 RET
 
 Disp_MSG3:
 MOV A, #80H
 ACALL Initial
 
 
 MOV DPTR, #MESSAGE3
 MOV R1, #16D
 
 MSG3: MOV A,#00H
 ACALL Digit_display
 INC DPTR
 DJNZ R1, MSG3
 
 RET
 
 Disp_MSG4:
 MOV A, #0C0H
 ACALL Initial
 
 
 MOV DPTR, #MESSAGE4
 MOV R1, #13D
 
 MSG4: MOV A,#00H
 ACALL Digit_display
 INC DPTR
 DJNZ R1, MSG4
 
 RET
 
 
 Disp_MSG5:
 MOV A, #080H
 ACALL Initial
 
 
 MOV DPTR, #MESSAGE5
 MOV R1, #16D
 
 MSG5: MOV A,#00H
 ACALL Digit_display
 INC DPTR
 DJNZ R1, MSG5
 
 RET
 
 
 
 
 INIT:MOV A, #38H   ; use 2 lines and 5*7 
 ACALL initial
 ACALL DELAY2 
 MOV A, #0EH   ;cursor blinking off 
 ACALL initial
 ACALL DELAY2
 ACALL CLSCR
 RET
 
 
 CLSCR:MOV A, #01H   ;clear screen 
 ACALL initial
 ACALL DELAY2
 RET
 
 
 
 
 VALUE:DB '0' 
       DB '1'
       DB '2'
       DB '3'
       DB '4'
       DB '5'
       DB '6'
       DB '7'
       DB '8'
       DB '9'
 
 UNITS: DB 'c'
        DB 'm'
 
 MESSAGE1: DB 'ULTRASONIC DIST',0
 MESSAGE2: DB 'MEASUREMENT',0
 MESSAGE3: DB 'BY JEREMY INYEGA',0
 MESSAGE4: DB 'F17/1323/2018'
 MESSAGE5: DB 'THE DISTANCE IS:',0
 
 END 