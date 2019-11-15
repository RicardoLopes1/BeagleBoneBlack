/*Paulo Ricardo da Silva Lopes*/ 
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

    /* Setup */
    bl .uart_init
    bl .disable_wdt
    bl .main

.main:
	bl .get_integer
	mov r6, r0
	cmp r6, #0
	beq .fim_programa
	mov r5, r6
	.for1:	
	    mov r4, r6
		bl .printa_quebra		
	.for2:
		cmp r5, r4
		beq .asterisco
		bl .printa_traco
		bl .printa_espaco
		b .sai
	.asterisco:
		bl .printa_asterisco
		bl .printa_espaco
	.sai:
		subs r4, r4, #1
		bne .for2
		subs r5 ,r5, #1
		bne .for1		
    b .fim_programa

.printa_espaco:
	stmfd sp!, {r0,lr}
	ldr r0, =' '
    bl .uart_putc
ldmfd sp!, {r0,pc}

.printa_asterisco:
stmfd sp!, {r0,lr}
	ldr r0, ='*'
    bl .uart_putc
ldmfd sp!, {r0,pc}

.printa_traco:
stmfd sp!, {r0,lr}
	ldr r0, ='-'
    bl .uart_putc
ldmfd sp!, {r0,pc}

.printa_quebra:
	stmfd sp!, {r0,lr}
	adrl r0, CRFL
    bl .uart_putc
    ldmfd sp!, {r0,pc}

/* Get integer values ​​from UART ex: 1 or 123 or 5250 */
.get_integer:
	stmfd sp!, {r1-r7,lr}
	mov r3, #0 /*Stack counter*/
	mov r4, #1
	mov r5, #0

    .get_int:
	bl .uart_getc
	cmp r0, #0x0D
	beq .fim_int
	and r0, r0, #0xFF
    	bl .uart_putc
	sub r0, r0, #48  

	stmfd sp!, {r0}
	add r3, r3, #1
	b .get_int

    .fim_int:
	cmp r3, #0
	beq .fim__int

	ldmfd sp!, {r0}	
	mov r6, r0	
	mul r0, r6, r4
	mov r6, r4
	mov r7, #10
	mul r4, r6, r7
	add r5, r5, r0
	subs r3, r3, #1
	b .fim_int

    .fim__int:
	mov r0, r5
    ldmfd sp!, {r1-r7,pc}
/* end get_integer */

    
/********************************************************
Imprime uma string até o '\0'
// R0 -> Endereço da string
/********************************************************/
.print_string:
    stmfd sp!,{r0-r2,lr}
    mov r1, r0
.print:
    ldrb r0,[r1],#1
    and r0, r0, #0xff
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

    ldr r1, =uart_base0

    /* Wait for transmit hold register to clear (TXFIFOE == 1) */
1:
    ldr r2, [r1, uart_lsr]
    tst r2, uart_lsr_txfifoe
    beq 1b

    /* Output character */
    str r0, [r1, uart_thr]

    bx lr

/********************************************************
UART0 GETC (Default configuration)  
********************************************************/
.uart_getc:

    ldr r1, =uart_base0

    /* Wait for transmit hold register to fill (RXFIFOE == 1) */
1:
    ldr r2, [r1, uart_lsr]
    tst r2, uart_lsr_rxfifoe
    beq 1b

    /* Input character */
    ldr r0, [r1, uart_rhr]

    bx lr

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


.print_matrix:
    stmfd sp!,{r0-r2,lr}
    # mov r2, #10
    # .for:
        ldr r0, ='\n'
        bl uart_putc
        ldr r0, ='R'
        bl uart_putc
        # subs r2, r2, #1
        # beq .for
    ldmfd sp!,{r1-r2,pc}    
    b lr 
/*********** */
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
/******** */        
.fim_programa:
bx lr


.align 4
CRFL: .asciz "\n\r"




