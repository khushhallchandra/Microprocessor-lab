;Program to blink an LED at port P1.4 at specific intervals. At location 4F H a user specified integer D is stored. 
;A subroutine called delay, when it is called it should read the value of D and insert a delay of D/2 seconds.
;The main program which will call delay in a loop and blink an LED by turning it ON for D/2 seconds and OFF for D/2 seconds.
;D will satisfy the following constraint:1 <= D <= 10.

ORG 00H ; setup main at reset vector
MAIN:
	   	MOV 4FH, #5  ; Delay time
		CLR P1.4
		LOOP:
			LCALL DELAY
			CPL P1.4			;complement the value at p1.4	
		SJMP LOOP

FIN:	SJMP	FIN	;ALL DONE

delay:		; this subroutine is for introducing delay
	USING 0
	;push registers being used in this subroutine on the stack		 
	PUSH AR0
	PUSH AR1
	PUSH AR2
	
	MOV A,4FH
	MOV B,#10
	MUL AB   ; for calculting the number of cycle delay1 should run
	MOV R0,A
	delay1:      
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