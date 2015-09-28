; This subroutine writes characters on the LCD

LCD_data equ P2    ;LCD Data port

LCD_rs   equ P0.0  ;LCD Register Select

LCD_rw   equ P0.1  ;LCD Read/Write

LCD_en   equ P0.2  ;LCD Enable

ORG 0000H

ljmp start

org 500h

start:
		mov P2,#00h
		mov P1,#00h
	  ;initial delay for lcd power up
	  ;here1:setb p1.0

		acall delay
	;	  clr p1.0
		acall delay
	;	  sjmp here1

		MOV SP,#0C0H
		acall lcd_init      ;initialise LCD

		acall delay
		acall delay
		acall delay

		mov a,#80h		 ;Put cursor on first row,0 column
		acall lcd_command	 ;send command to LCD
		acall delay
		mov   dptr,#my_string   ;Load DPTR with sring1 Addr
		acall lcd_sendstring	   ;call text strings sending routine
		acall delay

		mov a,#0C0h		  ;Put cursor on second row,0 column
		acall lcd_command
		acall delay
		LCALL STOREDATA
		LCALL PRINTDATA	   ;call text strings sending routine

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

;80H
;FFH
;KHUSHHALL
;4b 48 55 53 48 48 41 4c 4c
STOREDATA:
MOV R0,#80h
MOV @R0,#20H
INC R0
MOV @R0,#20H
INC R0
MOV @R0,#20H
INC R0
MOV @R0,#'k'
INC R0
MOV @R0,#48H
INC R0
MOV @R0,#55H
INC R0
MOV @R0,#53H
INC R0
MOV @R0,#48H
INC R0
MOV @R0,#48H
INC R0
MOV @R0,#41H
INC R0
MOV @R0,#4CH
INC R0
MOV @R0,#4CH
INC R0

MOV @R0,#20H
INC R0
MOV @R0,#20H
INC R0
MOV @R0,#20H
INC R0
MOV @R0,#20H
INC R0

RET
;org 300H
	USING 0
	PRINTDATA:
		PUSH AR0
		MOV R2,#10H ; FOR RUNNING THE LOOP 16 TIMES
		MOV R0,#80h
		LOOP:
		MOV A,@R0
		LCALL lcd_senddata	   ;call text strings sending routine

		INC R0
		DJNZ R2,LOOP
	POP AR0
	RET
	my_string:		DB   '?'
		DB "EE 337 - Lab 2 ", 00H
end