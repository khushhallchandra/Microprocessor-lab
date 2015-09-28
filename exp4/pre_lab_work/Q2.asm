;1First line of display should show the values of registers A, B and PSW in the format:
;“ABPSW = ?? ?? ??”, The second line should display the contents of R0, R1 and R2 in
;the format “R012 = ?? ?? ??” Here ?? represents the actual content of those registers
;in Hex. This display should be held for about 5 seconds.
;After this, the display should show “R345 = ?? ?? ??” on the first line and “R67SP =
;?? ?? ??” on the second line.


; This subroutine writes characters on the LCD

LCD_data equ P2    ;LCD Data port

LCD_rs   equ P0.0  ;LCD Register Select

LCD_rw   equ P0.1  ;LCD Read/Write

LCD_en   equ P0.2  ;LCD Enable



ORG 0000H

ljmp start



org 200h

start:

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


;----------------------------------------------------------------------------------------------------
	  mov a,#80h		 ;Put cursor on first row,5 column

	  acall lcd_command	 ;send command to LCD

	  acall delay
	  
	  mov   dptr,#my_string1   ;Load DPTR with sring1 Addr

	  acall lcd_sendstring	   ;call text strings sending routine

	  acall delay
;------------------------------
		MOV A,#48H
		MOV B,#48H
		MOV R0,#48H
		LCALL lcd_senddata	
		;acall delay
		MOV A,B
		LCALL lcd_senddata	
		;acall delay
		MOV A,R0
		LCALL lcd_senddata	
		acall delay

		
;-------------------------------


	  mov a,#0C0h		  ;Put cursor on second row,3 column

	  acall lcd_command

	  acall delay

	  mov   dptr,#my_string2

	  acall lcd_sendstring
	  acall delay
;------------------------------
		MOV R2,#48H
		MOV R3,#49H
		MOV R4,#50H
		
		MOV A,R2
		LCALL lcd_senddata	
		acall delay
		MOV A,R3
		LCALL lcd_senddata	
		acall delay
		MOV A,R4
		LCALL lcd_senddata	
		acall delay

		
;-------------------------------	  
;-----------------------------------------------------------------------------------------------------------------

MOV 4FH, #10  ; Delay time
LCALL longDelay
;------------------------------------------------------------------------------------------------------------------
      mov P2,#00h
	  mov P1,#00h
      acall delay
	  acall delay
	  acall lcd_init      ;initialise LCD
	  acall delay
	  acall delay
	  acall delay

	  mov a,#80h		 ;Put cursor on first row,5 column

	  acall lcd_command	 ;send command to LCD

	  acall delay
	  mov   dptr,#my_string3   ;Load DPTR with sring1 Addr

	  acall lcd_sendstring	   ;call text strings sending routine

	  acall delay
;------------------------------
		MOV A,#48H
		MOV B,#3H
		MOV R0,#4
		LCALL lcd_senddata	
		acall delay
		MOV A,B
		LCALL lcd_senddata	
		acall delay
		MOV A,R0
		LCALL lcd_senddata	
		acall delay

		
;-------------------------------
MOV 4FH, #10  ; Delay time
LCALL longDelay

	  mov a,#0C0h		  ;Put cursor on second row,3 column

	  acall lcd_command

	  acall delay

	  mov   dptr,#my_string4

	  acall lcd_sendstring
	  
;-----------------------------------------------------------------------------------------------------------------



here: sjmp here				//stay here 



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



;----------------------delay routine-----------------------------------------------------

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
;MOV 4FH, #5  ; Delay time
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

;------------- ROM text strings---------------------------------------------------------------

org 300h

my_string1:

        DB   "ABPSW = ",00H

my_string2:

		DB   "R012 = ", 00H
my_string3:

		DB   "R345 = ", 00H
my_string4:

		DB   "R67SP = ", 00H			

end

