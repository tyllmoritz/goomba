	INCLUDE equates.h
	INCLUDE mappers.h
	INCLUDE memory.h
	INCLUDE gbz80mac.h
	INCLUDE gbz80.h
	INCLUDE lcd.h
	INCLUDE io.h

	IMPORT findrom ;from main.c

	EXPORT loadcart
;	EXPORT mapBIOS_
	EXPORT map0123_
	EXPORT map4567_
	EXPORT map01234567_
	EXPORT mapAB_
	EXPORT savestate
	EXPORT loadstate
	EXPORT g_emuflags
	EXPORT romstart
	EXPORT romnum
	EXPORT g_cartflags
;----------------------------------------------------------------------------
 AREA rom_code, CODE, READONLY
;----------------------------------------------------------------------------

mappertbl
	DCD 0x00,mbc0init
	DCD 0x01,mbc1init
	DCD 0x02,mbc1init
	DCD 0x03,mbc1init
	DCD 0x05,mbc2init
	DCD 0x06,mbc2init
	DCD 0x08,mbc0init
	DCD 0x09,mbc0init
	DCD 0x0B,mmm01init
	DCD 0x0C,mmm01init
	DCD 0x0D,mmm01init
	DCD 0x0F,mbc3init
	DCD 0x10,mbc3init
	DCD 0x11,mbc3init
	DCD 0x12,mbc3init
	DCD 0x13,mbc3init
	DCD 0x15,mbc4init
	DCD 0x16,mbc4init
	DCD 0x17,mbc4init
	DCD 0x19,mbc5init
	DCD 0x1A,mbc5init
	DCD 0x1B,mbc5init
	DCD 0x1C,mbc5init
	DCD 0x1D,mbc5init
	DCD 0x1E,mbc5init
	DCD 0x22,mbc7init

;	DCD 0xFC,camerainit
;	DCD 0xFD,tama5init
	DCD 0xFE,huc3init
	DCD 0xFF,huc1init
;	DCD 0x00,mbc6init
	DCD -1,mbc0init
mbcflagstbl
	DCB 0
	DCB 0
	DCB MBC_RAM
	DCB MBC_RAM|MBC_SAV
	DCB 0
	DCB 0
	DCB MBC_SAV
	DCB 0
	DCB MBC_RAM			;0x08
	DCB MBC_RAM|MBC_SAV
	DCB 0
	DCB 0
	DCB MBC_RAM
	DCB MBC_RAM|MBC_SAV
	DCB 0
	DCB MBC_TIM			;MBC_SAV
	DCB MBC_TIM+MBC_RAM+MBC_SAV	;0x10
	DCB 0
	DCB MBC_RAM
	DCB MBC_RAM|MBC_SAV
	DCB 0
	DCB 0
	DCB MBC_RAM
	DCB MBC_RAM|MBC_SAV
	DCB 0				;0x18
	DCB 0
	DCB MBC_RAM
	DCB MBC_RAM|MBC_SAV
	DCB MBC_RUM
	DCB MBC_RUM|MBC_RAM
	DCB MBC_RUM+MBC_RAM+MBC_SAV
	DCB 0
	DCB 0				;0x20
	DCB 0
	DCB MBC_RAM|MBC_SAV
	DCB 0
;----------------------------------------------------------------------------
loadcart ;called from C:  r0=rom number, r1=emuflags, r2=clearvram
;----------------------------------------------------------------------------
	stmfd sp!,{r0-r1,r4-r11,lr}

	mov r4,r2
	ldr r1,=findrom
	bl thumbcall_r1

	ldr globalptr,=|wram_globals0$$Base|	;need ptr regs init'd
	ldr gb_zpage,=XGB_RAM

	mov r3,r0		;r0 now points to rom image
	str r3,rombase		;set rom base
				;r3=rombase til end of loadcart so DON'T FUCK IT UP

	;clear vram/sram?
	tst r4,#0xff
	beq lc2

	mov r0,#0
	ldr r1,=XGB_VRAM
	mov r2,#0xA000/4
	bl filler_		;clear GB SRAM+VRAM
lc2

	ldr r1,=AGB_VRAM+0x4000	;clear AGB Tiles
	mov r2,#0x8000/4
	bl filler_

	ldr r0,=0x01000100
	ldr r1,=AGB_BG		;clear AGB BG (GB Window sides)
	mov r2,#0x4000/4
	bl filler_

	ldmfd sp!,{r0-r1}
	str r0,romnumber
        str r1,emuflags

	mov r2,#0x8000
	ldrb r1,[r3,#0x148]	;get size in 32kByte chunks.
	mov r1,r2,lsl r1
	sub r1,r1,#1
	str r1,rommask		;rommask=romsize-1

	ldrb r0,[r3,#0x149]	;get ram size.
	adr r1,rammasktbl
	ldr r0,[r1,r0,lsl#2]
	str r0,rammask
	

	mov r0,#0		;default ROM mapping
	bl map0123_		;0123=1st 16k
	mov r0,#1
	bl map4567_		;4567=2nd 16k

;	bl FixRealBios
;	bl mapBIOS_		;01=BIOS

	ldrb r0,[r3,#0x147]	;get mbc#
	cmp r0,#0xFF		;HuC-1
	moveq r0,#3
	adr r1,mbcflagstbl
	ldrb r0,[r1,r0]		;get mbc flags.
	tst r3,#0x08000000
	biceq r0,r0,#MBC_SAV	;don't use true SRAM if not running from a flash cart
	strb r0,cartflags	;set cartflags
	ldr r1,=empty_W
	tst r0,#MBC_RAM
	ldrne r1,=sram_W
	tst r0,#MBC_SAV
	ldrne r1,=sram_W2
	str r1,sramwptr

	ldr r0,=default_scanlinehook
	str r0,scanlinehook	;no mapper irq

	mov r0,#0xe0		;was 0xe0
	mov r1,#AGB_OAM
	mov r2,#0x100
	bl filler_		;no stray sprites please
	ldr r1,=OAM_BUFFER1
	mov r2,#0x180
	bl filler_

	mov r0,#0		;clear gb ram+hram
	mov r1,gb_zpage
	mov r2,#0x2080/4
	bl filler_
	ldr r1,=mapperstate	;clear mapperdata so we don't have to do that in every MapperInit.
	mov r2,#32/4
	bl filler_

	ldr r0,=joy0_W
	ldr r1,=joypad_write_ptr
	str r0,[r1]		;reset FF00 write (SGB messes with it)

;	ldr r1,=sram_W2		;could be used for RTC?
;	ldr r1,=empty_W		;could be used for RTC?
	ldr r1,sramwptr		;could be used for RTC?
	str r1,writemem_tbl+20
	ldr r1,=XGB_VRAM-0x8000
	str r1,memmap_tbl+16
	ldr r1,=XGB_SRAM-0xA000
	str r1,memmap_tbl+20
	ldr r1,=XGB_RAM-0xC000
	str r1,memmap_tbl+24
	ldr r1,=XGB_HRAM-0xFF80
	str r1,memmap_tbl+28

	mov gb_pc,#0		;(eliminates any encodePC errors during mapper*init)
	str gb_pc,lastbank

	ldrb r0,[r3,#0x147]	;get mapper#
				;lookup mapper*init
	adr r1,mappertbl
lc0	ldr r2,[r1],#8
	teq r2,r0
	beq lc1
	bpl lc0
lc1				;call mapper*init
	adr lr,%F0
	adr r5,writemem_tbl
	ldr r0,[r1,#-4]
	ldmia r0!,{r1-r4}
	stmia r5,{r1-r4}
	mov pc,r0		;Jump to MapperInit
0
	bl mirror1_		;(call after mapperinit to allow mappers to set up cartflags first)

	bl emu_reset		;reset everything else
	ldmfd sp!,{r4-r11,lr}
	bx lr

;----------------------------------------------------------------------------
rammasktbl
	DCD 0x0000
	DCD 0x07FF
	DCD 0x1FFF
	DCD 0x7FFF
;----------------------------------------------------------------------------
FixRealBios;		r3=rombase
;----------------------------------------------------------------------------
	adr r2,DMGBIOS
	str r2,biosbase
	mov r1,#0x100
biosloop
	ldr r0,[r3,r1]
	str r0,[r2,r1]
	add r1,r1,#4
	cmp r1,#0x200
	bne biosloop
	bx lr
;----------------------------------------------------------------------------
savestate	;called from ui.c.
;int savestate(void): return size
;----------------------------------------------------------------------------
	stmfd sp!,{r4-r6,globalptr,lr}

	ldr globalptr,=|wram_globals0$$Base|

	ldr r2,rombase
	rsb r2,r2,#0			;adjust rom maps,etc so they aren't based on rombase
	bl fixromptrs			;(so savestates are valid after moving roms around)

	ldr r6,=STATEPTR			;r6=where to copy state (part 1)
	mov r0,#0			;r0 holds total size (return value)

	adr r4,savelst			;r4=list of stuff to copy
	mov r3,#(lstend-savelst)/8	;r3=items in list
ss1	ldr r2,[r4],#4				;r2=what to copy
	ldr r1,[r4],#4				;r1=how much to copy
	add r0,r0,r1
ss0	ldr r5,[r2],#4
	str r5,[r6],#4
	subs r1,r1,#4
	bne ss0
	subs r3,r3,#1
	bne ss1

	ldr r6,=STATEPTR2			;r6=where to copy state (part 2)

	adr r4,savelst2			;r4=list of stuff to copy
	mov r3,#(lstend2-savelst2)/8	;r3=items in list
ss12	ldr r2,[r4],#4				;r2=what to copy
	ldr r1,[r4],#4				;r1=how much to copy
	add r0,r0,r1
ss02	ldr r5,[r2],#4
	str r5,[r6],#4
	subs r1,r1,#4
	bne ss02
	subs r3,r3,#1
	bne ss12

	ldr r2,rombase
	bl fixromptrs

	ldr r1,=0xa000
	add r0,r0,r1

	ldmfd sp!,{r4-r6,globalptr,lr}
	bx lr

savelst
	DCD rominfo,4,XGB_RAM,0x2080
lstend

;already there
;DCD XGB_VRAM,0x2000,XGB_SRAM,0x8000

savelst2
	DCD GBOAM_BUFFER,0xA0,agb_pal,96
	DCD vram_map,64,agb_nt_map,16,mapperstate,32,rommap,16,cpustate,52,lcdstate,16
	DCD soundstate,4
lstend2

fixromptrs	;add r2 to some things
	adr r1,memmap_tbl
	ldmia r1,{r3-r6}
	add r3,r3,r2
	add r4,r4,r2
	add r5,r5,r2
	add r6,r6,r2
	stmia r1,{r3-r6}

	ldr r3,lastbank
	add r3,r3,r2
	str r3,lastbank

	ldr r3,cpuregs+6*4	;GB-Z80 PC
	add r3,r3,r2
	str r3,cpuregs+6*4

	mov pc,lr
;----------------------------------------------------------------------------
loadstate	;called from ui.c
;void loadstate(int rom#)	 (stateptr must be word aligned)
;----------------------------------------------------------------------------
	stmfd sp!,{r4-r7,globalptr,gb_zpage,lr}

	ldr r6,=STATEPTR		;r6=where state is at
	ldr globalptr,=|wram_globals0$$Base|
	ldr gb_zpage,=XGB_RAM

	ldr r1,[r6]		;emuflags
	mov r2,#0			;don't clear gb vram/sram
	bl loadcart		;cart init

	mov r0,#(lstend-savelst)/8	;read entire state (part 1)
	adr r4,savelst
ls1	ldr r2,[r4],#4
	ldr r1,[r4],#4
ls0	ldr r5,[r6],#4
	str r5,[r2],#4
	subs r1,r1,#4
	bne ls0
	subs r0,r0,#1
	bne ls1

	ldr r6,=STATEPTR2			;r6=where to copy state (part 2)

	mov r0,#(lstend2-savelst2)/8	;read entire state (part 2)
	adr r4,savelst2
ls12	ldr r2,[r4],#4
	ldr r1,[r4],#4
ls02	ldr r5,[r6],#4
	str r5,[r2],#4
	subs r1,r1,#4
	bne ls02
	subs r0,r0,#1
	bne ls12

	ldr r2,rombase		;adjust ptr shit (see savestate above)
	bl fixromptrs

	ldr r3,=XGB_VRAM	;init tiles+tilemaps
	mov r4,#0x8000
ls3	ldrb r0,[r3],#1
	mov addy,r4
	bl vram_W
	add r4,r4,#1
	tst r4,#0x2000
	beq ls3

	mov addy,#REG_BASE
	ldrb r0,sgcnt0_l_l
	strb r0,[addy,#REG_SGCNT_L]
	ldrb r0,sgcnt0_l_h
	strb r0,[addy,#REG_SGCNT_L+1]
	ldrb r0,sgcnt0_h_l
	strb r0,[addy,#REG_SGCNT_X]
	
	bl resetlcdregs

	ldmfd sp!,{r4-r7,globalptr,gb_zpage,lr}
	bx lr
;----------------------------------------------------------------------------
m0000	DCD 0x1a02,XGB_VRAM+0x1800,XGB_VRAM+0x1800,XGB_VRAM+0x1800,XGB_VRAM+0x1800
		DCD AGB_BG+0x0000,AGB_BG+0x0000,AGB_BG+0x0000,AGB_BG+0x0000

;----------------------------------------------------------------------------
DMGBIOS
;	INCBIN DMGBIOS.ROM
;	% 256

;----------------------------------------------------------------------------
 AREA wram_code4, CODE, READWRITE
;----------------------------------------------------------------------------
mirror1_
	ldr r0,=m0000
	stmfd sp!,{r0,r3-r5,lr}

	ldr r0,[sp],#4
	ldr r3,[r0],#4

	ldr r1,=vram_map+32
	ldmia r0!,{r2-r5}
	stmia r1,{r2-r5}
	ldr r1,=agb_nt_map
	ldmia r0!,{r2-r5}
	stmia r1,{r2-r5}
	ldmfd sp!,{r3-r5,pc}
;----------------------------------------------------------------------------
mapBIOS_
;----------------------------------------------------------------------------
	ldr r0,biosbase
	str r0,memmap_tbl
	b flush
;----------------------------------------------------------------------------
map0123_
;----------------------------------------------------------------------------
	ldr r1,rombase
	ldr r2,rommask
	and r0,r2,r0,lsl#14
	add r0,r1,r0
	str r0,memmap_tbl
	str r0,memmap_tbl+4
	b flush
;----------------------------------------------------------------------------
map4567_
;----------------------------------------------------------------------------
	ldr r1,rombase
	sub r1,r1,#0x4000
	ldr r2,rommask
	and r0,r2,r0,lsl#14
	add r0,r1,r0
	str r0,memmap_tbl+8
	str r0,memmap_tbl+12
flush		;update gb_pc & lastbank
	ldr r1,lastbank
	sub gb_pc,gb_pc,r1
	encodePC
	mov pc,lr
;----------------------------------------------------------------------------
map01234567_
;----------------------------------------------------------------------------
	ldr r1,rombase
	ldr r2,rommask
	and r0,r2,r0,lsl#15
	add r0,r1,r0
	str r0,memmap_tbl
	str r0,memmap_tbl+4
	str r0,memmap_tbl+8
	str r0,memmap_tbl+12
	b flush
;----------------------------------------------------------------------------
mapAB_
	ldr r1,=XGB_SRAM-0xA000
	ldr r2,rammask
	and r0,r2,r0,lsl#13
	add r0,r1,r0
	str r0,memmap_tbl+20
	b flush
;----------------------------------------------------------------------------
 AREA wram_globals2, CODE, READWRITE

soundstate
	DCB 0   ;soundcnt_l_l
	DCB 0	;soundcnt_l_h
	DCB 0	;soundcnt_h_l
	DCB 0	;soundcnt_h_h
mapperstate
	% 32	;mapperdata

	DCD 0	;sramwptr
biosstart
	DCD 0	;biosbase
romstart
	DCD 0	;rombase
romnum
	DCD 0	;romnumber
rominfo			;emuflags (for savestate/loadstate)
g_emuflags	DCB 0	;emuflags        (label this so UI.C can take a peek) see equates.h for bitfields
	% 3		;(sprite follow val)

	DCD 0	;rommask
	DCD 0	;rammask
g_cartflags
	DCB 0	;cartflags
;----------------------------------------------------------------------------
	END
