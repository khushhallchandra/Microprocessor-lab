; This subroutine writes characters on the LCD
LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable

ORG 0000H
ljmp start

org 200h
start:;ALSO THE MAIN
      mov P2,#00h
	  mov P1,#00h
	  ;initial delay for lcd power up

;here1:setb p1.0
      acall delay
;	  clr p1.0
	  acall delay
;	  sjmp here1

      acall lcd_init      ;initialise LCD
	
	  acall delay
	  acall delay
	  acall delay
MOV R0,#0FFh
AGAIN:
MOV A,R0
CPL A
MOV @R0,A
DJNZ R0,AGAIN
MOV SP,#0CFH

AGAIN1:
	  ACALL display;Displays array specified by P1
	  
		MOV 4FH, #10  ; Delay time
		LCALL longDelay;5s delay
	;%%%%%%%%%%%%%%%%%%%%%%%%%%	
	  mov P2,#00h
	  mov P1,#00h
      acall delay
;	  clr p1.0
	  acall delay
;	  sjmp here1
	  acall lcd_init      ;initialise LCD
	  acall delay
	  acall delay
	  acall delay
	  ;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
	  SJMP AGAIN1	  
;************************************************************************

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

;************************************************************************
;================================================


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
				BACK:
					DJNZ R1,BACK
			DJNZ R2,BACK1
	DJNZ R0,delay1
	;restored registers pushed
	POP AR2
	POP AR1
	POP AR0
	RET



delay:	
USING 0
	PUSH AR0
	PUSH AR1
         mov r0,#1

loop2:	 mov r1,#255

loop1:	 djnz r1, loop1

		 djnz r0,loop2
POP AR1
POP AR0
		 ret
	  
;================================================

ASCIICONV: 
using 0
push ar2
push ar3
MOV R2,A
ANL A,#0Fh
MOV R3,A
SUBB A,#0Ah  ;CHECK IF NIBBLE IS DIGIT OR ALPHABET
JNC ALPHA

MOV A,R3
ADD A,#30h   ;ADD 30H TO CONV HEX TO ASCII
MOV B,A
JMP NEXT

ALPHA: MOV A,R3  ;ADD 37H TO CONVERT ALPHABET TO ASCII
ADD A,#37h
MOV B,A

NEXT:MOV A,R2
ANL A,#0F0h          ;CHECK HIGHER NIBBLE IS DIGIT OR ALPHABET
SWAP A
MOV R3,A
SUBB A,#0Ah
JNC ALPHA2 

MOV A,R3			;DIGIT TO ASCII
ADD A,#30h
pop ar3
pop ar2
RET	

ALPHA2:MOV A,R3
ADD A,#37h           ;ALPHABET TO ASCII
pop ar3
pop ar2
RET

;THIS MODULE INITIALIZES THE WHOLE MEMORY


readNibble: 
		using 0
		PUSH AR1 
		LCALL LOOP4
		POP AR1
		RET
LOOP4:
		MOV P1,#0F0h 	; to ON the LEDs
		MOV 4FH, #10		; DELAY OF 5 SEC
		LCALL longDelay
		MOV P1,#0Fh  		; Setup internal latch for P1.3 - P1.0 high	so slide switches can be read
		MOV R1,P1	 	    ; read port lines P1.3 - P1.0 where slide switches are connected
		MOV 4fh, #2 			; delay for 1 sec
		LCALL longDelay
		MOV A,R1 
		SWAP A 				; swapped the content of A
		ORL A,#0FH
	    MOV P1,A 			;show the entered value on led
		MOV 4FH, #4
		LCALL longDelay
		MOV P1, #0FH 		; Setup internal latch for P1.3 - P1.0 high	so slide switches can be read
		MOV A, P1			;READ THE CONTENT OF SWITCHES
		mov b,r1
		CJNE A, b, LOOP4; CHECK THE VALUE ENTERED, IF USER CONFIRMED THEN STORE THE VALUE AT 4EH ELSE GO BACK TO LOOP
;MOV 4EH, r1 
MOV A, r1 
SWAP A
ANL A,#0F0H
RET

display:
LCALL readNibble
MOV R0,A

MOV R4,#2
AGAIN5:
;=================
		mov P2,#00h
		mov P1,#00h
      acall delay
;	  clr p1.0
	  acall delay
;	  sjmp here1
	  acall lcd_init      ;initialise LCD
	  acall delay
	  acall delay
	  acall delay
;=================

MOV A,#80H;FIRST LINE
ACALL lcd_command
acall delay
mov r5,#4; for printing 4 chars
firstline:
lcall space
mov a,@r0
lcall print
inc r0
djnz r5,firstline


mov a,#0c0h;SECOND LINE
ACALL lcd_command
acall delay
mov r5,#4; for printing 4 chars
secondline:
lcall space
mov a,@r0
lcall print
inc r0
djnz r5,secondline
MOV 4FH, #10  ; Delay time
LCALL longDelay;5s delay
DJNZ R4,AGAIN5
RET

space:
push ACC
acall delay
mov a,#' '
acall lcd_senddata
acall delay
POP ACC
ret

print:
	PUSH ACC
	lcall ASCIICONV
	acall lcd_senddata
	mov a,b
	acall lcd_senddata
	acall delay
	POP ACC
ret
;--------------------
end