;======================================MAIN=============================================
ORG 00H
MAIN:
MOV SP,#0CFH;-----------------------Initialize STACK POINTER
MOV 50H,#6;------------------------N memory locations of Array A
MOV 51H,#60H;------------------------Array A start location
LCALL zeroOut;----------------------Clear memory
MOV 50H,#6;------------------------N memory locations of Array B
MOV 51H,#70H;------------------------Array B start location
LCALL zeroOut;----------------------Clear memory
MOV 50H,#6;------------------------N memory locations of Array A
MOV 51H,#60H;------------------------Array A start location
LCALL sumOfSquares;-----------------Write at memory location
MOV 50H,#6;------------------------N elements of
MOV 51H,#60H;------------------------Array A start
MOV 52H,#70H;------------------------Array B start
LCALL memcpy;-----------------------Copy block of
MOV 50H,#6;------------------------N memory locations of Array B
MOV 51H,#70H;------------------------Array B start location
MOV 4FH,#2;------------------------User defined delay value
LCALL display;----------------------Display the last four bits of elements on LEDs
FIN:SJMP FIN;---------------------WHILE loop(Infinite Loop)
;----------------------------------------------------------------------------------------------------------------	
zeroOut:
		USING 0
		;push being used in this subroutine on the stack
		PUSH AR0
		PUSH AR1
		MOV R0,50H
		MOV R1,51H
		LOOP_1:    MOV @R1,#00H ;putting 0 at the memory pointed by R1
					  INC R1
					  DJNZ R0,LOOP_1
		;restored registers pushed
		POP AR1
		POP AR0			  
		RET
;----------------------------------------------------------------------------------------------------------------		
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
	
	COMP:JNC LOOP;  JUMP IF A>B
	
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
;----------------------------------------------------------------------------------------------------------------
;subroutine to display the content on P1
display:                ; subroutine for displaying the content on P1
			USING 0
			;push registers being used in this subroutine on the stack
			PUSH AR0 
			PUSH AR1   
			
			 MOV R0,50H
			 MOV R1,51H
			 LOOP_2:
				 MOV A,@R1  ;  copy the contents pointed by R1 to P1
				 SWAP A        ; MOVE the LSB to p4-p7.
				 MOV P1,A
				 LCALL delay
				 INC R1
				 DJNZ R0, LOOP_2
				 
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

;----------------------------------------------------------------------------------------------------------------
; subroutine to generate sum of squares
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
			 LOOP_3:
				INC R3
				MOV A,R3
				MOV B,R3
				MUL AB    ; to find the squares
				ADD A,R2
				MOV R2,A  ; summation
				MOV @R1,A
				INC R1
			DJNZ R0,LOOP_3
			;restored registers pushed
			POP AR3
			POP AR2
			POP AR1
			POP AR0
			RET

END
;------------------------------------END MAIN-------------------------------------------