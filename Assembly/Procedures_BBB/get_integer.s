/* Get integer numbers ex: 1, 123 or 5250 */
/*Typing 'enter' for end of get_integer */
.get_integer:
	stmfd sp!, {r1-r7,lr}
	mov r3, #0 /*Stack counter*/
	/*r4 & r7 They'll help us to reconstruct the number  */
    mov r4, #1
    mov r7, #10
	mov r5, #0

    .get_int:
	bl .uart_getc
	cmp r0, #0x0D /*If enter then end */
	beq .fim_int
	and r0, r0, #0xff
    	bl .uart_putc
	sub r0, r0, #0x30  
    stmfd sp!, {r0}
	add r3, r3, #1 /*Increment stack one */
	b .get_int

    .fim_int:
	cmp r3, #0
	beq .fim__int

	ldmfd sp!, {r0}	
	mov r6, r0	
	mul r0, r6, r4
	mov r6, r4
	
	mul r4, r6, r7
	add r5, r5, r0
	subs r3, r3, #1 /*pilha decrementa 1 */
	
	b .fim_int

     .fim__int:
	mov r0, r5
     ldmfd sp!, {r1-r7,pc}
/* Integer -> r0 */

