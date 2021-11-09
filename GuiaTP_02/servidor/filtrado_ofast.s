	.arch armv7-a
	.eabi_attribute 28, 1
	.eabi_attribute 23, 1
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 2
	.eabi_attribute 30, 2
	.eabi_attribute 34, 1
	.eabi_attribute 18, 4
	.file	"filtrado.c"
	.text
	.global	__aeabi_idiv
	.align	1
	.p2align 2,,3
	.global	filtro
	.arch armv7-a
	.syntax unified
	.thumb
	.thumb_func
	.fpu vfpv3-d16
	.type	filtro, %function
filtro:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	cmp	r1, #1
	itt	gt
	addgt	r3, r1, #1073741824
	addgt	r3, r3, #-1
	push	{r4, lr}
	it	gt
	addgt	r3, r0, r3, lsl #2
	ble	.L6
.L5:
	ldr	r4, [r3, #-4]!
	cmp	r0, r3
	str	r4, [r3, #4]
	bne	.L5
.L6:
	cmp	r1, #0
	str	r2, [r0]
	it	le
	movle	r0, #0
	ble	.L1
	mov	r3, r0
	add	r4, r0, r1, lsl #2
	movs	r0, #0
.L7:
	ldr	r2, [r3], #4
	cmp	r4, r3
	add	r0, r0, r2
	bne	.L7
	bl	__aeabi_idiv(PLT)
.L1:
	pop	{r4, pc}
	.size	filtro, .-filtro
	.ident	"GCC: (Debian 8.3.0-6) 8.3.0"
	.section	.note.GNU-stack,"",%progbits
