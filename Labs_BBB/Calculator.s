/*
PAULO RICARDO DA SILVA LOPES 
*/
/*Blink LED - BOARD*/
/* Clock */
.equ CM_PER_BASE,   0x44e00000  /*clock base*/
.equ GPIO1_OFFSET,  0xAC        /*offset do clock*/         
.equ GPIO1_DATAIN, 0x138
/* GPIO1 */
.equ GPIO1_BASE,                0x4804C000
.equ GPIO1_OE_OFFSET,           0x134
.equ GPIO1_SETDATAOUT_OFFSET,   0x194
.equ GPIO1_CLEARDATAOUT_OFFSET, 0x190
/* GPIO */
.equ GPIO1_OE, 0x4804C134
.equ GPIO1_SETDATAOUT, 0x4804C194
.equ GPIO1_CLEARDATAOUT, 0x4804C190


/*CONTROL MODULE*/
.equ CNTMDL_BASE,               0x44E10854 


/* UART */
.equ UART0_BASE, 0x44E09000

/* Watch Dog Timer */
.equ WDT_BASE, 0x44E35000

.syntax unified

uart_base0              = 0x44e09000
uart_dll                = 0x00
uart_dlh                = 0x04
uart_lcr                = 0x0c
uart_lsr                = 0x14
uart_lsr_txfifoe        = 1 << 5
uart_lsr_rxfifoe        = 1 << 0
uart_sysc               = 0x54
uart_sysc_softreset     = 1 << 1
uart_syss               = 0x58
uart_syss_resetdone     = 1 << 0
uart_mdr1               = 0x20
uart_thr                = 0x00
uart_rhr                = 0x00

/* Startup Code */
_start:
    /* init */
    mrs r0, cpsr
    bic r0, r0, #0x1F @ clear mode bits
    orr r0, r0, #0x13 @ set SVC mode
    orr r0, r0, #0xC0 @ disable FIQ and IRQ
    msr cpsr, r0

    /* setup - Hardware init*/
    bl .uart_init 
    bl .gpio_setup
    bl .disable_wdt
    
    b .main
/*1-Soma, 2-SomaModular, 3-MultiplicacaoModular, 4-Rotacao, 5-Divisao */
.main:
    adrl r0, welcome
    bl .print_string

	bl .uart_getc
    bl .uart_putc
	cmp r0, #0x31
    beq .somaled
	cmp r0, #0x32
    beq .somamodled
	cmp r0, #0x33
    beq .multmodled
	cmp r0, #0x34
    beq .rotate
	cmp r0, #0x35
    beq .divled
    cmp r0, #0x66 /* f */
    bl .fim_programa
    b .outros_erros

.somaled:
    bl .printa_quebra
    adrl r0, wget_num
    bl .print_string

    bl .get_integer
    mov r3, r0
    bl .printa_espaco
    ldr r0, ='+'
    bl .uart_putc
    bl .printa_espaco
    bl .get_integer
    mov r4, r0
    bl .printa_espaco
    ldr r0, ='='
    bl .uart_putc
    bl .printa_espaco
    add r3, r3, r4
    mov r2, r3
    bl .print_integer /*printa valor em R2 */
    cmp r3, #15
    bgt .somaERROR
    mov r5, #5
.somapisca:
    mov r2, r3
    bl .print_led /*printa valor em R2 */
    bl .delay
    mov r2, #0
    bl .print_led
    bl .delay
    sub r5, r5, #1
    cmp r5, #0	
    bne .somapisca
    mov r2, r3
    bl .print_led /*printa valor em R2 */
    b .fim_programa
/*End of sum */  
/*init modular sum */
.somamodled:
    bl .printa_espaco
    adrl r0, wget_num
    bl .print_string

    bl .get_integer
    mov r3, r0
    bl .printa_espaco
    ldr r0, ='+'
    bl .uart_putc
    bl .printa_espaco
    bl .get_integer
    mov r4, r0
    bl .printa_espaco
    ldr r0, ='='
    bl .uart_putc
    bl .printa_espaco
    
    add r3, r3, r4
    mov r2, r3
.modulariza:
    cmp r2, #15
    subgt r2, r2, #16
    bgt .modulariza
    bl .print_integer
    mov r5, #5
.somamodpisca:
    mov r2, r3
    bl .print_led /*printa valor em R2 */
    bl .delay
    mov r2, #0
    bl .print_led
    bl .delay
    sub r5, r5, #1
    cmp r5, #0	
    bne .somamodpisca
    mov r2, r3
    bl .print_led /*printa valor em R2 */
    b .fim_programa
/*End of modular sum */
/*Modular multiplication */
.multmodled:
    bl .printa_espaco
    adrl r0, wget_num
    bl .print_string

    bl .get_integer
    mov r3, r0
    bl .printa_espaco
    ldr r0, ='*'
    bl .uart_putc
    bl .printa_espaco
    bl .get_integer
    mov r4, r0
    bl .printa_espaco
    ldr r0, ='='
    bl .uart_putc
    bl .printa_espaco
    
    mul r2, r3, r4
    
.mul_modulariza:
    cmp r2, #15
    subgt r2, r2, #16
    bgt .mul_modulariza
    bl .print_integer /*printa valor em R2 */
    mov r5, #5
    mov r3, r2
.mul_modpisca:
    mov r2, r3
    bl .print_led /*printa valor em R2 */
    bl .delay
    mov r2, #0
    bl .print_led
    bl .delay
    sub r5, r5, #1
    cmp r5, #0	
    bne .mul_modpisca
    mov r2, r3
    bl .print_led /*printa valor em R2 */
    b .fim_programa
/*End modular multiplication */
/*init rotation */ 
.rotate:
    bl .printa_quebra
    adrl r0, wrotate_opc
    bl .print_string
    bl .uart_getc
    bl .uart_putc
    cmp r0, #0x72 /* r */
    beq .rotate_r
    cmp r0, #0x6c /* l */ 
    beq .rotate_l
    b .outros_erros
.rotate_r:
    adrl r0, wrotate
    bl .print_string
    ldr r0, ='X'
    bl .uart_putc
    ldr r0, =':'
    bl .uart_putc
    bl .printa_espaco

    bl .get_integer
    mov r2, r0
    cmp r2, #15
    bgt .fim_programa
    bl .printa_espaco
    ldr r0, ='N'
    bl .uart_putc
    ldr r0, =':'
    bl .uart_putc
    bl .printa_espaco

    bl .get_integer
    mov r3, r0
    bl .printa_espaco
    ldr r0, ='='
    bl .uart_putc
    bl .printa_espaco
    mov r4, r3
.rotate_r_p1:
    and r3, r2, #1
    mov r1, r2
    mov r2, r1, LSR #1 
    
    cmp r3, #1
    addeq r2, r2, #8

    sub r4, r4, #1
    cmp r4, #0
    bne .rotate_r_p1
    mov r3, r2
    mov r5, #5
    bl .print_integer /*printa valor em R2 */
.rotate_r_p2:
    mov r2, r3
    bl .print_led /*pisca os led em R2 até 4 bits */
    bl .delay
    mov r2, #0
    bl .print_led
    bl .delay
    sub r5, r5, #1
    cmp r5, #0
    bne .rotate_r_p2
    mov r2, r3
    bl .print_led /*printa valor em R2 */
    b .fim_programa

.rotate_l:
    adrl r0, wrotate
    bl .print_string
    ldr r0, ='X'
    bl .uart_putc
    ldr r0, =':'
    bl .uart_putc
    bl .printa_espaco

    bl .get_integer
    mov r2, r0
    bl .printa_espaco
    cmp r2, #15
    bgt .fim_programa
    ldr r0, ='N'
    bl .uart_putc
    ldr r0, =':'
    bl .uart_putc
    bl .printa_espaco

    bl .get_integer
    mov r3, r0
    bl .printa_espaco
    ldr r0, ='='
    bl .uart_putc
    bl .printa_espaco
    mov r4, r3
    
.rotate_l_p1:
    and r3, r2, #8
    mov r1, r2
    mov r2, r1, LSL #1 
    and r2, r2, #0x0F
    cmp r3, #8
    addeq r2, r2, #1

    sub r4, r4, #1
    cmp r4, #0
    bne .rotate_l_p1
    mov r3, r2
    mov r5, #5
    bl .print_integer /*printa valor em R2 */
.rotate_l_p2:
    mov r2, r3
    bl .print_led /*pisca os led em R2 até 4 bits */
    bl .delay
    mov r2, #0
    bl .print_led
    bl .delay
    sub r5, r5, #1
    cmp r5, #0
    bne .rotate_l_p2
    mov r2, r3
    bl .print_led /*printa valor em R2 */
    b .fim_programa
/*End rotation */

.somaERROR:
    mov r5, #3
    adrl r0, werro
    bl .print_string
.somaERROR_led:
    mov r2, #5
    bl .print_led
    bl .delay
    mov r2, #0
    bl .print_led
    bl .delay
    sub r5, r5, #1
    cmp r5, #0
    bne .somaERROR_led
    b .fim_programa    
/*End ERROR sum */
/*Init division led*/
/* r2/r3  */
.divled:
    bl .printa_quebra
    adrl r0, wget_num
    bl .print_string

    bl .get_integer
    mov r2, r0
    bl .printa_espaco
    ldr r0, ='/'
    bl .uart_putc
    bl .printa_espaco
    bl .get_integer
    mov r3, r0
    bl .printa_espaco
    ldr r0, ='='
    bl .uart_putc
    bl .printa_espaco
    bl .div
    mov r2, r0
    bl .print_integer /*printa valor em R2 */
    cmp r0, #15
    bgt .divisaoERROR
    mov r5, #5
.divled_pisca:
    mov r2, r0
    bl .print_led /*printa valor em R2 */
    bl .delay
    mov r2, #0
    bl .print_led
    bl .delay
    sub r5, r5, #1
    cmp r5, #0	
    bne .divled_pisca
    mov r2, r0
    bl .print_led /*printa valor em R2 */
    b .fim_programa
/*End of division led*/

/*Division ERROR */
.divisaoERROR:
    adrl r0, werro
    bl .print_string
    mov r5, #3
.divisaoERROR_p:
    mov r2, #6
    bl .print_led
    bl .delay
    mov r2, #0
    bl .print_led
    bl .delay
    sub r5, r5, #1
    cmp r5, #0
    bne .divisaoERROR_p
    mov r2, #6
    bl .print_led
    b .fim_programa
/*Others ERROR */ 
.outros_erros:
    adrl r0, werro
    bl .print_string
    mov r5, #5
.outros_erros_p:
    mov r2, #15
    bl .print_led
    bl .delay
    mov r2, #0
    bl .print_led
    bl .delay
    sub r5, r5, #1
    cmp r5, #0
    bne .outros_erros_p
    b .fim_programa 

/* Pet integer values ex: 1, 123 or 5250 */
/*Typing 'enter' indicates the end of get_integer */ 
.get_integer:
	stmfd sp!, {r1-r7,lr}
	mov r3, #0 /*stack counter*/
	/*r4 & r7 Help in reconstructing the number*/ 
    mov r4, #1
    mov r7, #10
	mov r5, #0

    .get_int:
	bl .uart_getc
	cmp r0, #0x0D /*If 'enter' goes to end */ 
	beq .fim_int
    /*If not number goes to erro */
    cmp r0, #0x30
    blt .outros_erros
    cmp r0, #0x39
    bgt .outros_erros
    /* ********* */
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
     ldmfd sp!, {r1 - r7,pc}
/*O valor do inteiro fica em r0 */

/********************************************************
Print number of 4 bits on leds
// R2 -> number
/********************************************************/
.print_led:
    stmfd sp!,{r0-r3,lr}

    ldr r0, =GPIO1_CLEARDATAOUT
    ldr r1, =(15<<21)
    str r1, [r0]

    and r3, r2, #1
    cmp r3, #0
    beq .P1

    ldr r0, =GPIO1_SETDATAOUT
    ldr r1, =(1<<21)
    str r1, [r0]

    .P1:
    and r3, r2, #(1<<1)
    cmp r3, #0
    beq .P2

    ldr r0, =GPIO1_SETDATAOUT
    ldr r1, =(1<<22)
    str r1, [r0]

    .P2:
    and r3, r2, #(1<<2)
    cmp r3, #0
    beq .P3

    ldr r0, =GPIO1_SETDATAOUT
    ldr r1, =(1<<23)
    str r1, [r0]

    .P3:
    and r3, r2, #(1<<3)
    cmp r3, #0
    beq .P4

    ldr r0, =GPIO1_SETDATAOUT
    ldr r1, =(1<<24)
    str r1, [r0]
	
    .P4:
    ldmfd sp!,{r0-r3,pc}
 /* * end print led*************** */   

.fim_programa:
mov r0, #0
 adrl r0, exit
bl .print_string 
/*reinicia programa */
.fim_programa_p:
ldr r0, =GPIO1_BASE
add r0, #GPIO1_DATAIN
ldr r1, [r0]
and r1, r1, #(1<<7) 
mov r1, r1, LSR #7 
cmp r1, #1
bne .fim_programa_p
mov r2, #0
bl .print_led
b .main

.printa_espaco:
	stmfd sp!, {r0-r3,lr}
	ldr r0, =' '
    bl .uart_putc
ldmfd sp!, {r0-r3,pc}

/*Enter */
.printa_quebra:
	stmfd sp!, {r0-r2,lr}
	ldr r0, ='\n'
    bl .uart_putc
    ldr r0, ='\r'
    bl .uart_putc
	ldmfd sp!, {r0-r2,pc}
/*Division procedure*/
/*Div r2/r3 */
.div:
    stmfd sp!, {r2-r3, lr}
    cmp r3, #0
    beq .divzeroerro
    /* R0 -> quociente, R1 -> resto*/
    mov r0, #0
.div1:
    mov r1, r2
    cmp r2, r3 
    blt .fim_div
    sub r2, r2, r3
    add r0, r0, #1
    b .div1
.fim_div:
    ldmfd sp!, {r2-r3, pc}
.divzeroerro:
    adrl r0, wdivzero
    bl .print_string
    b .outros_erros
/*End of division*/
/*print an integer. R2 -> number */
.print_integer:
    stmfd sp!, {r0-r4, lr}
    mov r3, #10
    mov r4, #0 /* contador de quantos numeros tenho na pilha*/
.print_int:
    bl .div /*divide r2 por r3 */
    stmfd sp!, {r1} /*Armazeno o resto da divisao na pilha */
    add r4, r4, #1 /*pilha incrementa 1 */
    mov r2, r0 /*r0 -> quociente da divisao */
    cmp r2, #0
    bne .print_int
.repeat_print_int:
    ldmfd sp!, {r0}
    add r0, r0, #0x30 /*Converto inteiro para ASCII */
    bl .uart_putc
    sub r4, r4, #1 /*Decremento o contador de pilha */
    cmp r4, #0
    bne .repeat_print_int

    ldmfd sp!, {r0-r4, pc}
/*End print integer*/
.delay:
    stmfd sp!, {r7, lr}
	mov r7, #0xfffffff
    .delay1:
    sub r7, r7, #1
	cmp r7, #0
	bne .delay1
    ldmfd sp!, {r7, pc}

/********************************************************
Print a string to '\0'
// R0 -> string */
.print_string:
    stmfd sp!,{r0-r2,lr}
    mov r1, r0
.print:
    ldrb r0,[r1],#1
    and r0, r0, #0xFF
    cmp r0, #0
    beq .end_print
    bl .uart_putc
    b .print
.end_print:
    ldmfd sp!,{r0-r2,pc}
/********************************************************/

/********************************************************
UART0 PUTC (Default configuration)  
********************************************************/
.uart_putc:
    stmfd sp!, {r1 - r2, lr}
    ldr r1, =uart_base0

    /* Wait for transmit hold register to clear (TXFIFOE == 1) */
1:
    ldr r2, [r1, uart_lsr]
    tst r2, uart_lsr_txfifoe
    beq 1b

    /* Output character */
    str r0, [r1, uart_thr]

    ldmfd sp!, {r1 - r2, pc}
/********************************************************
UART0 GETC (Default configuration)  
********************************************************/
.uart_getc:
    stmfd sp!, {r1 - r2, lr}
    ldr r1, =uart_base0

    /* Wait for transmit hold register to fill (RXFIFOE == 1) */
1:
    ldr r2, [r1, uart_lsr]
    tst r2, uart_lsr_rxfifoe
    beq 1b

    /* Input character */
    ldr r0, [r1, uart_rhr]

    ldmfd sp!, {r1 - r2, pc}

/********************************************************/
.uart_init:

    ldr r0, =uart_base0

    /* Reset: set UARTi.UART_SYSC[1] SOFTRESET to 1 */
    mov r1, uart_sysc_softreset
    str r1, [r0, uart_sysc]
    
    /* Wait for reset: poll for UARTi.UART_SYSS[0] RESETDONE == 1 */
1:
    ldr r1, [r0, uart_syss]
    cmp r1, uart_syss_resetdone
    bne 1b

    mov r1, 0x83
    str r1, [r0, uart_lcr]

    /* Set Baud Rate to 115200: assume DLH == 0 (default), set DLL = 0x1A */
    mov r1, 0x1a
    str r1, [r0, uart_dll]

    /* Enable UART 16x mode: set UARTi.UART_MDR1[2:0] MODESELECT to 0 */
    mov r1, 0
    str r1, [r0, uart_mdr1]

    /* Switch to Operational mode: clear UARTi.UART_LCR[7] DIV_EN */
    ldr r1, [r0, uart_lcr]
    bic r1, r1, 0x80
    str r1, [r0, uart_lcr]

    bx lr
/*INICIO GPIO SETUP */
.gpio_setup:
    /* set clock for GPIO1, TRM 8.1.12.1.31 */
    ldr r0, =CM_PER_BASE
    add r0, #GPIO1_OFFSET
    mov r2, #1
    lsl r1, r2, #1
    lsl r3, r2, #18
    orr r1, r1, r3
    str r1, [r0]

    /*ldr r0, =CNTMDL_BASE
    mov r1, #7
    str r1, [r0]*/

    /* set pin 21 for output, led USR0, TRM 25.3.4.3 */
    ldr r0, =GPIO1_BASE
    add r0, #GPIO1_OE_OFFSET
    ldr r1, [r0]
    bic r1, r1, #(15<<21)
    str r1, [r0]

    /*setup pin input button */
    ldr r0, =GPIO1_BASE
    add r0, #GPIO1_OE_OFFSET
    ldr r1, [r0]
    orr r1, r1, #(1<<7) /*GPIO1_7 LOGICO, PIN 4 FISICO - P8 */
    str r1, [r0] /* 1 - ENTRADA */
    bx lr
/*END GPIO SETUP */

/********************************************************
  Registers (see TRM 20.4.4.1):
    WDT_BASE -> 0x44E35000
    WDT_WSPR -> 0x44E35048
    WDT_WWPS -> 0x44E35034
********************************************************/
/********************************************************
  WDT disable sequence (see TRM 20.4.3.8):
    1- Write XXXX AAAAh in WDT_WSPR.
    2- Poll for posted write to complete using WDT_WWPS.W_PEND_WSPR. (bit 4)
    3- Write XXXX 5555h in WDT_WSPR.
    4- Poll for posted write to complete using WDT_WWPS.W_PEND_WSPR. (bit 4)
    
  Registers (see TRM 20.4.4.1):
    WDT_BASE -> 0x44E35000
    WDT_WSPR -> 0x44E35048
    WDT_WWPS -> 0x44E35034
********************************************************/
.disable_wdt: 
    /* TRM 20.4.3.8 */
    stmfd sp!,{r0-r1,lr}
    ldr r0, =WDT_BASE
    
    ldr r1, =0xAAAA
    str r1, [r0, #0x48]
    bl .poll_wdt_write

    ldr r1, =0x5555
    str r1, [r0, #0x48]
    bl .poll_wdt_write

    ldmfd sp!,{r0-r1,pc}

.poll_wdt_write:
    ldr r1, [r0, #0x34]
    and r1, r1, #(1<<4)
    cmp r1, #0
    bne .poll_wdt_write
    bx lr
/********************************************************/
/*Digite  a operação que deseja fazer \n\r(Ex: 1-Soma, 2-SomaModular, 3-MultiplicacaoModular, 
4-Rotacao, 5-Divisao). O 'E/nter' indica o fim da insercao do numero.*/ 
.align 4
welcome: .asciz "\n\rDigite a operacao que deseja fazer(Ex: 1-Soma, 2-SomaModular,\n\r3-MultiplicacaoModular, 4-Rotacao, 5-Divisao, 'f' para encerrar): \n\r"
wget_num: .asciz "\n\rDigite os valores. O 'Enter' indica o fim da insercao do numero.\n\r"
wdivzero: .asciz "\n\rImpossivel dividir por zero. \n\rFim do programa."
wrotate_opc: .asciz "\n\rRotacao para a direita digite 'r', para a esquerda digite 'l' \n\r"
wrotate: .asciz "\n\rDigite o numero e a quantidade de rotacoes que deseja fazer\n\r O 'Enter' indica o fim da insercao do numero.\n\r"
werro: .asciz "\n\rERROR!!!\n\r"
exit: .asciz "\n\rPrograma encerrado!"
