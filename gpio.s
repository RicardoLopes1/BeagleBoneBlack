/* Clock */
.equ CM_PER_BASE,   0x44e00000  /*clock base*/
.equ GPIO1_OFFSET,  0xAC        /*offset do clock*/         

/* GPIO */
.equ GPIO1_BASE,                0x4804C000
.equ GPIO1_OE_OFFSET,           0x134
.equ GPIO1_SETDATAOUT_OFFSET,   0x194
.equ GPIO1_CLEARDATAOUT_OFFSET, 0x190

/*CONTROL MODULE*/
.equ CNTMDL_BASE,               0x44E10854

_start:
    /* init */
    mrs r0, cpsr
    bic r0, r0, #0x1F @ clear mode bits
    orr r0, r0, #0x13 @ set SVC mode
    orr r0, r0, #0xC0 @ disable FIQ and IRQ
    msr cpsr, r0


    bl .gpio_setup

.main_loop:
    ldr r0, =GPIO1_BASE
    add r0, #GPIO1_SETDATAOUT_OFFSET
    ldr r1, =(1<<21)
    str r1, [r0]

    bx lr





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
    bic r1, r1, #(1<<21)
    str r1, [r0]
    bx lr



















