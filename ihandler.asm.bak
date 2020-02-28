.equ LEDS0, 0x2000 
.equ LEDS1, 0x2004
.equ LEDS2, 0x2008
.equ PULSEWIDTH, 0x200C
.equ TIMER, 0x2020 ; timer address
.equ STATUS, 0x2030 ;Buttons status
.equ PERIOD, 1000 ;Period for counter

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
	andi a3, a1, 4
	addi a1, zero, 1
	beq a2, a1, secondCounter
	beq a3, a1, firstCounter 	; call the corresponding routine
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
	addi a0, zero, 4
	addi a1, zero, PERIOD
	stw a1, TIMER(a0);Initializing the enables
	addi a0, zero, 1
	wrctl ctl0, a0
	addi a0, zero, 5
	wrctl ctl3, a0
loop:
    ldw a2, LEDS2(zero)
	addi a2,a2,1
    stw a2, LEDS2(zero)
    jmpi loop

firstCounter : 
ldw a0, STATUS(zero)
andi a1, a0, 15
addi a2, zero, 14
ldw a3, LEDS0(zero)
beq a1,a2, btnOne
addi a2, zero, 13
beq a1,a2, btnTwo
addi a2, zero, 11
beq a1,a2, btnThree
addi a2, zero, 7
beq a1,a2, btnFour

end:
	stw a3, LEDS0(zero)	
	jmpi continue
btnOne: 
    addi a3,a3,-1
    jmpi end
btnTwo:
    addi a3,a3,1
    jmpi end
btnThree:
    addi a3,a3,-3
    jmpi end
btnFour:
    addi a3,a3,3
    jmpi end

secondCounter: 
    rdctl a0, ctl4
    andi a0, a0, 1
    addi a1, zero, 1
    beq a0,a1, incSecCounter
    jmpi continue
incSecCounter:
    ldw a2, LEDS0(zero)
    addi a2,a2,1
    stw a2, LEDS1(zero)
    jmpi continue

