		.data
nombre:	.word	0x1234
		.code
		daddi r1, r0, 0x1234
		pushh r1
		nop
		nop
		nop
		pushh r1
		nop
		nop
		nop
		poph r4
		halt
		