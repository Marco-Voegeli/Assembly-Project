.equ    RAM, 0x1000
.equ    LEDs, 0x2000
.equ    TIMER, 0x2020
.equ    BUTTON, 0x2030

.equ    LFSR, RAM

br main
br interrupt_handler

main:
    ; Variable initialization for spend_time
    addi t0, zero, 18
    stw t0, LFSR(zero)

; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; DO NOT CHANGE ANYTHING ABOVE THIS LINE
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    ; WRITE YOUR CONSTANT DEFINITIONS AND main HERE
.equ COUNTER, 0x10A0
.equ B_PRESSED, 0x10B0
    addi 	t0, zero, 0x4C4
	slli 	t0, t0, 12
	addi 	t0, t0, 0xB40
;	addi 	t0, zero, 100
    stw 	t0, TIMER+4(zero) ;set period
    addi 	t0, zero,11
    stw 	t0, TIMER+8(zero); setting control
    addi	sp, zero, 0x1BA0 
	stw		zero, COUNTER(zero)
	addi	t0, zero, 1 ;Setting the Control Registers
	wrctl 	ctl0, t0
	addi 	t0, zero, 5 ;Setting the iactive bits
	wrctl 	ctl3, t0 
loop:
	jmpi	loop ;Infinite loop waiting for IRQ's
	
interrupt_handler:
	; WRITE YOUR INTERRUPT HANDLER HERE
	wrctl 	ctl0, zero ;Should be done automatically....
;Stack 
	addi	sp, sp, -36
    stw		t0, 0(sp)
    stw		t1, 4(sp)
    stw 	t2, 8(sp)
    stw 	t3, 12(sp)
    stw     t4, 16(sp)
	stw 	s0, 20(sp)
	stw		s1, 24(sp)
	stw 	s2, 28(sp)
	stw 	s3, 32(sp)
;Stack
	rdctl 	t0, ctl4 ;Reading iPending
	andi  	t1, t0, 4
	addi 	t2, zero, 4
	beq 	t1, t2, button_pressed ;if IRQ bit 2 is on
	andi 	t0, t0, 1
	addi 	t1, zero, 1
	beq 	t0, t1, timer_increment ;if IRQ bit 0 is on
err_end:
    ldw     t0, 0(sp)
    ldw     t1, 4(sp)
    ldw     t2, 8(sp)
    ldw     t3, 12(sp)
    ldw     t4, 16(sp)
	ldw 	s0, 20(sp)
	ldw 	s1, 24(sp)
	ldw 	s2, 28(sp)
	ldw 	s3, 32(sp)
	addi	sp, sp, 36
	addi 	ea, ea, -4
	eret
button_pressed:
    ldw t0, BUTTON + 4(zero)
	stw zero, BUTTON + 4 (zero);resetting EDGE_CAPTURE here
	addi t1, zero, 1
	beq t0, t1, button_0
	jmpi but_end
button_0:
	addi t0, zero, 1
	addi sp, sp, -4
	stw ea, 0(sp) ;Storing ea register in stack
;Boolean en memoire
	stw t0, B_PRESSED(zero)
	addi t1, zero, 1
	wrctl ctl3, t1 ;Disabling the buttons interrupts 
	wrctl ctl0, t0 ;After storing the error address
	call spend_time
	stw zero, B_PRESSED(zero)
;Turn boolean off
	wrctl ctl0, zero
	addi t1, zero, 5
	wrctl ctl3, t1
	ldw ea, 0(sp)
	addi sp, sp, 4
but_end:
 ;We are out of spend_time so we go back to no nested exceptions
	jmpi err_end ;Check this maybe
timer_increment:
	ldw t0, B_PRESSED(zero)
	addi t1, zero, 1
	beq t0, t1, timer_without_display
	ldw a0, COUNTER(zero)
	call display
	ldw a0, COUNTER(zero) ;Incrementing the counter
	addi a0, a0, 1
	stw a0, COUNTER(zero)	
	jmpi timer_end
timer_without_display:
	ldw t0, COUNTER(zero)
	addi t0, t0, 1
	stw t0, COUNTER(zero)
timer_end:
	ldw t0, TIMER + 12(zero);Resetting TO from status
	xori t0, t0, 2
	stw t0, TIMER + 12(zero)
	jmpi err_end

; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; DO NOT CHANGE ANYTHING BELOW THIS LINE
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ----------------- Common functions --------------------
; a0 = tenths of second
display:
    addi   sp, sp, -20
    stw    ra, 0(sp)
    stw    s0, 4(sp)
    stw    s1, 8(sp)
    stw    s2, 12(sp)
    stw    s3, 16(sp)
    add    s0, a0, zero
    add    a0, zero, s0
    addi   a1, zero, 600
    call   divide
    add    s0, zero, v0
    add    a0, zero, v1
    addi   a1, zero, 100
    call   divide
    add    s1, zero, v0
    add    a0, zero, v1
    addi   a1, zero, 10
    call   divide
    add    s2, zero, v0
    add    s3, zero, v1

    slli   s3, s3, 2
    slli   s2, s2, 2
    slli   s1, s1, 2
    ldw    s3, font_data(s3)
    ldw    s2, font_data(s2)
    ldw    s1, font_data(s1)

    xori   t4, zero, 0x8000
    slli   t4, t4, 16
    add    t5, zero, zero
    addi   t6, zero, 4
    minute_loop_s3:
    beq    zero, s0, minute_end
    beq    t6, t5, minute_s2
    or     s3, s3, t4
    srli   t4, t4, 8
    addi   s0, s0, -1
    addi   t5, t5, 1
    br minute_loop_s3

    minute_s2:
    xori   t4, zero, 0x8000
    slli   t4, t4, 16
    add    t5, zero, zero
    minute_loop_s2:
    beq    zero, s0, minute_end
    beq    t6, t5, minute_s1
    or     s2, s2, t4
    srli   t4, t4, 8
    addi   s0, s0, -1
    addi   t5, t5, 1
    br minute_loop_s2

    minute_s1:
    xori   t4, zero, 0x8000
    slli   t4, t4, 16
    add    t5, zero, zero
    minute_loop_s1:
    beq    zero, s0, minute_end
    beq    t6, t5, minute_end
    or     s1, s1, t4
    srli   t4, t4, 8
    addi   s0, s0, -1
    addi   t5, t5, 1
    br minute_loop_s1

    minute_end:
    stw    s1, LEDs(zero)
    stw    s2, LEDs+4(zero)
    stw    s3, LEDs+8(zero)

    ldw    ra, 0(sp)
    ldw    s0, 4(sp)
    ldw    s1, 8(sp)
    ldw    s2, 12(sp)
    ldw    s3, 16(sp)
    addi   sp, sp, 20

    ret

flip_leds:
    addi t0, zero, -1
    ldw t1, LEDs(zero)
    xor t1, t1, t0
    stw t1, LEDs(zero)
    ldw t1, LEDs+4(zero)
    xor t1, t1, t0
    stw t1, LEDs+4(zero)
    ldw t1, LEDs+8(zero)
    xor t1, t1, t0
    stw t1, LEDs+8(zero)
    ret

spend_time:
    addi sp, sp, -4
    stw  ra, 0(sp)
    call flip_leds
    ldw t1, LFSR(zero)
    add t0, zero, t1
    srli t1, t1, 2
    xor t0, t0, t1
    srli t1, t1, 1
    xor t0, t0, t1
    srli t1, t1, 1
    xor t0, t0, t1
    andi t0, t0, 1
    slli t0, t0, 7
    srli t1, t1, 1
    or t1, t0, t1
    stw t1, LFSR(zero)
    slli t1, t1, 15
    addi t0, zero, 1
    slli t0, t0, 22
    add t1, t0, t1
;	addi t1, zero, 20 ;SpendTIME REMOVE PLEASE AT QUARTUS

spend_time_loop:
    addi   t1, t1, -1
    bne    t1, zero, spend_time_loop
    
    call flip_leds
    ldw ra, 0(sp)
    addi sp, sp, 4

    ret

; v0 = a0 / a1
; v1 = a0 % a1
divide:
    add    v0, zero, zero
divide_body:
    add    v1, a0, zero
    blt    a0, a1, end
    sub    a0, a0, a1
    addi   v0, v0, 1
    br     divide_body
end:
    ret



font_data:
    .word 0x7E427E00 ; 0
    .word 0x407E4400 ; 1
    .word 0x4E4A7A00 ; 2
    .word 0x7E4A4200 ; 3
    .word 0x7E080E00 ; 4
    .word 0x7A4A4E00 ; 5
    .word 0x7A4A7E00 ; 6
    .word 0x7E020600 ; 7
    .word 0x7E4A7E00 ; 8
    .word 0x7E4A4E00 ; 9
    .word 0x7E127E00 ; A
    .word 0x344A7E00 ; B
    .word 0x42423C00 ; C
    .word 0x3C427E00 ; D
    .word 0x424A7E00 ; E
    .word 0x020A7E00 ; F
