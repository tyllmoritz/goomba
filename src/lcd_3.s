	INCLUDE equates.h
	INCLUDE memory.h
	INCLUDE cart.h
	INCLUDE io.h
	INCLUDE gbz80.h
	INCLUDE sound.h
	INCLUDE mappers.h

 [ RUMBLE
	IMPORT RumbleInterrupt
	IMPORT StartRumbleComs
 ]
	IMPORT ui_visible
	IMPORT ui_y
	IMPORT ui_x

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
	EXPORT FF44_W
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
	EXPORT FF4F_W
	EXPORT FF4F_R

	EXPORT FF68_R	;BCPS - BG Color Palette Specification
	EXPORT FF69_R	;BCPD - BG Color Palette Data
	EXPORT FF6A_R	;OCPS - OBJ Color Palette Specification
	EXPORT FF6B_R	;OCPD - OBJ Color Palette Data

	EXPORT FF68_W	;BCPS - BG Color Palette Specification
	EXPORT FF69_W	;BCPD - BG Color Palette Data
	EXPORT FF6A_W	;OCPS - OBJ Color Palette Specification
	EXPORT FF6B_W	;OCPD - OBJ Color Palette Data

	EXPORT vram_W
	EXPORT vram_W2
	EXPORT debug_
	EXPORT AGBinput
	EXPORT EMUinput
	EXPORT paletteinit
	EXPORT PaletteTxAll
	EXPORT transfer_palette
	EXPORT newframe
	EXPORT lcdstate
	EXPORT gammavalue
	EXPORT oambuffer
	EXPORT makeborder
	EXPORT bcolor
	EXPORT palettebank
	EXPORT resetlcdregs
	EXPORT fpsenabled
	EXPORT FPSValue
	EXPORT vbldummy
	EXPORT vblankfptr
;	EXPORT vcountfptr
	EXPORT vblankinterrupt
	EXPORT gbc_palette
;	EXPORT vcountinterrupt
	
	EXPORT move_ui
	
	EXPORT WINBUFF

	EXPORT DISPCNTBUFF
	EXPORT BG0CNTBUFF
	EXPORT SCROLLBUFF1
	EXPORT SCROLLBUFF2
;	EXPORT DMA0BUFF


 AREA rom_code, CODE, READONLY

;----------------------------------------------------------------------------
GBPalettes; RGB 24bit.

;yellow
	DCB 0xF3,0xFF,0x33, 0xC1,0xCE,0x22, 0x6F,0x7B,0x11, 0x00,0x00,0x00		;BG
	DCB 0xF3,0xFF,0x33, 0xC1,0xCE,0x22, 0x6F,0x7B,0x11, 0x00,0x00,0x00		;WIN
	DCB 0xF3,0xFF,0x33, 0xC1,0xCE,0x22, 0x6F,0x7B,0x11, 0x00,0x00,0x00		;OB0
	DCB 0xF3,0xFF,0x33, 0xC1,0xCE,0x22, 0x6F,0x7B,0x11, 0x00,0x00,0x00		;OB1
;grey
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
;multi1
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	DCB 0xEF,0xEF,0xFF, 0x5A,0x8C,0xE7, 0x18,0x4A,0x9C, 0x00,0x00,0x00
	DCB 0xFF,0xEF,0xEF, 0xEF,0x5A,0x63, 0xAD,0x10,0x18, 0x00,0x00,0x00
;multi2
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	DCB 0xE7,0xEF,0xD6, 0xC6,0xDE,0x8C, 0x6B,0x84,0x29, 0x00,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xEF,0x5A,0x63, 0xAD,0x10,0x18, 0x00,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0x5A,0x8C,0xE7, 0x18,0x4A,0x9C, 0x00,0x00,0x00
;Zelda.
	DCB 0xFF,0xFF,0xA0, 0x67,0xD7,0x67, 0x8C,0x55,0x20, 0x46,0x15,0x07
	DCB 0xFF,0xFF,0xAD, 0x80,0x80,0xB7, 0x25,0x29,0x59, 0x00,0x00,0x00
	DCB 0xFF,0xB0,0x7F, 0x5A,0x8C,0xE7, 0x18,0x4A,0x9C, 0x00,0x00,0x00
	DCB 0xFF,0xEF,0xEF, 0xEF,0x5A,0x63, 0xAD,0x10,0x18, 0x00,0x00,0x00
;Metroid
	DCB 0xDF,0xDF,0x7F, 0x00,0x5F,0xAF, 0x1F,0x3F,0x1F, 0x00,0x00,0x00
	DCB 0xFF,0xDF,0x00, 0x80,0xFF,0xFF, 0x00,0x80,0x80, 0x00,0x00,0x00
	DCB 0xFF,0xDF,0x00, 0xFF,0x00,0x00, 0x3F,0x37,0x00, 0x00,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xC0,0xC0,0xC0, 0x80,0x80,0x80, 0x00,0x00,0x00
;Adventure Island
	DCB 0xFF,0xFF,0xFF, 0x9C,0xB5,0xFF, 0x31,0x94,0x00, 0x00,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xF7,0xCE,0x73, 0x8C,0x4A,0x08, 0x21,0x21,0x9C
	DCB 0xFF,0xFF,0xDE, 0xEF,0xC6,0x73, 0xFF,0x63,0x52, 0x00,0x00,0x29
	DCB 0xFF,0xFF,0xFF, 0xE7,0xA5,0xA5, 0x7B,0x29,0x29, 0x42,0x00,0x00
;Adventure Island 2
	DCB 0xFF,0xFF,0xFF, 0xF7,0xEF,0x75, 0x29,0x6B,0xBD, 0x00,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xF7,0xCE,0x73, 0x8C,0x4A,0x08, 0x21,0x21,0x9C
	DCB 0xFF,0xFF,0xDE, 0xEF,0xC6,0x73, 0xFF,0x63,0x52, 0x00,0x00,0x29
	DCB 0xFF,0xFF,0xFF, 0xE7,0xA5,0xA5, 0x7B,0x29,0x29, 0x42,0x00,0x00
;Balloon Kid
	DCB 0xA5,0xD6,0xFF, 0xE7,0xEF,0xFF, 0xDE,0x8C,0x10, 0x5A,0x10,0x00
	DCB 0xFF,0xFF,0xFF, 0xF7,0xCE,0x73, 0x8C,0x4A,0x08, 0x21,0x21,0x9C
	DCB 0xFF,0xC6,0xC6, 0xFF,0x6B,0x6B, 0xFF,0x00,0x00, 0x63,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xEF,0x42,0xEF, 0x7B,0x29,0x29, 0x42,0x00,0x00
;Batman
	DCB 0xFF,0xF7,0xEF, 0xC8,0x90,0x88, 0x84,0x50,0x44, 0x42,0x10,0x00
	DCB 0xFF,0xFF,0xFF, 0xA5,0xA5,0xFF, 0x52,0x52,0xBD, 0x00,0x00,0xA5
	DCB 0xFF,0xFF,0xFF, 0xA5,0xA5,0xC6, 0x52,0x52,0x8C, 0x00,0x00,0x5A
	DCB 0xFF,0xFF,0xFF, 0xAD,0xB5,0xBD, 0x5A,0x6B,0x7B, 0x08,0x21,0x42
;Batman - Return of the Joker
	DCB 0xFF,0xFF,0xFF, 0xA5,0xAD,0xBD, 0x52,0x5A,0x7B, 0x00,0x10,0x39
	DCB 0xFF,0xFF,0xFF, 0xA5,0xAD,0xBD, 0x52,0x5A,0x7B, 0x00,0x10,0x39
	DCB 0xFF,0xFF,0xFF, 0xA5,0xAD,0xBD, 0x52,0x5A,0x7B, 0x00,0x10,0x39
	DCB 0xFF,0xFF,0xFF, 0xAD,0xB5,0xBD, 0x5A,0x6B,0x7B, 0x08,0x21,0x42
;Bionic Commando
	DCB 0xEF,0xF7,0xFF, 0xCE,0xB5,0xAD, 0xC6,0x21,0x29, 0x39,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0x94,0xCE,0xF7, 0x10,0x39,0xFF, 0x00,0x00,0x4A
	DCB 0xFF,0xFF,0xFF, 0xFF,0xAD,0x84, 0x5A,0x39,0x00, 0x00,0x00,0x00
	DCB 0xEF,0xEF,0xEF, 0xAD,0xA5,0x9C, 0x6B,0x5A,0x5A, 0x42,0x10,0x08
;Castlevania Adventure
	DCB 0xD6,0xD6,0xE7, 0x8C,0xA5,0xB5, 0x42,0x52,0x6B, 0x00,0x10,0x18
	DCB 0xFF,0xFF,0xFF, 0xA5,0xA5,0xD6, 0x52,0x52,0xAD, 0x00,0x00,0x84
	DCB 0xFF,0xFF,0xFF, 0xFF,0xE7,0x84, 0xFF,0x52,0x42, 0x5A,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xF7,0xEF,0xCE, 0xF7,0xDE,0x9C, 0xF7,0xB5,0x6B
;Dr. Mario
	DCB 0xFF,0xFF,0xFF, 0xFF,0xFF,0x66, 0x21,0x42,0xFF, 0x00,0x10,0x52
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xD6, 0x55,0x55,0xAD, 0x00,0x00,0x84
	DCB 0xFF,0xFF,0xFF, 0xFF,0xE7,0x84, 0xFF,0x52,0x42, 0x8C,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xFF,0xCE,0x8C, 0xF7,0x9C,0x5A, 0x84,0x52,0x00
;Kirby
	DCB 0xFF,0xFF,0x83, 0xFF,0xA5,0x3E, 0x73,0x42,0x00, 0x33,0x09,0x00
	DCB 0xCC,0xCC,0xFF, 0x77,0x78,0xFF, 0x23,0x35,0xC1, 0x05,0x0A,0x5A
	DCB 0xFF,0xBD,0xC4, 0xF1,0x4D,0x60, 0x9F,0x12,0x29, 0x20,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
;Donkey Kong Land
	DCB 0xE2,0xFF,0xD1, 0xA9,0xFF,0x89, 0x51,0xA2,0x48, 0x04,0x25,0x03
	DCB 0xFF,0xB4,0xB4, 0xFF,0x47,0x47, 0x80,0x00,0x00, 0x00,0x00,0x00
	DCB 0xFF,0xF2,0xB0, 0xD6,0xC3,0x4D, 0xA3,0x5B,0x11, 0x6A,0x00,0x00
	DCB 0xF7,0xFF,0x63, 0xC6,0xCE,0x42, 0x73,0x7B,0x21, 0x00,0x00,0x00

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

	ldr r1,=AGB_PALETTE			;clear some of the AGB Palette
	mov r2,#0x80/4
	bl filler_

	ldr r1,=DISPCNTBUFF			;clear DISPCNT+DMA1BUFF
	mov r2,#328/4
	bl filler_

	;fill window buffer
	ldr r0,=0x28C8C8C8 ;win0h, win1h
	ldr r1,=0x08989898 ;win0v, win1v
	ldr r3,=WINBUFF
	mov r2,#160*8/8
fill_win_loop
	stmia r3!,{r0,r1}
	subs r2,r2,#1
	bne fill_win_loop

	mov r1,#REG_BASE
	mov r0,#0x0008
;	mov r0,#0x0028
	strh r0,[r1,#REG_DISPSTAT]	;vblank en

	mov r0,#8
	strh r0,[r1,#REG_BLDY]		;darkness setting for faded screens (bigger number=darker)
	ldr r0,=0x353A
	strh r0,[r1,#REG_WININ]		;WinIN0/1, BG0 not enable in Win0
	ldr r0,=0x3F20
	strh r0,[r1,#REG_WINOUT]	;WinOUT0/1, Everything enabled outside Windows


	add r0,r1,#REG_BG0HOFS		;DMA0 always goes here
	str r0,[r1,#REG_DM0DAD]
	mov r0,#1					;1 word transfer
	strh r0,[r1,#REG_DM0CNT_L]
;	ldr r0,=DMA0BUFF			;DMA0 src=
;	str r0,[r1,#REG_DM0SAD]

	str r1,[r1,#REG_DM1DAD]		;DMA1 goes here
	mov r0,#1					;1 word transfer
	strh r0,[r1,#REG_DM1CNT_L]

	add r2,r1,#REG_IE
	mov r0,#-1
	strh r0,[r2,#2]		;stop pending interrupts
	ldr r0,=0x1081
	strh r0,[r2]		;key,vblank,serial interrupt enable
;	ldr r0,=0x1085
;	strh r0,[r2]		;key,vcount,vblank,serial interrupt enable
	mov r0,#1
	strh r0,[r2,#8]		;master irq enable

	ldr r1,=AGB_IRQVECT
	ldr r2,=irqhandler
	str r2,[r1]

	bx addy
;----------------------------------------------------------------------------
GFX_reset	;called with CPU reset
;----------------------------------------------------------------------------
	stmfd sp!,{addy,lr}
	mov r0,#0

	ldr r1,=AGB_BG		;clear most of the GB VRAM
	mov r2,#0x2000/4
	bl filler_

	mov r0,#0
	bl FF4F_W

	
	mov r0,#0
	strb r0,lcdstat		;flags off
	strb r0,scrollX
	strb r0,scrollY
	strb r0,windowX
	strb r0,windowY
	strb r0,lcdyc_r
	strb r0,vrambank

	mov r0,#0x91
	strb r0,lcdctrl		;LCDC
	strb r0,ppuctrl1

	mov r1,#REG_BASE
	ldr r0,=0x28C8				;40-200
	strh r0,[r1,#REG_WIN1H]		;Win0H
	ldr r0,=0x0898				;8-152
	strh r0,[r1,#REG_WIN1V]		;Win0V

;	mov r0,#0x0000
;	strh r0,[r1,#REG_BG3CNT]	;Border

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
move_ui
;----------------------------------------------------------------------------
	stmfd sp!,{r0-addy,lr}
	ldr r0,=ui_x
	ldr r0,[r0]
	ldr r3,=ui_y
	ldr r3,[r3]
	orr r0,r0,r3,lsl#16
	ldr r3,=BG0CNTBUFF+6
	ldr r4,=DISPCNTBUFF
	mov r1,#160
	ldr r2,=dmascrollbuff
	ldr r2,[r2]
	add r2,r2,#12
;	ldr r7,=DMA0BUFF
;	add r7,r7,#12
	ldr r8,=scrollbuff
	ldr r8,[r8]
	add r8,r8,#12
;	ldr r7,=
;	ldr r2,=DMA0BUFF
;	ldr r6,=dmascrollbuff
;	str r2,[r6]
;	ldr r2,=DMA0BUFF+12
	ldr r6,=0x5A0C
move_ui_loop
	str r0,[r2],#16
;	str r0,[r7],#16
	str r0,[r8],#16
	ldrh r5,[r4]
	orr r5,r5,#0x0800
	strh r5,[r4],#2
	strh r6,[r3],#8
	subs r1,r1,#1
	bne move_ui_loop

	ldmfd sp!,{r0-addy,lr}
	bx lr

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
;	mov r1,#REG_BASE
;	ldr r2,=0x3F3F
;	strh r2,[r1,#REG_WININ]		;WinIN0/1, Everything enabled inside Windows
;	subne r2,r2,#0x17			;r0=0x3f28
;	strh r2,[r1,#REG_WINOUT]	;WinOUT0/1, SPR, BG0, BG1 & BG2 not enable outside Win0
	bx lr

;
;	mov r1,#0x06000000
;	adr r2,SGBorder
;	mov r3,#32*20
;	ldr r0,bcolor
;	cmp r0,#3
;	moveq r0,#0x120
;	beq bordloopt
;	mov r0,r0,lsl#12
;	add r0,r0,#0x3100
;bordloop
;	ldrb addy,[r2],#1
;	orr addy,addy,r0
;	strh addy,[r1],#2
;	subs r3,r3,#1
;	bne bordloop
;	bx lr
;bordloopt
;	strh r0,[r1],#2
;	subs r3,r3,#1
;	bne bordloopt
;	bx lr
;;----------------------------------------------------------------------------
bcolor
	DCD 0 ;Border color
;SGBorder
;	DCB 0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f
;	DCB 0x7f,0x7f,0x7f,0x7f,0x7f,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f
;	DCB 0x7f,0x7f,0x7f,0x7f,0x7f,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f
;	DCB 0x7f,0x7f,0x7f,0x7f,0x7f,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f
;	DCB 0x7f,0x7f,0x7f,0x7f,0x7f,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f
;	DCB 0x7f,0x7f,0x7f,0x7f,0x7f,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f
;	DCB 0x7f,0x7f,0x7f,0x7f,0x7f,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f
;	DCB 0x7f,0x7f,0x7f,0x7f,0x7f,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f
;	DCB 0x7f,0x7f,0x7f,0x7f,0x7f,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f
;	DCB 0x7f,0x7f,0x7f,0x7f,0x7f,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f
;	DCB 0x7f,0x7f,0x7f,0x7f,0x7f,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f
;	DCB 0x7f,0x7f,0x7f,0x7f,0x7f,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f
;	DCB 0x7f,0x7f,0x7f,0x7f,0x7f,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f
;	DCB 0x7f,0x7f,0x7f,0x7f,0x7f,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f
;	DCB 0x7f,0x7f,0x7f,0x7f,0x7f,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f
;	DCB 0x7f,0x7f,0x7f,0x7f,0x7f,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f
;	DCB 0x7f,0x7f,0x7f,0x7f,0x7f,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f
;	DCB 0x7f,0x7f,0x7f,0x7f,0x7f,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f
;	DCB 0x7f,0x7f,0x7f,0x7f,0x7f,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f
;	DCB 0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f,0x7f
;----------------------------------------------------------------------------
paletteinit;	r0-r3 modified.
;called by ui.c:  void map_palette(char gammavalue)
;----------------------------------------------------------------------------
	stmfd sp!,{r4-r7,lr}
	ldr r7,=GBPalettes
	ldr r1,palettebank	;Which color set (yellow, grey...)
	add r1,r1,r1,lsl#1	;r1 x 3
	add r7,r7,r1,lsl#4	;r7 + r1 x 16
	ldr r6,=MAPPED_RGB
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
transfer_palette
;----------------------------------------------------------------------------
	stmfd sp!,{r0-r5}
	mov r0,#AGB_PALETTE
	;transfer first 15 colors for solid blocks
	ldr r1,=gbc_palette
;	ldrh r2,[r1]
;	strh r2,[r0],#2
	mov r3,#16
pal_loop1
	ldrh r2,[r1],#8
	strh r2,[r0],#2
	subs r3,r3,#1
	bne pal_loop1

	mov r3,#16
	ldr r1,=gbc_palette
	ldr r0,=AGB_PALETTE+256
pal_loop2
	ldmia r1!,{r4,r5}
	stmia r0,{r4,r5}
	add r0,r0,#32
	subs r3,r3,#1
	bne pal_loop2
	ldmfd sp!,{r0-r5}
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

 [ RUMBLE
	str lr,[sp,#-4]!
	ldr r1,=StartRumbleComs
	adr lr,ret_
	bx r1
ret_
	ldr lr,[sp],#4
 ]


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
gammavalue DCB 0
		DCB 0
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
;		bne jmpintr
;		ands r0,r1,#0x04
;		ldrne r12,vcountfptr
;		bne jmpintr
		
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
 [ RUMBLE
serialfptr DCD RumbleInterrupt
 |
serialfptr DCD vbldummy
 ]
;vcountfptr DCD vblankinterrupt
twitch DCD 0
vblankinterrupt;
;----------------------------------------------------------------------------
	stmfd sp!,{r4-r7,globalptr,lr}
	ldr globalptr,=|wram_globals0$$Base|

	bl showfps_


;	ldr r2,=DMA0BUFF			;setup DMA buffer for scrolling:
;	add r3,r2,#160*16			;For both background and window
;	ldr r1,dmascrollbuff
;vbl6
;	ldmia r1!,{r0,r4-r7}
;	stmia r2!,{r0,r4-r7}
;	cmp r2,r3
;	bmi vbl6

	mov r1,#REG_BASE

	ldrb r0,windowYbuf
	ldrb r2,windowY
	strb r2,windowYbuf
	cmp r0,#0x98
	movpl r0,#0x98

;	ldr r2,=0x0898				;end of window
;	add r2,r2,r0,lsl#8
;	strh r2,[r1,#REG_WIN0V]		;Win0Vertical, BG0 not enable in Win0

;	ldrb r0,windowXbuf
;	cmp r0,#0xA7
;	movpl r0,#0xA7

;	mov r0,#7
;	ldr r2,=0x21C8				;end of window
;	add r2,r2,r0,lsl#8
;	strh r2,[r1,#REG_WIN0H]		;Win0Horizontal, BG0 not enable in Win0

	strh r1,[r1,#REG_DM0CNT_H]	;DMA stop
	strh r1,[r1,#REG_DM1CNT_H]
	strh r1,[r1,#REG_DM2CNT_H]
	strh r1,[r1,#REG_DM3CNT_H]

	ldr r0,dmaoambuffer			;OAM transfer:
	str r0,[r1,#REG_DM3SAD]
	mov r0,#AGB_OAM
	str r0,[r1,#REG_DM3DAD]
	mov r0,#0x84000000			;noIRQ 32bit incsrc incdst
	orr r0,r0,#0x50				;80 words=40sprites, was 128 words,512 bytes,64sprites.
	str r0,[r1,#REG_DM3CNT_L]	;DMA go

	ldr r0,dmascrollbuff			;setup HBLANK DMA for display scroll:
	str r0,[r1,#REG_DM0SAD]
	ldr r0,=0xA6600004			;noIRQ hblank 32bit repeat incsrc inc_reloaddst 4 words
	str r0,[r1,#REG_DM0CNT_L]	;DMA go
								;setup HBLANK DMA for DISPCNT (BG/OBJ enable)
	ldr r3,=DISPCNTBUFF
	ldrh r2,[r3],#2
	strh r2,[r1,#REG_DISPCNT]	;set 1st value manually, HBL is AFTER 1st line
	str r3,[r1,#REG_DM1SAD]		;dmasrc=
	ldr r0,=0xA240				;noIRQ hblank 16bit repeat incsrc fixeddst
	strh r0,[r1,#REG_DM1CNT_H]	;DMA go

	;window dma
	add r0,r1,#REG_WIN0H
	str r0,[r1,#REG_DM2DAD]
	ldr r4,=WINBUFF
	str r4,[r1,#REG_DM2SAD]
	ldr r0,=0xA6600002			;noIRQ hblank 32bit repeat incsrc inc_reloaddst 2 words
	str r0,[r1,#REG_DM2CNT_L]	;DMA go
								;setup HBLANK DMA for BG CHR
	add r0,r1,#REG_BG0CNT
	str r0,[r1,#REG_DM3DAD]
	ldr r4,=BG0CNTBUFF
	str r4,[r1,#REG_DM3SAD]
	ldr r0,=0xA6600002			;noIRQ hblank 32bit repeat incsrc inc_reloaddst 2 words
	str r0,[r1,#REG_DM3CNT_L]	;DMA go

	ldmfd sp!,{r4-r7,globalptr,pc}

totalblend	DCD 0
;palrptr	DCD 0
;palwptr	DCD 0
;
;;----------------------------------------------------------------------------
;vcountinterrupt; for palette changes
;;----------------------------------------------------------------------------
;	stmfd sp!,{r4-r7}
;	ldr r4,=AGB_PALETTE
;	adr r0,palrptr
;	ldr r1,[r0]
;	ldr r6,[r0,#4]
;	cmp r1,r6
;	beq vci_return
;	
;	ldr r2,=palbuff
;	ldr r12,[r1,r2]
;vci_loop1
;	mov r5,r12,lsr#16
;	;bg color?
;	tst r12,#0x00000600
;	and r3,r12,#0x00007800
;	moveq r7,r3,lsr#10
;	streqh r5,[r4,r7]
;	mov r3,r3,lsr#6
;	and r7,r12,#0x00000600
;	mov r7,r7,lsr#8
;	orr r3,r3,r7
;	add r3,r3,#256
;	strh r5,[r4,r3]
;	add r1,r1,#4
;	bic r1,r1,#0x200
;	str r1,[r0]
;	cmp r1,r6
;	beq vci_return
;	and r3,r12,#0x000000FF
;	ldr r12,[r1,r2]
;	and r5,r12,#0x000000FF
;	cmp r3,r5
;	beq vci_loop1
;	ldr r7,=REG_BASE+REG_DISPSTAT
;	ldrh r0,[r7]
;	bic r0,r0,#0xFF00
;	orr r0,r0,r12,lsl#8
;	strh r0,[r7]	
;vci_return	
;	ldmfd sp!,{r4-r7}
;	bx lr
	
	

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
	ldr r5,chrold2
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

	bl transfer_palette

	ldr pc,[sp],#4

;----------------------------------------------------------------------------
FF40_R;		LCD Control
;----------------------------------------------------------------------------
	ldrb r0,lcdctrl
	mov pc,lr
;----------------------------------------------------------------------------
FF40_W;		LCD Control
;----------------------------------------------------------------------------
	stmfd sp!,{r3,r4,r5,lr}
	ldrb r1,lcdctrl
	strb r0,lcdctrl
	eor r1,r1,r0
	and r1,r1,r0
	tst r1,#0x80		;Is LCD turned on?
	ldrne addy,=line145_to_end
	strne addy,nexttimeout
	movne r1,#152
	strne r1,scanline
	
	ldr r1,=0x04010401   ;bg0, win
	ldr r5,=0x06020603   ;bg0back, winback
	tst r0,#0x10		;Which charset?
	addeq r1,r1,#0x00000004
	addeq r1,r1,#0x00040000
	tst r0,#0x08		;BG tilemap select?
	addne r1,r1,#0x00000100
	addne r5,r5,#0x00000100
	tst r0,#0x40		;WIN tilemap select?
	addne r1,r1,#0x01000000
	addne r5,r5,#0x01000000
	adr r2,chrold
	swp r3,r1,[r2]		;r3=lastval
	adr r2,chrold2
	swp r5,r5,[r2]		;r3=lastval

	ldr r1,=0x4040		;1d sprites, WIN1 enable

	tst r0,#0x80		;LCD en?
	beq nodisp
	tst r0,#0x01		;bg en?
	orrne r1,r1,#0x0500
	tst r0,#0x20		;win en?
	orrne r1,r1,#0x2A00	;GBA Win0 & GBA BG1
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
	ldmfd sp!,{r3,r4,r5,pc}

ctrl1finish
	ldr r2,=ui_visible
	ldr r2,[r2]
	cmp r2,#0
	beq ctrl1finish_no_ui_visible
	;if UI visible, make BG3 visible
	orr r0,r0,#0x0800
	bic r5,r5,#0xFF000000
	bic r5,r5,#0x00FF0000
	orr r5,r5,#0x5A000000
	orr r5,r5,#0x000C0000
ctrl1finish_no_ui_visible
	ldr r4,=BG0CNTBUFF
	ldr r2,=DISPCNTBUFF
	add r1,r2,r1,lsl#1
	add r2,r2,addy,lsl#1
	add r4,r4,addy,lsl#3
	add r4,r4,#8
ct1	strh r0,[r2],#-2	;fill backwards from scanline to lastline
	str r5,[r4,#-4]!		;fill backwards from scanline to lastline
	str r3,[r4,#-4]!		;fill backwards from scanline to lastline
	cmp r2,r1
	bpl ct1

	mov pc,lr

chrold		DCD 0		;last write
chrold2		DCD 0		;last write2
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
	
	ldr r2,cyclesperscanline
	cmp r2,#DOUBLE_SPEED
	movne r1,cycles
	moveq r1,cycles,lsr#1
	
	cmp r1,#376*CYCLE
	orrpl r0,r0,#2		;in OAM access
	movpl pc,lr

	cmp r1,#204*CYCLE
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
	add r1,r2,r1,lsl#4
	add addy,addy,#1
	add r2,r2,addy,lsl#4
sy1
	strh r0,[r2,#-8]!	;fill backwards from scanline to lastline
	strh r0,[r2,#-8]!	;fill backwards from scanline to lastline
	cmp r2,r1
	bgt sy1
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
	add r1,r2,r1,lsl#4
	add addy,addy,#1
	add r2,r2,addy,lsl#4
sx1	strh r0,[r2,#-8]!	;fill backwards from scanline to lastline
	strh r0,[r2,#-8]!	;fill backwards from scanline to lastline
	cmp r2,r1
	bgt sx1
	mov pc,lr

scrollXold DCD 0 ;last write
scrollXline DCD 0 ;..was when?
;----------------------------------------------------------------------------
FF44_R;      LCD Scanline
;----------------------------------------------------------------------------
   ldrb r0,lcdctrl
   ands r0,r0,#0x80
   ldrne r0,scanline
;   ldr r0,scanline
   mov pc,lr
;;----------------------------------------------------------------------------
;FF44_R;		LCD Scanline
;;----------------------------------------------------------------------------
;
;
;	ldr r0,scanline
;;	cmp r0,#153
;;	moveq r0,#0
;	
;	
;;	sub cycles,cycles,#23*CYCLE	;LCD hack?
;	mov pc,lr
;----------------------------------------------------------------------------
FF44_W;		LCD Scanline
;----------------------------------------------------------------------------
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
;	cmp r0,#0
;	moveq r0,#153
	strb r0,lcdyc
	mov pc,lr
;----------------------------------------------------------------------------
FF47_R;		BGP - BG Palette Data
;----------------------------------------------------------------------------
	ldrb r0,gbpalette
	mov pc,lr
;----------------------------------------------------------------------------
FF47_W;		BGP - BG Palette Data  (GB MODE ONLY)
;----------------------------------------------------------------------------
	strb r0,gbpalette
	
	ldr r2,=gbc_palette
	ldr addy,=MAPPED_RGB
	str lr,[sp,#-4]!
	bl dopalette
	ldr lr,[sp],#4
	
	ldr r2,=gbc_palette+4*2
	ldr addy,=MAPPED_RGB+16
dopalette
	ldrb r1,gbmode
	cmp r1,#0
	bxne lr

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
	ldr r2,=gbc_palette+64
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
	ldr r2,=gbc_palette+64+8
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
	adr r1,windowYold
	swp r0,r0,[r1]		;r0=lastval

	ldr addy,scanline	;addy=scanline
	add addy,addy,#8
	cmp addy,#159
	movhi addy,#159
	adr r2,windowYline
	swp r1,addy,[r2]	;r1=lastline, lastline=scanline
	stmfd sp!,{r3,r4,r5,lr}
	bl windowYfinish
	ldmfd sp!,{r3,r4,r5,pc}
;-------------------------------
windowYfinish			;newframe jumps here
;wininitY			;NewFrame jumps here
	add r4,r0,#8
	cmp r4,#8
	movlt r4,#8
	cmpge r4,#152
	movgt r4,#152
	
	rsb r0,r0,#0
	sub r0,r0,#8
	mov r5,r0
	
	ldr r2,=ui_visible  ;if UI visible, use 0 as y position
	ldr r2,[r2]
	cmp r2,#0
	ldrne r5,=ui_y
	ldrne r5,[r5]

	ldr r2,scrollbuff
	ldr r3,=WINBUFF+5+160*8
	add r2,r2,#6		;r2+=6, win Y write

	add r1,r2,r1,lsl#4	;r1=base
	add r2,r2,#160*16	;r2=end2
;	add r3,r3,#160*8
wy1
	strh r0,[r1],#8
	strh r5,[r1],#8
	strb r4,[r3,#-8]!	;fill backwards from scanline to lastline
	cmp r1,r2
	blo wy1
	mov pc,lr
windowYold DCD 0 ;last write
windowYline DCD 0 ;..was when?
;----------------------------------------------------------------------------
FF4F_W;		VBK - VRAM Bank - CGB Mode Only
;----------------------------------------------------------------------------
	ldrb r1,gbmode
	cmp r1,#0
	moveq r0,#0
	
	and r0,r0,#1
	strb r0,vrambank
	
	
	
 [ RESIZABLE
 	ldr addy,xgb_vram
 	sub addy,addy,#0x8000
 |
	ldr addy,=XGB_VRAM-0x8000
 ]
	add addy,addy,r0,lsl#13	
	str addy,memmap_tbl+32
	mov addy,#AGB_VRAM
	add addy,addy,r0,lsl#13
	str addy,agb_vrambank
	mov pc,lr
;----------------------------------------------------------------------------
FF4F_R;		VBK - VRAM Bank - CGB Mode Only
;----------------------------------------------------------------------------
	ldrb r0,vrambank
	mov pc,lr


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
	stmfd sp!,{r3,r4,r5,lr}
	bl windowXfinish
	ldmfd sp!,{r3,r4,r5,pc}

windowXfinish			;newframe jumps here
	add r4,r0,#33
	cmp r4,#40
	movlt r4,#40
	cmpge r4,#200
	movgt r4,#200
	
	rsb r0,r0,#0
	sub r0,r0,#33		;window x-7
	mov r5,r0
	
	ldr r2,=ui_visible  ;if UI visible, use 0 as x position
	ldr r2,[r2]
	cmp r2,#0
	ldrne r5,=ui_x
	ldrne r5,[r5]

	ldr r2,scrollbuff
	add r2,r2,#4		;r2+=4, win X write
	add r1,r2,r1,lsl#4
	add addy,addy,#1
	add r2,r2,addy,lsl#4
	ldr r3,=WINBUFF+1
	add r3,r3,addy,lsl#3
wx1	
	strh r5,[r2,#-8]!	;fill backwards from scanline to lastline
	strh r0,[r2,#-8]!	;fill backwards from scanline to lastline
	strb r4,[r3,#-8]!	;fill backwards from scanline to lastline
	
	cmp r2,r1
	bgt wx1
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
	ldr r2,memmap_tbl+32
	strb r0,[r2,addy]
	cmp addy,#0x9800
	bpl VRAM_name0
;----------------------------------------------------------------------------
;VRAM_chr;	8000-97FF
;----------------------------------------------------------------------------
	bic addy,addy,#1
	ldrb r0,[r2,addy]!	;read 1st plane
	ldrb r1,[r2,#1]		;read 2nd plane
	sub addy,addy,#0x8000

	adr r2,chr_decode
	ldr r0,[r2,r0,lsl#2]
	ldr r1,[r2,r1,lsl#2]
	orr r0,r0,r1,lsl#1

	add addy,addy,addy

;f(2x) =
;{
;	0...FFF: sprite 0, bg 4000
;	1000...1FFF: sprite 1000, bg 5000, bg D000
;       2000...2FFF: bg C000
;}

	ldr r2,agb_vrambank		;AGB BG tileset
	tst addy,#0x2000
	addeq r1,r2,#0x10000	;0x06010000=OBJ
	streq r0,[r1,addy]		;OBJ
	addne r2,r2,#0x6000
	addeq r2,r2,#0x4000		;0x06004000/8000=BG
	str r0,[r2,addy]		;BG

	add r2,r2,#0x2000
	tst addy,#0x1000
	addne r2,r2,#0x2000
	strne r0,[r2,addy]		;BG

	mov pc,lr
;----------------------------------------------------------------------------
VRAM_name0	;(9800-9FFF)
;----------------------------------------------------------------------------
	ldrb r2,gbmode
	cmp r2,#0
 [ RESIZABLE
	ldr r2,xgb_vram
 |
	ldr r2,=XGB_VRAM
 ]
	sub addy,addy,#0x8000
	ldrb r0,[r2,addy]
	addne r2,r2,#0x2000
	ldrneb r1,[r2,addy]
	moveq r1,#0
	and r2,r1,#0x7
	mov r2,r2,lsl#12
	orr r0,r0,r2
;	and r2,r1,#0x8
;	mov r2,r2,lsl#5
;	orr r0,r0,r2
;	and r2,r1,#0x60
;	mov r2,r2,lsl#5
;	orr r0,r0,r2
	and r2,r1,#0x68
	mov r2,r2,lsl#5
	orr r0,r0,r2
	orr r0,r0,#0x00008200

;gbc byte 2
;  Bit 0-2  Background Palette number  (BGP0-7)
;  Bit 3    Tile VRAM Bank number      (0=Bank 0, 1=Bank 1)
;  Bit 4    Not used
;  Bit 5    Horizontal Flip            (0=Normal, 1=Mirror horizontally)
;  Bit 6    Vertical Flip              (0=Normal, 1=Mirror vertically)
;  Bit 7    BG-to-OAM Priority         (0=Use OAM priority bit, 1=BG Priority)

;gba format
;  0-9   Tile Number     (0-1023)
;  10    Horizontal Flip (0=Normal, 1=Mirrored)
;  11    Vertical Flip   (0=Normal, 1=Mirrored)
;  12-15 Palette Number  (0-15)    (Not used in 256 color/1 palette mode)
	
;	ldrb r1,vrambank
;	tst r1,#1
;	movne pc,lr  ;hack for GBC mode...

	ldr r2,=AGB_BG
	and r1,r1,#0x07
;	add r1,r1,#0x01
	
	bic addy,addy,#0xf800	;AND $07ff
	add addy,addy,addy	;lsl#1

	strh r0,[r2,addy]	;write tile#
	addne addy,addy,#0x1000
	strneh r1,[r2,addy]	;write background tile#
	
	mov pc,lr

;----------------------------------------------------------------------------
VRAM_nameD	;(9800-9FFF)    Bloody Hack for Push16.
;----------------------------------------------------------------------------
	sub addy,addy,#0x8000
	stmfd sp!,{addy,lr}
	bl VRAM_name0
	ldmfd sp!,{addy,lr}
	add addy,addy,#1
	b VRAM_name0
;	
;	ldr r2,memmap_tbl+32
;	ldrb r1,vrambank
;	tst r1,#1
;	movne pc,lr  ;hack for GBC mode...
;	
;	
;	sub addy,addy,#1
;	ldrb r0,[r2,addy]!	;read 1st char
;	ldrb r1,[r2,#1]		;read 2nd char
;
;	ldr r2,agb_nt0
;	bic addy,addy,#0xf800	;AND $07ff
;	add addy,addy,addy	;lsl#1
;	tst addy,#0x0800	;for WIN color.
;	addne addy,addy,#0x1800
;	orr r0,r0,#0x300
;	orr r1,r1,#0x300
;	strh r0,[r2,addy]!	;write tile#
;	strh r1,[r2,#2]		;write tile#
;
;	bic r0,r0,#0x100	;for BG color.
;	bic r1,r1,#0x100	;for BG color.
;	add r2,r2,#0x1800
;	strh r0,[r2]		;write tile#
;	strh r1,[r2,#2]		;write tile#
;	mov pc,lr

;----------------------------------------------------------------------------

FF68_R	;BCPS - BG Color Palette Specification
	ldrb r0,BCPS_index
	bx lr
FF69_R	;BCPD - BG Color Palette Data
	ldrb r1,BCPS_index
	and r1,r1,#0x3F
	ldr r0,=gbc_palette
	ldrb r0,[r0,r1]
	bx lr
FF6A_R	;OCPS - OBJ Color Palette Specification
	ldrb r0,OCPS_index
	bx lr
FF6B_R	;OCPD - OBJ Color Palette Data
	ldrb r1,OCPS_index
	and r1,r1,#0x3F
	ldr r0,=gbc_palette+64
	ldrb r0,[r0,r1]
	bx lr

FF68_W	;BCPS - BG Color Palette Specification
	strb r0,BCPS_index
	bx lr
FF69_W	;BCPD - BG Color Palette Data
	ldrb r1,BCPS_index
	and r2,r1,#0x3F
	ldr addy,=gbc_palette
	strb r0,[addy,r2]
	tst r1,#0x80
	addne r1,r1,#1
	strneb r1,BCPS_index
	bx lr
;FF69_W	;BCPD - BG Color Palette Data
;	ldrb r1,BCPS_index
;	and r2,r1,#0x3F
;	ldr addy,=gbc_palette
;	add addy,addy,r2
;	ldrb r2,[addy]
;	strb r0,[addy]
;	tst r1,#0x80
;	addne r1,r1,#1
;	strneb r1,BCPS_index
;	and r1,r1,#0x3E
;in_ff69
;	cmp r2,r0
;	bxeq lr
;store_palette
;	ldr addy,=gbc_palette
;	ldr r0,scanline
;	add r0,r0,#8
;	orr r0,r0,r1,lsl#8
;	ldrh r2,[addy,r1]
;	orr r0,r0,r2,lsl#16
;	ldr addy,=palrptr
;	ldr r1,[addy],#4
;	ldr r2,[addy]
;	cmp r1,r2
;	ldr r1,=palbuff
;	str r0,[r1,r2]
;	add r2,r2,#4
;	bic r2,r2,#0x200
;	str r2,[addy]
;	bxne lr
;	ldr r1,=REG_BASE+REG_DISPSTAT
;	ldrh r2,[r1]
;	bic r2,r2,#0xFF00
;	and r0,r0,#0xFF
;	orr r2,r2,r0,lsl#8
;	strh r2,[r1]
;	bx lr
FF6A_W	;OCPS - OBJ Color Palette Specification
	strb r0,OCPS_index
	bx lr
FF6B_W	;OCPD - OBJ Color Palette Data
	ldrb r1,OCPS_index
	and r2,r1,#0x3F
	ldr addy,=gbc_palette+64
	strb r0,[addy,r2]
	tst r1,#0x80
	addne r1,r1,#1
	strneb r1,OCPS_index
	bx lr
;FF6B_W	;OCPD - OBJ Color Palette Data
;	ldrb r1,OCPS_index
;	and r2,r1,#0x3F
;	ldr addy,=gbc_palette+64
;	add addy,addy,r2
;	ldrb r2,[addy]
;	strb r0,[addy]
;	tst r1,#0x80
;	addne r1,r1,#1
;	strneb r1,OCPS_index
;	and r1,r1,#0x3E
;	add r1,r1,#0x40
;	b in_ff69
;;	adr addy,agb_pal+256
;;	mov r1,r2,lsr#3
;;	mov r1,r1,lsl#5
;;	and r2,r2,#0x07
;;	add r2,r2,r1
;;	strb r0,[addy,r2]
;;	bx lr

oambuffer	DCD OAM_BUFFER1,OAM_BUFFER2
dmaoambuffer	DCD OAM_BUFFER2

gbc_palette	% 128	;CGB $FF68-$FF6D???

scrollbuff	DCD SCROLLBUFF1
dmascrollbuff	DCD SCROLLBUFF2

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
	DCB 0 ;vrambank
	DCB 0 ;palette_index
	DCB 0
	DCD 0 ;dma_src
	DCD 0 ;agb_vrambank
;...update load/savestate if you move things around in here
;----------------------------------------------------------------------------
	END
