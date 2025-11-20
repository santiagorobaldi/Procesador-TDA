		.data
nombre:	.word	0x1234
		.code
		daddi r1, r0, 0x1234
		pushh r1
		pushh r1
		poph r2
		poph r3
		halt
		