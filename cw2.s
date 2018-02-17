.data
char:
    .asciz "%c"				@ format for printing a char using printf
newline:
    .asciz "\n"				@ format for printing a new line using printf
.text
    .global main			@ set global function to main
    .extern printf			@ include printf

@ Version 1.2	
	
@ An ARM assembly program that encrypts or decrypts standard input based on the user having entered 0 or 1
@ The result will be displayed to standard output
	
@ r0 - char to be processed and encrypted
@ r1 - argv array and output format
@ r2 - loaded byte from private key
@ r3 - program mode from argv array
@ r4 - loaded byte from program mode
@ r5 - private key from argv array
@ r6 - copy of r5 for key resets
	
@ main - main function to load values from command line arguments
main:
	PUSH {r4,r5,r6,lr} 		@ load registers onto the stack  
  	LDR r3, [r1, #4] 		@ loads the second element of the argv array into r3
   	LDRB r4, [r3], #4 		@ load a byte from r3, either 0 or 1, for encrypt or decrypt into r4
	LDR r5, [r1, #8] 		@ loads the private key, the third element of the argv array, into r5 
	MOV r6, r5 			@ move r5 into r6, make a copy of the privaate key for resets
	 
@ getnewchar - get a new character and check to see whether its valid or uppercase	 
getnewchar:	
	BL getchar 			@ loads a char from standard input to r0
	CMP r0, #-1 			@ compare r0 with end of file
	BEQ end 			@ branch to end function if eof has been reached
	CMP r0, #65 			@ compare r0 with decimal value 65(A)
	BLT getnewchar			@ get a new char if r0 is less than A  
	CMP r0, #90 			@ compare r0 with decimal value 90(Z)
	ADDLE r0, #32			@ if r0 is less than 90, add 32 to r0
	BLE mode			@ branch to mode if character was uppercase
	
@ processing - continue processing the character checking that it is a valid lowercase character
processing:
	CMP r0, #97 			@ compare r0 with decimal value 97(a)
	BLT getnewchar			@ get a new char if r0 is less than a
	CMP r0, #122 			@ compare r0 with decimal value 122(z)
	BGT getnewchar			@ get a new char if r0 is greater than z

@ mode - load a byte from the private key and check program mode
mode:	
	LDRB r2,[r5], #1 		@ load a byte from r5, increment over each letter of private key
	CMP r2, #0 			@ compare r2 with value null
	MOVEQ r5, r6			@ if r2 is null, move r6, the copy of the original private key, into r5
	BEQ mode 			@ branch to mode if r2 is null	
	
	SUB r0, #96			@ get character between 1 and 26
	SUB r2, #96			@ get private key between 1 and 26

	CMP r4, #48 			@ compare r4 with decimal value 48(0)
	BNE decrypt			@ branch to decrypt if r4 is not equal to 0, otherwise go to encrypt
	
@ encrypt - encrypt the character in r0	
encrypt:
	SUB r0, r2			@ subtract r2 from r0
	CMP r0, #0			@ compare r0 with decimal value 0
	ADDLE r0, #26			@ if r0 is less than 0, add 26 to r0
	B output			@ branch to output

@ decrypt - decrypt the character in r0
decrypt:
	ADD r0, r2			@ add r2 to r0
	CMP r0, #26			@ compare r0 with decimal value 26
	SUBGT r0, #26			@ if r0 is greater than 26, subtract 26 from r0
	@ removed B ouput as this was unecessary
	
@ output - add 96 to bring into a-z range, print character to console
output:
	ADD r1, r0, #96			@ add the value 96 to bring r0 into a-z range, move into r1
	LDR r0, =char			@ load the format for output into r0
	BL printf			@ printf r1
	B getnewchar			@ branch to getnewchar
			
@ end - function to end program, new line printed to make output clearer
end:	
	LDR r0, =newline		@ load the format for output into r0
	BL printf			@ print 
	POP {r4,r5,r6,lr}		@ pop registers off the stack
	BX lr				@ end program
	

	
