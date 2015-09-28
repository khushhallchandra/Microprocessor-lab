ORG 00H
	MAIN:
MOV 55H,#1
MOV 56H,#2	
MOV 57H,#3	
MOV 58H,#4	

MOV 50H,#7	
MOV 51H,#7	
MOV 52H,#7	
MOV 53H,#7	
	LCALL matMult


	FIN: SJMP FIN
	
	matMult:
	;--------------------
	MOV R0,50H
	MOV R1,55H
	MOV R2,51H
	MOV R3,57H
	MOV A,R0
	MOV B,R1
	MUL AB
	
	MOV R4,A
	
	MOV A,R2
	MOV B,R3
	MUL AB	
	ADD A,R4
	MOV 60H,A
	
	;-----------------------

	;--------------------
	MOV R0,50H
	MOV R1,56H
	MOV R2,51H
	MOV R3,58H
	MOV A,R0
	MOV B,R1
	MUL AB
	
	MOV R4,A
	
	MOV A,R2
	MOV B,R3
	MUL AB	
	ADD A,R4
	MOV 61H,A
	
	;-----------------------
	
	;--------------------
	MOV R0,52H
	MOV R1,55H
	MOV R2,53H
	MOV R3,57H
	MOV A,R0
	MOV B,R1
	MUL AB
	
	MOV R4,A
	
	MOV A,R2
	MOV B,R3
	MUL AB	
	ADD A,R4
	MOV 62H,A
	
	;-----------------------	
	;--------------------
	MOV R0,52H
	MOV R1,56H
	MOV R2,53H
	MOV R3,58H
	MOV A,R0
	MOV B,R1
	MUL AB
	
	MOV R4,A
	
	MOV A,R2
	MOV B,R3
	MUL AB	
	ADD A,R4
	MOV 63H,A
	
	;-----------------------

	RET
	
	END