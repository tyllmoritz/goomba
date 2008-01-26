	AREA wram_code2, CODE, READWRITE

	INCLUDE equates.h
	INCLUDE gbz80.h
	INCLUDE lcd.h

	EXPORT void
	EXPORT empty_R
	EXPORT empty_W
	EXPORT mem_R00
	EXPORT mem_R20
	EXPORT mem_R40
	EXPORT mem_R60
	EXPORT mem_R80
	EXPORT mem_RA0
	EXPORT mem_RC0
	EXPORT mem_RC0_2
	EXPORT sram_W
	EXPORT sram_W2
	EXPORT wram_W
	EXPORT wram_W_2
	EXPORT echo_W
	EXPORT echo_R
	
	EXPORT memset_
	EXPORT memcpy_
	EXPORT memset__
	EXPORT memcpy__
;----------------------------------------------------------------------------
empty_R		;read bad address (error)
;----------------------------------------------------------------------------
	[ DEBUG
		mov r0,addy
		mov r1,#0
		b debug_
	]

;	mov gb_flg,addy,lsr#8
;	mov pc,lr
void ;- - - - - - - - -empty function
	mov r0,#0xff	;is this good?
	mov pc,lr
;----------------------------------------------------------------------------
empty_W		;write bad address (error)
;----------------------------------------------------------------------------
	[ DEBUG
		mov r0,addy
		mov r1,#0
		b debug_
	|
		mov pc,lr
	]
;----------------------------------------------------------------------------
mem_R00	;rom read ($0000-$1FFF)
;----------------------------------------------------------------------------
	ldr r1,memmap_tbl
	ldrb r0,[r1,addy]
	mov pc,lr
;----------------------------------------------------------------------------
mem_R20	;rom read ($2000-$3FFF)
;----------------------------------------------------------------------------
	ldr r1,memmap_tbl+8
	ldrb r0,[r1,addy]
	mov pc,lr
;----------------------------------------------------------------------------
mem_R40	;rom read ($4000-$5FFF)
;----------------------------------------------------------------------------
	ldr r1,memmap_tbl+16
	ldrb r0,[r1,addy]
	mov pc,lr
;----------------------------------------------------------------------------
mem_R60	;rom read ($6000-$7FFF)
;----------------------------------------------------------------------------
	ldr r1,memmap_tbl+24
	ldrb r0,[r1,addy]
	mov pc,lr
;----------------------------------------------------------------------------
mem_R80	;vram read ($8000-$9FFF)
;----------------------------------------------------------------------------
	ldr r1,memmap_tbl+32
	ldrb r0,[r1,addy]
	mov pc,lr
;----------------------------------------------------------------------------
mem_RA0	;sram read ($A000-$BFFF)
;----------------------------------------------------------------------------
	ldr r1,memmap_tbl+40
	ldrb r0,[r1,addy]
	mov pc,lr
;----------------------------------------------------------------------------
mem_RC0	;ram read ($C000-$CFFF)
;----------------------------------------------------------------------------
	ldr r1,memmap_tbl+48
	ldrb r0,[r1,addy]
	mov pc,lr
;----------------------------------------------------------------------------
mem_RC0_2	;ram read ($D000-$DFFF)
;----------------------------------------------------------------------------
	ldr r1,memmap_tbl+52
	ldrb r0,[r1,addy]
	mov pc,lr
;----------------------------------------------------------------------------
sram_W2	;write to real sram ($A000-$BFFF)  AND emulated sram
;----------------------------------------------------------------------------
	orr r1,addy,#0xe000000	;r1=e00A000+
 [ SRAM_32
 	sub r1,r1,#0x4000   ;32k sram: A000>>6000
 | ;64k sram
	add r1,r1,#0x4000   ;64k sram: A000>>E000
 ]
	strb r0,[r1]
;----------------------------------------------------------------------------
sram_W	;sram write ($A000-$BFFF)
;----------------------------------------------------------------------------
	ldr r1,memmap_tbl+40
	strb r0,[r1,addy]
	mov pc,lr
;----------------------------------------------------------------------------
wram_W	;wram write ($C000-$CFFF)
;----------------------------------------------------------------------------
;	ldr r1,memmap_tbl+48
	adrl r1,xgb_ram-0xC000
	strb r0,[r1,addy]
	mov pc,lr
;----------------------------------------------------------------------------
wram_W_2	;wram write ($D000-$DFFF)
;----------------------------------------------------------------------------
	ldr r1,memmap_tbl+52
	strb r0,[r1,addy]
	mov pc,lr

echo_R
	sub addy,addy,#0x2000
	tst addy,#0x1000
	beq mem_RC0
	b mem_RC0_2

echo_W
	sub addy,addy,#0x2000
	tst addy,#0x1000
	beq wram_W
	b wram_W_2


memset__
;word aligned only
;r0 = dest, r1 = data, r2 = byte count
	subs r2,r2,#32
	blt %f2
	stmfd sp!,{r3-r9}
	mov r3,r1
	mov r4,r1
	mov r5,r1
	mov r6,r1
	mov r7,r1
	mov r8,r1
	mov r9,r1
0	
	stmia r0!,{r1,r3-r9}
	subs r2,r2,#32
	blt %f1
	stmia r0!,{r1,r3-r9}
	subs r2,r2,#32
	blt %f1
	stmia r0!,{r1,r3-r9}
	subs r2,r2,#32
	blt %f1
	stmia r0!,{r1,r3-r9}
	subs r2,r2,#32
	bge %b0
1
	ldmfd sp!,{r3-r9}
2
	adds r2,r2,#32
	bxeq lr
0
	str r1,[r0],#4
	subs r2,r2,#4
	bne %b0
	bx lr
memcpy__
;word aligned only
;r0=dest, r1=src, r2=byte count
	subs r2,r2,#32
	blt %f2
	stmfd sp!,{r3-r10}
0
	ldmia r1!,{r3-r10}
	stmia r0!,{r3-r10}
	subs r2,r2,#32
	blt %f1
	ldmia r1!,{r3-r10}
	stmia r0!,{r3-r10}
	subs r2,r2,#32
	blt %f1
	ldmia r1!,{r3-r10}
	stmia r0!,{r3-r10}
	subs r2,r2,#32
	blt %f1
	ldmia r1!,{r3-r10}
	stmia r0!,{r3-r10}
	subs r2,r2,#32
	bge %b0
1
	ldmfd sp!,{r3-r10}
2
	adds r2,r2,#32
	bxeq lr
0
	ldr r12,[r1],#4
	str r12,[r0],#4
	subs r2,r2,#4
	bne %b0
	bx lr

 AREA rom_code, CODE, READONLY
memset_
	b_long memset__
memcpy_
	b_long memcpy__
 
;filler_ ;r0=data r1=dest r2=word count
;;	exit with r0 unchanged
;;----------------------------------------------------------------------------
;	subs r2,r2,#1
;	str r0,[r1,r2,lsl#2]
;	bne filler_
;	bx lr
;;----------------------------------------------------------------------------
;copy_
;	;r0=dest, r1=src, r2=count, addy=destroyed
;	subs r2,r2,#1
;	ldr addy,[r1,r2,lsl#2]
;	str addy,[r0,r2,lsl#2]
;	bne copy_
;	bx lr

	END
