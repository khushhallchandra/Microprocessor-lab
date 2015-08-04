;WRITING A PROGRAM TO COPY THE VALUES 
;A AND B CAN BE ANY MEMORY LOCATION
ORG 00
	MAIN:
	MOV 50H, #5      ;initialize the number N
	MOV 51H, #60H  ;location of pointer A
	MOV 52H, #63H  ;location of pointer B
	MOV SP,#0CFH
	LCALL MEMCPY
FIN:SJMP FIN	
	
	MEMCPY:
	 USING 0
	 ;push registers being used in this subroutine on the stack		 
	 PUSH AR0
	 PUSH AR1
	 PUSH AR2
	
	MOV R2,50H
	MOV R0,51H; THIS ACTS AS A
	MOV R1,52H; THIS ACTS AS B
	MOV A,@R0
	MOV B,@R1
	CJNE A,B, COMP
	SJMP FIN
	
	COMP:JNC LOOP ;  JUMP IF A>B
	
	;Copy if a<b
	
	;this loop1 is for moving the pointer at the end
	LOOP1:
	INC R0
	INC R1
	DJNZ R2,LOOP1
	MOV R2,50H
	
	; to move the values from a to b when a<b
	LOOP2:
	CLR A
		DEC R0
	DEC R1
	MOV A,@R0 ; moving value to accumulator
	MOV @R1,A ; copying to memory pointed at R1

	DJNZ R2,LOOP2
	
	SJMP FIN
	
	;to copy A to B if a>b
	LOOP:
	CLR A
	MOV A,@R0 ; moving value to accumulator
	MOV @R1,A ; copying to memory pointed at R1
	INC R0
	INC R1
	DJNZ R2,LOOP

	;restored registers pushed	
	POP AR2
	POP AR1
	POP AR0
	RET	
END