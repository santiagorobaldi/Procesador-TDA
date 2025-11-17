		.data
h:	.word	0x463B
		.code
		daddi r1, r0, 0x1234
		pushh r1
		poph r2
		daddi r5, r0, 0x1111
		halt
	