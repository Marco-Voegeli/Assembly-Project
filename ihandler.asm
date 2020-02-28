– The second counter must be incremented each time the timer generates an IRQ. Set the period
such that the counter is incremented once every 1000 cycles. The second counter is displayed
on leds1, counting from 0.
– The third counter is controlled from the main procedure in an infinite loop. The third counter
is displayed on leds2, counting from 0.
– Implement an interrupt handler that looks for the source of the interrupt and calls the corresponding
interrupt service routine (ISR). Do not forget to consider what should happen if
there are two interrupts in the same cycle.
– Implement two ISRs to handle the interrupts coming from the timer and the push buttons.
– In the main procedure, initialize the stack pointer and set the value of the control registers to
enable the interrupts.



.equ LEDS0, 0x2000 
.equ LEDS1, 0x2004
.equ LEDS2, 0x2008
.equ PULSEWIDTH, 0x200C
.equ TIMER, 0x2020 ; timer address
.equ STATUS 0x2030 ;Buttons status

_start:
    br main ; jump to the main function

interrupt_hanler: ; save the registers to the stack
    ; read the ipending register to identify the source
    ; call the corresponding routine
    ; restore the registers from the stack
    addi ea, ea, -4 ; correct the exception return address
    eret ; return from exception
main:
    ; main procedure here




firstCounter : 
ldw a0, STATUS($r0)
andi a1, a0, 15
addi a2, $r0, 14
ldw a3, LEDS0
beq a1,a2, btnOne
addi a2, $r0, 13
beq a1,a2, btnTwo
addi a2, $r0, 11
beq a1,a2, btnThree
addi a2, $r0, 7
beq a1,a2, btnFour

end:
    ret

btnOne: 
    addi a3,a3,-1
    stw a3, LEDS0
    jmpi end
btnTwo:
    addi a3,a3,1
    stw a3, LEDS0
    jmpi end
btnThree:
    addi a3,a3,-3
    stw a3, LEDS0
    jmpi end
btnFour:
    addi a3,a3,3
    stw a3, LEDS0
    jmpi end


secondCounter : 
    rdctl a0, ctl4
    andi a0, a0, 1
    addi a1,a1,1
    beq a0,a1, incSecCounter
    ret

incSecCounter:
    ldw a2, LEDS0
    addi a2,a2,1
    stw a2, LEDS1
    ret

