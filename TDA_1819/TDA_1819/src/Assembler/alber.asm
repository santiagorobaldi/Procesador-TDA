		.data
A:	.hword	0x4005
		.code
		daddi r1, r0, 10
		daddi r2, r0, 20
		daddi r3, r0, 30
		nop
		pushh r1
		pushh r2
		pushh r3
		jmp seguir
seguir:		nop
		poph r1
		poph r2
		poph r3
		nop
		halt
	