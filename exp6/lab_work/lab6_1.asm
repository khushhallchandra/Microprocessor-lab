LCD_data equ P2    
LCD_rs   equ P0.0  
LCD_rw   equ P0.1  
LCD_en   equ P0.2  

ORG 0000H
LJMP MAINS
ORG 000BH
INC R7
MOV TH0, #0F0H
MOV TL0, #60H
RETI

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
         mov r0,#1
loop2:	 mov r1,#255
loop1:	 djnz r1, loop1
		 djnz r0,loop2
		 ret
;========================================
;---------------SUBROUTINE TO CONVERT BYTE TO ASCII---------------------------------------------

ASCIICONV: MOV R2,A
ANL A,#0Fh
MOV R3,A
SUBB A,#09h  ;CHECK IF NIBBLE IS DIGIT OR ALPHABET
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
SUBB A,#09h
JNC ALPHA2 

MOV A,R3			;DIGIT TO ASCII
ADD A,#30h
RET

ALPHA2:MOV A,R3
ADD A,#37h          ;ALPHABET TO ASCII
RET		
;=================DISPLAY===============================
DISPLAY1:
MOV R5,B
MOV R4,A
MOV A,#0C0H		  
ACALL LCD_COMMAND
ACALL DELAY

MOV A, P1
ANL A,#0FH
CLR C
MOV 50H,A
MOV A,#15
SUBB A,50H

MOV B,#2
MUL AB
MOV B,#10
DIV AB
PUSH B
ACALL ASCIICONV
MOV A,B
ACALL LCD_SENDDATA
POP B

MOV A,B
ACALL ASCIICONV
MOV A,B
ACALL LCD_SENDDATA
 
MOV A,#0C3H
ACALL LCD_COMMAND
ACALL DELAY

MOV A, R5
ACALL ASCIICONV
MOV A,B
ACALL LCD_SENDDATA
MOV A, R4
ACALL ASCIICONV
ACALL LCD_SENDDATA
MOV A,B
ACALL LCD_SENDDATA

RET

MAINS:
LCALL LCD_INIT

MOV P1,#0FH
MOV TMOD,#51H

MOV IE,#82H
MOV A,#01H
ACALL LCD_COMMAND
ACALL DELAY

MOV A,#02H
ACALL LCD_COMMAND
ACALL DELAY

MOV A,#80H		 
ACALL LCD_COMMAND
ACALL DELAY

MOV   DPTR,#MY_STRING1   
ACALL LCD_SENDSTRING	 
ACALL DELAY
  
ACALL MAIN
HERE: SJMP HERE	


MAIN:
MOV R6,#0
MOV TH1,#0
MOV TL1,#0
MOV A,P1
BACK:
MOV P1,#0FH

ANL A,#0FH
MOV R7,#0
MOV TH0, #0F0H
MOV TL0, #60H
SETB TR0
SETB TR1
WAIT:
CJNE A,07H,BACK1
SETB P3.0
BACK1:
CJNE R7,#15, WAIT
INC R6
CLR P3.0

CJNE R6,#33,BACK2
MOV B,TL1
MOV A,#2
MUL AB

PUSH ACC
PUSH B
MOV A, TL1
ANL A,#0F0H
MOV R4,A
MOV A,P1
ORL A,R4
MOV P1,A
POP B
POP ACC

ACALL DISPLAY1
SJMP MAIN
BACK2:
SJMP BACK
RET
;------------- ROM text strings---------------------------------------------------------------
ORG 300H
MY_STRING1:
DB   "IN RPM", 00H
END
	