ORG 00H ; setup main at reset vector
ljmp main		

readNibble:
	MOV A,P1			; read port lines P1.3 - P1.0 where slide switches are connected
	ANL A,#0FH			; retain lower nibble and mask off upper one
	RET					; Return to caller with nibble in A

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

main:
	; Port initialisation
	
	
	MOV P1,#0Fh			; Setup internal latch for P1.3 - P1.0 high	so slide switches can be read

	; read nibble from port

	LCALL readNibble		; read nibble using subroutine

	MOV 50H,A				; save nibble read in location 50H

    SWAP A

	MOV 51H, #60H

	MOV SP,#0CFH ; initialized stack pointer

	LCALL zeroOut

    MOV P1,A

	; end of job

STOP: JMP STOP		
END
