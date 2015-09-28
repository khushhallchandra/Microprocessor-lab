ORG 00H
	
MAIN:
	SETB EA
	SETB ET0					
	MOV TMOD,#01h				;Configures TMOD,(for 16 bit mode)
	LCALL readNibble
	MOV R5,#33
	SETB TR0					;Starts Timer ()
	LCALL setDUTY
	SJMP MAIN
	
STOP: JMP STOP		

	readNibble: 
	MOV P1,#0FH
	MOV A,P1     				; read input from user through switches
	MOV R0,A  					; R0 STORES T1 i.e. ON time
	CLR C
	MOV A,#15
	SUBB A,R0
	MOV R1,A 					; R1 STORES T2 i.e. OFF time
	RET	

START_TIMER:
	MOV TL0,#60H
	MOV TH0,#0F0H
	AGAIN:  JNB  TF0,AGAIN
	CLR TF0
RET

setDUTY:
	MOV R3,0					;R3 stores ON time
	MOV R4,1					;R4 stores OFF time
	MOV a,r3
	JZ tOFF
	;This block turn on led
	tON:		
	SETB P1.4
		LCALL START_TIMER
		DJNZ R3,tON
	MOV A,R1
	JZ HERE
	;This block turn off led
	tOFF:     	
		CLR P1.4
		LCALL START_TIMER
		DJNZ R4,tOFF
		HERE: DJNZ R5,setDUTY
	RET
END