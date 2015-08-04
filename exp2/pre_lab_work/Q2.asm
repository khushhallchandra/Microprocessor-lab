;Subroutine zeroOut which will read a number N from location 50H and a pointer P from 51H.
;The subroutine should zero out the contents of memory in N consecutive locations starting at P.
;N will satisfy the following constraint: 1< = N <= 16. 

ORG 00H
	MAIN:
		MOV 50H, #5  ; value initialized
		MOV 51H, #60H
		MOV SP,#0CFH ; initialized stack pointer
		LCALL zeroOut
FIN:SJMP FIN	
	zeroOut:
		USING 0
		;push registers being used in this subroutine on the stack	
		PUSH AR0 
		PUSH AR1 
		MOV R0,50H
		MOV R1,51H
		LOOP:    MOV @R1,#00H  ;putting 0 at the memory pointed by R1
					  INC R1
					  DJNZ R0,LOOP
		;restored registers pushed			  
		POP AR1 ; pop the value back to register
		POP AR0	; pop the value back to register		  
		RET

END