ORG 00H
	SUM_OF_N:
;using 0 will select the 0th register
USING 0
	MOV R0,50H
	MOV R1, #51H
	MOV A, #0
	MOV R2,#00H
	
	LOOP: INC R2
	ADD A,R2
	MOV @R1,A
	INC R1
	DJNZ R0, LOOP
	;INC R1
	;MOV @R1,A
	Stop: JMP STOP
	END
	