/*PISCA LED*/

/* Clock */
.equ CM_PER_BASE,   0x44e00000  /*clock base*/
.equ GPIO1_OFFSET,  0xAC        /*offset do clock*/         

/* GPIO1 */
.equ GPIO1_BASE,                0x4804C000
.equ GPIO1_OE_OFFSET,           0x134
.equ GPIO1_SETDATAOUT_OFFSET,   0x194
.equ GPIO1_CLEARDATAOUT_OFFSET, 0x190

/*CONTROL MODULE*/
.equ CNTMDL_BASE,               0x44E10854

/* Watch Dog Timer */
.equ WDT_BASE, 0x44E35000


_start:
    /* init */
    mrs r0, cpsr
    bic r0, r0, #0x1F @ clear mode bits
    orr r0, r0, #0x13 @ set SVC mode
    orr r0, r0, #0xC0 @ disable FIQ and IRQ
    msr cpsr, r0
    
    bl .disable_wdt
    bl .gpio_setup
    

.main_loop:
    ldr r0, =GPIO1_BASE
    add r0, #GPIO1_SETDATAOUT_OFFSET
    ldr r1, =(1<<21)
    str r1, [r0]
	mov  r5, #0xfffffff
	bl .delay

	ldr r0, =GPIO1_BASE
	add r0, #GPIO1_CLEARDATAOUT_OFFSET
	ldr r1, =(1<<21)
	str r1, [r0]	
	mov  r5, #0xfffffff
	bl .delay

	ldr r0, =GPIO1_BASE
        add r0, #GPIO1_SETDATAOUT_OFFSET
        ldr r1, =(1<<22)
        str r1, [r0]
	mov  r5, #0xfffffff
	bl .delay

	ldr r0, =GPIO1_BASE
	add r0, #GPIO1_CLEARDATAOUT_OFFSET
	ldr r1, =(1<<22)
	str r1, [r0]	
	mov  r5, #0xfffffff
	bl .delay

	ldr r0, =GPIO1_BASE
        add r0, #GPIO1_SETDATAOUT_OFFSET
        ldr r1, =(1<<23)
        str r1, [r0]
	mov  r5, #0xfffffff
	bl .delay

	ldr r0, =GPIO1_BASE
	add r0, #GPIO1_CLEARDATAOUT_OFFSET
	ldr r1, =(1<<23)
	str r1, [r0]	
	mov  r5, #0xfffffff
	bl .delay

	ldr r0, =GPIO1_BASE
        add r0, #GPIO1_SETDATAOUT_OFFSET
        ldr r1, =(1<<24)
        str r1, [r0]
	mov  r5, #0xfffffff
	bl .delay

	ldr r0, =GPIO1_BASE
	add r0, #GPIO1_CLEARDATAOUT_OFFSET
	ldr r1, =(1<<24)
	str r1, [r0]	
	mov  r5, #0xfffffff
	bl .delay

    b .main_loop





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
    bx lr

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

.delay:	
	sub r5, r5, #1
	cmp r5, #0
	bne .delay
	bx lr



















