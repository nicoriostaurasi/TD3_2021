	.arch armv7-a
	.eabi_attribute 28, 1
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 2
	.eabi_attribute 30, 6
	.eabi_attribute 34, 1
	.eabi_attribute 18, 4
	.file	"filtrado.c"
	.text
	.global	__aeabi_idiv
	.align	1
	.global	filtro
	.arch armv7-a
	.syntax unified
	.thumb
	.thumb_func
	.fpu vfpv3-d16
	.type	filtro, %function
filtro:
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #24
	add	r7, sp, #0
	str	r0, [r7, #12]
	str	r1, [r7, #8]
	str	r2, [r7, #4]
	movs	r3, #0
	str	r3, [r7, #20]
	movs	r3, #0
	str	r3, [r7, #16]
	b	.L2
.L3:
	ldr	r3, [r7, #16]
	adds	r3, r3, #1
	ldr	r2, [r7, #8]
	subs	r3, r2, r3
	add	r3, r3, #1073741824
	subs	r3, r3, #1
	lsls	r3, r3, #2
	ldr	r2, [r7, #12]
	add	r2, r2, r3
	ldr	r3, [r7, #16]
	adds	r3, r3, #1
	ldr	r1, [r7, #8]
	subs	r3, r1, r3
	lsls	r3, r3, #2
	ldr	r1, [r7, #12]
	add	r3, r3, r1
	ldr	r2, [r2]
	str	r2, [r3]
	ldr	r3, [r7, #16]
	adds	r3, r3, #1
	str	r3, [r7, #16]
.L2:
	ldr	r3, [r7, #8]
	subs	r3, r3, #1
	ldr	r2, [r7, #16]
	cmp	r2, r3
	blt	.L3
	ldr	r3, [r7, #12]
	ldr	r2, [r7, #4]
	str	r2, [r3]
	movs	r3, #0
	str	r3, [r7, #16]
	b	.L4
.L5:
	ldr	r3, [r7, #16]
	lsls	r3, r3, #2
	ldr	r2, [r7, #12]
	add	r3, r3, r2
	ldr	r3, [r3]
	ldr	r2, [r7, #20]
	add	r3, r3, r2
	str	r3, [r7, #20]
	ldr	r3, [r7, #16]
	adds	r3, r3, #1
	str	r3, [r7, #16]
.L4:
	ldr	r2, [r7, #16]
	ldr	r3, [r7, #8]
	cmp	r2, r3
	blt	.L5
	ldr	r1, [r7, #8]
	ldr	r0, [r7, #20]
	bl	__aeabi_idiv(PLT)
	mov	r3, r0
	str	r3, [r7, #20]
	ldr	r3, [r7, #20]
	mov	r0, r3
	adds	r7, r7, #24
	mov	sp, r7
	@ sp needed
	pop	{r7, pc}
	.size	filtro, .-filtro
	.ident	"GCC: (Debian 8.3.0-6) 8.3.0"
	.section	.note.GNU-stack,"",%progbits
