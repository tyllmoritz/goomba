	INCLUDE equates.h
	INCLUDE memory.h
	INCLUDE cart.h
	INCLUDE io.h
	INCLUDE gbz80.h
	INCLUDE sound.h
	INCLUDE mappers.h

	IMPORT RumbleInterrupt
	IMPORT StartRumbleComs
	IMPORT border_titles
	IMPORT gbpalettes

	EXPORT GFX_init
	EXPORT GFX_reset
	EXPORT FF40_R
	EXPORT FF40_W
	EXPORT FF41_R
	EXPORT FF41_W
	EXPORT FF42_R
	EXPORT FF42_W
	EXPORT FF43_R
	EXPORT FF43_W
	EXPORT FF44_R
	EXPORT FF45_R
	EXPORT FF45_W
	EXPORT FF47_R
	EXPORT FF47_W
	EXPORT FF48_R
	EXPORT FF48_W
	EXPORT FF49_R
	EXPORT FF49_W
	EXPORT FF4A_R
	EXPORT FF4A_W
	EXPORT FF4B_R
	EXPORT FF4B_W
	EXPORT vram_W
	EXPORT vram_W2
	EXPORT agb_nt_map
	EXPORT vram_map
;	EXPORT VRAM_chr
	EXPORT debug_
	EXPORT AGBinput
	EXPORT EMUinput
	EXPORT paletteinit
	EXPORT palettereload
	EXPORT palettepreview
	EXPORT PaletteTxAll
	EXPORT newframe
	EXPORT agb_pal
	EXPORT lcdstate
;	EXPORT writeBG
	EXPORT gammavalue
	EXPORT oambuffer
	EXPORT makeborder
	EXPORT bcolor
	EXPORT peasoup
	EXPORT grey
	EXPORT multi1
	EXPORT multi2
	EXPORT custompal
	EXPORT presetpal
	EXPORT dgbmaxpal
	EXPORT palettebank
	EXPORT resetlcdregs
	EXPORT fpsenabled
	EXPORT messageshow
	EXPORT messagetxt
	EXPORT FPSValue
	EXPORT vbldummy
	EXPORT vblankfptr
	EXPORT vblankinterrupt

 AREA rom_code, CODE, READONLY

;----------------------------------------------------------------------------
GBPalettes; RGB 24bit.

peasoup
;pea soup 
	DCB 175,203,70, 121,170,109, 34,111,95, 8,41,85 
	DCB 175,203,70, 121,170,109, 34,111,95, 8,41,85 
	DCB 175,203,70, 121,170,109, 34,111,95, 8,41,85 
	DCB 175,203,70, 121,170,109, 34,111,95, 8,41,85
peasoup_title
	DCB "Pea Soup"
	DCD 0, 0, 0, 0
grey
;grey
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
grey_title
	DCB "Grayscale", 0, 0, 0
	DCD 0, 0, 0
multi1
;multi1
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	DCB 0xEF,0xEF,0xFF, 0x5A,0x8C,0xE7, 0x18,0x4A,0x9C, 0x00,0x00,0x00
	DCB 0xFF,0xEF,0xEF, 0xEF,0x5A,0x63, 0xAD,0x10,0x18, 0x00,0x00,0x00
multi1_title
	DCB "Multi 1", 0
	DCD 0, 0, 0, 0
multi2
;multi2
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	DCB 0xE7,0xEF,0xD6, 0xC6,0xDE,0x8C, 0x6B,0x84,0x29, 0x00,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xEF,0x5A,0x63, 0xAD,0x10,0x18, 0x00,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0x5A,0x8C,0xE7, 0x18,0x4A,0x9C, 0x00,0x00,0x00
multi2_title
	DCB "Multi 2", 0
	DCD 0, 0, 0, 0

custompal
;Custom
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
custom_title
	DCB "Custom", 0, 0
	DCD 0, 0, 0, 0

presetpal
;Preset palette
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
preset_title
	DCB "Quasi-GBC Preset"
	DCD 0, 0

dgbmaxpal
;DGBMax palette
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
dgbmax_title
	DCB "DGBMax", 0, 0
	DCD 0, 0, 0, 0

calculatebuffer
	% 16*4	; space for gamma corrected customapl
	

;----------------------------------------------------------------------------
GFX_init	;(called from main.c) only need to call once
;----------------------------------------------------------------------------
	mov addy,lr

	mov r1,#0xffffff00			;build chr decode tbl
	ldr r2,=CHR_DECODE
ppi0	mov r0,#0
	tst r1,#0x01
	orrne r0,r0,#0x10000000
	tst r1,#0x02
	orrne r0,r0,#0x01000000
	tst r1,#0x04
	orrne r0,r0,#0x00100000
	tst r1,#0x08
	orrne r0,r0,#0x00010000
	tst r1,#0x10
	orrne r0,r0,#0x00001000
	tst r1,#0x20
	orrne r0,r0,#0x00000100
	tst r1,#0x40
	orrne r0,r0,#0x00000010
	tst r1,#0x80
	orrne r0,r0,#0x00000001
	str r0,[r2],#4
	adds r1,r1,#1
	bne ppi0

	mov r0,#0
	ldr r1,=AGB_VRAM+0x8000		;clear most of the AGB VRAM
	mov r2,#0x8000/4
	bl filler_

	ldr r1,=AGB_VRAM+0x2000		;clear tile 256
	mov r2,#0x8
	bl filler_

	ldr r1,=AGB_PALETTE			;clear some of the AGB Palette
	mov r2,#0x80/4
	bl filler_

	ldr r1,=DMA1BUFF			;clear DISPCNT+DMA1BUFF
	mov r2,#328/2
	bl filler_

	mov r1,#REG_BASE
	mov r0,#0x0008
	strh r0,[r1,#REG_DISPSTAT]	;vblank en

	mov r0,#8
	strh r0,[r1,#REG_BLDY]		;darkness setting for faded screens (bigger number=darker)
	ldr r0,=0x3F3F
	strh r0,[r1,#REG_WININ]		;WinIN0/1, BG0 not enable in Win0
	sub r0,r0,#2				;r0=0x3f3f
	strh r0,[r1,#REG_WINOUT]	;WinOUT0/1, Everything enabled outside Windows


	add r0,r1,#REG_BG0HOFS		;DMA0 always goes here
	str r0,[r1,#REG_DM0DAD]
	mov r0,#1					;1 word transfer
	strh r0,[r1,#REG_DM0CNT_L]
	ldr r0,=DMA0BUFF			;DMA0 src=
	str r0,[r1,#REG_DM0SAD]

	str r1,[r1,#REG_DM1DAD]		;DMA1 goes here
	mov r0,#1					;1 word transfer
	strh r0,[r1,#REG_DM1CNT_L]

	add r2,r1,#REG_IE
	mov r0,#-1
	strh r0,[r2,#2]		;stop pending interrupts
	ldr r0,=0x1081
	strh r0,[r2]		;key,vblank,serial interrupt enable
	mov r0,#1
	strh r0,[r2,#8]		;master irq enable

	ldr r1,=AGB_IRQVECT
	ldr r2,=irqhandler
	str r2,[r1]

	bx addy
;----------------------------------------------------------------------------
GFX_reset	;called with CPU reset
;----------------------------------------------------------------------------
	mov r0,#0
	strb r0,lcdstat		;flags off
	strb r0,scrollX
	strb r0,scrollY
	strb r0,windowX
	strb r0,windowY
	strb r0,lcdyc_r

	mov r0,#0x91
	strb r0,lcdctrl		;LCDC
	strb r0,ppuctrl1

	mov r1,#REG_BASE
	mov r0,#0x0000
	strh r0,[r1,#REG_BG3CNT]	;Border
	stmfd sp!,{addy,lr}
	bl makeborder
	bl paletteinit
	mov r0,#0xfc
	strb r0,gbpalette
	mov r0,#0xff
	strb r0,ob0palette
	strb r0,ob1palette
	bl resetlcdregs
	ldmfd sp!,{addy,lr}

	mov pc,lr
;----------------------------------------------------------------------------
resetlcdregs
;----------------------------------------------------------------------------
	str lr,[sp,#-4]!

	ldrb r0,lcdctrl
	bl FF40_W
	ldrb r0,lcdstat
	bl FF41_W
	ldrb r0,scrollY
	bl FF42_W
	ldrb r0,scrollX
	bl FF43_W
	ldrb r0,lcdyc_r
	bl FF45_W
	ldrb r0,windowY
	bl FF4A_W
	ldrb r0,windowX
	bl FF4B_W
	bl PaletteTxAll
	
	ldr pc,[sp],#4
;----------------------------------------------------------------------------
PaletteTxAll;		also called from UI.c
;----------------------------------------------------------------------------
	str lr,[sp,#-4]!
	ldrb r0,gbpalette
	bl FF47_W
	ldrb r0,ob0palette
	bl FF48_W
	ldrb r0,ob1palette
	bl FF49_W
	ldr lr,[sp],#4
	bx lr
;----------------------------------------------------------------------------
makeborder;		also called from UI.c
;----------------------------------------------------------------------------
	str r4,[sp,#-4]!
	ldr r0,bcolor
	ldr r1,=border_titles
	ldr r1,[r1]
	add r1,r1,r0,lsl#2
	ldr r0,[r1]
	; tiles
	add r0,r0,#24 ; 24 = title
	mov r4,r0
	add r0,r0,#4
	ldr r1,=0x06000000
	add r1,r1,#0x500
	swi 0x120000			;LZ77UnCompVram - r0 = src, r1 = dst
	; palette
	ldr r3,[r4]     ; load tiles size
	add r0,r4,r3    ; then add to step to next part
	ldr r1,=AGB_PALETTE
	add r1,r1,#0x1C0
	mov r3,#16
borderpal
	ldrh r2,[r0],#2
	strh r2,[r1],#2
	subs r3,r3,#1
	bne borderpal
	; screen map
	ldr r1,=0x06000000
	swi 0x120000			;LZ77UnCompVram - r0 = src, r1 = dst
	ldr r4,[sp],#4
	bx lr
;----------------------------------------------------------------------------
bcolor
	DCD 0 ;Border color
;----------------------------------------------------------------------------
paletteinit;	r0-r3 modified.
;called by ui.c:  void paletteinit(void)
;----------------------------------------------------------------------------
	stmfd sp!,{r6-r7,lr}
	ldr r0,=gbpalettes
	ldr r0,[r0]
	ldr r1,palettebank
	add r0,r0,r1,lsl#2
	ldr r7,[r0]
	ldr r6,=MAPPED_RGB
	bl palettecalculate
	ldmfd sp!,{r6-r7,lr}
	bx lr

;----------------------------------------------------------------------------
palettecalculate;	r0-r3 modified.
		;	reads palette from r7 and writes gamma corrected 32-bit
		;	almost agb compatible palette to r6
;----------------------------------------------------------------------------
	stmfd sp!,{r4-r7,lr}
	ldrb r1,gammavalue	;gamma value = 0 -> 4
	mov r4,#16
nomap					;map rrrrrrrrggggggggbbbbbbbb  ->  0bbbbbgggggrrrrr
	ldrb r0,[r7],#1		;Red ready
	bl gammaconvert
	mov r5,r0

	ldrb r0,[r7],#1		;Green ready
	bl gammaconvert
	orr r5,r5,r0,lsl#5

	ldrb r0,[r7],#1		;Blue ready
	bl gammaconvert
	orr r5,r5,r0,lsl#10

	str r5,[r6],#4
	subs r4,r4,#1
	bpl nomap

	ldmfd sp!,{r4-r7,lr}
	bx lr

;----------------------------------------------------------------------------
palettereload; r0-r3 modified
;called by ui.c:  void palettereload(void)
;----------------------------------------------------------------------------
	stmfd sp!,{r4-r9,lr}

	mov r8,#AGB_PALETTE		;palette transfer
	ldr addy,=agb_pal
	ldmia addy!,{r0-r7}
	stmia r8,{r0,r1}
	add r8,r8,#8
	stmia r8,{r2,r3}
	add r8,r8,#0x1f8

	ldmia addy!,{r0-r7}
	stmia r8,{r0,r1}
	add r8,r8,#32
	stmia r8,{r2,r3}

	ldmfd sp!,{r4-r9,lr}
	bx lr

;----------------------------------------------------------------------------
palettepreview;	r0-r3 modified.
;called by ui.c:  void palettepreview(void)
;----------------------------------------------------------------------------
	stmfd sp!,{r6-r7,lr}
	ldr r7,=custompal
	ldr r6,=calculatebuffer
	bl palettecalculate
	ldr r7,=AGB_PALETTE
	add r7,r7,#0x180
	add r7,r7,#2
	mov r1,#8
	mov r2,r7
	bl palettecopy
	mov r1,#8
	mov r7,r2
	add r7,r7,#0x20
	bl palettecopy
	ldmfd sp!,{r6-r7,lr}
	bx lr

palettecopy ;32-bit bgr to 16-bit bgr copy
	ldr r0,[r6],#4		;bgr palette
	strh r0,[r7],#2
	subs r1,r1,#1
	bne palettecopy
	bx lr

;----------------------------------------------------------------------------
gammaconvert;	takes value in r0(0-0xFF), gamma in r1(0-4),returns new value in r0=0x1F
;----------------------------------------------------------------------------
	rsb r2,r0,#0x100
	mul r3,r2,r2
	rsbs r2,r3,#0x10000
	rsb r3,r1,#4
	orr r0,r0,r0,lsl#8
	mul r2,r1,r2
	mla r0,r3,r0,r2
	mov r0,r0,lsr#13
	bx lr

;----------------------------------------------------------------------------
showfps_		;fps output, r0-r3=used.
;----------------------------------------------------------------------------
	ldrb r0,fpschk
	subs r0,r0,#1
	movmi r0,#59
	strb r0,fpschk
	bxpl lr					;End if not 60 frames has passed

	str lr,[sp,#-4]!
	ldr r1,=StartRumbleComs
	adr lr,ret_
	bx r1
ret_
	ldr lr,[sp],#4


	ldrb r0,fpsenabled
	tst r0,#1
	bxeq lr					;End if not enabled

	ldr r0,fpsvalue
	cmp r0,#0
	bxeq lr					;End if fps==0, to keep it from appearing in the menu
	mov r1,#0
	str r1,fpsvalue

	mov r1,#100
	swi 0x060000			;Division r0/r1, r0=result, r1=remainder.
	add r0,r0,#0x30
	strb r0,fpstext+5
	mov r0,r1
	mov r1,#10
	swi 0x060000			;Division r0/r1, r0=result, r1=remainder.
	add r0,r0,#0x30
	strb r0,fpstext+6
	add r1,r1,#0x30
	strb r1,fpstext+7
	

	adr r0,fpstext
	ldr r2,=DEBUGSCREEN
;	add r2,r2,r1,lsl#6
db1
	ldrb r1,[r0],#1
	orr r1,r1,#0x4100
	strh r1,[r2],#2
	tst r2,#15
	bne db1

	bx lr
;----------------------------------------------------------------------------
showmessage_		;message output, r0-r3=used.
;----------------------------------------------------------------------------

	ldrb r0,messageshow
	tst r0,#0xff
	bxeq lr					;End if not enabled

	sub r0,r0,#1
	strb r0,messageshow
	
	ldr r1,=DEBUGSCREEN ;and screen offset to draw to
	mov	r2,#19
	add r1,r1,r2,lsl#6

	;clear name
	mov r2,#0x4100
	orr r2,r2,#0x20
	mov r3,#32
pn2
	strh r2,[r1],#2
	subs r3,r3,#1
	bne pn2

	tst r0,#0xff ;if counter is zero, don't redraw the name
	bxeq lr

	ldr r1,=messagetxt

	ldr r2,=DEBUGSCREEN ;and screen offset to draw to
	mov	r3,#19
	add r2,r2,r3,lsl#6

	;center name
	add r2,r2,#32
	mov r0,r1
pn0
	sub r2,r2,#1
	ldrb r3,[r0],#1
	tst r3,#0xff
	bne pn0

	;make even
	bic r2,r2,#1

pn1
	ldrb r0,[r1],#1
	tst r0,#0xff
	beq pn1_end
	orr r0,r0,#0x4100
	strh r0,[r2],#2
	tst r2,#15
	b pn1

pn1_end

	bx lr
;----------------------------------------------------------------------------
debug_		;debug output, r0=val, r1=line, r2=used.
;----------------------------------------------------------------------------
 [ DEBUG
	ldr r2,=DEBUGSCREEN
	add r2,r2,r1,lsl#6
db0
	mov r0,r0,ror#28
	and r1,r0,#0x0f
	cmp r1,#9
	addhi r1,r1,#7
	add r1,r1,#0x30
	orr r1,r1,#0x4100
	strh r1,[r2],#2
	tst r2,#15
	bne db0
 ]
	bx lr
;----------------------------------------------------------------------------
palettebank	DCD 0
fpstext DCB "FPS:    "
fpsenabled DCB 0
fpschk	DCB 0
messagetxt % 32
messageshow DCB 0
gammavalue DCB 0
;----------------------------------------------------------------------------
	AREA wram_code1, CODE, READWRITE
irqhandler	;r0-r3,r12 are safe to use
;----------------------------------------------------------------------------
	mov r2,#REG_BASE
	mov r3,#REG_BASE
	ldr r1,[r2,#REG_IE]!
	and r1,r1,r1,lsr#16	;r1=IE&IF
	ldrh r0,[r3,#-8]
	orr r0,r0,r1
	strh r0,[r3,#-8]

		;---this CAN'T be interrupted
		ands r0,r1,#0x80
		strneh r0,[r2,#2]		;IF clear
		ldrne r12,serialfptr
		bxne r12
		;---
		adr r12,irq0

		;---this CAN be interrupted
		ands r0,r1,#0x01
		ldrne r12,vblankfptr
		;----
		moveq r0,r1				;if unknown interrupt occured clear it.
jmpintr
	strh r0,[r2,#2]				;IF clear

	mrs r3,spsr
	stmfd sp!,{r3,lr}
	mrs r3,cpsr
	bic r3,r3,#0x9f
	orr r3,r3,#0x1f				;--> Enable IRQ & FIQ. Set CPU mode to System.
	msr cpsr_cf,r3
	stmfd sp!,{lr}
	adr lr,irq0

	bx r12


irq0
	ldmfd sp!,{lr}
	mrs r3,cpsr
	bic r3,r3,#0x9f
	orr r3,r3,#0x92        		;--> Disable IRQ. Enable FIQ. Set CPU mode to IRQ
	msr cpsr_cf,r3
	ldmfd sp!,{r0,lr}
	msr spsr_cf,r0
vbldummy
	bx lr
;----------------------------------------------------------------------------
vblankfptr DCD vbldummy			;later switched to vblankinterrupt
;serialfptr DCD serialinterrupt
serialfptr DCD RumbleInterrupt
twitch DCD 0
vblankinterrupt;
;----------------------------------------------------------------------------
	stmfd sp!,{r4-r7,globalptr,lr}
	ldr globalptr,=|wram_globals0$$Base|

	bl showfps_
	bl showmessage_


	ldr r2,=DMA0BUFF			;setup DMA buffer for scrolling:
	add r3,r2,#160*8			;For both background and window
	ldr r1,dmascrollbuff
vbl6
	ldmia r1!,{r0,r4-r7}
	stmia r2!,{r0,r4-r7}
	cmp r2,r3
	bmi vbl6

	ldr r3,=DISPCNTBUFF
	ldr r4,=BG0CNTBUFF

	mov r1,#REG_BASE

	ldrb r0,windowYbuf
	ldrb r2,windowY
	strb r2,windowYbuf
	cmp r0,#0x98
	movpl r0,#0x98
	mov r2,#0x08A0				;end of window
	add r2,r2,r0,lsl#8
	strh r2,[r1,#REG_WIN0V]		;Win0Vertical, BG0 not enable in Win0
;	ldrb r0,windowXbuf
;	cmp r0,#0xA7
;	movpl r0,#0xA7
	mov r0,#7
	ldr r2,=0x21EF				;end of window
	add r2,r2,r0,lsl#8
	strh r2,[r1,#REG_WIN0H]		;Win0Horizontal, BG0 not enable in Win0

	strh r1,[r1,#REG_DM0CNT_H]	;DMA stop
	strh r1,[r1,#REG_DM1CNT_H]
	strh r1,[r1,#REG_DM3CNT_H]

	ldr r0,dmaoambuffer			;OAM transfer:
	str r0,[r1,#REG_DM3SAD]
	mov r0,#AGB_OAM
	str r0,[r1,#REG_DM3DAD]
	mov r0,#0x84000000			;noIRQ 32bit incsrc incdst
	orr r0,r0,#0x50				;80 words=40sprites, was 128 words,512 bytes,64sprites.
	str r0,[r1,#REG_DM3CNT_L]	;DMA go

;	ldr r0,=DMA0BUFF			;setup HBLANK DMA for display scroll:
	ldr r0,=0xA6600002			;noIRQ hblank 32bit repeat incsrc inc_reloaddst 2 words
	str r0,[r1,#REG_DM0CNT_L]	;DMA go
								;setup HBLANK DMA for DISPCNT (BG/OBJ enable)
	ldrh r2,[r3],#2
	strh r2,[r1,#REG_DISPCNT]	;set 1st value manually, HBL is AFTER 1st line
	str r3,[r1,#REG_DM1SAD]		;dmasrc=
	ldr r0,=0xA240				;noIRQ hblank 16bit repeat incsrc fixeddst
	strh r0,[r1,#REG_DM1CNT_H]	;DMA go
								;setup HBLANK DMA for BG CHR
	add r0,r1,#REG_BG0CNT
	str r0,[r1,#REG_DM3DAD]
	str r4,[r1,#REG_DM3SAD]
	ldr r0,=0xA6400001			;noIRQ hblank 32bit repeat incsrc fixeddst, 1 word transfer
	str r0,[r1,#REG_DM3CNT_L]	;DMA go

	ldmfd sp!,{r4-r7,globalptr,pc}

totalblend	DCD 0
;----------------------------------------------------------------------------
newframe	;called at line 0	(r0-r9 safe to use)
;----------------------------------------------------------------------------
	str lr,[sp,#-4]!

	bl OAMfinish
;-----------------------
	ldr r0,ctrl1old
	ldr r1,ctrl1line
	mov addy,#159
	ldr r3,chrold
	bl ctrl1finish
;------------------------
	ldr r0,scrollXold
	ldr r1,scrollXline
	mov addy,#159
	bl scrollXfinish
;--------------------------
	ldr r0,scrollYold
	ldr r1,scrollYline
	mov addy,#159
	bl scrollYfinish
;--------------------------
	ldr r0,windowXold
	ldr r1,windowXline
	mov addy,#159
	bl windowXfinish
;--------------------------
	ldr r0,windowYold
	ldr r1,windowYline
	mov addy,#159
	bl windowYfinish
;--------------------------
	mov r0,#0
	str r0,ctrl1line
	str r0,scrollXline
	str r0,scrollYline
	str r0,windowXline
	str r0,windowYline
;--------------------------

;	ldrb r2,windowX
;	strb r2,windowXbuf

	ldr r0,scrollbuff
	ldr r1,dmascrollbuff
	str r1,scrollbuff
	str r0,dmascrollbuff

	ldr r0,oambuffer
	str r0,dmaoambuffer

	mov r8,#AGB_PALETTE		;palette transfer
	adrl addy,agb_pal
nf8	ldmia addy!,{r0-r7}
	stmia r8,{r0,r1}
	add r8,r8,#8
	stmia r8,{r2,r3}
;	add r8,r8,#56
;	stmia r8,{r4,r5}
;	add r8,r8,#32
;	stmia r8,{r6,r7}
	add r8,r8,#0x1f8

	ldmia addy!,{r0-r7}
	stmia r8,{r0,r1}
	add r8,r8,#32
	stmia r8,{r2,r3}

;	tst r8,#0x200
;	subne r8,r8,#8
;	bne nf8			;(2nd pass: sprite pal)

	ldr pc,[sp],#4

;----------------------------------------------------------------------------
FF40_R;		LCD Control
;----------------------------------------------------------------------------
	ldrb r0,lcdctrl
	mov pc,lr
;----------------------------------------------------------------------------
FF40_W;		LCD Control
;----------------------------------------------------------------------------
	stmfd sp!,{r3,r4,lr}
	ldrb r1,lcdctrl
	strb r0,lcdctrl
	eor r1,r1,r0
	and r1,r1,r0
	tst r1,#0x80		;Is LCD turned on?
	ldrne addy,=line145_to_end
	strne addy,nexttimeout
	movne r1,#152
	strne r1,scanline

	ldr r1,=0xd8011b02
	tst r0,#0x10		;Which charset?
	addeq r1,r1,#0x00000004
	addeq r1,r1,#0x00040000
	tst r0,#0x08		;BG tilemap select?
	addne r1,r1,#0x00000400
	tst r0,#0x40		;WIN tilemap select?
	addne r1,r1,#0x04000000
	adr r2,chrold
	swp r3,r1,[r2]		;r3=lastval

	mov r1,#0x0C40		;1d sprites, BG2/3 enable. DISPCNTBUFF startvalue. 0x0440
	tst r0,#0x80		;LCD en?
	beq nodisp
	tst r0,#0x01		;bg en?
	orrne r1,r1,#0x0100
	tst r0,#0x20		;win en?
	orrne r1,r1,#0x2200	;GBA Win0 & GBA BG1
	tst r0,#0x02		;obj en?
	orrne r1,r1,#0x1000
nodisp
	adr r2,ctrl1old
	swp r0,r1,[r2]		;r0=lastval

	adr r2,ctrl1line
	ldr addy,scanline	;addy=scanline
	add addy,addy,#8	;GB display begins 8 pixels down (maybe 7 is good?).
	cmp addy,#159
	movhi addy,#159
	swp r1,addy,[r2]	;r1=lastline, lastline=scanline
	bl ctrl1finish
	ldmfd sp!,{r3,r4,pc}

ctrl1finish
	ldr r4,=BG0CNTBUFF
	ldr r2,=DISPCNTBUFF
	add r1,r2,r1,lsl#1
	add r2,r2,addy,lsl#1
	add r4,r4,addy,lsl#2
ct1	strh r0,[r2],#-2	;fill backwards from scanline to lastline
	str r3,[r4],#-4		;fill backwards from scanline to lastline
	cmp r2,r1
	bpl ct1

	mov pc,lr

chrold		DCD 0		;last write
ctrl1old	DCD 0x0C40	;last write
ctrl1line	DCD 0		;when?
;----------------------------------------------------------------------------
FF41_R;		LCD Status
;----------------------------------------------------------------------------
	ldrb r0,lcdstat
	ldr r1,scanline
	ldrb r2,lcdyc
	cmp r1,r2
	orreq r0,r0,#4		;scanline=LYC
	tst r0,#0x01		;in VBlank.
	movne pc,lr

	cmp cycles,#376*CYCLE
	orrpl r0,r0,#2		;in OAM access
	movpl pc,lr

	cmp cycles,#204*CYCLE
	orrpl r0,r0,#3		;in VRAM access
	mov pc,lr
;----------------------------------------------------------------------------
FF41_W;		LCD Status
;----------------------------------------------------------------------------
	ldrb r1,lcdstat
	and r1,r1,#0x01		;Save VBlank bit.
	and r0,r0,#0x78
	orr r0,r0,r1
	strb r0,lcdstat
	mov pc,lr
;----------------------------------------------------------------------------
FF42_R;		SCY - Scroll Y
;----------------------------------------------------------------------------
	ldrb r0,scrollY
	mov pc,lr
;----------------------------------------------------------------------------
FF42_W;		SCY - Scroll Y
;----------------------------------------------------------------------------
	strb r0,scrollY
	adr r1,scrollYold
	swp r0,r0,[r1]		;r0=lastval

	ldr addy,scanline	;addy=scanline
	add addy,addy,#8
	cmp addy,#159
	movhi addy,#159
	adr r2,scrollYline
	swp r1,addy,[r2]	;r1=lastline, lastline=scanline
scrollYfinish			;newframe jumps here
	sub r0,r0,#8
	ldr r2,scrollbuff
	add r2,r2,#2		;r2+=2, bg Y write
	add r1,r2,r1,lsl#3
	add r2,r2,addy,lsl#3
sy1	strh r0,[r2],#-8	;fill backwards from scanline to lastline
	cmp r2,r1
	bpl sy1
	mov pc,lr

scrollYold DCD 0 ;last write
scrollYline DCD 0 ;..was when?
;----------------------------------------------------------------------------
FF43_R;		SCX - Scroll X
;----------------------------------------------------------------------------
	ldrb r0,scrollX
	mov pc,lr
;----------------------------------------------------------------------------
FF43_W;		SCX - Scroll X
;----------------------------------------------------------------------------
	strb r0,scrollX
;	ldrb r0,scrollX
	adr r1,scrollXold
	swp r0,r0,[r1]		;r0=lastval

	adr r2,scrollXline
	ldr addy,scanline	;addy=scanline
	add addy,addy,#8
	cmp addy,#159
	movhi addy,#159
	swp r1,addy,[r2]	;r1=lastline, lastline=scanline
scrollXfinish			;newframe jumps here
	sub r0,r0,#40
	ldr r2,scrollbuff
;	add r2,r2,#0		;r2+=0, bg X write
	add r1,r2,r1,lsl#3
	add r2,r2,addy,lsl#3
sx1	strh r0,[r2],#-8	;fill backwards from scanline to lastline
	cmp r2,r1
	bpl sx1
	mov pc,lr

scrollXold DCD 0 ;last write
scrollXline DCD 0 ;..was when?
;----------------------------------------------------------------------------
FF44_R;		LCD Scanline
;----------------------------------------------------------------------------
	ldr r0,scanline
;	sub cycles,cycles,#23*CYCLE	;LCD hack?
	mov pc,lr
;----------------------------------------------------------------------------
FF45_R;		LCD Y Compare
;----------------------------------------------------------------------------
	ldrb r0,lcdyc_r
	mov pc,lr
;----------------------------------------------------------------------------
FF45_W;		LCD Y Compare
;----------------------------------------------------------------------------
	strb r0,lcdyc_r
	cmp r0,#0
	moveq r0,#153
	strb r0,lcdyc
	mov pc,lr
;----------------------------------------------------------------------------
FF47_R;		BGP - BG Palette Data
;----------------------------------------------------------------------------
	ldrb r0,gbpalette
	mov pc,lr
;----------------------------------------------------------------------------
FF47_W;		BGP - BG Palette Data
;----------------------------------------------------------------------------
	strb r0,gbpalette
	ldr r2,=agb_pal
	ldr addy,=MAPPED_RGB
	str lr,[sp,#-4]!
	bl dopalette
	ldr lr,[sp],#4
	
	ldr r2,=agb_pal+4*2
	ldr addy,=MAPPED_RGB+16
dopalette
	and r1,r0,#0x03
	ldr r1,[addy,r1,lsl#2]
	strh r1,[r2]		;store in agb palette
	and r1,r0,#0x0C
	ldr r1,[addy,r1]
	strh r1,[r2,#2]		;store in agb palette
	and r1,r0,#0x30
	ldr r1,[addy,r1,lsr#2]
	strh r1,[r2,#4]		;store in agb palette
	and r1,r0,#0xC0
	ldr r1,[addy,r1,lsr#4]
	strh r1,[r2,#6]		;store in agb palette

	mov pc,lr
;----------------------------------------------------------------------------
FF48_R;		OBP0 - OBJ 0 Palette Data
;----------------------------------------------------------------------------
	ldrb r0,ob0palette
	mov pc,lr
;----------------------------------------------------------------------------
FF48_W;		OBP0 - OBJ 0 Palette Data
;----------------------------------------------------------------------------
	strb r0,ob0palette
	ldr r2,=agb_pal+16*2
	ldr addy,=MAPPED_RGB+32
	b dopalette
;----------------------------------------------------------------------------
FF49_R;		OBP1 - OBJ 1 Palette Data
;----------------------------------------------------------------------------
	ldrb r0,ob1palette
	mov pc,lr
;----------------------------------------------------------------------------
FF49_W;		OBP1 - OBJ 1 Palette Data
;----------------------------------------------------------------------------
	strb r0,ob1palette
	ldr r2,=agb_pal+20*2
	ldr addy,=MAPPED_RGB+48
	b dopalette
;----------------------------------------------------------------------------
FF4A_R;		WINY - Window Y
;----------------------------------------------------------------------------
	ldrb r0,windowY
	mov pc,lr
;----------------------------------------------------------------------------
FF4A_W;		WINY - Window Y
;----------------------------------------------------------------------------
	strb r0,windowY
;	mov pc,lr
	adr r1,windowYold
	swp r0,r0,[r1]		;r0=lastval

	ldr addy,scanline	;addy=scanline
	add addy,addy,#8
	cmp addy,#159
	movhi addy,#159
	adr r2,windowYline
	swp r1,addy,[r2]	;r1=lastline, lastline=scanline
;-------------------------------
windowYfinish			;newframe jumps here
;wininitY			;NewFrame jumps here
	rsb r0,r0,#0
	sub r0,r0,#8
	ldr r2,scrollbuff
	add r2,r2,#6		;r2+=6, win Y write
	add r1,r2,r1,lsl#3	;r1=base
	add r2,r2,#160*8	;r2=end2
wy1
	strh r0,[r1],#8
	cmp r1,r2
	blo wy1
	mov pc,lr
windowYold DCD 0 ;last write
windowYline DCD 0 ;..was when?
;----------------------------------------------------------------------------
FF4B_R;		WINX - Window X
;----------------------------------------------------------------------------
	ldrb r0,windowX
	mov pc,lr
;----------------------------------------------------------------------------
FF4B_W;		WINX - Window X
;----------------------------------------------------------------------------
	and r0,r0,#0xff		;not needed?
	strb r0,windowX
	adr r1,windowXold
	swp r0,r0,[r1]		;r0=lastval

	adr r2,windowXline
	ldr addy,scanline	;addy=scanline
	add addy,addy,#8
	cmp addy,#159
	movhi addy,#159
	swp r1,addy,[r2]	;r1=lastline, lastline=scanline
windowXfinish			;newframe jumps here
	rsb r0,r0,#0
	sub r0,r0,#33		;window x-7
	ldr r2,scrollbuff
	add r2,r2,#4		;r2+=4, win X write
	add r1,r2,r1,lsl#3
	add r2,r2,addy,lsl#3
wx1	strh r0,[r2],#-8	;fill backwards from scanline to lastline
	cmp r2,r1
	bpl wx1
	mov pc,lr

windowXold DCD 0 ;last write
windowXline DCD 0 ;..was when?

;----------------------------------------------------------------------------
vram_W2
;----------------------------------------------------------------------------
	mov addy,addy,lsr#16
	cmp addy,#0x9800
	bpl VRAM_nameD
;----------------------------------------------------------------------------
vram_W
;----------------------------------------------------------------------------
	sub addy,addy,#0x8000
	ldr r2,=XGB_VRAM
	strb r0,[r2,addy]
	cmp addy,#0x1800
	bpl VRAM_name0
;----------------------------------------------------------------------------
;VRAM_chr;	8000-97FF
;----------------------------------------------------------------------------
	bic addy,addy,#1
	ldrb r0,[r2,addy]!	;read 1st plane
	ldrb r1,[r2,#1]		;read 2nd plane

	adr r2,chr_decode
	ldr r0,[r2,r0,lsl#2]
	ldr r1,[r2,r1,lsl#2]
	orr r0,r0,r1,lsl#1

	add addy,addy,addy

	mov r2,#AGB_VRAM		;AGB BG tileset
	tst addy,#0x2000
	addeq r1,r2,#0x10000	;0x06010000=OBJ
	streq r0,[r1,addy]		;OBJ
	addne r2,r2,#0x2000
	add r2,r2,#0x4000		;0x06004000/8000=BG
	str r0,[r2,addy]		;BG

	add r2,r2,#0x2000
	ldr r1,=0x3FE0			;tile 127
	ands r1,r1,addy
;	tst r1,#0x0FE0
	ldr r1,=0x44444444		;For window test.
	orr r1,r0,r1
	strne r1,[r2,addy]		;Win
	tst addy,#0x1000
	addne r2,r2,#0x2000
	strne r0,[r2,addy]		;BG
	addne r2,r2,#0x2000
	strne r1,[r2,addy]		;Win

	mov pc,lr
;----------------------------------------------------------------------------
VRAM_name0	;(9800-9FFF)
;----------------------------------------------------------------------------
	ldr r2,agb_nt0
	bic addy,addy,#0xf800	;AND $07ff
	add addy,addy,addy	;lsl#1
;	ldrh r1,[r2,addy]	;use old color
;	and r1,r1,#0xf000
;	orr r0,r0,r1
	tst addy,#0x0800
	addne addy,addy,#0x1800
	orr r0,r0,#0x300	;for WIN color.
	strh r0,[r2,addy]	;write tile#
	bic r0,r0,#0x100	;for BG color.
	add addy,addy,#0x1800
	strh r0,[r2,addy]	;write tile#
	mov pc,lr

;----------------------------------------------------------------------------
VRAM_nameD	;(9800-9FFF)    Bloody Hack for Push16.
;----------------------------------------------------------------------------
	sub addy,addy,#0x8000
	ldr r2,=XGB_VRAM
	sub addy,addy,#1
	ldrb r0,[r2,addy]!	;read 1st char
	ldrb r1,[r2,#1]		;read 2nd char

	ldr r2,agb_nt0
	bic addy,addy,#0xf800	;AND $07ff
	add addy,addy,addy	;lsl#1
	tst addy,#0x0800	;for WIN color.
	addne addy,addy,#0x1800
	orr r0,r0,#0x300
	orr r1,r1,#0x300
	strh r0,[r2,addy]!	;write tile#
	strh r1,[r2,#2]		;write tile#

	bic r0,r0,#0x100	;for BG color.
	bic r1,r1,#0x100	;for BG color.
	add r2,r2,#0x1800
	strh r0,[r2]		;write tile#
	strh r1,[r2,#2]		;write tile#
	mov pc,lr

;----------------------------------------------------------------------------

vram_map	;for vmdata_R
	DCD 0
	DCD 0
	DCD 0
	DCD 0
	DCD 0
	DCD 0
	DCD 0
	DCD 0
nes_nt0 DCD XGB_VRAM+0x1800 ;$9800
nes_nt1 DCD XGB_VRAM+0x1800 ;$9800
nes_nt2 DCD XGB_VRAM+0x1800 ;$9800
nes_nt3 DCD XGB_VRAM+0x1800 ;$9800
	DCD XGB_VRAM+0x2C00
	DCD XGB_VRAM+0x2C00
	DCD XGB_VRAM+0x2C00
	DCD XGB_VRAM+0x2C00

agb_nt_map	;set thru mirror*
agb_nt0 DCD 0
agb_nt1 DCD 0
agb_nt2 DCD 0
agb_nt3 DCD 0

agb_pal		% 32*2	;copy this to real AGB palette every frame
cgb_palette	% 32	;CGB $FF68-$FF6D???

scrollbuff	DCD SCROLLBUFF1
dmascrollbuff	DCD SCROLLBUFF2

oambuffer	DCD OAM_BUFFER1,OAM_BUFFER2
dmaoambuffer	DCD OAM_BUFFER2

windowYbuf	DCB 0
windowXbuf	DCB 0,0,0
;----------------------------------------------------------------------------
	AREA wram_globals1, CODE, READWRITE

FPSValue
	DCD 0
AGBinput		;this label here for main.c to use
	DCD 0 ;AGBjoypad (why is this in lcd.s again?  um.. i forgot)
EMUinput	DCD 0 ;EMUjoypad (this is what GB sees)

lcdstate
	DCB 0 ;scrollX
	DCB 0 ;scrollY
	DCB 0 ;windowX
	DCB 0 ;windowY
	DCB 0 ;lcdyc_r
	DCB 0 ;lcdyc
	DCB 0 ;lcdstat
	DCB 0 ;lcdctrl
	DCB 0 ;lcdctrl0frame	;state of $2000 at frame start
	DCB 0 ;ppuctrl1
	DCB 0 ;gbpalette
	DCB 0 ;ob0palette
	DCB 0 ;ob1palette
	DCB 0,0,0
;...update load/savestate if you move things around in here
;----------------------------------------------------------------------------
	END
