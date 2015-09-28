ORG 00H ; setup main at reset vector
	MAIN:
	    MOV P1,#0Fh  ; Setup internal latch for P1.3 - P1.0 high	so slide switches can be read
		MOV A,P1; read port lines P1.3 - P1.0 where slide switches are connected
	    ANL A,#0FH; retain lower nibble and mask off upper one
		LCALL CONVERT
		MOV P1,A ; show the gray code on the LED
		LCALL MAIN
		STOP:LJMP STOP
		
	CONVERT:
		SWAP A 
		MOV B,A;copy the content of A to B
		RR A ; right shift the data of A
		XRL A,B ; A = A^b
		RET
END