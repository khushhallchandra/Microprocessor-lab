ORG 00H; setup main at reset vector
MAIN:
	MOV 50H, #5      ;initialize the number K
	MOV 51H, #60H  ;location of pointer P
	MOV SP,#0CFH;
	;storing the data at the given memory location

	MOV 60H,#1
	MOV 61H,#2
	MOV 62H,#8
	MOV 63H,#4
	MOV 64H,#5
	MOV SP,#0CFH
	LCALL displayValues
FIN: SJMP FIN	

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

END