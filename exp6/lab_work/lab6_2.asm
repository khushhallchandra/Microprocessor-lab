LCD_data equ P2    		;LCD Data port
LCD_rs   equ P0.0  		;LCD Register Select
LCD_rw   equ P0.1  		;LCD Read/Write
LCD_en   equ P0.2  		;LCD Enable
;--------------------------------------------------------------------------
ORG 0000H
LJMP MAIN
;--------------------------------------------------------------------------

ORG 000BH 			;ISR address for Timer 0
INC R0 				;To keep the count of no. of times timer has overflown
RETI
;--------------------------------------------------------------------------

;-------------------INITIALIZATION SUBROUTINE------------------------------
INIT:
	MOV P2,#00H
	MOV P1,#00H

	;INITIAL DELAY FOR LCD POWER UP
    ACALL DELAY
	ACALL DELAY

	ACALL LCD_INIT      ;INITIALISE LCD
	
	ACALL DELAY
	ACALL DELAY
	ACALL DELAY
	RET
	

;--------------------MAIN PROGRAMME------------------------------------  
MAIN:
	LCALL INIT
	MOV R1, #5
	MOV 50H, #0
	MOV 51H, #0
	
	BACK:
	LCALL DISPLAY_MSG1
	LCALL START_TIMER
	LCALL DISPLAY_MSG2
	
	DJNZ R1, BACK
	
	LCALL DISPLAY_MSG3
	
	HERE: SJMP HERE

		
;-------------------DISPLAY MSG 1 SUBROUTINE---------------------------		
DISPLAY_MSG1:
	LCALL INIT
	MOV A,#80H		 		;PUT CURSOR ON 1ST ROW, 1ST COLUMN
	ACALL LCD_COMMAND	 	;SEND COMMAND TO LCD
    ACALL DELAY

	MOV DPTR,#STRING1       ;LOAD DPTR WITH SRING1 ADDR
	ACALL LCD_SENDSTRING	;CALL TEXT STRINGS SENDING ROUTINE
	ACALL DELAY

    MOV A,#0C2H		 		;PUT CURSOR ON 2ND ROW, 3RD COLUMN
	ACALL LCD_COMMAND	 	;SEND COMMAND TO LCD
	ACALL DELAY

	MOV DPTR,#STRING2       ;LOAD DPTR WITH SRING2 ADDR
	ACALL LCD_SENDSTRING	;CALL TEXT STRINGS SENDING ROUTINE
	ACALL DELAY
	
	RET


;------------------------TIMER SUBROUTINE----------------------------------
START_TIMER:
	MOV R0, #00H
	MOV TMOD, #01H
	SETB EA
	SETB ET0
	MOV P1, #00H
	MOV P1, #10H		;TURNS LED P1.4 ON
	
	SETB TR0			;STARTS TIMER 0
	SETB P1.0			;SETS P1.0 AS INPUT PORT
	
	AGAIN:
	MOV A, P1
	ANL A, #01H
	JZ AGAIN			
	
	CLR TR0				
	MOV P1, #00H		
	RET
;-------------------DISPLAY MSG 2 SUBROUTINE---------------------------	
DISPLAY_MSG2:

	LCALL INIT
	mov a,#81h		 		;Put cursor on 1st row, 2ND column
	acall lcd_command	 	;send command to LCD
    acall delay

	mov dptr,#string3       ;Load DPTR with sring3 Addr
	acall lcd_sendstring	;call text strings sending routine
	acall delay

    mov a,#0C4h		 		;Put cursor on 2nd row, 5TH column
	acall lcd_command	 	;send command to LCD
	acall delay
	; T = 33*R0 + TH0/8
	
	MOV A, R0
	MOV B, #33
	MUL AB
	MOV R7, A
	MOV R6, B
	MOV A, TH0
	MOV B, #8
	DIV AB
	ADD A, R7
	MOV R7, A
	JNC SKIP
	INC R6
	SKIP:
	LCALL SUM			;calling subroutine to stored time
	LCALL BIN2BCD		;calling subroutine for decimal display of binary no
	MOV A, R3				;send R3
	lcall ASCIICONV
	mov a, b
	acall lcd_senddata
	acall delay
	acall delay
	
	MOV A, R4				;send R4
	lcall ASCIICONV
	acall lcd_senddata
	acall delay 
	mov a, b
	acall lcd_senddata
	acall delay
	acall delay
	
	MOV A, R5				;send R5
	lcall ASCIICONV
	acall lcd_senddata
	acall delay 
	mov a, b
	acall lcd_senddata
	acall delay
	acall delay
	
	MOV A, #' '
	acall lcd_senddata
	acall delay

	MOV A, #'m'
	acall lcd_senddata
	acall delay
	
	MOV A, #'s'
	acall lcd_senddata
	acall delay
	
	LCALL DELAY5
	RET


;-------------------DISPLAY MSG 3 SUBROUTINE---------------------------	
DISPLAY_MSG3:
	
	LCALL INIT
	mov a,#81h		 		;Put cursor on 1st row, 2ND column
	acall lcd_command	 	;send command to LCD
    acall delay

	mov dptr,#string4       ;Load DPTR with sring4 Addr
	acall lcd_sendstring	;call text strings sending routine
	acall delay

    mov a,#0C1h		 		;Put cursor on 2nd row, 2ND column
	acall lcd_command	 	;send command to LCD
	acall delay

	mov dptr,#string5       ;Load DPTR with sring5 Addr
	acall lcd_sendstring	;call text strings sending routine
	acall delay

	MOV A, #' '
	acall lcd_senddata
	acall delay
	
	
	MOV R1, 50H
	MOV R0, 51H
	MOV R3, #0H
	MOV R2, #5H
	
	LCALL DIV16		;calling subroutine to get 16 bit division
	MOV A, R1		;to comput avg reaction time
	MOV R6, A
	MOV A, R0
	MOV R7, A
	
	LCALL BIN2BCD		;calling subroutine for decimal display of binary no
	
	MOV A, R3				;send R3
	lcall ASCIICONV
	mov a, b
	acall lcd_senddata
	acall delay
	acall delay
	
	MOV A, R4				;send R4
	lcall ASCIICONV
	acall lcd_senddata
	acall delay 
	mov a, b
	acall lcd_senddata
	acall delay
	acall delay
	
	MOV A, R5				;send R5
	lcall ASCIICONV
	acall lcd_senddata
	acall delay 
	mov a, b
	acall lcd_senddata
	acall delay
	acall delay
	
	MOV A, #' '
	acall lcd_senddata
	acall delay

	MOV A, #'m'
	acall lcd_senddata
	acall delay
	
	MOV A, #'s'
	acall lcd_senddata
	acall delay
	
	RET
; This part of the code I wrote with the help of an article given on net.
;----------------------BINARY TO DECIMAL-----------------------------
BIN2BCD:	
	CLR A	
	MOV R5,A
	MOV R4,A
	MOV R3,A

	MOV R2,#16 

	BIN_10:	
	MOV A,R7 
	ADD A,R7
	MOV R7,A
	MOV A,R6
	ADDC A,R6 
	MOV R6,A

	MOV A,R5 
	ADDC A,R5 
	DA A
	MOV R5,A

	MOV A,R4
	ADDC A,R4 
	DA A
	MOV R4,A

	MOV A,R3
	ADDC A,R3 
	DA A
	MOV R3,A
	DJNZ R2,BIN_10
	RET

; This part of the code I wrote with the help of an article given on net.
;------------------SUBROUTINE TO DO 16 BIT DIVISION----------------------------
DIV16: 
	MOV R7, #0 
	MOV R6, #0
	MOV B, #16 

	DIV_LOOP: CLR C 
	MOV A, R0 
	RLC A 
	MOV R0, A
	MOV A, R1
	RLC A
	MOV R1, A
	MOV A, R6 
	RLC A 
	MOV R6, A
	MOV A, R7
	RLC A
	MOV R7, A
	MOV A, R6 
	CLR C 
	SUBB A, R2
	MOV DPL, A
	MOV A, R7
	SUBB A, R3
	MOV DPH, A
	CPL C 
	JNC DIV_1 
	MOV R7, DPH 
	MOV R6, DPL
	DIV_1: MOV A, R4 
	RLC A 
	MOV R4, A
	MOV A, R5
	RLC A
	MOV R5, A
	DJNZ B, DIV_LOOP
	MOV A, R5 
	MOV R1, A
	MOV A, R4
	MOV R0, A
	MOV A, R7 
	MOV R3, A 
	MOV A, R6
	MOV R2, A
	RET
	

;----------------subroutine to calculate 16 bit sum------------------------
SUM:				
	PUSH PSW
	CLR C
	MOV A, 51H
	ADD A, R7
	MOV 51H, A
	MOV A, 50H
	ADDC A, R6
	MOV 50H, A
	POP PSW
	RET
	

;------------------------LCD Initialisation routine----------------------------------------------------
lcd_init:
         mov   LCD_data,#38H  ;Function set: 2 Line, 8-bit, 5x7 dots
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en

	     acall delay

         mov   LCD_data,#0CH  ;Display on, Cursor off
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
		 


;---------------SUBROUTINE TO CONVERT BYTE TO ASCII---------------------------------------------
ASCIICONV: 
	PUSH PSW 
	USING 0
		PUSH AR2

	MOV R2,A
	ANL A,#0FH
	
		PUSH AR3
	MOV R3,A
	SUBB A,#0AH  		;CHECK IF NIBBLE IS DIGIT OR ALPHABET
	JNC ALPHA

	MOV A,R3
	ADD A,#30H   		;ADD 30H TO CONV HEX TO ASCII
	MOV B, A
	JMP NEXT

	ALPHA: 
	MOV A,R3  			;ADD 37H TO CONVERT ALPHABET TO ASCII
	ADD A,#37H
	MOV B, A

	NEXT:
	MOV A,R2
	ANL A,#0F0H         ;CHECK HIGHER NIBBLE IS DIGIT OR ALPHABET
	SWAP A
	MOV R3,A
	SUBB A,#0AH
	JNC ALPHA2 

	MOV A,R3			;DIGIT TO ASCII
	ADD A,#30H
		
		POP AR3
		POP AR2
		POP PSW
	RET

	ALPHA2:
	MOV A,R3
	ADD A,#37H          ;ALPHABET TO ASCII
	
		POP AR3
		POP AR2
		POP PSW
	RET
	
	
;----------------------delay routine-----------------------------------------------------
delay:	 
		USING 0
		PUSH AR2
		PUSH AR1
			
        mov r2,#1
loop2:  mov r1,#255
loop1:  djnz r1, loop1
		djnz r2,loop2
		 
		POP AR1
		POP AR2
		
		ret
		

;-------------------5 SEC DELAY GENERATOR------------------------------------------------
DELAY5:				
	PUSH PSW
	USING 0
	
	PUSH AR2
	PUSH AR1
	PUSH AR0
	
	MOV R0, #0AH
	MOV A, R0
	MOV B, A
	MOV A, #0AH
	MUL AB
	MOV R0, A
	
	MOV R2, #200
	
	BACK1:
	MOV R1,#0FFH
	BACK2 :
		DJNZ R1, BACK2
		DJNZ R2, BACK1
		
	DJNZ R0, BACK1
		
	POP AR0
	POP AR1
	POP AR2
	POP PSW
	RET
	
	
;------------- ROM text strings---------------------------------------------------------------
string1:
         DB "PRESS SWITCH SW1", 00H
			 
string2:
         DB "AS LED GLOWS", 00H
			 
string3:
         DB "REACTION TIME", 00H

string4:
         DB "AVG REACTION", 00H
			 
string5:
         DB "TIME", 00H			 
END