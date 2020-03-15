.equ LEDS0, 0x2000
.equ LEDS1, 0x2004
.equ LEDS2, 0x2008
.equ TIMER, 0x2020
.equ BUTTONS, 0x2030
.equ PERIOD, 1000
start:
br main
interrupt_handler:
	wrctl ctl0, zero 
	addi sp, sp, -16
	stw t0, 0(sp)
	stw t1, 4(sp)
	stw t2, 8(sp)
	stw t3, 12(sp)
	rdctl t0, ctl4
	andi t2, t0, 4
	addi t1, zero, 4
	beq t2, t1, firstCounter
	;Masked with 1
	andi t2, t0, 1 ;Mask to get 3LSB
	;andi t2, t0, 1
	addi t1, zero, 1;If LSB 3 is on
	beq t2, t1, secondCounter
	addi t1, zero, 5
	beq t0, t1, reset_interrupts
continue:
	ldw t0, 0(sp)
	ldw t1, 4(sp)
	ldw t2, 8(sp)
	ldw t3, 12(sp)
	addi sp, sp, 16
	addi ea, ea, -4
	eret
main:
	stw zero, LEDS0(zero)
	stw zero, LEDS1(zero)
	stw zero, LEDS2(zero)
	stw zero, BUTTONS(zero)
	stw zero, BUTTONS + 4(zero)
	addi sp, zero, 0x1B10
	wrctl ctl3, t0 ;First 3 bits are enabled
	addi t0, zero, 1
	wrctl ctl0, t0
	addi t0, zero, PERIOD
	stw t0, TIMER + 4 (zero)
	addi t0, zero, 11
	stw t0, TIMER + 8 (zero)
	addi t0, zero, 5
	wrctl ctl3, t0
loop:
	ldw t0, LEDS2(zero)
	addi t0, t0, 1
	stw t0, LEDS2(zero)	
	jmpi loop

firstCounter:
	ldw t0, BUTTONS + 4(zero) ;Getting the edgecapture, somehow the 4th bit is turned on regardless
	;mask with 3
	andi t0, t0, 3
	addi t1, zero, 3
	beq t0,t1, end
	andi t1, t0, 1
	addi t2, zero, 1
	beq t1,t2, btn1
	andi t1, t0, 2
	addi t2, zero, 2
	beq t1, t2, btn2
end:
	stw zero, BUTTONS + 4(zero)
	jmpi continue
btn1:
	ldw t0, LEDS0(zero)
	addi t0, t0, -1
	stw t0, LEDS0(zero)
	jmpi end
btn2:
	ldw t0, LEDS0(zero)
	addi t0, t0, 1
	stw t0, LEDS0(zero)
	jmpi end


secondCounter:
	ldw t0, TIMER + 12(zero);Resetting TO from status
	xori t0, t0, 2
	stw t0, TIMER + 12(zero)
	ldw t0, LEDS1(zero)
	addi t0, t0, 1
	stw t0, LEDS1(zero)
	jmpi continue	

reset_interrupts:
	ldw t0, TIMER + 12(zero);Resetting TO from status
	xori t0, t0, 2
	stw t0, TIMER + 12(zero)
	stw zero, BUTTONS + 4(zero)
	jmpi continue