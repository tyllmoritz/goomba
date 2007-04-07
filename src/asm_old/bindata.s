	AREA rom_code, CODE, READONLY
	ENTRY

	INCLUDE equates.h

	IMPORT |Image$$RO$$Base|
	IMPORT |Image$$RO$$Limit|
	IMPORT |Image$$RW$$Base|
	IMPORT |Image$$RW$$Limit|
	IMPORT |Image$$ZI$$Base|
	IMPORT |Image$$ZI$$Limit|

	IMPORT C_entry	;from main.c
	IMPORT textstart

	IMPORT max_multiboot_size ;from mbclient.c

	EXPORT font
	EXPORT fontpal
;------------------------------------------------------------
head
 	b __main

	DCB 36,255,174,81,105,154,162,33,61,132,130,10,132,228,9,173
	DCB 17,36,139,152,192,129,127,33,163,82,190,25,147,9,206,32
	DCB 16,70,74,74,248,39,49,236,88,199,232,51,130,227,206,191
	DCB 133,244,223,148,206,75,9,193,148,86,138,192,19,114,167,252
	DCB 159,132,77,115,163,202,154,97,88,151,163,39,252,3,152,118
	DCB 35,29,199,97,3,4,174,86,191,56,132,0,64,167,14,253
	DCB 255,82,254,3,111,149,48,241,151,251,192,133,96,214,128,37
	DCB 169,99,190,3,1,78,56,226,249,162,52,255,187,62,3,68
	DCB 120,0,144,203,136,17,58,148,101,192,124,99,135,240,60,175
	DCB 214,37,228,139,56,10,172,114,33,212,248,7
	DCB "GOOMBA COLOR"	;title
	DCB "GMBC"			;gamecode
	DCW 0				;maker
	DCB 0x96			;fixed value
	DCB 0				;unit code
	DCB 0x80			;device type
	DCB 0,0,0,0,0,0,0	;unused
	DCB 0				;version
	DCB 0x64			;complement check
	DCW 0				;unused
;----------------------------------------------------------
__main
;----------------------------------------------------------
	b %F0
	% 28			;multiboot struct. clock regs also?
0
	ldr sp,=0x3007F00			;set System Stack

	;set waitstates
	mov r0,#0x0014		;3/1 waitstate
	ldr r1,=REG_WAITCNT
	strh r0,[r1]
	
	;disable interrupts
	mov r0,#0
	ldr r2,=REG_BASE+REG_IME
	strh r0,[r2]
	
	;r1 = source address
	adr r1,head
	
	ldr r0,=|Image$$RO$$Base|
	ldr r3,=|Image$$RO$$Limit|
	sub r2,r3,r0
	bl memcopy
	
	ldr r0,=|Image$$RW$$Base|
	ldr r3,=|Image$$ZI$$Base|
	sub r2,r3,r0
	bl memcopy
	
	;r0 = |Image$$ZI$Base|
	ldr r3,=|Image$$ZI$$Limit|
	sub r2,r3,r0
	mov r3,#0
	bl memset
	
	;r1 = textstart if not in multiboot mode
	tst r1,#0x08000000
	bne %F1
	
	;multiboot mode - copy appended data to beginning of available EWRAM
	
	;test if rolimit is in ewram, if so use it
	ldr r0,=|Image$$RO$$Limit|
	and r2,r0,#0xFF000000
	cmp r2,#0x02000000
	
	;otherwise check if rwlimit is in ewram, if so use it
	ldrne r0,=|Image$$RW$$Limit|
	andne r2,r0,#0xFF000000
	cmpne r2,#0x02000000
	
	;otherwise all ewram is free, use base as append address
	movne r0,#0x02000000
	ldr r2,=0x02040000
	sub r2,r2,r1 ;copy 256k - append location base
	
	stmfd sp!,{r0}
	bl memcopy
	ldmfd sp!,{r1}
1
	ldr r3,=textstart
	str r1,[r3]
	
	ldr r2,=(MULTIBOOT_LIMIT-0x2000000)	;how much free space is left?
	ldr r3,=max_multiboot_size
	str r2,[r3]

	ldr r1,=C_entry
	bx r1
;----------------------------------------------------------
memset
;r0 = dest
;r2 = size
;r3 = fill
0
	str r3,[r0],#4
	subs r2,r2,#4
	bgt %b0
	bx lr
memcopy
;in:
;r0 = dest
;r1 = src
;r2 = size
;out:
;r0 = dest+size
;r1 = src+size
;r2 = 0
	;src == dest?
	cmp r0,r1
	beq nocopy

 	;if already in rom, there's no multiboot support anyway,
 	;don't care if header is corrupt
 [ VERSION_IN_ROM
 |
	;Use headcopy if SRC = 0x08000000
	cmp r1,#0x08000000
	;Use headcopy because supercard corrupts the header
	bne noheadcopy
	stmfd sp!,{r1,r2,lr}
	adr r1,headcopy
	mov r2,#192
	bl memcopy
	ldmfd sp!,{r1,r2,lr}
	sub r2,r2,#192
	add r1,r1,#192
noheadcopy
 ]	
1
 	;fast memcopy using r4-r11
 	subs r2,r2,#32
 	ldmplia r1!,{r4-r11}
 	stmplia r0!,{r4-r11}
 	bpl %b1
 	adds r2,r2,#32
 	bxeq lr
2
	ldr r4,[r1],#4
	str r4,[r0],#4
	subs r2,r2,#4
	bgt %b2
 	bx lr
nocopy
	add r0,r0,r2
	add r1,r1,r2
	mov r2,#0
	bx lr



 [ VERSION_IN_ROM
 |
headcopy
	DCD 0xEA00002E			;b main
	DCB 36,255,174,81,105,154,162,33,61,132,130,10,132,228,9,173
	DCB 17,36,139,152,192,129,127,33,163,82,190,25,147,9,206,32
	DCB 16,70,74,74,248,39,49,236,88,199,232,51,130,227,206,191
	DCB 133,244,223,148,206,75,9,193,148,86,138,192,19,114,167,252
	DCB 159,132,77,115,163,202,154,97,88,151,163,39,252,3,152,118
	DCB 35,29,199,97,3,4,174,86,191,56,132,0,64,167,14,253
	DCB 255,82,254,3,111,149,48,241,151,251,192,133,96,214,128,37
	DCB 169,99,190,3,1,78,56,226,249,162,52,255,187,62,3,68
	DCB 120,0,144,203,136,17,58,148,101,192,124,99,135,240,60,175
	DCB 214,37,228,139,56,10,172,114,33,212,248,7
	DCB "GOOMBA COLOR"	;title
	DCB "GMBC"			;gamecode
	DCW 0				;maker
	DCB 0x96			;fixed value
	DCB 0				;unit code
	DCB 0x80			;device type
	DCB 0,0,0,0,0,0,0	;unused
	DCB 0				;version
	DCB 0x64			;complement check
	DCW 0				;unused
 ]
font
	INCBIN font.lz77
;	INCBIN font.bin
fontpal
	INCBIN fontpal.bin
	END
