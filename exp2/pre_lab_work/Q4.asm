;Write a subroutine sumOfSquares that will read a number N from location 50H and
;a pointer P from 51H. The subroutine must generate sum of squares i.e.
;j=1 i for
;i = 1 · · · N and store them in locations P to P + N - 1.

ORG 00H
	MAIN:
	MOV 50H, #5      ;initialize the number N
	MOV 51H, #60H  ;location of pointer P
	MOV SP,#0CFH
	LCALL sumOfSquares
FIN:SJMP FIN	
sumOfSquares:
			 USING 0
		     ;push registers being used in this subroutine on the stack		 
			 PUSH AR0
			 PUSH AR1
			 PUSH AR2
			 PUSH AR3
			 
			 MOV R0,50H 
			 MOV R1,51H
			 MOV R2,#00H ; initializing with 0.  R2 is used for storing the summation
			 MOV R3,#00H ; initializing with 0.  R3 is used for generating number from 1
			 
			 ;to find the sum of squares at each iteration
			 LOOP:
				INC R3
				MOV A,R3
				MOV B,R3
				MUL AB ; to find the squares
				ADD A,R2  
				MOV R2,A ; summation
				MOV @R1,A
				INC R1
			DJNZ R0,LOOP
			
			;restored registers pushed
			POP AR3
			POP AR2
			POP AR1
			POP AR0
			RET

END