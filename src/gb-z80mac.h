PSR_n EQU 0x80000000
PSR_Z EQU 0x40000000
PSR_C EQU 0x20000000
PSR_h EQU 0x10000000


Z EQU 2_10000000	;gb-Z80 flags
n EQU 2_01000000	;was the last opcode + or -
h EQU 2_00100000	;half carry
C EQU 2_00010000	;carry


	MACRO		;translate gb_pc from GB-Z80 PC to rom offset
	encodePC
	and r1,gb_pc,#0xe000
	adr r2,memmap_tbl
	ldr r0,[r2,r1,lsr#11]
	str r0,lastbank
	add gb_pc,gb_pc,r0
	MEND

	MACRO		;pack GB-Z80 flags into r0
	encodeFLG
	and r0,gb_flg,#0xA0000000	;nC
	and r1,gb_flg,#0x50000000	;Zh
	mov r1,r1,lsr#23
	orr r0,r1,r0,lsr#25		;N
	MEND

	MACRO		;unpack GB-Z80 flags from r0
	decodeFLG
	and gb_flg,r0,#0xA0		;Zh
	and r0,r0,#0x50			;nC
	mov r0,r0,lsl#25
	orr gb_flg,r0,gb_flg,lsl#23	;N
	MEND


	MACRO
	fetch $count
	subs cycles,cycles,#$count*CYCLE
	ldrplb r0,[gb_pc],#1
	ldrpl pc,[gb_optbl,r0,lsl#2]
	ldr pc,nexttimeout
	MEND

	MACRO
	readmemHL
	mov addy,gb_hl,lsr#16
	readmem
	MEND

	MACRO
	readmem
	and r1,addy,#0xE000
	adr r2,readmem_tbl
	adr lr,%F0
	ldr pc,[r2,r1,lsr#11]	;in: addy,r1=addy&0xE000 (for rom_R)
0				;out: r0=val (bits 8-31=0 ), addy preserved for RMW instructions
	MEND

	MACRO
	writememHL
	mov addy,gb_hl,lsr#16
	writemem
	MEND

	MACRO
	writemem
	and r1,addy,#0xE000
	adr r2,writemem_tbl
	adr lr,%F0
	ldr pc,[r2,r1,lsr#11]	;in: addy,r0=val(bits 8-31=?)
0				;out: r0,r1,r2,addy=?
	MEND

;----------------------------------------------------------------------------

;	MACRO
;	push16
;	str r0,[sp,#-4]!
;	ldr addy,gb_sp
;	sub addy,addy,#0x00020000
;	str addy,gb_sp
;	mov addy,addy,lsr#16
;	and r1,addy,#0xE000
;	adr r2,writemem_tbl
;	adr lr,%F0
;	and r0,r0,#0xff
;	ldr pc,[r2,r1,lsr#11]
;0
;	ldr r0,[sp],#4
;	ldr addy,gb_sp
;	add addy,addy,#0x00010000
;	mov addy,addy,lsr#16
;	and r1,addy,#0xE000
;	adr r2,writemem_tbl
;	adr lr,%F1
;	mov r0,r0,lsr#8
;	ldr pc,[r2,r1,lsr#11]
;1
;	MEND		;r1,r2=?

	MACRO
	push16		;push r0
	ldr addy,gb_sp
	sub addy,addy,#0x00020000
	str addy,gb_sp
	and r1,addy,#0xE0000000
	adr r2,memmap_tbl
	ldr r2,[r2,r1,lsr#27]
	strb r0,[r2,addy,lsr#16]
	add addy,addy,#0x00010000
	mov r0,r0,lsr#8
	strb r0,[r2,addy,lsr#16]

	cmp r1,#0x80000000	; just to solve some stupid games
	bleq vram_W2		; that use push16 to write to vram
	MEND		;r1,r2=?

	MACRO
	pop16 $x		;pop BC,DE,HL,PC
	ldr addy,gb_sp
	and r1,addy,#0xE0000000
	adr r2,memmap_tbl
	ldr r1,[r2,r1,lsr#27]
	ldrb $x,[r1,addy,lsr#16]
	add addy,addy,#0x00010000
	ldrb r0,[r1,addy,lsr#16]
	add addy,addy,#0x00010000
	str addy,gb_sp
	orr $x,$x,r0,lsl#8
	MEND		;r0,r1=?

	MACRO
	popAF			;pop AF
	ldr addy,gb_sp
	and r1,addy,#0xE0000000
	adr r2,memmap_tbl
	ldr r1,[r2,r1,lsr#27]
	ldrb r0,[r1,addy,lsr#16]
	add addy,addy,#0x00010000
	ldrb gb_a,[r1,addy,lsr#16]
	add addy,addy,#0x00010000
	str addy,gb_sp
	mov gb_a,gb_a,lsl#24
	MEND		;r0=flags,r1=?
;----------------------------------------------------------------------------

	MACRO
	opADC
	msr cpsr_f,gb_flg		;get C
	mov r1,#0x00FFFFFF
	orrcs r0,r0,r1
	eor r1,gb_a,r0			;prepare for check of half carry.
	adcs gb_a,gb_a,r0
	mrs gb_flg,cpsr          	;C & Z
	and gb_flg,gb_flg,#PSR_Z|PSR_C	;only keep C & Z
	eor r1,r1,gb_a
	tst r1,#0x10000000		;h, correct
	orrne gb_flg,gb_flg,#PSR_h
	MEND

	MACRO
	opADCH $x
	and r0,$x,#0xFF000000
	opADC
	MEND

	MACRO
	opADCL $x
	mov r0,$x,lsl#8
	opADC
	MEND

	MACRO
	opADCb $x
	mov r0,$x,lsl#24
	opADC
	MEND
;---------------------------------------

	MACRO
	opADD16 $x
	eor r1,gb_hl,$x
	and gb_flg,gb_flg,#PSR_Z	;save zero, clear n
	adds gb_hl,gb_hl,$x
	orrcs gb_flg,gb_flg,#PSR_C
	eor r1,r1,gb_hl
	tst r1,#0x10000000		;h, correct.
	orrne gb_flg,gb_flg,#PSR_h
	MEND
;---------------------------------------

	MACRO
	opADD $x,$y
	eor r1,gb_a,$x,lsl#$y
	adds gb_a,gb_a,$x,lsl#$y
	mrs gb_flg,cpsr          	;C & Z
	and gb_flg,gb_flg,#PSR_Z|PSR_C	;only keep C & Z
	eor r1,r1,gb_a
	tst r1,#0x10000000		;h, correct.
	orrne gb_flg,gb_flg,#PSR_h
	MEND

	MACRO
	opADDH $x
	opADD $x,0
	and gb_a,gb_a,#0xFF000000
	MEND

	MACRO
	opADDL $x
	opADD $x,8
	MEND

	MACRO
	opADDb $x
	opADD $x,24
	MEND
;---------------------------------------

	MACRO
	opAND $x,$y
	mov gb_flg,#PSR_h		;set h, clear C & n.
	ands gb_a,gb_a,$x,lsl#$y
	orreq gb_flg,gb_flg,#PSR_Z	;Z
	MEND

	MACRO
	opANDb $x
	opAND $x,24
	MEND

	MACRO
	opANDH $x
	opAND $x,0
	MEND

	MACRO
	opANDL $x
	opAND $x,8
	MEND
;---------------------------------------

	MACRO
	opBIT $x
	mov r0,r0,lsr#3
	and gb_flg,gb_flg,#PSR_C	;keep C
	tst $x,r1,lsl r0		;r0 0x08-0x0F
	orreq gb_flg,gb_flg,#PSR_Z	;Z
	orr gb_flg,gb_flg,#PSR_h	;set h
	MEND

	MACRO
	opBITH $x
	mov r1,#0x00010000
	opBIT $x
	MEND

	MACRO
	opBITL $x
	mov r1,#0x00000100
	opBIT $x
	MEND
;---------------------------------------

	MACRO
	opCP $x,$y
	eor r1,gb_a,$x,lsl#$y		;prepare for 
	subs r0,gb_a,$x,lsl#$y
	mrs gb_flg,cpsr          	;C & Z
	and gb_flg,gb_flg,#PSR_Z|PSR_C	;only keep C & Z
	eor gb_flg,gb_flg,#PSR_n|PSR_C	;invert C and set n.
	eor r1,r1,r0
	tst r1,#0x10000000		;h, correct
	orrne gb_flg,gb_flg,#PSR_h
	MEND

	MACRO
	opCPb $x
	opCP $x,24
	MEND

	MACRO
	opCPH $x
	and r0,$x,#0xFF000000
	opCP r0,0
	MEND

	MACRO
	opCPL $x
	opCP $x,8
	MEND
;---------------------------------------

	MACRO
	opDEC16 $x
	sub $x,$x,#0x00010000
	MEND

	MACRO
	opDEC8H $x
	and gb_flg,gb_flg,#PSR_C	;save carry
	orr gb_flg,gb_flg,#PSR_n	;set n
	sub $x,$x,#0x01000000
	tst $x,#0xff000000		;Z
	orreq gb_flg,gb_flg,#PSR_Z
	and r1,$x,#0x0f000000
	teq r1,#0x0f000000		;h
	orreq gb_flg,gb_flg,#PSR_h
	MEND

	MACRO
	opDEC8L $x
	mov $x,$x,ror#24
	opDEC8H $x
	mov $x,$x,ror#8
	MEND

	MACRO
	opINC16 $x
	add $x,$x,#0x00010000
	MEND

	MACRO
	opINC8H $x
	and gb_flg,gb_flg,#PSR_C	;save carry, clear n
	add $x,$x,#0x01000000
	tst $x,#0xff000000		;Z
	orreq gb_flg,gb_flg,#PSR_Z
	tst $x,#0x0f000000		;h
	orreq gb_flg,gb_flg,#PSR_h
	MEND

	MACRO
	opINC8L $x
	mov $x,$x,ror#24
	opINC8H $x
	mov $x,$x,ror#8
	MEND
;---------------------------------------

	MACRO
	opLDIM16
	ldrb r0,[gb_pc],#1
	ldrb r1,[gb_pc],#1
	orr r0,r0,r1,lsl#8
	MEND

	MACRO
	opLDIM8H $x
	ldrb r0,[gb_pc],#1
	and $x,$x,#0x00ff0000
	orr $x,$x,r0,lsl#24
	MEND

	MACRO
	opLDIM8L $x
	ldrb r0,[gb_pc],#1
	and $x,$x,#0xff000000
	orr $x,$x,r0,lsl#16
	MEND
;---------------------------------------

	MACRO
	opOR $x,$y
	mov gb_flg,#0			;clear flags.
	orrs gb_a,gb_a,$x,lsl#$y
	orreq gb_flg,gb_flg,#PSR_Z	;Z
	MEND

	MACRO
	opORH $x
	and r0,$x,#0xFF000000
	opOR r0,0
	MEND

	MACRO
	opORL $x
	opOR $x,8
	MEND

	MACRO
	opORb $x
	opOR $x,24
	MEND
;---------------------------------------

	MACRO
	opRES $x
	mov r0,r0,lsr#3
	bic $x,$x,r1,lsl r0		;r0 0x10-0x17
	MEND

	MACRO
	opRESH $x
	mov r1,#0x00000100
	opRES $x
	MEND

	MACRO
	opRESL $x
	mov r1,#0x00000001
	opRES $x
	MEND
;---------------------------------------

	MACRO
	opRL $x
	tst gb_flg,#PSR_C		;check C
	orrne $x,$x,#0x00800000
	adds $x,$x,$x
	mrs gb_flg,cpsr          	;C & Z
	and gb_flg,gb_flg,#PSR_Z|PSR_C	;only keep C & Z
	MEND

	MACRO
	opRLH $x
	and r0,$x,#0xFF000000
	and $x,$x,#0x00FF0000
	opRL r0
	orr $x,$x,r0
	MEND

	MACRO
	opRLL $x
	mov r0,$x,lsl#8
	and $x,$x,#0xFF000000
	opRL r0
	orr $x,$x,r0,lsr#8
	MEND
;---------------------------------------

	MACRO
	opRLC $x
	mov gb_flg,#0			;clear flags
	adds $x,$x,$x
	orrcs gb_flg,gb_flg,#PSR_C	;set C
	orrcss $x,$x,#0x01000000
	orreq gb_flg,gb_flg,#PSR_Z	;set Z
	MEND

	MACRO
	opRLCH $x
	and r0,$x,#0xFF000000
	and $x,$x,#0x00FF0000
	opRLC r0
	orr $x,$x,r0
	MEND

	MACRO
	opRLCL $x
	mov r0,$x,lsl#8
	and $x,$x,#0xFF000000
	opRLC r0
	orr $x,$x,r0,lsr#8
	MEND
;---------------------------------------

	MACRO
	opRR $x
	movs gb_flg,gb_flg,lsr#30	;get C, clear flags
	mov $x,$x,rrx
	tst $x,#0x00800000
	orrne gb_flg,gb_flg,#PSR_C
	ands $x,$x,#0xFF000000
	orreq gb_flg,gb_flg,#PSR_Z
	MEND

	MACRO
	opRRH $x
	and r0,$x,#0xFF000000
	and $x,$x,#0x00FF0000
	opRR r0
	orr $x,$x,r0
	MEND

	MACRO
	opRRL $x
	mov r0,$x,lsl#8
	and $x,$x,#0xFF000000
	opRR r0
	orr $x,$x,r0,lsr#8
	MEND
;---------------------------------------

	MACRO
	opRRC $x,$y
	mov gb_flg,#0			;clear flags
	movs $x,$x,lsr#$y
	orrcs gb_flg,gb_flg,#PSR_C	;set C
	orrcss $x,$x,#0x00000080
	orreq gb_flg,gb_flg,#PSR_Z	;set Z
	MEND

	MACRO
	opRRCH $x
	and r0,$x,#0xFF000000
	and $x,$x,#0x00FF0000
	opRRC r0,25
	orr $x,$x,r0,lsl#24
	MEND

	MACRO
	opRRCL $x
	and r0,$x,#0x00FF0000
	and $x,$x,#0xFF000000
	opRRC r0,17
	orr $x,$x,r0,lsl#16
	MEND

	MACRO
	opRRCb $x
	opRRC r0,1
	MEND
;---------------------------------------

	MACRO
	opSET $x
	mov r0,r0,lsr#3
	and r0,r0,#7
	orr $x,$x,r1,lsl r0		;r0 0-7
	MEND

	MACRO
	opSETH $x
	mov r1,#0x01000000
	opSET $x
	MEND

	MACRO
	opSETL $x
	mov r1,#0x00010000
	opSET $x
	MEND
;---------------------------------------


	MACRO
	opSBC
	eor gb_flg,gb_flg,#PSR_C	;invert C.
	movs gb_flg,gb_flg,lsr#30	;get C, clear flags.
	eor r1,gb_a,r0			;prepare for check of half carry.
	sbcs gb_a,gb_a,r0
	orrcs gb_flg,gb_flg,#PSR_C	;C
	eor gb_flg,gb_flg,#PSR_n|PSR_C	;invert C and set n.
	ands gb_a,gb_a,#0xFF000000
	orreq gb_flg,gb_flg,#PSR_Z	;set Z
	eor r1,r1,gb_a
	tst r1,#0x10000000		;h, correct
	orrne gb_flg,gb_flg,#PSR_h
	MEND

	MACRO
	opSBCH $x
	and r0,$x,#0xFF000000
	opSBC
	MEND

	MACRO
	opSBCL $x
	mov r0,$x,lsl#8
	opSBC
	MEND
;---------------------------------------

	MACRO
	opSLA $x
	adds $x,$x,$x
	mrs gb_flg,cpsr          	;C & Z
	and gb_flg,gb_flg,#PSR_Z|PSR_C	;only keep C & Z
	MEND

	MACRO
	opSLAH $x
	and r0,$x,#0xFF000000
	and $x,$x,#0x00FF0000
	opSLA r0
	orr $x,$x,r0
	MEND

	MACRO
	opSLAL $x
	mov r0,$x,lsl#8
	and $x,$x,#0xFF000000
	opSLA r0
	orr $x,$x,r0,lsr#8
	MEND

	MACRO
	opSLAb $x
	mov r0,$x,lsl#24
	opSLA r0
	mov $x,r0,lsr#24
	MEND
;---------------------------------------

	MACRO
	opSRAx $x
	movs $x,$x,asr#25
	mrs gb_flg,cpsr          	;C & Z
	and gb_flg,gb_flg,#PSR_Z|PSR_C	;only keep C & Z
	MEND

	MACRO
	opSRA $x
	opSRAx $x
	mov $x,$x,lsl#24
	MEND

	MACRO
	opSRAH $x
	and r0,$x,#0xFF000000
	and $x,$x,#0x00FF0000
	opSRAx r0
	orr $x,$x,r0,lsl#24
	MEND

	MACRO
	opSRAL $x
	mov r0,$x,lsl#8
	and $x,$x,#0xFF000000
	opSRAx r0
	and r0,r0,#0xff
	orr $x,$x,r0,lsl#16
	MEND

	MACRO
	opSRAb $x
	mov $x,$x,lsl#24
	opSRAx $x
	and $x,$x,#0xff
	MEND
;---------------------------------------

	MACRO
	opSRLx $x,$y,$z
	movs $y,$x,lsr#$z
	mrs gb_flg,cpsr          	;C & Z
	and gb_flg,gb_flg,#PSR_Z|PSR_C	;only keep C & Z
	MEND

	MACRO
	opSRL $x
	opSRLx $x,$x,25
	mov $x,$x,lsl#24
	MEND

	MACRO
	opSRLH $x
	opSRLx $x,r0,25
	and $x,$x,#0x00FF0000
	orr $x,$x,r0,lsl#24
	MEND

	MACRO
	opSRLL $x
	and r0,$x,#0x00FF0000
	and $x,$x,#0xFF000000
	opSRLx r0,r0,17
	orr $x,$x,r0,lsl#16
	MEND
;---------------------------------------

	MACRO
	opSUB $x,$y
	eor r1,gb_a,$x,lsl#$y
	subs gb_a,gb_a,$x,lsl#$y
	mrs gb_flg,cpsr          	;C & Z
	and gb_flg,gb_flg,#PSR_Z|PSR_C	;only keep C & Z
	eor gb_flg,gb_flg,#PSR_n|PSR_C	;invert C and set n.
	eor r1,r1,gb_a
	tst r1,#0x10000000		;h, correct
	orrne gb_flg,gb_flg,#PSR_h
	MEND

	MACRO
	opSUBH $x
	and r0,$x,#0xFF000000
	opSUB r0,0
	MEND

	MACRO
	opSUBL $x
	opSUB $x,8
	MEND

	MACRO
	opSUBb $x
	opSUB $x,24
	MEND
;---------------------------------------
	MACRO
	opSWAP $x
	mov $x,$x,ror#28
	orr $x,$x,$x,lsl#24
	ands $x,$x,#0xFF000000
	mrs gb_flg,cpsr          	;Z
	and gb_flg,gb_flg,#PSR_Z	;only keep Z
	MEND

	MACRO
	opSWAPL $x
	and r0,$x,#0x00FF0000	;mask low to r0
	eor $x,$x,r0		;mask out high
	mov r0,r0,ror#20
	orr r0,r0,r0,lsl#24
	ands r0,r0,#0xFF000000
	mrs gb_flg,cpsr          	;Z
	and gb_flg,gb_flg,#PSR_Z	;only keep Z
	orr $x,$x,r0,lsr#8
	MEND

	MACRO
	opSWAPH $x
	and r0,$x,#0xFF000000	;mask high to r0
	eor $x,$x,r0		;mask out low
	opSWAP r0
	orr $x,$x,r0
	MEND
;---------------------------------------

	MACRO
	opXOR $x,$y
	mov gb_flg,#0			;clear flags.
	eors gb_a,gb_a,$x,lsl#$y
	orreq gb_flg,gb_flg,#PSR_Z	;Z
	MEND

	MACRO
	opXORb $x
	opXOR $x,24
	MEND

	MACRO
	opXORH $x
	and r0,$x,#0xFF000000
	opXOR r0,0
	MEND

	MACRO
	opXORL $x
	opXOR $x,8
	MEND
;---------------------------------------
	END
