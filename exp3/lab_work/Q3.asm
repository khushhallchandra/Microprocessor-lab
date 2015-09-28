ORG 00H; setup main at reset vector
MAIN:
	MOV 4FH,#00H
	MOV 50H, #2      ;initialize the number K
	MOV 51H, #60H  ;location of pointer P, START LOCATION OF ARRAY A
	LCALL readValues
	MOV 52H,#70H; START LOCATION OF ARRAY B
	LCALL shuffleBits
	LCALL displayValues; it display the last four bits of the data on LEDs
FIN: SJMP FIN	

;*****************************************************************************************************************************************************************************
;readValues start here
readValues:
	USING 0
	;push registers being used in this subroutine on the stack
	PUSH AR0 
	PUSH AR1   
	MOV R0,50H;no of data to read "N"
	MOV R1,51H; 51H store the adress pointer from where data is to be stored
	LOOP2:  
				LCALL packNibble
				MOV @R1,4FH  ;move content of 4fh to the location poited by R1
				INC R1				 ; increment the memory adress to access next memory location
				DJNZ R0, LOOP2
	;restored registers pushed	 
	POP AR1 
	POP AR0 
	RET	


packNibble:
	PUSH AR0
	LCALL readNibble
	MOV A,4EH
	SWAP A
	ANL A,#0F0H; retain UPPER nibble and mask off LOWER one
	MOV R0,A
	LCALL readNibble
	MOV A,4EH
	ANL A,#0FH; retain LOWER nibble and mask off UPPER one
	ORL A,R0
	MOV 4FH,A
	POP AR0
RET	

readNibble: 
		using 0
		PUSH AR1 
		LCALL LOOP
		POP AR1
		RET

LOOP:
		MOV P1,#0F0h 	; to ON the LEDs
		MOV 4FH, #10		; DELAY OF 5 SEC
		LCALL delay
		MOV P1,#0Fh  		; Setup internal latch for P1.3 - P1.0 high	so slide switches can be read
		MOV R1,P1	 	    ; read port lines P1.3 - P1.0 where slide switches are connected
		MOV 4fh, #2 			; delay for 2 sec
		LCALL delay
		MOV A,R1 
		SWAP A 				; swapped the content of A
		ORL A,#0FH
	    MOV P1,A 			;show the entered value on led
		MOV 4FH, #10
		LCALL delay
		MOV P1, #0FH 		; Setup internal latch for P1.3 - P1.0 high	so slide switches can be read
		MOV A, p1			;READ THE CONTENT OF SWITCHES
		CJNE A, #0FH, LOOP; CHECK THE VALUE ENTERED, IF USER CONFIRMED THEN STORE THE VALUE AT 4EH ELSE GO BACK TO LOOP
	MOV 4EH, r1 
RET

;----------------------------------
; the delay time is given as 5 sec
delay:
			USING 0
			;push registers being used in this subroutine on the stack
			PUSH AR0  
			PUSH AR1  
			PUSH AR2  
	MOV A,4FH ;------------ Read the value of delay from 4FH
	MOV B,#10
	MUL AB   ; for calculting the number of cycle delay1 should run
	MOV R0,A

delay1:   ; subroutine for introducing delay of 50 ms
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
;readValues ends here
;*****************************************************************************************************************************************************************************

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;shuffleBits starts here
shuffleBits:
PUSH AR0
PUSH AR1
PUSH AR2

MOV R0,51H; POINTER TO A
MOV R1,52H ;POINTER TO B
MOV R2,50H; VALUE OF "K"
DEC R2; THIS IS DONE TO REDUCE THE VALUE BY ONE OF K
shuffleLoop:
MOV A,@R0
INC R0			; to fetch the next value in the memory
XRL A,@R0
MOV @R1,A ; store the value to the array B
INC R1
DJNZ R2, shuffleLoop


MOV A,@R0
MOV R0,51H
XRL A,@R0; xor operation on first and last element of A
MOV @R1,A
POP AR2
POP AR1
POP AR0
RET
;shuffleBits ends here
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


;displayValues start here
displayValues:
	USING 0
	;push registers being used in this subroutine on the stack
	PUSH AR0 
	PUSH AR1   
	PUSH AR2
	PUSH AR3

	CHECK:
	MOV A,50H
	MOV R1,51H
	MOV P1,#0Fh  ; Setup internal latch for P1.3 - P1.0 high	so slide switches can be read
	MOV R2,P1
	MOV R0,P1; STORE THE VALUE FROM PORT
	CLR C
	SUBB A,R0 ; subtract r0 from A
	JC CHECK ; JUMP TO CHECK IF P1> VALUE AT K, if K value is greater then go back to CHECK
	MOV A,R2
	ADD A,R1
	MOV R1,A
	DEC R1  ; the actual memory location is one value less than the sum
	MOV A,@R1
	MOV P1,A; glow the LEDs
	SWAP A
	MOV R3,A
	MOV 4FH,#4 ; FOR DELAY OF 2 SEC
	LCALL delay
	MOV P1,R3; glow the LEDs
	LCALL delay
	JMP CHECK ;go back to CHECK
	
	POP AR3
	POP AR2 
	POP AR1   
	POP AR0
RET

END