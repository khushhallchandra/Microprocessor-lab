ORG 0000H
LJMP MAIN

ADD_16BIT:
	MOV A, @R0
	ADDC A, @R1
	USING 0
	PUSH AR0
	MOV R0,2
	MOV @R0,A
	POP AR0
	RET	
	SETOVERFLOW:
	MOV 62H, #1H	; THIS IS TO INDICATE OVERFLOW
INIT:
	MOV R0, #61H; 61 IS LSB 
	MOV R1, #71H; 71 IS LSB
	MOV R2, #64H	
	RET

ORG 20H

MAIN:
	CLR C
	MOV 62H,#0H
	CLR PSW.2
	ACALL INIT
	ACALL ADD_16BIT
	DEC R0
	DEC R1
	DEC R2
	ACALL ADD_16BIT
	JBC PSW.2 , SETOVERFLOW
	STOP: JMP STOP
END