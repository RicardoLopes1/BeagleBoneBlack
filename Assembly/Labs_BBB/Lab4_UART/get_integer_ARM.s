/* Get integer values ex: 1 ou 123 ou 5250. 
PPress enter to indicate end of number  */
.get_integer:
	stmfd sp!, {r1-r7,lr} /*salvo o conterxto */
	mov r3, #0 /*contador de pilha*/
	mov r4, #1 /* multiplicador */
	mov r5, #0 /* Armazenará o valor final */

    .get_int:
	bl .uart_getc /* chama a funcao para pegar um caractere do teclado */
	cmp r0, #0x0D /* verifico se o "enter" foi pressionado */
	beq .fim_int
	and r0, r0, #0xFF
    	bl .uart_putc /* printo na tela o valor digitado */
	sub r0, r0, #48 /* converto de asc para inteiro */ 

	stmfd sp!, {r0} /* salvo na pilha o primeito número digitado */
	add r3, r3, #1 /* incremento o contador de pilha */
	b .get_int

    .fim_int:
	cmp r3, #0 /* verifico se nao ha nada na pilha */
	beq .fim__int

	ldmfd sp!, {r0}	/*pego um valor inteiro da pilha */
	mov r6, r0	
	mul r0, r6, r4 /*multiplico o valor pegue da pilha pelo meu multiplicador */
	/* aumento meu multiplicador em 10x */
	mov r6, r4
	mov r7, #10
	mul r4, r6, r7
	/*fim do aumento 10x */
	add r5, r5, r0 /*somo o valor pegue da pilha */
	subs r3, r3, #1 /*decremento o contador de pilha */
	
	b .fim_int

     .fim__int:
	mov r0, r5 /*o valor final estará em r0 */
     ldmfd sp!, {r1-r7,pc} /*retorno todo o contexto */
/* end get_integer */


