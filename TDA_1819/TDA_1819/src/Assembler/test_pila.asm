		.data
nombre:	.word	0x1234
		.code
		daddi r1, r0, 0x1234
		pushh r1
		nop
		nop
		nop
		lh r2, 0(sp)
		daddi r3, r0, 0x9999
		sh r3, 0(sp)
		poph r4
		halt
		