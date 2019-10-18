/* Pega valores inteiros ex: 1 ou 123 ou 5250 */
/*Digitar 'enter' indica o fim do get_integer */
.get_integer:
	stmfd sp!, {r1-r7,lr}
	mov r3, #0 /*contador de pilha*/
	/*r4 e r7 vao ajudar a 'reconstruir o numero' */
    mov r4, #1
    mov r7, #10
	mov r5, #0

    .get_int:
	bl .uart_getc
	cmp r0, #0x0D /*comparo com 'enter' */
	beq .fim_int
	and r0, r0, #0xff
    	bl .uart_putc
	sub r0, r0, #0x30  
    stmfd sp!, {r0}
	add r3, r3, #1 /*pilha incrementa 1 */
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
/*O valor do inteiro fica em r0 */

