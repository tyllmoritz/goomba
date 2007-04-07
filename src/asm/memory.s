	.section ".iwram"
	.subsection 2
 .align
 .pool

	.global void
	.global empty_R
	.global empty_W
	.global mem_R00
	.global mem_R20
	.global mem_R40
	.global mem_R60
	.global mem_R80
	.global mem_RA0
	.global mem_RC0
	.global mem_RC0_2
	.global sram_W
	.global sram_W2
	.global wram_W
	.global wram_W_2
	.global echo_W
	.global echo_R
	
	.global filler_
	.global copy_
@----------------------------------------------------------------------------
empty_R:		@read bad address (error)
@----------------------------------------------------------------------------
	.if DEBUG
		mov r0,addy
		mov r1,#0
		b debug_
	.endif

@	mov gb_flg,addy,lsr#8
@	mov pc,lr
void: @- - - - - - - - -empty function
	mov r0,#0xff	@is this good?
	mov pc,lr
@----------------------------------------------------------------------------
empty_W:		@write bad address (error)
@----------------------------------------------------------------------------
	.if DEBUG
		mov r0,addy
		mov r1,#0
		b debug_
	.else
		mov pc,lr
	.endif
@----------------------------------------------------------------------------
mem_R00:	@rom read ($0000-$1FFF)
@----------------------------------------------------------------------------
	ldr_ r1,memmap_tbl
	ldrb r0,[r1,addy]
	mov pc,lr
@----------------------------------------------------------------------------
mem_R20:	@rom read ($2000-$3FFF)
@----------------------------------------------------------------------------
	ldr_ r1,memmap_tbl+8
	ldrb r0,[r1,addy]
	mov pc,lr
@----------------------------------------------------------------------------
mem_R40:	@rom read ($4000-$5FFF)
@----------------------------------------------------------------------------
	ldr_ r1,memmap_tbl+16
	ldrb r0,[r1,addy]
	mov pc,lr
@----------------------------------------------------------------------------
mem_R60:	@rom read ($6000-$7FFF)
@----------------------------------------------------------------------------
	ldr_ r1,memmap_tbl+24
	ldrb r0,[r1,addy]
	mov pc,lr
@----------------------------------------------------------------------------
mem_R80:	@vram read ($8000-$9FFF)
@----------------------------------------------------------------------------
	ldr_ r1,memmap_tbl+32
	ldrb r0,[r1,addy]
	mov pc,lr
@----------------------------------------------------------------------------
mem_RA0:	@sram read ($A000-$BFFF)
@----------------------------------------------------------------------------
	ldr_ r1,memmap_tbl+40
	ldrb r0,[r1,addy]
	mov pc,lr
@----------------------------------------------------------------------------
mem_RC0:	@ram read ($C000-$CFFF)
@----------------------------------------------------------------------------
	ldr_ r1,memmap_tbl+48
	ldrb r0,[r1,addy]
	mov pc,lr
@----------------------------------------------------------------------------
mem_RC0_2:	@ram read ($D000-$DFFF)
@----------------------------------------------------------------------------
	ldr_ r1,memmap_tbl+52
	ldrb r0,[r1,addy]
	mov pc,lr
@----------------------------------------------------------------------------
sram_W2:	@write to real sram ($A000-$BFFF)  AND emulated sram
@----------------------------------------------------------------------------
	orr r1,addy,#0xe000000	@r1=e00A000+
	add r1,r1,#0x4000		@r1=e00e000+
	strb r0,[r1]
@----------------------------------------------------------------------------
sram_W:	@sram write ($A000-$BFFF)
@----------------------------------------------------------------------------
	ldr_ r1,memmap_tbl+40
	strb r0,[r1,addy]
	mov pc,lr
@----------------------------------------------------------------------------
wram_W:	@wram write ($C000-$DFFF)
@----------------------------------------------------------------------------
	ldr_ r1,memmap_tbl+48
	strb r0,[r1,addy]
	mov pc,lr
@----------------------------------------------------------------------------
wram_W_2:	@wram write ($C000-$DFFF)
@----------------------------------------------------------------------------
	ldr_ r1,memmap_tbl+52
	strb r0,[r1,addy]
	mov pc,lr

echo_R:
	sub addy,addy,#0x2000
	tst addy,#0x1000
	beq mem_RC0
	b mem_RC0_2

echo_W:
	sub addy,addy,#0x2000
	tst addy,#0x1000
	beq wram_W
	b wram_W_2


@----------------------------------------------------------------------------
 .text
 .align
 .pool
filler_: @r0=data r1=dest r2=word count
@	exit with r0 unchanged
@----------------------------------------------------------------------------
	subs r2,r2,#1
	str r0,[r1,r2,lsl#2]
	bne filler_
	bx lr
@----------------------------------------------------------------------------
copy_:
	@r0=dest, r1=src, r2=count, addy=destroyed
	subs r2,r2,#1
	ldr addy,[r1,r2,lsl#2]
	str addy,[r0,r2,lsl#2]
	bne copy_
	bx lr

