.equ EDGE_CAPTURE, 0x2034
.equ TIMER, 0x2020
.equ LEDS0, 0x2000
.equ LEDS1, 0x2004
.equ LEDS2, 0x2008
.equ PERIOD, 0x0
start:
	br main
interrupt_handler:
	wrctl ctl0, zero
	addi sp, sp, -16
	stw t0, 0 (sp)
	stw t1, 4 (sp)
	stw	t2, 8 (sp)
	stw t3, 12(sp)
	rdctl t0, ctl4
	andi t1, t0, 5
	addi t2, zero, 4
	beq t1, t2, firstCounter ;Counter for LEDS1
	addi t2, zero, 1
	beq t1, t2, secondCounter ;Counter for LEDS1
	jmpi thirdCounter
continue:
	ldw t0, 0(sp)
	ldw t1, 4(sp)
	ldw t2, 8(sp)
	ldw t3, 12(sp)
	addi sp, sp, 16
	addi ea, ea, -4
	eret
main:
	addi sp, zero, 0x0F11
	addi t0, zero, 1
	wrctl ctl0, t0
	addi t0, zero, 5	
	wrctl ctl3, t0 ;Setting the interupts
	addi t0, zero, 11	
	stw t0, TIMER + 8 (zero) ;Setting the control to 11
	addi t0, zero, 1-PERIOD
	stw t0, TIMER + 4 (zero) ;Setting the period
loop: ;This is never ran
	ldw t0, LEDS2(zero)
	addi t0, t0, 1
	stw t0, LEDS2(zero)
	jmpi loop

firstCounter: ;If a button is pressed
	ldw t0, EDGE_CAPTURE(zero)
	stw zero, EDGE_CAPTURE(zero)
	ldw t3, LEDS0(zero)
	addi t1, zero, 3
	beq t0, t1, end ;Nothing should happen if button 0 and 1 are pressed at the same time
	addi t1, zero, 1
	beq t0, t1, btn1
	addi t1, zero, 2
	beq t0, t1, btn2
	addi t1, zero, 4
	beq t0, t1, btn3
	addi t1, zero, 8
	beq t0, t1, btn4

end: 
	stw t3, LEDS0(zero)
	jmpi continue
btn1:
	addi t3, t3, -1
	jmpi end
btn2:
	addi t3, t3, 1
	jmpi end
btn3:
	addi t3, t3, 2
	jmpi end
btn4:
	addi t3, t3, -2
	jmpi end

secondCounter: ;If the timer reaches 0
	ldw t1, TIMER + 12(zero)
	xori t1, zero, 2
	stw t1, TIMER + 12(zero)	  
	ldw t1, LEDS1(zero)
	addi t1, t1, 1
	stw t1, LEDS1(zero)
	jmpi continue

thirdCounter:
	rdctl t0, ctl4
	stw t0, LEDS2(zero)
	jmpi firstCounter
	