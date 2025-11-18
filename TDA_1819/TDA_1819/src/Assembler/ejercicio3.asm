		.data
A:	.word	3769
B:	.word	7867
SUMA:	.word	0
MAYOR:	.word	0
MENOR:	.word	0
		.code
		lw r1, A(r0)
		lw r2, B(r0)
		slt r5, r1, r2
		bnez r5, Amenor
Bmenor:		daddi r10, r1, 0
		daddi r11, r2, 0
		jmp seguir
Amenor:		daddi r10, r2, 0
		daddi r11, r1, 0
seguir:		dadd r3, r1, r2
		pushh r3
		andi r4, r3, 1
		beqz r4, ESPAR
IMPAR:		pushh r10
		nop 
		nop
		nop
		pushh r11
		jmp segui
ESPAR:		pushh r11
		nop 
		nop
		nop
		pushh r10
segui:		nop
		nop
		nop
		lh r6, 4(sp)
		sw r6, SUMA(r0)
		lh r7, 2(sp)
		lh r8, 0(sp)
		slt r9, r7, r8 
		bnez r9, pri
		sw r7, MAYOR(r0)
		sw r8, MENOR(r0)
		jmp dale
pri:		sw r8, MAYOR(r0)
		sw r7, MENOR(r0)
dale:		beqz r4, ESPARP
		daddi r12, r0, 1
		sh r12, 4(sp)
		poph r11
		nop
		nop
		nop
		poph r10
		nop
		nop
		nop
		poph r3
		jmp fin
ESPARP:		sh r0, 4(sp)
		poph r10
		nop
		nop
		nop
		poph r11
		nop
		nop
		nop
		poph r3
fin:		nop
		nop
		nop
		halt
	