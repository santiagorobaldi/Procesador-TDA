		.data
nombre:	.word	0x1234
		.code
		daddi r1, r0, 0x1234
		daddi r2, r0, 0x5678
		pushh r1
		pushh r2
		poph r3
		poph r4
		halt
		