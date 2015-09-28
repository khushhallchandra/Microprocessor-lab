	
ORG 00H; setup main at reset vector
MAIN:
	LCALL packNibble
FIN:SJMP FIN
	
packNibble:
USING 0
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
END