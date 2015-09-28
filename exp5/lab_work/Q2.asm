LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable
LED equ P1

ORG 0000H
LJMP MAIN

ORG 000BH ;ISR address for Timer 0
INC R0 ;To keep the count of no. of times timer has overflown
RETI

ORG 200H
MAIN:
LCALL DISPLAY_MSG1
	BACK: 	
	
	LCALL START_TIMER
	LCALL DISPLAY_MSG2
	SJMP BACK
HERE: SJMP HERE

DISPLAY_MSG1:
	  mov P2,#00h
	  mov P1,#00h
	  ;initial delay for lcd power up
      	  acall delay
	  acall delay

	  acall lcd_init      ;initialise LCD
	  
	  acall delay
	  acall delay
	  acall delay

	  mov a,#80h		 ;Put cursor on first row,0 column

	  acall lcd_command	 ;send command to LCD

	  acall delay

	  mov   dptr,#STR1   ;Load DPTR with sring1 Addr

	  acall lcd_sendstring	   ;call text strings sending routine

	  acall delay

	  mov a,#0C2h		  ;Put cursor on second row,2 column

	  acall lcd_command

	  acall delay

	  mov   dptr,#STR2

	  acall lcd_sendstring

	ret

	

;-------------starting timer----------------------------------------------------------

START_TIMER:

	MOV TMOD,#01h				;Configures TMOD,(for 16 bit mode)

	MOV TL0,#0

	MOV TH0,#0

	SETB EA
	SETB ET0					;Setting IE correctly and actions on timer overflow should be

	MOV p1,#1Fh					;-Switches on LED

	MOV R0,#0

	SETB TR0					;Starts Timer ()

	AGAIN:jnb p1.0,AGAIN				;Wait for switch to go off.

	MOV p1,#0Fh
	CLR TR0						;Clear TR0 to stop timer.
	RET

;-----------Displays second msg---------------------------------------------

DISPLAY_MSG2:
	  mov P2,#00h
	  mov P1,#01h

	  ;initial delay for lcd power up

      acall delay
	  acall delay

	  acall lcd_init      ;initialise LCD

	  acall delay
	  acall delay
	  acall delay

	  mov a,#81h		 		;Put cursor on first row,1 column
	  acall lcd_command	 		;send command to LCD
	  acall delay

	  mov   dptr,#STR3   ;Load DPTR with sring1 Addr
	  acall lcd_sendstring	   ;call text strings sending routine
	  acall delay

	  mov a,#0C0h		  		;Put cursor on second row,0 column
	  acall lcd_command
	  acall delay

	  mov   dptr,#STR4
	  acall lcd_sendstring

		  ;-----display R0-------------------------------
		  MOV A,R0
		  lcall ASCIICONV		;Convert to ascii and display values of R0

		  ;-----display TH0-------------------------------
		  MOV A,TH0
		  lcall ASCIICONV		;Convert to ascii and display values of TH0

		  ;-----display TL0-------------------------------
		  MOV a,TL0
		  lcall ASCIICONV		;Convert to ascii and display values of TL0
		
		   MOV 4FH, #10  ; Delay time =5 SEC
    	   LCALL longDelay
		  RET

;----------------------delay routine-----------------------------------------------------

delay:
	USING 00H
		PUSH PSW

		PUSH AR0

		PUSH AR2

         mov r0,#1

loop2:	 mov r1,#255

loop1:	 djnz r1, loop1

		 djnz r0,loop2

		  POP AR2

		 POP AR0

		 POP PSW

		 ret

;----------------------delay routine-----------------------------------------------------

longDelay:		; this subroutine is for introducing delay

	USING 0
	;push registers being used in this subroutine on the stack		 

	PUSH AR0
	PUSH AR1
	PUSH AR2

	MOV A,4FH
	MOV B,#10

	MUL AB   ; for calculting the number of cycle delay1 should run
	MOV R0,A
	delay1:      
		MOV R2,#200
			BACK1:
				MOV R1,#0FFH
				BACK2:
					DJNZ R1,BACK2
			DJNZ R2,BACK1
	DJNZ R0,delay1
	;restored registers pushed
	POP AR2
	POP AR1
	POP AR0

RET

;-------convert byte to ascii and also send the ascii values to the lcd--------------

ASCIICONV: 

		PUSH PSW

		PUSH AR2

		PUSH AR3

		MOV R2,A

		ANL A,#0F0h

		SWAP A

		MOV R3,A

		SUBB A,#0Ah  ;CHECK IF NIBBLE IS DIGIT OR ALPHABET

		JNC ALPHA



		MOV A,R3

		ADD A,#30h   ;ADD 30H TO CONV HEX TO ASCII

		lcall lcd_senddata 		;send msb in ascii

		JMP NEXT



		ALPHA: MOV A,R3  ;ADD 37H TO CONVERT ALPHABET TO ASCII

		ADD A,#37h

		lcall lcd_senddata 		;send msb in ascii



		NEXT:MOV A,R2

		ANL A,#0Fh          ;CHECK HIGHER NIBBLE IS DIGIT OR ALPHABET		

		MOV R3,A

		SUBB A,#0Ah

		JNC ALPHA2 



		MOV A,R3			;DIGIT TO ASCII

		ADD A,#30h

		lcall lcd_senddata 	;send lsb in ascii



		POP AR3

		POP AR2

		POP PSW

		RET



		ALPHA2:MOV A,R3

		ADD A,#37h          ;ALPHABET TO ASCII

		lcall lcd_senddata 	;send lsb in ascii



		POP AR3

		POP AR2

		POP PSW

	RET							;Return from routine


;------------------------LCD Initialisation routine----------------------------------------------------

lcd_init:

         mov   LCD_data,#38H  ;Function set: 2 Line, 8-bit, 5x7 dots

         clr   LCD_rs         ;Selected command register

         clr   LCD_rw         ;We are writing in instruction register

         setb  LCD_en         ;Enable H->L

		 acall delay

         clr   LCD_en

	     acall delay



         mov   LCD_data,#0CH  ;Display on, Curson off

         clr   LCD_rs         ;Selected instruction register

         clr   LCD_rw         ;We are writing in instruction register

         setb  LCD_en         ;Enable H->L

		 acall delay

         clr   LCD_en

         

		 acall delay

         mov   LCD_data,#01H  ;Clear LCD

         clr   LCD_rs         ;Selected command register

         clr   LCD_rw         ;We are writing in instruction register

         setb  LCD_en         ;Enable H->L

		 acall delay

         clr   LCD_en

         

		 acall delay



         mov   LCD_data,#06H  ;Entry mode, auto increment with no shift

         clr   LCD_rs         ;Selected command register

         clr   LCD_rw         ;We are writing in instruction register

         setb  LCD_en         ;Enable H->L

		 acall delay

         clr   LCD_en



		 acall delay

         

         ret                  ;Return from routine



;-----------------------command sending routine-------------------------------------

 lcd_command:

         mov   LCD_data,A     ;Move the command to LCD port

         clr   LCD_rs         ;Selected command register

         clr   LCD_rw         ;We are writing in instruction register

         setb  LCD_en         ;Enable H->L

		 acall delay

         clr   LCD_en

		 acall delay

    

         ret  

;-----------------------data sending routine-------------------------------------		     

 lcd_senddata:

         mov   LCD_data,A     ;Move the command to LCD port

         setb  LCD_rs         ;Selected data register

         clr   LCD_rw         ;We are writing

         setb  LCD_en         ;Enable H->L

		 acall delay

         clr   LCD_en

         acall delay

		 acall delay

         ret                  ;Return from busy routine



;-----------------------text strings sending routine-------------------------------------

lcd_sendstring:

         clr   a                 ;clear Accumulator for any previous data

         movc  a,@a+dptr         ;load the first character in accumulator

         jz    exit              ;go to exit if zero

         acall lcd_senddata      ;send first char

         inc   dptr              ;increment data pointer

         sjmp  LCD_sendstring    ;jump back to send the next character

exit:

         ret                     ;End of routine

;-----------------------------------------------------------------------




;------------- ROM text strings---------------------------------------------------------------

org 700h

STR1:DB   "PRESS SWITCH SW1", 00H

STR2:DB   "AS LED GLOWS", 00H

STR3:DB   "REACTION TIME", 00H

STR4:DB   "COUNT IS ", 00H

END
