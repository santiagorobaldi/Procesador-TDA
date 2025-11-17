		.data
h:	.word	0x463B
		.code
		daddi r1, r0, 0x1234
		pushh r1
		nop
		nop
		nop
		poph r2
		halt
	