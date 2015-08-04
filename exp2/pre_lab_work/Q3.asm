;Subroutine display which will read a number N from location 50H and a pointer P from 51H. 
;The subroutine must read the last four bits of the values at locations P to P + N - 1 and display on the LEDs, one at a time.
;There should be a delay of 1s between each such display.
;Use the ports P1.4 to P1.7 for the 4 LEDs.
ORG 00
MAIN:
	MOV 50H, #5      ;initialize the number N
	MOV 51H, #60H  ;location of pointer P
	MOV 4FH, #2     ;initialize the delay time
	MOV SP,#0CFH
	LCALL display

FIN:SJMP FIN	

display:                ; subroutine for displaying the content on P1
			USING 0
			;push registers being used in this subroutine on the stack
			PUSH AR0 
			PUSH AR1   
			
			 MOV R0,50H
			 MOV R1,51H
			 LOOP:
				 MOV A,@R1  ;  copy the contents pointed by R1 to P1
				 SWAP A ; MOVE the LSB to p4-p7.
				 mov P1,A
				 LCALL delay
				 INC R1
				 DJNZ R0, LOOP
				 
			;restored registers pushed	 
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
	RET
	
END
