ORG 00H

findSmallest:
MOV 50H,#34
MOV 51H,#20
MOV 52H,#98	
MOV 53H,#54
MOV 54H,#32


	MOV R0,#50H
	MOV R1,#51H
	MOV R2,#5
	
	MOV 55H,@R0
	LCALL LOOP



	;MOV R3,#60H; TO STORE THE ORDERED LIST
	LOOP:
	MOV A,@R1
	CLR C
	SUBB A,@R0
	JC TEST      ;JUMP TO LOOP IF R0> R1 then go back to TEST
	MOV A,@R0   ;IF R0<R1, THEN STORE THE SMALLER VALUE
	INC R0
	INC R1
	
	DJNZ R2,LOOP
JMP FIN
	TEST:
	MOV A,@R1    ; IF R1<R0, THEN STORE THE SMALLER VALUE
	INC R0
	INC R1
	MOV 55H,A
	DJNZ R2,LOOP 
	;MOV 55H,R3
JMP FIN

FIN: LJMP FIN

END