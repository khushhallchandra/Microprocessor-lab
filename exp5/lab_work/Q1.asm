ORG 00H
	MAIN:
	MOV TMOD,#01
	LCALL DELAY
	
	FIN: SJMP FIN
	
	DELAY:

	MOV R0,#81H;FOR ACCESSING THE MEMORY INDIRECTLY
	MOV R1,#82H; LOWER BIT

	MOV A,#0
	CLR C
	SUBB A,@R1; TO CONVERT INTO TWO'S COMPLEMENT FORMAT
	MOV TL0,A
	
	MOV A, #0
	SUBB A,@R0; TO CONVERT INTO TWO'S COMPLEMENT FORMAT
	MOV TH0,A;STORING THE VALUE

	SETB TR0
	
	REPEAT: JNB TF0,REPEAT
	CLR TR0
	RET
END	