.equ LEDS0, 0x2000 
.equ LEDS1, 0x2004
.equ LEDS2, 0x2008
.equ PULSEWIDTH, 0x200C
.equ TIMER, 0x2020 ; timer address
.equ EDGE_CONTROL, 0x2034
.equ PERIOD, 0 ;Period for counter

start:
    br main ; jump to the main function
interrupt_handler: 
	addi sp, sp, -16 ; save the registers to the stack
	stw sp, 0(a1)
	stw sp, 4(a2)
	stw sp, 8(a3)
	stw sp, 12(ra)
	rdctl a1, ctl4	; read the ipending register to identify the source
	andi a2, a1, 1
	srli a3, a1, 2 ;Checking if the 3rd bit is on
 	andi a3, a3, 1
	addi a1, zero, 1 
	beq a3, a1, firstCounter 
	beq a2, a1, secondCounter ; call the corresponding routine
   continue: 
	ldw a1, 0(sp); restore the registers from the stack
	ldw a2, 4(sp)
	ldw a3, 8(sp)
	ldw ra, 12(sp)
	addi sp, sp, 16
    addi ea, ea, -4 ; correct the exception return address
    eret ; return from exception
	
main:  ; main procedure here
	addi sp, zero, 0x1F00
	addi t1, zero, PERIOD
	stw t1, TIMER + 8 (zero)
	addi t1, zero, 11
	stw t1, TIMER + 4 (zero)
	addi t0, zero, 1
	wrctl ctl0, t0 ;allowing interupts to work on our system
	addi t0, zero, 5
	wrctl ctl3, t0 ;Setting which values we are listening too
loop:
    ldw t2, LEDS2(zero)
	addi t2, t2, 1
    stw t2, LEDS2(zero)
    jmpi loop

firstCounter : 
	ldw t0, EDGE_CONTROL(zero) ;Getting the buttons which are turned on
	ldw t3, LEDS0(zero)
	andi t0, t0, 0xF
	addi t2, zero, 8
	beq t0,t2, btnFour
	addi t2, zero, 1
	beq t0,t2, btnOne
	addi t2, zero, 2
	beq t0,t2, btnTwo
	addi t2, zero, 4
	beq t0,t2, btnThree

end:
	stw t3, LEDS0(zero)	
	stw zero, EDGE_CONTROL(zero)
	jmpi continue
btnOne: 
    addi t3,t3,-1
    jmpi end
btnTwo:
    addi t3,t3,1
    jmpi end
btnThree:
    addi t3,t3,-3
    jmpi end
btnFour:
    addi t3,t3,3
    jmpi end

secondCounter: 
    ldw t2, LEDS1(zero)
    addi t2,t2,1
    stw t2, LEDS1(zero)
    jmpi continue

