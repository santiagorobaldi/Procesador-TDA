		.data
A:	.hword	3769
B:	.hword	7867
SUMA:	.hword	0
MAYOR:	.hword	0
MENOR:	.hword	0
		.code
		lh r1, A(r0)
		lh r2, B(r0)
		slt r5, r1, r2
		andi r5, r5, 1
		bnez r5, Amenor
Bmenor:		daddi r10, r2, 0
		daddi r11, r1, 0
		jmp seguir
Amenor:		daddi r10, r1, 0
		daddi r11, r2, 0
seguir:		dadd r3, r1, r2
		pushh r3 ; lo pusheo
		andi r4, r3, 1
		beqz r4, ESPAR
IMPAR:		pushh r10
		pushh r11
		jmp incizoh
ESPAR:		pushh r11 
		pushh r10
incizoh:	lh r6, 4(sp)
		sh r6, SUMA(r0)
		lh r7, 2(sp)
		lh r8, 0(sp)
		slt r9, r7, r8
		andi r9, r9, 1 	
		bnez r9, sietemnr
		sh r7, MAYOR(r0)
		sh r8, MENOR(r0)
		jmp incizoi
sietemnr:	sh r8, MAYOR(r0)
		sh r7, MENOR(r0)
incizoi:	beqz r4, ESPARP
		daddi r12, r0, 1 
		sh r12, 4(sp)
		poph r11
		poph r10
		jmp fin
ESPARP:		sh r0, 4(sp)
		poph r10
		poph r11
fin:		poph r3
		halt
	