@newerest todo:
@fix timers in double speed hack mode

@newest todo:
@*Fix balloon kid's garbage graphics
@Take lots of non-critical code out of IWRAM
@*remove NONE from double speed menu
@option to use color 0 as border color
@Fix the damn UI shaking, fix the darkened UI when changing between SGB and non SGB
@Finish the job, make the interrupt handler be in charge of adding the UI/Border
@	Do this by comparing my_ui_border with _ui_border_visible
@	Also make my_ui_border work
@*TIMERS doublespeed mode should be full double speed during vblank period
@Incorporate UI and Border into scanline filler, also ensure 4 layers always visible

@newer todo:
@fix flickering

@new todo:
@fix sprite priority in window split mode
@sync BG tiles
@
@SGB STUFF:
@do SGB colors correctly
@do sgb attributes
@*update SGB border palette for real
@*Proper darkness when UI and Border visible

@other border stuff:
@custom borders



@TODO:
@* = written, + = tested
@fake bios, init sound like the real bios
@*verify that turning off screen is working correctly
@*verify that interrupts are working correctly
@fix STOP instruction
@*"ugly hack" from io.s?
@Border Support
@	border generation ui, border loading...
@*set default double speed mode to Full
@Save options per game, like palette, double speed mode
@Custom palettes
@SGB Support
@Palette changes per line using vcount, may up to 4 palettes per frame total
@Savestates
@Real HDMA
@re-add GBAMP support
@Possibly separate gbz80 core from gb system stuff?
@Port to NDS
@ROM Compression

@test new code
@*buffer filler (vblank and others)
@*newframe_vblank

@finished TODO:
@*fix recent_tiles again, there's graphics corruption
@*correct graphics in fast mode
@*gamma correct GBC palette
@*init window values
@*newframe applys at start of vblank
@*look again at those buffer fillers, check the code for problems
@*fill in values for bgxcntbuff
@*incorporate UI visibility
@*change windowx code to store into a buffer
@*new code for DMAing the buffers (using vcount interrupts to start and stop)
@*write vcount interrupt
@*write code to generate GBA tilemaps, including HP tiles
@*new vram arrangement
@*integrate dirty tiles
@*integrate delayed dirty tiles
@*add sprite generator


@dma: scrolling, dispcnt, bgXcnt, windowx
@border GFX takes up 1E00 bytes [240 tiles] per border

@vram usage:
@1a
@2a
@solid tiles, border tiles
@4 maps
@1b
@2b
@font, (2 maps) bg0,bg00
@(4 maps) bg0H,bg1,bg101bg1H
@
@26, 27, 28, 29, 30, 31


@
@
@maps:
@6 GB maps
@2 UI maps
@1 border map
@1 free map

@	#include "equates.h"
@	#include "memory.h"
@	#include "cart.h"
@	#include "io.h"
@	#include "gbz80.h"
@	#include "sound.h"
@	#include "mappers.h"
@	#include "sgb.h"

	VRAM_BASE = 0x06000000
	VRAM_OBJ_BASE = 0x06010000
	SCREEN_X_START = 40
	SCREEN_Y_START = 8
	OAM_BASE = 0x07000000
	PALETTE_BASE = AGB_PALETTE

@ AGB_BG			= AGB_VRAM+0xA000
@ AGB_BG_GBMODE		= AGB_VRAM+0x4000
@
	DEBUGSCREEN = VRAM_BASE+0x7800

 .if RUMBLE
	@IMPORT RumbleInterrupt
	@IMPORT StartRumbleComs
 .endif
	.global ui_border_visible
	.global ui_y
	.global ui_x
	.global darkness
	.global sgb_palette_number
	
	.global move_ui
	
	.global newframe_vblank
	.global gbc_chr_update
	
	.global GFX_init
	.global GFX_init_irq
	.global GFX_reset
	.global FF40_R
	.global FF40_W
	.global FF41_R
	.global FF41_W
	.global FF42_R
	.global FF42_W
	.global FF43_R
	.global FF43_W
	.global FF44_R
	.global FF44_W
	.global FF45_R
	.global FF45_W
	.global FF46_W
	.global FF47_R
	.global FF47_W
	.global FF48_R
	.global FF48_W
	.global FF49_R
	.global FF49_W
	.global FF4A_R
	.global FF4A_W
	.global FF4B_R
	.global FF4B_W
	.global FF4F_W
	.global FF4F_R

	.global FF68_R	@BCPS - BG Color Palette Specification
	.global FF69_R	@BCPD - BG Color Palette Data
	.global FF6A_R	@OCPS - OBJ Color Palette Specification
	.global FF6B_R	@OCPD - OBJ Color Palette Data

	.global FF68_W	@BCPS - BG Color Palette Specification
	.global FF69_W	@BCPD - BG Color Palette Data
	.global FF6A_W	@OCPS - OBJ Color Palette Specification
	.global FF6B_W	@OCPD - OBJ Color Palette Data

	.global OAM_W
	.global OAM_R

	.global vram_W
	.global vram_W2
	.global debug_
	.global AGBinput
	.global EMUinput
	.global paletteinit
	.global PaletteTxAll
	.global transfer_palette
	.global update_sgb_palette
	.global newframe
	.global lcdstate
	.global gammavalue
	.global palettebank
	.global resetlcdregs
	.global fpsenabled
	.global FPSValue
	.global vbldummy
	.global vblankfptr
	.global vcountfptr
	.global vblankinterrupt
	.global gbc_palette
	.global vcountinterrupt
	.global WINDOWBUFF

@	EXPORT DISPCNTBUFF
@	EXPORT BG0CNTBUFF
@	EXPORT SCROLLBUFF1
@	EXPORT SCROLLBUFF2
@	EXPORT DMA0BUFF


 .align
 .pool
 .text
 .align
 .pool

@----------------------------------------------------------------------------
GBPalettes:@ RGB 24bit.

@yellow
	.byte 0xF3,0xFF,0x33, 0xC1,0xCE,0x22, 0x6F,0x7B,0x11, 0x00,0x00,0x00		@BG
	.byte 0xF3,0xFF,0x33, 0xC1,0xCE,0x22, 0x6F,0x7B,0x11, 0x00,0x00,0x00		@WIN
	.byte 0xF3,0xFF,0x33, 0xC1,0xCE,0x22, 0x6F,0x7B,0x11, 0x00,0x00,0x00		@OB0
	.byte 0xF3,0xFF,0x33, 0xC1,0xCE,0x22, 0x6F,0x7B,0x11, 0x00,0x00,0x00		@OB1
@grey
	.byte 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	.byte 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	.byte 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	.byte 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
@multi1
	.byte 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	.byte 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	.byte 0xEF,0xEF,0xFF, 0x5A,0x8C,0xE7, 0x18,0x4A,0x9C, 0x00,0x00,0x00
	.byte 0xFF,0xEF,0xEF, 0xEF,0x5A,0x63, 0xAD,0x10,0x18, 0x00,0x00,0x00
@multi2
	.byte 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	.byte 0xE7,0xEF,0xD6, 0xC6,0xDE,0x8C, 0x6B,0x84,0x29, 0x00,0x00,0x00
	.byte 0xFF,0xFF,0xFF, 0xEF,0x5A,0x63, 0xAD,0x10,0x18, 0x00,0x00,0x00
	.byte 0xFF,0xFF,0xFF, 0x5A,0x8C,0xE7, 0x18,0x4A,0x9C, 0x00,0x00,0x00
@Zelda.
	.byte 0xFF,0xFF,0xA0, 0x67,0xD7,0x67, 0x8C,0x55,0x20, 0x46,0x15,0x07
	.byte 0xFF,0xFF,0xAD, 0x80,0x80,0xB7, 0x25,0x29,0x59, 0x00,0x00,0x00
	.byte 0xFF,0xB0,0x7F, 0x5A,0x8C,0xE7, 0x18,0x4A,0x9C, 0x00,0x00,0x00
	.byte 0xFF,0xEF,0xEF, 0xEF,0x5A,0x63, 0xAD,0x10,0x18, 0x00,0x00,0x00
@Metroid
	.byte 0xDF,0xDF,0x7F, 0x00,0x5F,0xAF, 0x1F,0x3F,0x1F, 0x00,0x00,0x00
	.byte 0xFF,0xDF,0x00, 0x80,0xFF,0xFF, 0x00,0x80,0x80, 0x00,0x00,0x00
	.byte 0xFF,0xDF,0x00, 0xFF,0x00,0x00, 0x3F,0x37,0x00, 0x00,0x00,0x00
	.byte 0xFF,0xFF,0xFF, 0xC0,0xC0,0xC0, 0x80,0x80,0x80, 0x00,0x00,0x00
@Adventure Island
	.byte 0xFF,0xFF,0xFF, 0x9C,0xB5,0xFF, 0x31,0x94,0x00, 0x00,0x00,0x00
	.byte 0xFF,0xFF,0xFF, 0xF7,0xCE,0x73, 0x8C,0x4A,0x08, 0x21,0x21,0x9C
	.byte 0xFF,0xFF,0xDE, 0xEF,0xC6,0x73, 0xFF,0x63,0x52, 0x00,0x00,0x29
	.byte 0xFF,0xFF,0xFF, 0xE7,0xA5,0xA5, 0x7B,0x29,0x29, 0x42,0x00,0x00
@Adventure Island 2
	.byte 0xFF,0xFF,0xFF, 0xF7,0xEF,0x75, 0x29,0x6B,0xBD, 0x00,0x00,0x00
	.byte 0xFF,0xFF,0xFF, 0xF7,0xCE,0x73, 0x8C,0x4A,0x08, 0x21,0x21,0x9C
	.byte 0xFF,0xFF,0xDE, 0xEF,0xC6,0x73, 0xFF,0x63,0x52, 0x00,0x00,0x29
	.byte 0xFF,0xFF,0xFF, 0xE7,0xA5,0xA5, 0x7B,0x29,0x29, 0x42,0x00,0x00
@Balloon Kid
	.byte 0xA5,0xD6,0xFF, 0xE7,0xEF,0xFF, 0xDE,0x8C,0x10, 0x5A,0x10,0x00
	.byte 0xFF,0xFF,0xFF, 0xF7,0xCE,0x73, 0x8C,0x4A,0x08, 0x21,0x21,0x9C
	.byte 0xFF,0xC6,0xC6, 0xFF,0x6B,0x6B, 0xFF,0x00,0x00, 0x63,0x00,0x00
	.byte 0xFF,0xFF,0xFF, 0xEF,0x42,0xEF, 0x7B,0x29,0x29, 0x42,0x00,0x00
@Batman
	.byte 0xFF,0xF7,0xEF, 0xC8,0x90,0x88, 0x84,0x50,0x44, 0x42,0x10,0x00
	.byte 0xFF,0xFF,0xFF, 0xA5,0xA5,0xFF, 0x52,0x52,0xBD, 0x00,0x00,0xA5
	.byte 0xFF,0xFF,0xFF, 0xA5,0xA5,0xC6, 0x52,0x52,0x8C, 0x00,0x00,0x5A
	.byte 0xFF,0xFF,0xFF, 0xAD,0xB5,0xBD, 0x5A,0x6B,0x7B, 0x08,0x21,0x42
@Batman - Return of the Joker
	.byte 0xFF,0xFF,0xFF, 0xA5,0xAD,0xBD, 0x52,0x5A,0x7B, 0x00,0x10,0x39
	.byte 0xFF,0xFF,0xFF, 0xA5,0xAD,0xBD, 0x52,0x5A,0x7B, 0x00,0x10,0x39
	.byte 0xFF,0xFF,0xFF, 0xA5,0xAD,0xBD, 0x52,0x5A,0x7B, 0x00,0x10,0x39
	.byte 0xFF,0xFF,0xFF, 0xAD,0xB5,0xBD, 0x5A,0x6B,0x7B, 0x08,0x21,0x42
@Bionic Commando
	.byte 0xEF,0xF7,0xFF, 0xCE,0xB5,0xAD, 0xC6,0x21,0x29, 0x39,0x00,0x00
	.byte 0xFF,0xFF,0xFF, 0x94,0xCE,0xF7, 0x10,0x39,0xFF, 0x00,0x00,0x4A
	.byte 0xFF,0xFF,0xFF, 0xFF,0xAD,0x84, 0x5A,0x39,0x00, 0x00,0x00,0x00
	.byte 0xEF,0xEF,0xEF, 0xAD,0xA5,0x9C, 0x6B,0x5A,0x5A, 0x42,0x10,0x08
@Castlevania Adventure
	.byte 0xD6,0xD6,0xE7, 0x8C,0xA5,0xB5, 0x42,0x52,0x6B, 0x00,0x10,0x18
	.byte 0xFF,0xFF,0xFF, 0xA5,0xA5,0xD6, 0x52,0x52,0xAD, 0x00,0x00,0x84
	.byte 0xFF,0xFF,0xFF, 0xFF,0xE7,0x84, 0xFF,0x52,0x42, 0x5A,0x00,0x00
	.byte 0xFF,0xFF,0xFF, 0xF7,0xEF,0xCE, 0xF7,0xDE,0x9C, 0xF7,0xB5,0x6B
@Dr. Mario
	.byte 0xFF,0xFF,0xFF, 0xFF,0xFF,0x66, 0x21,0x42,0xFF, 0x00,0x10,0x52
	.byte 0xFF,0xFF,0xFF, 0xAA,0xAA,0xD6, 0x55,0x55,0xAD, 0x00,0x00,0x84
	.byte 0xFF,0xFF,0xFF, 0xFF,0xE7,0x84, 0xFF,0x52,0x42, 0x8C,0x00,0x00
	.byte 0xFF,0xFF,0xFF, 0xFF,0xCE,0x8C, 0xF7,0x9C,0x5A, 0x84,0x52,0x00
@Kirby
	.byte 0xFF,0xFF,0x83, 0xFF,0xA5,0x3E, 0x73,0x42,0x00, 0x33,0x09,0x00
	.byte 0xCC,0xCC,0xFF, 0x77,0x78,0xFF, 0x23,0x35,0xC1, 0x05,0x0A,0x5A
	.byte 0xFF,0xBD,0xC4, 0xF1,0x4D,0x60, 0x9F,0x12,0x29, 0x20,0x00,0x00
	.byte 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
@Donkey Kong Land
	.byte 0xE2,0xFF,0xD1, 0xA9,0xFF,0x89, 0x51,0xA2,0x48, 0x04,0x25,0x03
	.byte 0xFF,0xB4,0xB4, 0xFF,0x47,0x47, 0x80,0x00,0x00, 0x00,0x00,0x00
	.byte 0xFF,0xF2,0xB0, 0xD6,0xC3,0x4D, 0xA3,0x5B,0x11, 0x6A,0x00,0x00
	.byte 0xF7,0xFF,0x63, 0xC6,0xCE,0x42, 0x73,0x7B,0x21, 0x00,0x00,0x00

move_ui:
	stmfd sp!,{globalptr}
	ldr globalptr,=GLOBAL_PTR_BASE
	ldr_ r1,_ui_y
	ldr_ r0,_ui_x
	mov r0,r0,lsl#8
	bic r0,r0,#0xFF000000
	orr r0,r0,r1,lsl#24
	ldrb_ r1,_ui_border_visible
	orr r0,r0,r1
	str_ r0,_ui_border_request
	ldmfd sp!,{globalptr}
	bx lr

GFX_init_irq:
	@install IRQ handler
	ldr r1,=AGB_IRQVECT
	ldr r2,=irqhandler
	str r2,[r1]

	mov r1,#REG_BASE
	mov r0,#0x0008
@	mov r0,#0x0028
	strh r0,[r1,#REG_DISPSTAT]	@vblank en

	add r2,r1,#REG_IE
	mov r0,#-1
	strh r0,[r2,#2]		@stop pending interrupts
@	ldr r0,=0x1081
@	strh r0,[r2]		;key,vblank,serial interrupt enable
	ldr r0,=0x1085
	strh r0,[r2]		@key,vcount,vblank,serial interrupt enable
	mov r0,#1
	strh r0,[r2,#8]		@master irq enable

	bx lr

@----------------------------------------------------------------------------
GFX_init:	@(called from main.c) only need to call once
@----------------------------------------------------------------------------
	mov addy,lr

	mov r1,#0xffffff00			@build chr decode tbl
	ldr r2,=CHR_DECODE
ppi0:	mov r0,#0
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
	ldr r1,=PALETTE_BASE			@clear some of the AGB Palette
	mov r2,#0x80/4
	bl filler_

	ldr r0,=0x5F405F40
	ldr r1,=DISPCNTBUFF			@clear DISPCNT+DMA1BUFF
	mov r2,#144/4
	bl filler_
	ldr r1,=DISPCNTBUFF2			@clear DISPCNT+DMA1BUFF
	mov r2,#144/4
	bl filler_

@	mov r1,#REG_BASE
@	mov r0,#8
@	strh r0,[r1,#REG_BLDY]		;darkness setting for faded screens (bigger number=darker)
@	ldr r0,=0x353A
@	strh r0,[r1,#REG_WININ]		;WinIN0/1, BG0 not enable in Win0
@	ldr r0,=0x3F20
@	strh r0,[r1,#REG_WINOUT]	;WinOUT0/1, Everything enabled outside Windows


@	add r0,r1,#REG_BG0HOFS		;DMA0 always goes here
@	str r0,[r1,#REG_DM0DAD]
@	mov r0,#1					;1 word transfer
@	strh r0,[r1,#REG_DM0CNT_L]
@@	ldr r0,=DMA0BUFF			;DMA0 src=
@@	str r0,[r1,#REG_DM0SAD]
@
@	str r1,[r1,#REG_DM1DAD]		;DMA1 goes here
@	mov r0,#1					;1 word transfer
@	strh r0,[r1,#REG_DM1CNT_L]

	bx addy
@----------------------------------------------------------------------------
GFX_reset:	@called with CPU reset
@----------------------------------------------------------------------------
	stmfd sp!,{addy,lr}

	mov r0,#0

@	ldr r1,=AGB_BG		;clear most of the GB VRAM
@	mov r2,#0x2000/4
@	bl filler_

@@--------
	@clear dirtytiles and dirtyrows
	ldr r1,=DIRTY_TILES
	mov r2,#(768+48+4)/4
	bl filler_
	
	@clear RECENT_TILENUM
	mvn r0,#0
	ldr r1,=RECENT_TILENUM
	mov r2,#(MAX_RECENT_TILES/2)+1
	bl filler_
	
	@clear RECENT_TILES for no reason
	mov r0,#0
	ldr r1,=RECENT_TILES
	mov r2,#(MAX_RECENT_TILES*16)/4
	bl filler_
	
	@clear XGB_VRAM
	ldr r1,=XGB_VRAM
	mov r2,#0x4000/4   @maybe this needs to change for 'resizable'
	bl filler_
	
	@clear GBA vram corresponding to XGB_VRAM
	ldr r1,=VRAM_BASE
	mov r2,#0x4000/4
	bl filler_
	ldr r1,=VRAM_BASE+0x8000
	mov r2,#0x4000/4
	bl filler_
	ldr r1,=VRAM_OBJ_BASE
	mov r2,#0x4000/4
	bl filler_
	@clear GBA tilemaps corresponding to XGB_VRAM
	ldr r1,=VRAM_BASE+0xD000
	mov r2,#0x3000/4
	bl filler_
	
	@clear GB OAM
	mov r0,#200
	ldr r1,=GBOAMBUFF1
	mov r2,#160/4
	bl filler_
	ldr r1,=GBOAMBUFF2
	mov r2,#160/4
	bl filler_

@@--------


	mov r0,#0
	bl_long FF4F_W
	
	@reset emu buffers FIXME
@	mov r0,#0
@	strb r0,frame_windowy
@	strb r0,active_windowy
@	strb r0,gboamdirty
	

	
	mov r0,#0
	strb_ r0,lcdstat		@flags off
	strb_ r0,scrollX
	strb_ r0,scrollY
	strb_ r0,windowX
	strb_ r0,windowY
	strb_ r0,lcdyc
	strb_ r0,vrambank
	strb_ r0,BCPS_index
	strb_ r0,OCPS_index
	strb_ r0,doublespeed
	str_ r0,dma_src @and dma_dest

	mov r0,#0x91
	strb_ r0,lcdctrl		@LCDC

	mov r1,#REG_BASE
	ldr r0,=(SCREEN_X_START*256 + (SCREEN_X_START+160))
	strh r0,[r1,#REG_WIN1H]		@Win0H
	ldr r0,=(SCREEN_Y_START*256 + (SCREEN_Y_START+144))
	strh r0,[r1,#REG_WIN1V]		@Win0V

@	mov r0,#0x0000
@	strh r0,[r1,#REG_BG3CNT]	;Border

	bl paletteinit
	mov r0,#0xfc
	strb_ r0,bgpalette
	mov r0,#0xff
	strb_ r0,ob0palette
	strb_ r0,ob1palette
	bl resetlcdregs
	@init the buffer filling engine
	mov r0,#0xFF
	strb_ r0,rendermode
	bl_long newframeinit

	ldrb_ r0,_ui_border_visible
	bic r0,r0,#2	@turn off border
	strb_ r0,_ui_border_visible
	bl move_ui
	
	bl_long update_ui_border_masks


	ldmfd sp!,{addy,lr}


	mov pc,lr

@@----------------------------------------------------------------------------
@move_ui
@@----------------------------------------------------------------------------
@	stmfd sp!,{r0-addy,lr}
@	ldr r0,=ui_x
@	ldr r0,[r0]
@	ldr r3,=ui_y
@	ldr r3,[r3]
@	orr r0,r0,r3,lsl#16
@	ldr r3,=BG0CNTBUFF+6
@	ldr r4,=DISPCNTBUFF
@	mov r1,#160
@	ldr r2,=dmascrollbuff
@	ldr r2,[r2]
@	add r2,r2,#12
@@	ldr r7,=DMA0BUFF
@@	add r7,r7,#12
@	ldr r8,=scrollbuff
@	ldr r8,[r8]
@	add r8,r8,#12
@@	ldr r7,=
@@	ldr r2,=DMA0BUFF
@@	ldr r6,=dmascrollbuff
@@	str r2,[r6]
@@	ldr r2,=DMA0BUFF+12
@	ldr r6,=0x5A0C
@move_ui_loop
@	str r0,[r2],#16
@@	str r0,[r7],#16
@	str r0,[r8],#16
@	ldrh r5,[r4]
@	orr r5,r5,#0x0800
@	strh r5,[r4],#2
@	strh r6,[r3],#8
@	subs r1,r1,#1
@	bne move_ui_loop
@
@	ldmfd sp!,{r0-addy,lr}
@	bx lr

@----------------------------------------------------------------------------
resetlcdregs:
@----------------------------------------------------------------------------
	str lr,[sp,#-4]!

@	ldrb r0,lcdctrl
@	bl_long FF40_W
	ldrb_ r0,lcdstat
	bl_long FF41_W
@	ldrb r0,scrollY
@	bl_long FF42_W
@	ldrb r0,scrollX
@	bl_long FF43_W
	ldrb_ r0,lcdyc
	bl_long FF45_W
@	ldrb r0,windowY
@	bl_long FF4A_W
@	ldrb r0,windowX
@	bl_long FF4B_W
	bl PaletteTxAll
	
	ldr pc,[sp],#4
@----------------------------------------------------------------------------
PaletteTxAll:@		also called from UI.c
@----------------------------------------------------------------------------
	str lr,[sp,#-4]!
	ldrb_ r0,bgpalette
	bl_long FF47_W
	ldrb_ r0,ob0palette
	bl_long FF48_W
	ldrb_ r0,ob1palette
	bl_long FF49_W
	bl copy_gbc_palette
	ldr lr,[sp],#4
	bx lr

copy_gbc_palette:
	@copy GBC palette
	ldr r1,=gbc_palette
	ldr r2,=gbc_palette2
	mov addy,#128
palcopyloop:
	ldr r0,[r1],#4
	str r0,[r2],#4
	subs addy,addy,#4
	bne palcopyloop
	bx lr

@----------------------------------------------------------------------------
paletteinit:@	r0-r3 modified.
@called by ui.c:  void map_palette(char gammavalue)
@----------------------------------------------------------------------------
	stmfd sp!,{r4-r7,globalptr,lr}
	ldr globalptr,=GLOBAL_PTR_BASE
	ldr r7,=GBPalettes
	ldr_ r1,_palettebank	@Which color set (yellow, grey...)
	add r1,r1,r1,lsl#1	@r1 x 3
	add r7,r7,r1,lsl#4	@r7 + r1 x 16
	ldr r6,=SGB_PALETTE
@	ldrb r1,gammavalue	;gamma value = 0 -> 4
	mov r4,#16
nomap:					@map rrrrrrrrggggggggbbbbbbbb  ->  0bbbbbgggggrrrrr
	ldrb r0,[r7],#1		@Red ready
@	bl gammaconvert
	mov r0,r0,lsr#3
	mov r5,r0

	ldrb r0,[r7],#1		@Green ready
@	bl gammaconvert
	mov r0,r0,lsr#3
	orr r5,r5,r0,lsl#5

	ldrb r0,[r7],#1		@Blue ready
@	bl gammaconvert
	mov r0,r0,lsr#3
	orr r5,r5,r0,lsl#10

	strh r5,[r6],#2
	subs r4,r4,#1
	bpl nomap

	ldmfd sp!,{r4-r7,globalptr,lr}
	bx lr

@----------------------------------------------------------------------------
transfer_palette:
@----------------------------------------------------------------------------
	stmfd sp!,{r0-r9,globalptr,lr}
	ldr globalptr,=GLOBAL_PTR_BASE
	
	ldrb_ r0,update_border_palette
	movs r0,r0
	movne r0,#0
	strneb_ r0,update_border_palette
	blne update_the_border_palette

	ldr r4,=PALETTE_BASE+256

	ldrb_ r2,sgb_mask
	cmp r2,#2
	bge sgb_mask_palette

	ldrb_ r2,lcdctrl0frame
	tst r2,#0x80 @screen off?
	beq white_palette
	
	ldr r5,=gbc_palette2
	
	mov r8,#16 @16 palettes

	ldrb_ r1,_gammavalue
	movs r1,r1   
	beq nogamma1
	
pal_loop1:
	mov r9,#4
pal_loop11:
	bl gamma_convert_one
	
	subs r9,r9,#1
	bne pal_loop11
	add r4,r4,#24
	subs r8,r8,#1
	bne pal_loop1
	b aftergamma
nogamma1:
pal_loop2:
	ldmia r5!,{r0,r1}
	stmia r4,{r0,r1}
	add r4,r4,#32
	subs r8,r8,#1
	bne pal_loop2
aftergamma:	
	
	@Copy SGB palette to first entry based on UI selection, this will be removed when proper coloizing is supported
	ldrb_ r0,sgbmode
	movs r0,r0
	beq 9f
	ldrb_ r0,_sgb_palette_number
	movs r0,r0
	beq 9f
	ldr r2,=PALETTE_BASE+0x100
	ldr r1,[r2,r0,lsl#5]
	str r1,[r2]
	add r2,r2,#4
	ldr r1,[r2,r0,lsl#5]
	str r1,[r2]
	ldr r2,=PALETTE_BASE+0x200
	ldr r1,[r2,r0,lsl#6]
	str r1,[r2]
	add r2,r2,#4
	ldr r1,[r2,r0,lsl#6]
	str r1,[r2]
	add r2,r2,#0x1C
	ldr r1,[r2,r0,lsl#6]
	str r1,[r2]
	add r2,r2,#4
	ldr r1,[r2,r0,lsl#6]
	str r1,[r2]
9:	
	@for the hell of it, copy first transparent color to color zero
	@DELETEME?
	@only do it if SGB border is visible
	ldrb_ r0,_ui_border_screen
	tst r0,#2
	
	@otherwise pick black border?
	ldr r0,=PALETTE_BASE
	ldr r1,=PALETTE_BASE+0x100
	ldrneh r3,[r1]
	moveq r3,#0
	strh r3,[r0]
	
	@now copy first 8 transparent colors to solid blocks
	ldr r0,=PALETTE_BASE+0xF0
	ldr r1,=PALETTE_BASE+0x100
	mov r2,#8
pal_loop3:
	ldrh r3,[r1],#32
	strh r3,[r0],#2
	
	subs r2,r2,#1
	bne pal_loop3
	
	ldmfd sp!,{r0-r9,globalptr,lr}
	bx lr


white_palette:
	ldrb_ r0,gbcmode
	movs r0,r0
	mvn r0,#0
	bne 3f
	mov r2,#4
sgb_mask_palette:
	mov r0,#0
	cmp r2,#4
	ldreq r0,=SGB_PALETTE @if 3, use black, if 4, use SGB color #0
	ldreqh r0,[r0]
	orreq r0,r0,r0,lsl#16
3:
	mov r1,r0
	mov r2,#16
whitepal_loop:
	stmia r4,{r0,r1}
	add r4,r4,#32
	subs r2,r2,#1
	bne whitepal_loop
	b aftergamma

update_the_border_palette:
	stmfd sp!,{lr}
	
	ldr r4,=PALETTE_BASE+32
	ldr r5,=BORDER_PALETTE
	
	mov r9,#64 @64 colors

	ldrb_ r1,_gammavalue
	movs r1,r1
	beq 1f
	
0:
	bl gamma_convert_one
	subs r9,r9,#1
	bne 0b
	ldmfd sp!,{pc}
	
1:
	ldr r0,[r5],#4
	str r0,[r4],#4
	subs r9,r9,#2
	bne 1b
	ldmfd sp!,{pc}


gamma_convert_one:
	@r5 = src, r4 = dest
	stmfd sp!,{lr}

	ldrh r6,[r5],#2 @read color
	ands r0,r6,#0x1F  @red gamma
	addne r0,r0,#1
	mov r0,r0,lsl#3
	subne r0,r0,#1
	bl gammaconvert
	mov r7,r0
	ands r0,r6,#0x3E0 @green gamma
	addne r0,r0,#0x20
	mov r0,r0,lsr#2
	subne r0,r0,#1
	bl gammaconvert
	orr r7,r7,r0,lsl#5
	ands r0,r6,#0x7C00 @blue gamma
	addne r0,r0,#400
	mov r0,r0,lsr#7
	subne r0,r0,#1
	bl gammaconvert
	orr r7,r7,r0,lsl#10 @all combined
	strh r7,[r4],#2
	
	ldmfd sp!,{pc}



@----------------------------------------------------------------------------
gammaconvert:@	takes value in r0(0-0xFF), gamma in r1(0-4),returns new value in r0=0x1F
@----------------------------------------------------------------------------
	rsb r2,r0,#0x100
	mul r3,r2,r2
	rsbs r2,r3,#0x10000
	rsb r3,r1,#4
	orr r0,r0,r0,lsl#8
	mul r2,r1,r2
	mla r0,r3,r0,r2
	mov r0,r0,lsr#13
	bx lr
@----------------------------------------------------------------------------
showfps_:		@fps output, r0-r3=used.
@----------------------------------------------------------------------------
	ldr r2,=fpsenabled
	ldrb r0,[r2,#1] @fpschk
	subs r0,r0,#1
	movmi r0,#59
	strb r0,[r2,#1]
	bxpl lr					@End if not 60 frames has passed

 .if RUMBLE
	str lr,[sp,#-4]!
	ldr r1,=StartRumbleComs
	adr lr,ret_
	bx r1
ret_:
	ldr lr,[sp],#4
	ldr r2,=fpsenabled
 .endif


	ldrb r0,[r2,#0]
	tst r0,#1
	bxeq lr					@End if not enabled

	ldr_ r0,fpsvalue
	cmp r0,#0
	bxeq lr					@End if fps==0, to keep it from appearing in the menu
	mov r1,#0
	str_ r1,fpsvalue

	mov r1,#100
	swi 0x060000			@Division r0/r1, r0=result, r1=remainder.
	add r0,r0,#0x30
	strb r0,[r2,#-3]@fpstext+5
	mov r0,r1
	mov r1,#10
	swi 0x060000			@Division r0/r1, r0=result, r1=remainder.
	add r0,r0,#0x30
	strb r0,[r2,#-2]@fpstext+6
	add r1,r1,#0x30
	strb r1,[r2,#-1]@fpstext+7
	

	ldr r0,=fpstext
	ldr r2,=DEBUGSCREEN
@	add r2,r2,r1,lsl#6
db1:
	ldrb r1,[r0],#1
	orr r1,r1,#0x5000
	sub r1,r1,#32
	strh r1,[r2],#2
	tst r2,#15
	bne db1

	bx lr
@----------------------------------------------------------------------------
debug_:		@debug output, r0=val, r1=line, r2=used.
@----------------------------------------------------------------------------
 .if DEBUG
	ldr r2,=DEBUGSCREEN
	add r2,r2,r1,lsl#6
db0:
	mov r0,r0,ror#28
	and r1,r0,#0x0f
	cmp r1,#9
	addhi r1,r1,#7
	add r1,r1,#0x30
	orr r1,r1,#0x4100
	strh r1,[r2],#2
	tst r2,#15
	bne db0
 .endif
	bx lr

update_sgb_palette:
	stmfd sp!,{lr}
	bl update_sgb_bg_palette
	bl update_sgb_obj0_palette
	bl update_sgb_obj1_palette
	ldmfd sp!,{pc}

update_sgb_bg_palette:
	stmfd sp!,{lr}
	ldrb_ r0,bgpalette
	ldr r2,=gbc_palette
	ldr addy,=SGB_PALETTE
	bl_long dopalette
	ldr r2,=gbc_palette+8
	ldr addy,=SGB_PALETTE+8
	bl_long dopalette
	ldr r2,=gbc_palette+16
	ldr addy,=SGB_PALETTE+16
	bl_long dopalette
	ldr r2,=gbc_palette+24
	ldr addy,=SGB_PALETTE+24
	bl_long dopalette
	ldmfd sp!,{pc}

update_sgb_obj0_palette:
	stmfd sp!,{lr}
	ldrb_ r0,ob0palette
	ldr r2,=gbc_palette+64
	ldr addy,=SGB_PALETTE
	bl_long dopalette
	ldr r2,=gbc_palette+80
	ldr addy,=SGB_PALETTE+8
	bl_long dopalette
	ldr r2,=gbc_palette+96
	ldr addy,=SGB_PALETTE+16
	bl_long dopalette
	ldr r2,=gbc_palette+112
	ldr addy,=SGB_PALETTE+24
	bl_long dopalette
	ldmfd sp!,{pc}
update_sgb_obj1_palette:
	stmfd sp!,{lr}
	ldrb_ r0,ob1palette
	ldr r2,=gbc_palette+64+8
	ldr addy,=SGB_PALETTE
	bl_long dopalette
	ldr r2,=gbc_palette+80+8
	ldr addy,=SGB_PALETTE+8
	bl_long dopalette
	ldr r2,=gbc_palette+96+8
	ldr addy,=SGB_PALETTE+16
	bl_long dopalette
	ldr r2,=gbc_palette+112+8
	ldr addy,=SGB_PALETTE+24
	bl_long dopalette
	ldmfd sp!,{pc}


 .align
 .pool
 .section .iwram, "ax", %progbits
 .subsection 2
 .align
 .pool
 decodeptr	.req r2 @mem_chr_decode
 gbcptr		.req r4 @chr src
 d_tiles		.req r5 @dirtytiles
 d_rows		.req r6 @dirtyrows
 tilenum		.req r8
 r_tiles 	.req r9
 r_tnum		.req r7
 tilesleft	.req r11
 agbptr_1	.req r3  @shared with ldmia/stmia copy registers
 agbptr_2	.req r12
 agbptr_3	.req r11 @shared with tilesleft

@So here's the new tile update system

@update_tile_hook isn't used yet, but I could replace storing/drawing with just drawing.  Probably should do that.
update_tile_hook: .word store_recent_tile
@this determines whether to draw stored tiles, or just fail when the tile buffer gets full.  When I replace storing/drawing with just drawing, I won't need this.
@recent_tiles_full_hook DCD abort_recent_tiles
init_hook: .word storetiles_init

consumedirty_init:
	ldr r0,=render_dirty_tile
	str r0,update_tile_hook
	mov r_tnum,#0
	ldr decodeptr,=CHR_DECODE
	bx lr
storetiles_init:
	ldr r0,=store_recent_tile
	str r0,update_tile_hook
@	ldr r0,=abort_recent_tiles
@	str r0,recent_tiles_full_hook
	ldr r_tiles,=RECENT_TILES
	ldr r_tnum,=RECENT_TILENUM
	mov tilesleft,#MAX_RECENT_TILES
	
	@seek through recent tiles for first empty slot
storetiles_init_seek_empty_loop:
	ldrh r0,[r_tnum]
	tst r0,#0x8000
	bne storetiles_init_firstempty
	subs tilesleft,tilesleft,#1
	beq storetiles_init_full
	add r_tnum,r_tnum,#2
	add r_tiles,r_tiles,#16
	b storetiles_init_seek_empty_loop
	
storetiles_init_firstempty:
	bx lr

storetiles_init_full:
	bx lr

@Directly consume dirty tiles
consume_dirty_tiles:
	ldrb_ r0,consume_dirty
	movs r0,r0
	bxeq lr
	mov r0,#0
	strb_ r0,consume_dirty

	ldr r0,=consumedirty_init
	b set_init_hook_
@Store dirty tiles into a cache
gbc_chr_update:
	ldr r0,=storetiles_init
set_init_hook_:
	str r0,init_hook
check_dirty_rows:
	@first - check if any tiles are dirty the fast way, look at all rows
	ldr addy,=DIRTY_ROWS
	ldmia addy!,{r0-r2}
	orrs r0,r0,r1
	orreqs r0,r0,r2
	ldmeqia addy!,{r0-r2}
	orreqs r0,r0,r1
	orreqs r0,r0,r2
	ldmeqia addy!,{r0-r2}
	orreqs r0,r0,r1
	orreqs r0,r0,r2
	ldmeqia addy!,{r0-r2}
	orreqs r0,r0,r1
	orreqs r0,r0,r2
	bxeq lr @quit if tiles are clean
	
	stmfd sp!,{r0-r12,lr}
	bl process_dirty_tiles
	ldmfd sp!,{r0-r12,pc}

process_dirty_tiles:
	stmfd sp!,{lr}
	mov lr,pc
	ldr pc,init_hook
update_tiles:
	@push lr before entering here
	ldr d_rows,=DIRTY_ROWS
	ldr d_tiles,=DIRTY_TILES
updatetiles:
	@coarse version on words
	mov tilenum,#0
updatetiles_loop:
	cmp tilenum,#768
	bge updatetiles_done
	ldr r0,[d_rows,tilenum,lsr#4]
	movs r0,r0
	bne updatetiles_fine
	add tilenum,tilenum,#64
	b updatetiles_loop

updatetiles_fine:
	@fine - operates on bytes
	@jump here only from 64-aligned tilenum, r0=word from dirtyrows
	tst r0,#0x000000FF
	addeq tilenum,tilenum,#16
	tsteq r0,#0x0000FF00
	addeq tilenum,tilenum,#16
	tsteq r0,#0x00FF0000
	addeq tilenum,tilenum,#16

updaterow_loop:
	ldrb r0,[d_tiles,tilenum]
	movs r0,r0
@@
	ldrne pc,update_tile_hook
@was	bne store_recent_tile
	add tilenum,tilenum,#1
backto_updaterow_loop:
	tst tilenum,#0x0F
	bne updaterow_loop
updatetiles_resume:
	tst tilenum,#63
	beq updatetiles_loop
updatetiles_fine2:
	@byte aligned version of updatetiles, jumps back once aligned
	ldrb r0,[d_rows,tilenum,lsr#4]
	movs r0,r0
	bne updaterow_loop
	add tilenum,tilenum,#16
	b updatetiles_resume

get_agb_vram_address:
	ldr agbptr_1,=VRAM_BASE
	and r1,tilenum,#0x7F
	add agbptr_1,agbptr_1,r1,lsl#5
	subs r0,tilenum,#384
	movlt r0,tilenum
	addge agbptr_1,agbptr_1,#0x2000
	tst r0,#0x100
	addne agbptr_3,agbptr_1,#0x8000  @255-383: bg 8000
	addne agbptr_2,agbptr_1,#0x8000
	addne agbptr_1,agbptr_1,#0x8000
	bxne lr
	tst r0,#0x080
	addeq agbptr_3,agbptr_1,#0x10000 @0-127: sprite 0000, bg 0000
	addeq agbptr_2,agbptr_1,#0x0000
	addeq agbptr_1,agbptr_1,#0x0000

	addne agbptr_3,agbptr_1,#0x11000 @128-255: sprite 1000, bg 1000, bg 9000
	addne agbptr_2,agbptr_1,#0x9000
	addne agbptr_1,agbptr_1,#0x1000

	bx lr

render_dirty_tile:
	bl get_agb_vram_address
	ldr gbcptr,=XGB_VRAM
	add gbcptr,gbcptr,r0,lsl#4
	cmp tilenum,#384
	addge gbcptr,gbcptr,#0x2000

render_dirty_tile_loop:
	ldrb r0,[gbcptr],#1  @first plane
	ldrb r1,[gbcptr],#1  @second plane

	ldr r0,[decodeptr,r0,lsl#2]
	ldr r1,[decodeptr,r1,lsl#2]
	orr r0,r0,r1,lsl#1
	
	str r0,[agbptr_1],#4
	str r0,[agbptr_2],#4
	str r0,[agbptr_3],#4
	tst agbptr_1,#0x1F @finished with AGB tile?
	bne render_dirty_tile_loop
	@next tile
	mov r0,#0
	strb r0,[d_tiles,tilenum]
	add tilenum,tilenum,#1
	ldrb r0,[d_tiles,tilenum]
	movs r0,r0
	beq backto_updaterow_loop
	tst tilenum,#0x7F
	bne render_dirty_tile_loop
	b render_dirty_tile

store_recent_tile:
	ldr gbcptr,=XGB_VRAM
	subs r0,tilenum,#384
	movlt r0,tilenum
	add gbcptr,gbcptr,r0,lsl#4
	addge gbcptr,gbcptr,#0x2000
storetileloop:
	subs tilesleft,tilesleft,#1
@@@@
@@	movmi lr,pc
@@	ldrmi pc,recent_tiles_full_hook
@was	blmi flush_recent_tiles
	bmi abort_recent_tiles

	ldmia gbcptr!,{r0-r3}
	stmia r_tiles!,{r0-r3}
	strh tilenum,[r_tnum],#2
	mov r0,#0
	strb r0,[d_tiles,tilenum]
	add tilenum,tilenum,#1
	ldrb r0,[d_tiles,tilenum]
	movs r0,r0
	beq backto_updaterow_loop
	cmp tilenum,#384
	bne storetileloop
	b store_recent_tile

abort_recent_tiles:
	mov r0,#1
	strb_ r0,consume_dirty
@@	strb r0,recenttilesfull
	mov r0,#0x8000
	strh r0,[r_tnum]
	ldmfd sp!,{pc}
	
updatetiles_done:
	mov r0,#0x8000
	movs r_tnum,r_tnum
	strneh r0,[r_tnum]
	mov r1,#12
	mov r0,#0
0:	
	str r0,[d_rows],#4
	subs r1,r1,#1
	bne 0b
	ldmfd sp!,{pc}

@flush_recent_tiles
@	stmfd sp!,{r4,r7-r9,lr}
@	bl consume_recent_tiles_entry
@	ldr r_tiles,recent_tiles
@	ldr r_tnum,recent_tilenum
@	stmfd sp!,{r5,r6}
@	bl render_recent_tiles
@	mov tilesleft,#MAX_RECENT_TILES-1
@	ldmfd sp!,{r5,r6}
@	ldmfd sp!,{r4,r7-r9,pc}

consume_recent_tiles:
	ldrb_ r0,consume_buffer
	movs r0,r0
	bxeq lr
	mov r0,#0
	strb_ r0,consume_buffer
	
	stmfd sp!,{lr}
	
@	ldrb r0,recenttilesfull
@	movs r0,r0
@	beq consume_recent_tiles_entry
@	
@	stmfd sp!,{r0-addy,lr}
@	bl consume_recent_tiles_entry
@	mov r0,#0
@	str r0,recenttilesfull
@	ldr r0,=flush_recent_tiles
@	str r0,recent_tiles_full_hook
@	bl flush_dirty_tiles
@	bl flush_recent_tiles
@	ldmfd sp!,{r0-addy,pc}
@consume_recent_tiles_entry
	ldr decodeptr,=CHR_DECODE
	ldr r_tiles,=RECENT_TILES
	ldr r_tnum,=RECENT_TILENUM
	mov r0,#0x8000
	ldrh tilenum,[r_tnum]
	strh r0,[r_tnum],#2
@	b render_next_tile
@	
@render_recent_tiles
@	ldr decodeptr,=CHR_DECODE
@	ldrh tilenum,[r_tnum],#2
consume_next_tile:
	tst tilenum,#0x8000
	ldmnefd sp!,{pc}
	
	bl get_agb_vram_address
consume_tile_loop:
	ldrb r0,[r_tiles],#1  @first plane
	ldrb r1,[r_tiles],#1  @second plane

	ldr r0,[decodeptr,r0,lsl#2]
	ldr r1,[decodeptr,r1,lsl#2]
	orr r0,r0,r1,lsl#1
	
	str r0,[agbptr_1],#4
	str r0,[agbptr_2],#4
	str r0,[agbptr_3],#4
	tst agbptr_1,#0x1F @finished with AGB tile?
	bne consume_tile_loop
	@next tile
	add r0,tilenum,#1
	ldrh tilenum,[r_tnum],#2
	cmp r0,tilenum
	bne consume_next_tile
	tst tilenum,#0x7F  @crossing 128 tile boundary?
	bne consume_tile_loop
	b consume_next_tile

 .align
 .pool
 .section .iwram, "ax", %progbits
 .subsection 1
 .align
 .pool
irqhandler:	@r0-r3,r12 are safe to use
@----------------------------------------------------------------------------
	mov r2,#REG_BASE
	mov r3,#REG_BASE
	ldr r1,[r2,#REG_IE]!
	and r1,r1,r1,lsr#16	@r1=IE&IF
	ldrh r0,[r3,#-8]
	orr r0,r0,r1
	strh r0,[r3,#-8]

		@---this CAN'T be interrupted
		ands r0,r1,#0x80
		strneh r0,[r2,#2]		@IF clear
		ldrne r12,serialfptr
		bxne r12
		@---
		adr r12,irq0

		@---this CAN be interrupted
		ands r0,r1,#0x01
		ldrne r12,vblankfptr
		bne jmpintr
		ands r0,r1,#0x04
		ldrne r12,vcountfptr
		bne jmpintr
		
		@----
		moveq r0,r1				@if unknown interrupt occured clear it.
jmpintr:
	strh r0,[r2,#2]				@IF clear

	mrs r3,spsr
	stmfd sp!,{r3,lr}
	mrs r3,cpsr
	bic r3,r3,#0x9f
	orr r3,r3,#0x1f				@--> Enable IRQ & FIQ. Set CPU mode to System.
	msr cpsr_cf,r3
	stmfd sp!,{lr}
	adr lr,irq0

	bx r12


irq0:
	ldmfd sp!,{lr}
	mrs r3,cpsr
	bic r3,r3,#0x9f
	orr r3,r3,#0x92        		@--> Disable IRQ. Enable FIQ. Set CPU mode to IRQ
	msr cpsr_cf,r3
	ldmfd sp!,{r0,lr}
	msr spsr_cf,r0
vbldummy:
	bx lr
@----------------------------------------------------------------------------
vblankfptr: .word vbldummy			@later switched to vblankinterrupt
@serialfptr DCD serialinterrupt
 .if RUMBLE
serialfptr: .word RumbleInterrupt
 .else
serialfptr: .word vbldummy
 .endif
vcountfptr: .word vcountinterrupt
vcountstate: .word 0
vblankinterrupt:@
@----------------------------------------------------------------------------
	stmfd sp!,{r4-addy,lr}
	ldr globalptr,=GLOBAL_PTR_BASE
	
	mov r0,#1
	strb_ r0,vblank_happened
	
	bl display_frame
		
	bl display_sprites
	bl consume_recent_tiles
	bl consume_dirty_tiles
	
	bl_long showfps_
	
	mov r2,#REG_BASE
	
	@write buffer values for scanline 0
	ldr_ r1,bigbufferbase2
	ldmia r1,{r3-r8}
	
@	;force first 8 scanlines to contain UI?
@	;for this to work, you need to enable it at reg_winout, then suppress it afterwards
@	ldrb r1,_ui_border_visible
@	tst r1,#1
@	bne %f0
@	tst r1,#2
@	ldr r0,_ui_x
@	bic r0,r0,#0xFF000000
@	bic r0,r0,#0x00FF0000
@	ldr r1,_ui_y
@	orr r0,r0,r1,lsl#16
@	biceq r4,r4,#0xFF000000
@	biceq r4,r4,#0x00FF0000
@	orreq r4,r4,#0x4E000000
@	orreq r4,r4,#0x000C0000
@	moveq r8,r0
@	bicne r4,r4,#0xFF00
@	bicne r4,r4,#0x00FF
@	orrne r4,r4,#0x4E00
@	orrne r4,r4,#0x000C
@	movne r7,r0
@0
	
	
	
	add r1,r2,#REG_BG0CNT
	stmia r1,{r3-r8}
	
	
	
	
	mov r0,#0
	strh r0,[r2,#REG_WIN0H]
	
	ldr_ r1,dispcntbase2
	ldrh r0,[r1]
	bic r0,r0,#0x2000 @remove window 0 if present
	strh r0,[r2,#REG_DISPCNT]
	
	@finish up the job at scanline 7, writing new values as scanline 8 starts
	ldr r0,=do_gba_hdma
	str r0,vcountfptr

	ldr r0,=0x28  + 256*(SCREEN_Y_START-1) @scanline 7, enable vblank+vcount interrupts
	strh r0,[r2,#REG_DISPSTAT]

	bl_long transfer_palette

	ldmfd sp!,{r4-addy,pc}

@@@@@@@
@@@@@@
@@@@@
@@@@
@@@
@@
@

newframeinit:
	mov r0,#0
	strb_ r0,buffer_lastscanline

	ldr_ r0,bigbufferbase@2
	str_ r0,bigbuffer
	ldr_ r0,dispcntbase@2
	str_ r0,dispcntaddr

	mvn r0,#(SCREEN_Y_START-1)  @-8
	mov r0,r0,lsl#16
	str_ r0,windowyscroll
	
	
	
	@fall thru to newmode  (calls newmode then returns)

newmode:
	ldrb_ r0,lcdctrl
	tst r0,#0x20
	beq entermode0
	
	ldr_ r0,hblankposition  @if cycles >=hblankposition, inside hblank
	cmp cycles,r0
	ldrb_ r0,scanline
	addmi r0,r0,#1
	cmp r0,#144
	movge r0,#0
	ldrb_ r1,windowY
	cmp r0,r1
	blt entermode0
	
	ldrb_ r1,windowX
	cmp r1,#166
	bgt entermode0
	cmp r1,#7
	ble entermode1

	@r1=bigbuffer
	@r2=bg01cnt
	@r3=bg23cnt
	@r4=xyscroll
	@r5=xyscroll2
	
	@dispcntdata
	@windata
	@dispcntaddr
entermode2:
@	ldrb r0,rendermode
@	cmp r0,#2
@	moveq r1,pc
@	bxeq lr
entermode2_:
	mov r0,#2
	strb_ r0,rendermode
	@get LCDC
	ldrb_ r0,lcdctrl
	@default dispcnt | enable win 0, win 1, all 4 bg layers
	ldr r1,=0x5F40 | 0x6F00
	tst r0,#0x02 @sprite enable
	biceq r1,r1,#0x1000
	tst r0,#0x80 @screen off?
@	orreq r1,r1,#0x0F00  ;enable all layers, not necessary since they are on
	biceq r1,r1,#0x3000  @disable win 0, sprites, let the white palette mask the screen
	orr r1,r1,r1,lsl#16
	str_ r1,dispcntdata
	
	@default bgXcnt: 000mmmmm000cccpp
	ldr r1,=0x1A02
	tst r0,#0x10 @Tile Select
	orreq r1,r1,#0x0008

	orr r1,r1,r1,lsl#16
	tst r0,#0x08 @BG Tilemap
	addne r1,r1,#0x0300
	tst r0,#0x40 @Win Tilemap
	addne r1,r1,#0x03000000

	orr r1,r1,#0x00010000 @priority fix?

	tst r0,#0x01 @BG enable
	bne 0f
	ldrb_ r0,gbcmode
	cmp r0,#1
	orreq r1,r1,#0x0003	@For GBC, low priority for all layers
	addne r1,r1,#0x0100	@For non-gbc, make all tiles color zero
	bicne r1,r1,#0x000C
0:
	str_ r1,bg01cnt
	add r1,r1,#0x00000100 @for color 0 tiles (BG)
	add r1,r1,#0x01000000
	bic r1,r1,#0x0000000C
	bic r1,r1,#0x000C0000
	str_ r1,bg23cnt

mode2_update_scroll:
	ldr_ r1,windowyscroll
	
	@get wx
	ldrb_ r0,windowX
	
	@wx to screen scroll
	rsb r0,r0,#0
	sub r0,r0,#(SCREEN_X_START-7)
	mov r0,r0,lsl#16
	orr r1,r1,r0,lsr#16
	str_ r1,xyscroll2
	
	@wx to GBA window position
	rsb r0,r0,#0
	mov r0,r0,lsr#8
	orr r0,r0,#(SCREEN_X_START+160)
	orr r0,r0,r0,lsl#16
	str_ r0,windata
	
	@get y pos
	ldrb_ r0,scrollY
	sub r0,r0,#SCREEN_Y_START
	mov r1,r0,lsl#16
	
	@get x pos
	ldrb_ r0,scrollX
	sub r0,r0,#SCREEN_X_START
	mov r0,r0,lsl#16
	orr r1,r1,r0,lsr#16
	str_ r1,xyscroll
	bx lr
	
@nowindow
entermode0:
@	ldrb r0,rendermode
@	cmp r0,#0
@	moveq r1,pc
@	bxeq lr
entermode0_:
	mov r0,#0
	strb_ r0,rendermode
	@get LCDC
	ldrb_ r0,lcdctrl
	
	@default dispcnt, win 1, all 4 bg layers
	ldr r1,=0x5F40
	tst r0,#0x02 @sprite enable
	biceq r1,r1,#0x1000
	orr r1,r1,r1,lsl#16
	str_ r1,dispcntdata
	
	@default bgXcnt: 000mmmmm000cccpp
	ldr r1,=0x1A02
	tst r0,#0x10 @Tile Select
	orreq r1,r1,#0x0008
	tst r0,#0x08 @BG Tilemap
	addne r1,r1,#0x0300
	orr r1,r1,r1,lsl#16
	add r1,r1,#0x01000000 @for color 0 tiles
	orr r1,r1,#0x00010000
	bic r1,r1,#0x000C0000
	tst r0,#0x01 @BG enable
	bne 0f
	ldrb_ r0,gbcmode
	cmp r0,#1
	addne r1,r1,#0x0100
@	orrne r1,r1,#0x0001  ;because there's the unconditional right below this
	bicne r1,r1,#0x000C
	orr r1,r1,#0x0001
0:	
	str_ r1,bg01cnt
	addne r1,r1,#0x0200
	subne r1,r1,#1
	str_ r1,bg23cnt
mode0_update_scroll:
	@get y pos
	ldrb_ r0,scrollY
	sub r0,r0,#SCREEN_Y_START
	mov r1,r0,lsl#16
	
	@get x pos
	ldrb_ r0,scrollX
	sub r0,r0,#SCREEN_X_START
	mov r0,r0,lsl#16
	orr r1,r1,r0,lsr#16
	str_ r1,xyscroll
	bx lr

@nobg
entermode1:
@	ldrb r0,rendermode
@	cmp r0,#1
@	moveq r1,pc
@	bxeq lr
entermode1_:
	mov r0,#1
	strb_ r0,rendermode
	@get LCDC
	ldrb_ r0,lcdctrl
	
	@default dispcnt, win 1, all 4 bg layers
	ldr r1,=0x5F40
	tst r0,#0x02 @sprite enable
	biceq r1,r1,#0x1000
	orr r1,r1,r1,lsl#16
	str_ r1,dispcntdata
	
	@default bgXcnt: 000mmmmm000cccpp
	ldr r1,=0x1A02
	tst r0,#0x10 @Tile Select
	orreq r1,r1,#0x0008
	tst r0,#0x40 @Window Tilemap
	addne r1,r1,#0x0300
	orr r1,r1,r1,lsl#16
	add r1,r1,#0x01000000 @for color 0 tiles
	orr r1,r1,#0x00010000
	bic r1,r1,#0x000C0000
	tst r0,#0x01 @BG enable
	bne 0f
	ldrb_ r0,gbcmode
	cmp r0,#1
	orreq r1,r1,#0x0001
0:	
	str_ r1,bg01cnt
	addne r1,r1,#0x0200
	subne r1,r1,#1
	str_ r1,bg23cnt
	
mode1_update_scroll:
	ldr_ r1,windowyscroll
	@get wx
	ldrb_ r0,windowX
	
	@wx to screen scroll
	rsb r0,r0,#0
	sub r0,r0,#(SCREEN_X_START-7)
	mov r0,r0,lsl#16
	orr r1,r1,r0,lsr#16
	str_ r1,xyscroll
	bx lr

bufferfinish:
	mov r2,#144
	b 0f
tobuffer:
	ldr_ r2,hblankposition  @if cycles >=hblankposition, inside hblank
	cmp cycles,r2
	ldrb_ r2,scanline
	addmi r2,r2,#1
	cmp r2,#144
	movge r2,#0
0:
	ldrb_ r1,buffer_lastscanline
	subs r0,r2,r1
	
	bxeq lr
	ble bufferfinish
	
	@check if will reach wy
	ldrb_ addy,windowY
	@it will reach if:
	@s0<wy && s1>=wy
	cmp r1,addy
	bge 0f
	cmp r2,addy
	blt 0f
	@check if will reach a new mode, can only be in "no window" since window wasn't hit yet
	ldrb_ r1,lcdctrl
	tst r1,#0x20
	beq 0f
	ldrb_ r1,windowX
	cmp r1,#166
	bgt 0f
	
	ldrb_ r1,buffer_lastscanline
	@Will enter a window mode, so call rest of routine, then come back to finish
	sub r0,addy,r1
	stmfd sp!,{r2,addy,lr}
	bl 0f
	ldrb_ r1,windowX
	cmp r1,#7
	bgt 1f
	bl entermode1_
	cmp r0,r0
1:
	blgt entermode2_
	ldmfd sp!,{r2,addy,lr}

	subs r0,r2,addy
	bxeq lr
0:	
	strb_ r2,buffer_lastscanline
	ldrb_ r1,rendermode
	cmp r1,#1
	bgt tobuffer_split
	ldrlt_ addy,windowyscroll
	sublt addy,addy,r0,lsl#16
	strlt_ addy,windowyscroll
	
	@r0 = scanlines remaining
	
	@r1=bigbuffer
	@r2=bg01cnt
	@r3=bg23cnt
	@r4=xyscroll
	@r5=xyscroll2
	
	@dispcntdata
	@windata
	@dispcntaddr
	
	@windowyscroll
	
	stmfd sp!,{r3-r8,lr}
	@now we need intervention of UI and Border here
	adrl_ addy,bigbuffer
	ldmia addy,{r1-r4}
	mov r5,r4
	mov r6,r4
	mov r7,r4
	
	ldr_ r8,ui_border_cnt_bic
	tst r8,#0xFF000000
	beq 0f
	bic r3,r3,r8
	ldr_ r8,ui_border_cnt_orr
	orr r3,r3,r8
	tst r8,#0x0000FF00
	ldrne_ r6,ui_border_scroll2
	ldr_ r7,ui_border_scroll3
0:	
	mov r8,r0
	
	
1:
	stmia r1!,{r2,r3,r4,r5,r6,r7}
	subs r0,r0,#1
	bne 1b
	str_ r1,bigbuffer
	
	ldr_ addy,dispcntdata
	ldr_ r2,dispcntaddr
@	add r4,r2,#144*2
	bl apply16
	str_ r2,dispcntaddr
@	mov r2,r4
@	bl apply16
	ldmfd sp!,{r3-r8,pc}

tobuffer_split:
	stmfd sp!,{r3-r8,lr}
	adrl_ addy,bigbuffer
	ldmia addy,{r1-r5}
	mov r6,r4
	mov r7,r5

	ldr_ r8,ui_border_cnt_bic
	tst r8,#0xFF000000
	beq 0f
	bic r3,r3,r8
	ldr_ r8,ui_border_cnt_orr
	orr r3,r3,r8
	tst r8,#0x0000FF00
	ldrne_ r6,ui_border_scroll2
	ldr_ r7,ui_border_scroll3
0:	
	mov r8,r0

1:
	stmia r1!,{r2,r3,r4,r5,r6,r7}
	subs r0,r0,#1
	bne 1b
	str_ r1,bigbuffer

	ldr_ addy,dispcntdata
	ldr_ r2,dispcntaddr
	add r4,r2,#144*2
	bl apply16
	str_ r2,dispcntaddr
	mov r2,r4
	ldr_ addy,windata
	bl apply16
	ldmfd sp!,{r3-r8,pc}

apply16:
	@sets halfwords, plus one extra one if end is not aligned
	@r8 = count (in halfwords)
	@r2 = dest, does not have to be word aligned
	@addy = halfword repeated
	@can use r0-r3,r5-r8,addy
	
	mov r7,r8,lsl#1
	
	@make aligned
	tst r2,#2
	strneh addy,[r2],#2
	subne r7,r7,#2
	
	subs r7,r7,#24
	blt 0f
	mov r0,addy
	mov r1,addy
	mov r3,addy
	mov r5,addy
	mov r6,addy
1:	
	stmia r2!,{r0,r1,r3,r5,r6,addy}
	subs r7,r7,#24
	bge 1b
0:	
	adds r7,r7,#24
	bxeq lr
	subs r7,r7,#4
	blt 0f
1:
	str addy,[r2],#4
	subs r7,r7,#4
	bge 1b
	tst r7,#2
	bxeq lr
0:
	strh addy,[r2],#2
	bx lr

@
@@
@@@
@@@@
@@@@@
@@@@@@
@@@@@@@

move_ui_2:
	adr_ r2,ui_border_cnt_bic
	ldmia r2,{r4-r7}
@	ldr r4,ui_border_cnt_bic
@	ldr r5,ui_border_cnt_orr
@	ldr r6,ui_border_scroll2
@	ldr r7,ui_border_scroll3
	tst r4,#0xFF000000
	bxeq lr
	ldr_ r1,bigbufferbase2
	mov r2,#144
	tst r4,#0x0000FF00
	bne 1f
0:
	ldr r0,[r1,#4]
	bic r0,r0,r4
	orr r0,r0,r5
	str r0,[r1,#4]
	str r7,[r1,#20]
	add r1,r1,#24
	subs r2,r2,#1
	bne 0b
	bx lr
1:
0:
	str r5,[r1,#4]
	str r6,[r1,#16]
	str r7,[r1,#20]
	add r1,r1,#24
	subs r2,r2,#1
	bne 0b
	bx lr

add_ui_border:
	@Check if state of UI and border is correct
	ldr_ r1,_ui_border_screen
	ldr_ r0,_ui_border_request
	str_ r0,_ui_border_screen
	
	and r12,r0,#3
	@update WININ and WINOUT registers
	cmp r12,#2
	ldrle r2,=0xFFE8FFFA @one layer
	cmp r12,#3
	ldreq r2,=0xFFECFFFE @two layers
	cmp r12,#0
	ldreq r2,=0xFFE0FFFA @no extra layers
	mov r3,#REG_BASE
	str r2,[r3,#REG_WININ]

	@set BLDY
	ldrb_ r2,_darkness
	strh r2,[r3,#REG_BLDY]
	tst r2,#0x1F
	moveq r2,#0x0000
	beq 0f
	tst r2,#0x80	@if set the MSBit, brightness up instead of down

	@Set BLDMOD
	moveq r2,#0x00DF	@brightness down, all layers + obj
	movne r2,#0x009F	@brightness up, all layers+obj
	bne 0f			@brightness up applies to all layers
	cmp r12,#3	@UI and Border visible?
	biceq r2,r2,#0x0004 @no dark for BG2
	cmp r12,#1	@only UI visible?
	biceq r2,r2,#0x0008 @no dark for BG3
0:
	str r2,[r3,#REG_BLDMOD]
	
	@now check if UI or border has moved
	cmp r1,r0
	bxeq lr
	
	@now apply the settings to the active (to be displayed) scanline buffers
	adr_ r12,ui_border_cnt_bic
	ldmia r12,{r0-r3}
	stmfd sp!,{r0-r3,lr}		@push old
	ldr_ r1,_ui_border_screen
	bl update_ui_border_masks_2	@this gets restored afterwards
	bl move_ui_2
	ldmfd sp!,{r0-r3,lr}
	stmia r12,{r0-r3}		@restore old
	bx lr

update_ui_border_masks:
	ldr_ r1,_ui_border_request
	str_ r1,_ui_border_buffer
update_ui_border_masks_2:	
	and r0,r1,#3
	cmp r0,#1
	beq 1f
	cmp r0,#2
	beq 2f
	cmp r0,#3
	beq 3f
0: @neither visible
	mov r0,#0
	str_ r0,ui_border_cnt_bic
	str_ r0,ui_border_cnt_orr
	bx lr
1: @UI visible
	ldr r0,=0xFFFF0000
	str_ r0,ui_border_cnt_bic
	ldr r0,=0x4E0C0000
	str_ r0,ui_border_cnt_orr

	mov r0,r1,lsr#8    @ui_x
	bic r0,r0,#0x00FF0000
	mov r1,r1,lsr#24   @ui_y
	orr r0,r0,r1,lsl#16
	
	str_ r0,ui_border_scroll3
	bx lr
2: @Border visible
	ldr r0,=0xFFFF0000
	str_ r0,ui_border_cnt_bic
	ldr r0,=0x0D040000
	str_ r0,ui_border_cnt_orr
@snes_screen_y = (224-144)/2 = 40
@gba_screen_y = (160-144)/2 = 8
@snes y >> gba y: 40-8
@snes x >> gba x: 48-40
	ldr r0,= (40-SCREEN_Y_START)*65536 + (48-SCREEN_X_START)
	str_ r0,ui_border_scroll3
	bx lr
3: @UI and Border visible
	mvn r0,#0
	str_ r0,ui_border_cnt_bic
	ldr r0,=0x0D044E0C
	str_ r0,ui_border_cnt_orr
	ldr r0,= (40-SCREEN_Y_START)*65536 + (48-SCREEN_X_START)
	str_ r0,ui_border_scroll3

	mov r0,r1,lsr#8    @ui_x
	bic r0,r0,#0x00FF0000
	mov r1,r1,lsr#24   @ui_y
	orr r0,r0,r1,lsl#16

	str_ r0,ui_border_scroll2

	bx lr


display_frame:	@called at vblank
	stmfd sp!,{globalptr,lr}
	@init windows
	mov r1,#REG_BASE
	ldr r0,=(SCREEN_X_START*256 + (SCREEN_X_START+160))
	strh r0,[r1,#REG_WIN1H]		@Win1H
	ldr r0,=(SCREEN_Y_START*256 + (SCREEN_Y_START+144))*0x10001
	str r0,[r1,#REG_WIN0V]		@Win0V

	@fill line buffers
@	bl fill_line_buffers
	bl add_ui_border
	bl display_bg
	
	ldmfd sp!,{globalptr,pc}


display_bg:
	bx lr
@
@	;destroys r0-r12
@	ldr r9,=0x00070007
@	ldr r12,=0x00080008
@	ldr r11,=0x00680068
@	
@	mov r8,lr
@	mov r10,#0x1000
@	ldr r2,=XGB_VRAM+0x1800
@	ldr r6,=0x72007200 ;#512+4096*7
@
@	ldr r3,=AGB_VRAM+26*2048
@	bl display_bg2
@	mov lr,r8
@	ldr r3,=AGB_VRAM+29*2048
@display_bg2
@	mov r7,#1024/2
@display_bg_loop
@	ldrh r1,[r2,r10,lsl#1]   ;operates 2 tiles at a time
@	orr r1,r1,r1,lsl#8 ;doesn't matter if there's dirt in byte 1 of the word
@	ldrh r0,[r2],#2
@	orr r0,r0,r0,lsl#8
@	bic r0,r0,#0x00FF00 ;clear dirt from shifted OR of two tile numbers
@	and r5,r1,r9 ;0x00070007
@	add r5,r5,r12 ;0x00080008
@	orr r0,r0,r5,lsl#12
@	and r4,r1,r11 ;0x00680068 ;high tile num and flipping
@	orr r0,r0,r4,lsl#5
@	tst r1,#0x8080
@	str r6,[r3,r10]
@	beq %f0_no_hp_tile
@	tst r1,#0x8000 ;High Priority tile #2
@	strne r0,[r3,r10] ;store two tiles for yes to #2
@	tst r1,#0x80 ;High Priority tile
@	streqh r6,[r3,r10]
@	strneh r0,[r3,r10]
@0_no_hp_tile
@	add r5,r6,r5 ;Color 0 tile
@	str r5,[r3,0x800]
@	str r0,[r3],#4 ;Store tile
@	subs r7,r7,#1
@	bne display_bg_loop
@
@	bx lr

@@
@@	mov r8,lr
@@	mov r9,#0x0800
@@	mov r10,#0x1000
@@	mov r11,#0x2000
@@	ldr r2,=XGB_VRAM+0x1800
@@	mov r6,#512+4096*7
@@
@@	ldr r3,=AGB_VRAM+26*2048
@@	bl display_bg2
@@	mov lr,r8
@@	ldr r3,=AGB_VRAM+29*2048
@@display_bg2
@@	mov r7,#1024
@@display_bg_loop	
@@	ldrb r1,[r2,r11]
@@	ldrb r0,[r2],#1
@@	;tile color
@@	and r5,r1,#0x7
@@	add r5,r5,#0x8
@@	orr r0,r0,r5,lsl#12
@@	;high tile num and flipping
@@	and r4,r1,#0x68
@@	orr r0,r0,r4,lsl#5
@@	;High Priority tile
@@	tst r1,#0x80
@@	streqh r6,[r3,r10]
@@	strneh r0,[r3,r10]
@@	;Color 0 tile
@@	add r5,r6,r5
@@	strh r5,[r3,r9]
@@	;Store tile
@@	strh r0,[r3],#2
@@	subs r7,r7,#1
@@	bne display_bg_loop
@@
@@	bx lr


@----------------------------------------------------------------------------
FF46_W:@		sprite DMA transfer
@----------------------------------------------------------------------------
@	and r0,r0,#0xff		;not needed?
	and r1,r0,#0xF0
	adr_ r2,memmap_tbl
	ldr r1,[r2,r1,lsr#2]	@in: addy,r1=addy&0xE000 (for rom_R)
	add addy,r1,r0,lsl#8	@addy=DMA source
	ldr_ r2,gboambuff

	mov r1,#40		@number of sprites on the GB
OAMLoop:
	ldr r0,[addy],#4
	str r0,[r2],#4
	subs r1,r1,#1
	bne OAMLoop
	
	mov r0,#1
	strb_ r0,gboamdirty

	mov pc,lr

display_sprites:
@----------------------------------------------------------------------------
OAMfinish:@		transfer OAM from GB to GBA
@----------------------------------------------------------------------------
 PRIORITY = 0x800	@0x800=AGB OBJ priority 2
	ldr_ addy,active_gboambuff
	add r9,addy,#0xA0
	mov r2,#AGB_OAM
 	
	ldrb_ r5,gbcmode

	ldrb_ r0,lcdctrl0frame
@	ldr r0,active_lcdcbuff
@	ldrb r0,[r0,#71]	;8x16?
@	ldrb r0,lcdctrl		;8x16?
	tst r0,#0x04
	bne dm4
dm11:
	ldr r3,[addy],#4
	ands r0,r3,#0xff
	beq dm10		@skip if sprite Y=0
	cmp r0,#159
	bhi dm10		@skip if sprite Y>159

	add r0,r0,#(-16+SCREEN_Y_START)
	and r0,r0,#0xff

	and r1,r3,#0xff00
	add r1,r1,#(SCREEN_X_START-8)*256	@adjusted x
	orr r0,r0,r1,lsl#8
	and r1,r3,#0x60000000	@flip
	orr r0,r0,r1,lsr#1
	str r0,[r2],#4		@store OBJ Atr 0,1

@  Bit7   OBJ-to-BG Priority (0=OBJ Above BG, 1=OBJ Behind BG color 1-3)
@         (Used for both BG and Window. BG color 0 is always behind OBJ)
@  Bit6   Y flip          (0=Normal, 1=Vertically mirrored)
@  Bit5   X flip          (0=Normal, 1=Horizontally mirrored)
@  Bit4   Palette number  **Non CGB Mode Only** (0=OBP0, 1=OBP1)
@  Bit3   Tile VRAM-Bank  **CGB Mode Only**     (0=Bank 0, 1=Bank 1)
@  Bit2-0 Palette number  **CGB Mode Only**     (OBP0-7)

@  Bit   Expl.
@  0-9   Character Name          (0-1023=Tile Number)
@  10-11 Priority relative to BG (0-3; 0=Highest)
@  12-15 Palette Number   (0-15) (Not used in 256 color/1 palette mode)


	mov r1,#PRIORITY
	tst r3,#0x80000000	@priority
	orrne r1,r1,#PRIORITY>>1
	cmp r5,#0
	@gbc vram bank
	andne r0,r3,#0x08000000
	orrne r1,r1,r0,lsr#19
	@gbc color
	andne r0,r3,#0x07000000
	orrne r1,r1,r0,lsr#12
@	;gb color
	andeq r0,r3,#0x10000000
	orreq r1,r1,r0,lsr#16
	@tile
	and r0,r3,#0x00FF0000
	orr r1,r1,r0,lsr#16
	
	strh r1,[r2],#4		@store OBJ Atr 2
dm9:
	cmp addy,r9
	bne dm11
	bx lr
dm10:
	mov r0,#0x2a0		@double, y=160
	str r0,[r2],#8
	b dm9


dm4:	@- - - - - - - - - - - - -8x16

dm12:
	ldr r3,[addy],#4
	ands r0,r3,#0xff
	beq dm13		@skip if sprite Y=0
	cmp r0,#159
	bhi dm13		@skip if sprite Y>159

	add r0,r0,#(-16+SCREEN_Y_START)
	and r0,r0,#0xff

	and r1,r3,#0xff00
	add r1,r1,#(SCREEN_X_START-8)*256	@adjusted x
	orr r0,r0,r1,lsl#8
	and r1,r3,#0x60000000	@flip
	orr r0,r0,r1,lsr#1
	orr r0,r0,#0x8000	@8x16
	str r0,[r2],#4		@store OBJ Atr 0,1

	mov r1,#PRIORITY
	tst r3,#0x80000000	@priority
	orrne r1,r1,#PRIORITY>>1
	cmp r5,#0
	@gbc vram bank
	andne r0,r3,#0x08000000
	orrne r1,r1,r0,lsr#19
	@gbc color
	andne r0,r3,#0x07000000
	orrne r1,r1,r0,lsr#12
	@gb color
	andeq r0,r3,#0x10000000
	orreq r1,r1,r0,lsr#16
	@tile
	and r0,r3,#0x00FF0000
	orr r1,r1,r0,lsr#16
	bic r1,r1,#0x0001

	strh r1,[r2],#4		@store OBJ Atr 2
dm14:
	cmp addy,r9
	bne dm12
	bx lr
dm13:
	mov r0,#0x2a0		@double, y=160
	str r0,[r2],#8
	b dm14



@----------------------------------------------------------------------------
vcountinterrupt:
@----------------------------------------------------------------------------

do_gba_hdma:
	mov r12,globalptr
	ldr globalptr,=GLOBAL_PTR_BASE
	ldr r0,=REG_BASE+REG_DM0SAD
	ldr_ r1,bigbufferbase2
@	add r1,r1,#24  ;because first scanline was already displayed
	ldr r2,=REG_BASE+REG_BG0CNT
	ldr r3,=0xA6600006
	stmia r0!,{r1-r3}
	ldr_ r1,dispcntbase2
@	add r1,r1,#2   ;because first scanline was already displayed
	ldr r2,=REG_BASE+REG_DISPCNT
	ldr r3,=0xA2600001
	stmia r0!,{r1-r3}
@	ldr_ r1,dispcntbase2
	add r1,r1,#288
@	add r1,r1,#2   ;because first scanline was already displayed
	ldr r2,=REG_BASE+REG_WIN0H
	ldr r3,=0xA2600001
	stmia r0!,{r1-r3}

	adr r0,end_gba_hdma
	str r0,vcountfptr

	mov r2,#REG_BASE
	ldr r0,=0x28 + 256*(SCREEN_Y_START+144-1) @scanline 144+8-1, enable vblank+vcount interrupts
	strh r0,[r2,#REG_DISPSTAT]
	mov globalptr,r12
	bx lr
	
end_gba_hdma:
	mov r2,#REG_BASE
	strh r2,[r2,#REG_DM0CNT_H]	@DMA stop
	strh r2,[r2,#REG_DM1CNT_H]
	strh r2,[r2,#REG_DM2CNT_H]
@	strh r2,[r2,#REG_DM3CNT_H]

	ldr r0,=vbldummy
	str r0,vcountfptr

	mov r0,#0x0008 @scanline 0, enable vblank interrupt
	strh r0,[r2,#REG_DISPSTAT]

	bx lr
	
	


@@----------------------------------------------------------------------------
@vcountinterrupt; for palette changes
@@----------------------------------------------------------------------------
@	stmfd sp!,{r4-r7}
@	ldr r4,=PALETTE_BASE
@	adr r0,palrptr
@	ldr r1,[r0]
@	ldr r6,[r0,#4]
@	cmp r1,r6
@	beq vci_return
@	
@	ldr r2,=palbuff
@	ldr r12,[r1,r2]
@vci_loop1
@	mov r5,r12,lsr#16
@	;bg color?
@	tst r12,#0x00000600
@	and r3,r12,#0x00007800
@	moveq r7,r3,lsr#10
@	streqh r5,[r4,r7]
@	mov r3,r3,lsr#6
@	and r7,r12,#0x00000600
@	mov r7,r7,lsr#8
@	orr r3,r3,r7
@	add r3,r3,#256
@	strh r5,[r4,r3]
@	add r1,r1,#4
@	bic r1,r1,#0x200
@	str r1,[r0]
@	cmp r1,r6
@	beq vci_return
@	and r3,r12,#0x000000FF
@	ldr r12,[r1,r2]
@	and r5,r12,#0x000000FF
@	cmp r3,r5
@	beq vci_loop1
@	ldr r7,=REG_BASE+REG_DISPSTAT
@	ldrh r0,[r7]
@	bic r0,r0,#0xFF00
@	orr r0,r0,r12,lsl#8
@	strh r0,[r7]	
@vci_return	
@	ldmfd sp!,{r4-r7}
@	bx lr
	



@this code is broken...
@merge_recent_tiles
@	ldrb r0,recenttilesfull
@	movs r0,r0
@	bxne lr
@
@	;This shouldn't happen when VSYNC is on, but it does anyway!  Find out why!
@	
@	;Only used when vsync is off, fixes garbage when there are two tile updates before a GBA vblank.
@	
@	;psuedocode:
@	;if len1*2+len2*2>max_len*2, then just give up and flush buffer1
@	;copy tile numbers and tile data from buffer2 to buffer1, then swap again
@	
@	;find length of buffer2
@	ldr r1,dmarecent_tilenum  ;buffer2
@	sub r1,r1,#2
@strlen1
@	ldrh r0,[r1,#2]!
@	tst r0,#0x8000
@	beq strlen1
@	ldr r0,dmarecent_tilenum  ;buffer2
@	subs r0,r1,r0
@	;if buffer2 is empty, just swap.
@	beq just_unswap
@	
@	;now r0=length of buffer2*2, r1=buffer2+r0
@	
@	;find length of buffer1
@	stmfd sp!,{r2-addy,lr}
@	ldr r3,recent_tilenum
@	sub r4,r3,#2
@strlen2
@	ldrh r6,[r4,#2]!
@	tst r6,#0x8000
@	beq strlen2
@	sub r5,r4,r3
@	add r6,r0,r5
@	cmp r6,#MAX_RECENT_TILES*2
@	bgt merge_giveup
@
@	;r0 = length of buffer2*2
@	;r5 = length of buffer1*2
@	
@	ldr r0,recent_tilenum
@	ldr r1,recent_tiles
@	add r0,r0,r5
@	add r1,r1,r5,lsl#3
@	ldr r2,dmarecent_tilenum
@	ldr r3,dmarecent_tiles
@	;r0 = dest inside buffer2
@	;r1 = dest position inside buffer2
@	;r2 = src inside buffer1
@	;r3 = src position inside buffer1
@	
@	
@	
@	ldr r2,dmarecent_tiles
@	add r0,r2,r0,lsl#3
@	ldr r2,recent_tiles
@	
@	;copy!
@	ldrh r6,[r2]
@	mov r7,#0x8000 ;mark as empty
@	strh r7,[r2],#2
@mergeloop
@	strh r6,[r0],#2
@	ldmia r3!,{r6,r7,r8,r9}
@	stmia r1!,{r6,r7,r8,r9}
@	ldrh r6,[r2],#2
@	subs r5,r5,#2
@	bne mergeloop
@	ldmfd sp!,{r2-addy,lr}
@	b just_unswap
@merge_giveup
@	bl flush_recent_tiles
@	ldmfd sp!,{r2-addy,pc}


@----------------------------------------------------------------------------
newframe_vblank:	@called at line 144	(??? safe to use)
@----------------------------------------------------------------------------
	stmfd sp!,{r0-r12,lr}

@	ldrb r0,windowY
@	strb r0,frame_windowy

	@Finish buffers: Part 1  (remember to do part 2)
	bl bufferfinish

@	;finish dispcontrol buffer
@	ldr addy,lcdcbuff
@	ldrb r1,lcdctrl
@	ldrb r0,lcdctrlline
@	mov r2,#144
@	bl fill_byte_buff
@	
@	;finish yscroll buffer
@	ldr addy,yscrollbuff
@	ldrb r1,scrollY
@	ldrb r0,yscrollline
@	mov r2,#144
@	bl fill_byte_buff
@	
@	;finish xscroll buffer
@	ldr addy,xscrollbuff
@	ldrb r1,scrollX
@	ldrb r0,xscrollline
@	mov r2,#144
@	bl fill_byte_buff
@
@	;finish windowx buffer
@	ldr addy,wxbuff
@	ldrb r1,windowX
@	ldrb r0,wxline
@	mov r2,#144
@	bl fill_byte_buff
@	
@
@	mov r0,#0
@	str r0,lcdctrlline ;also writes yscrollline, xscrollline


	@disable GBA vblank interrupts while swapping buffers
	ldr addy,=REG_IE+REG_BASE
	ldrh r2,[addy]
	bic r2,r2,#1
	strh r2,[addy]
	
	@---
	@check for SGB MASKING
	@---
	ldrb_ r0,sgb_mask
	movs r0,r0
	bne no_swap

	@rotate out ui_border visibility flags
	ldr_ r0,_ui_border_buffer
	str_ r0,_ui_border_screen
	bl update_ui_border_masks

	@copy lcdctrl0's mid-frame status
	ldrb_ r0,lcdctrl0midframe
	strb_ r0,lcdctrl0frame
	
	@swap "big" buffer
	ldr_ r0,bigbufferbase
	ldr_ r1,bigbufferbase2
	str_ r1,bigbufferbase
	str_ r0,bigbufferbase2

	@swap dispcnt+window buffer
	ldr_ r0,dispcntbase
	ldr_ r1,dispcntbase2
	str_ r1,dispcntbase
	str_ r0,dispcntbase2

	

@	;swap xscroll buffer
@	ldr r0,xscrollbuff
@	ldr r1,active_xscrollbuff
@	str r1,xscrollbuff
@	str r0,active_xscrollbuff
@
@	;swap yscroll buffer
@	ldr r0,yscrollbuff
@	ldr r1,active_yscrollbuff
@	str r1,yscrollbuff
@	str r0,active_yscrollbuff
@
@	;swap control buffer
@	ldr r0,lcdcbuff
@	ldr r1,active_lcdcbuff
@	str r1,lcdcbuff
@	str r0,active_lcdcbuff
@	
@	;swap windowx buffer
@	ldr r0,wxbuff
@	ldr r1,active_wxbuff
@	str r1,wxbuff
@	str r0,active_wxbuff

@	;copy window coordinates
@	ldrb r0,frame_windowy
@	strb r0,active_windowy

	@swap gb oam buffer if not dirty
	ldrb_ r0,gboamdirty
	movs r0,r0
	beq gbaoamclean
	cmp r0,#2 @use copy instead of buffer swap?

	ldrne_ r0,gboambuff
	ldrne_ r1,active_gboambuff
	strne_ r1,gboambuff
	strne_ r0,active_gboambuff
	
	bleq copyoam
	
	
	mov r0,#0
	strb_ r0,gboamdirty
gbaoamclean:
	bl_long copy_gbc_palette
	
	@new code
@	if v=1 then
@		add tiles to buffer
@		B=1
@		if buffer becomes full, D=1
@		do not wait for vblank
@	else
@		D=1
@		wait for vblank
@	v=0
	
	ldrb_ r0,novblankwait_
	cmp r0,#1
	@fast mode overrides vblank system
	ldrneb_ r0,vblank_happened
	movs r0,r0
	beq dirty_ok_and_wait
	
	bl gbc_chr_update
	mov r0,#1
	strb_ r0,consume_buffer
	
	mov r0,#0
	strb_ r0,vblank_happened
	
reenable_vblank:
	@reenable GBA vblank interrupt
	ldr addy,=REG_IE+REG_BASE
	ldrh r2,[addy]
	orr r2,r2,#1
	strh r2,[addy]

	b after_wait
dirty_ok_and_wait:
	mov r0,#1
	strb_ r0,consume_dirty

	@reenable GBA vblank interrupt
	ldr addy,=REG_IE+REG_BASE
	ldrh r2,[addy]
	orr r2,r2,#1
	strh r2,[addy]

	@VSYNC!
	mov r0,#1				@always wait
	mov r1,#1				@VBL wait
	swi 0x040000			@ Turn of CPU until IRQ

	mov r0,#0
	strb_ r0,vblank_happened
	
after_wait:

	@Finish buffers: Part 2  (after doing part 1)
	bl newframeinit

	@slow motion? Vsync again...
	ldrb_ r0,novblankwait_
	cmp r0,#2
	
	moveq r0,#1
	moveq r1,#1
	swieq 0x040000
	moveq r0,#0
	strb_ r0,vblank_happened

	ldmfd sp!,{r0-r12,pc}

no_swap:
	b reenable_vblank
@	
@	;sgb display is masked off...
@	ldrb r0,novblankwait_
@	cmp r0,#1

	
	
	
@----------------------------------------------------------------------------
newframe:	@called at line 0	(r0-r9 safe to use)
@----------------------------------------------------------------------------
	str lr,[sp,#-4]!
	
@	bl OAMfinish
@-----------------------
@	ldr r0,ctrl1old
@	ldr r1,ctrl1line
@	mov addy,#159
@	ldr r3,chrold
@	ldr r5,chrold2
@	bl ctrl1finish
@------------------------
@	ldr r0,scrollXold
@	ldr r1,scrollXline
@	mov addy,#159
@	bl scrollXfinish
@--------------------------
@	ldr r0,scrollYold
@	ldr r1,scrollYline
@	mov addy,#159
@	bl scrollYfinish
@--------------------------
@	ldr r0,windowXold
@	ldr r1,windowXline
@	mov addy,#159
@	bl windowXfinish
@--------------------------
@	ldr r0,windowYold
@	ldr r1,windowYline
@	mov addy,#159
@	bl windowYfinish
@--------------------------
@	mov r0,#0
@	str r0,ctrl1line
@	str r0,scrollXline
@	str r0,scrollYline
@	str r0,windowXline
@	str r0,windowYline
@--------------------------

@	ldrb r2,windowX
@	strb r2,windowXbuf
@
@	ldr r0,scrollbuff
@	ldr r1,dmascrollbuff
@	str r1,scrollbuff
@	str r0,dmascrollbuff
@
@	ldr r0,oambuffer
@	str r0,dmaoambuffer
@
	ldr pc,[sp],#4

@----------------------------------------------------------------------------
FF40_R:@		LCD Control
@----------------------------------------------------------------------------
	ldrb_ r0,lcdctrl
	mov pc,lr
@----------------------------------------------------------------------------
FF40_W:@		LCD Control
@----------------------------------------------------------------------------
	ldrb_ r1,lcdctrl
	cmp r0,r1
	bxeq lr

	eor r2,r1,r0
	and r2,r2,r0
	tst r2,#0x80		@Is LCD turned on?
	ldrne r2,=line145_to_end
	strne_ r2,nexttimeout
	movne r2,#152
	strneb_ r2,scanline
	
	stmfd sp!,{r0,lr}
	bl tobuffer
	ldr r0,[sp]
	strb_ r0,lcdctrl
	bl newmode
@	mov r2,r1,lsr#16
@	cmp r2,#0x0300
@	bxeq r1
	ldmfd sp!,{r0,pc}

@----------------------------------------------------------------------------
FF41_R:@		LCD Status
@----------------------------------------------------------------------------
	ldrb_ r0,lcdstat
	ldrb_ r1,scanline
	ldrb_ r2,lcdyc
	cmp r1,r2
	orreq r0,r0,#4		@scanline=LYC
	tst r0,#0x01		@in VBlank.
	movne pc,lr
	
	ldr_ r2,cyclesperscanline
	cmp r2,#DOUBLE_SPEED
	movne r1,cycles
	moveq r1,cycles,lsr#1
	
	cmp r1,#376*CYCLE
	orrpl r0,r0,#2		@in OAM access
	movpl pc,lr

	cmp r1,#204*CYCLE
	orrpl r0,r0,#3		@in VRAM access
	mov pc,lr
@----------------------------------------------------------------------------
FF41_W:@		LCD Status
@----------------------------------------------------------------------------
	ldrb_ r1,lcdstat
	and r1,r1,#0x01		@Save VBlank bit.
	and r0,r0,#0x78
	orr r0,r0,r1
	strb_ r0,lcdstat
	mov pc,lr
@----------------------------------------------------------------------------
FF42_R:@		SCY - Scroll Y
@----------------------------------------------------------------------------
	ldrb_ r0,scrollY
	mov pc,lr
@----------------------------------------------------------------------------
FF42_W:@		SCY - Scroll Y
@----------------------------------------------------------------------------
	ldrb_ r1,scrollY
	cmp r0,r1
	bxeq lr
	
	stmfd sp!,{r0,lr}
	bl tobuffer
	ldr r0,[sp]
	strb_ r0,scrollY
	ldmfd sp!,{r0,lr}
	b scrollx_entry

@----------------------------------------------------------------------------
FF43_R:@		SCX - Scroll X
@----------------------------------------------------------------------------
	ldrb_ r0,scrollX
	mov pc,lr
@----------------------------------------------------------------------------
FF43_W:@		SCX - Scroll X
@----------------------------------------------------------------------------
	ldrb_ r1,scrollX
	cmp r0,r1
	bxeq lr
	
	stmfd sp!,{r0,lr}
	bl tobuffer
	ldr r0,[sp]
	strb_ r0,scrollX
	ldmfd sp!,{r0,lr}

scrollx_entry:
	ldrb_ r0,rendermode
	cmp r0,#1
	blt mode0_update_scroll
	bgt mode2_update_scroll
	bx lr

@----------------------------------------------------------------------------
FF44_R:@      LCD Scanline
@----------------------------------------------------------------------------
   ldrb_ r0,lcdctrl
   ands r0,r0,#0x80
   ldrneb_ r0,scanline
@   ldr r0,scanline
   mov pc,lr
@@----------------------------------------------------------------------------
@FF44_R;		LCD Scanline
@@----------------------------------------------------------------------------
@
@
@	ldr r0,scanline
@@	cmp r0,#153
@@	moveq r0,#0
@	
@	
@@	sub cycles,cycles,#23*CYCLE	;LCD hack?
@	mov pc,lr
@----------------------------------------------------------------------------
FF44_W:@		LCD Scanline
@----------------------------------------------------------------------------
	mov pc,lr

@----------------------------------------------------------------------------
FF45_R:@		LCD Y Compare
@----------------------------------------------------------------------------
	ldrb_ r0,lcdyc
	mov pc,lr
@----------------------------------------------------------------------------
FF45_W:@		LCD Y Compare
@----------------------------------------------------------------------------
	strb_ r0,lcdyc
	mov pc,lr
@----------------------------------------------------------------------------
FF47_R:@		BGP - BG Palette Data
@----------------------------------------------------------------------------
	ldrb_ r0,bgpalette
	mov pc,lr
@----------------------------------------------------------------------------
FF47_W:@		BGP - BG Palette Data  (GB MODE ONLY)
@----------------------------------------------------------------------------
	strb_ r0,bgpalette
	
	ldrb_ r1,gbcmode
	cmp r1,#0
	bxne lr
	ldrb_ r1,sgbmode
	cmp r1,#0
	bne_long update_sgb_bg_palette
	
	ldr r2,=gbc_palette
	ldr addy,=SGB_PALETTE
	str lr,[sp,#-4]!
	bl dopalette
	ldr lr,[sp],#4
	
	ldr r2,=gbc_palette+4*2
	ldr addy,=SGB_PALETTE+16
dopalette:
	and r1,r0,#0x03
	add r1,addy,r1,lsl#1
	ldrh r1,[r1]
	strh r1,[r2]		@store in agb palette
	and r1,r0,#0x0C
	add r1,addy,r1,lsr#1
	ldrh r1,[r1]
	strh r1,[r2,#2]		@store in agb palette
	and r1,r0,#0x30
	add r1,addy,r1,lsr#3
	ldrh r1,[r1]
	strh r1,[r2,#4]		@store in agb palette
	and r1,r0,#0xC0
	add r1,addy,r1,lsr#5
	ldrh r1,[r1]
	strh r1,[r2,#6]		@store in agb palette

	bx lr	

dopalette_invert:
	and r1,r0,#0x03
	eor r1,r1,#0x03
	add r1,addy,r1,lsl#1
	ldrh r1,[r1]
	strh r1,[r2]		@store in agb palette
	and r1,r0,#0x0C
	eor r1,r1,#0x0C
	add r1,addy,r1,lsr#1
	ldrh r1,[r1]
	strh r1,[r2,#2]		@store in agb palette
	and r1,r0,#0x30
	eor r1,r1,#0x30
	add r1,addy,r1,lsr#3
	ldrh r1,[r1]
	strh r1,[r2,#4]		@store in agb palette
	and r1,r0,#0xC0
	eor r1,r1,#0xC0
	add r1,addy,r1,lsr#5
	ldrh r1,[r1]
	strh r1,[r2,#6]		@store in agb palette

	bx lr	

@----------------------------------------------------------------------------
FF48_R:@		OBP0 - OBJ 0 Palette Data
@----------------------------------------------------------------------------
	ldrb_ r0,ob0palette
	mov pc,lr
@----------------------------------------------------------------------------
FF48_W:@		OBP0 - OBJ 0 Palette Data
@----------------------------------------------------------------------------
	strb_ r0,ob0palette
	ldrb_ r1,gbcmode
	cmp r1,#0
	bxne lr
	ldrb_ r1,sgbmode
	cmp r1,#0
	bne_long update_sgb_obj0_palette

	ldr r2,=gbc_palette+64
	ldr addy,=SGB_PALETTE+16
	b dopalette
@----------------------------------------------------------------------------
FF49_R:@		OBP1 - OBJ 1 Palette Data
@----------------------------------------------------------------------------
	ldrb_ r0,ob1palette
	mov pc,lr
@----------------------------------------------------------------------------
FF49_W:@		OBP1 - OBJ 1 Palette Data
@----------------------------------------------------------------------------
	strb_ r0,ob1palette

	ldrb_ r1,gbcmode
	cmp r1,#0
	bxne lr
	ldrb_ r1,sgbmode
	cmp r1,#0
	bne_long update_sgb_obj1_palette

	ldr r2,=gbc_palette+64+8
	ldr addy,=SGB_PALETTE+24
	b dopalette
@----------------------------------------------------------------------------
FF4A_R:@		WINY - Window Y
@----------------------------------------------------------------------------
	ldrb_ r0,windowY
	mov pc,lr
@----------------------------------------------------------------------------
FF4A_W:@		WINY - Window Y
@----------------------------------------------------------------------------
	ldrb_ r1,windowY
	cmp r0,r1
	bxeq lr

	stmfd sp!,{r0,lr}
	bl tobuffer
	ldr r0,[sp]
	strb_ r0,windowY
	bl newmode
	ldmfd sp!,{r0,pc}

@----------------------------------------------------------------------------
FF4F_W:@		VBK - VRAM Bank - CGB Mode Only
@----------------------------------------------------------------------------
	ldrb_ r1,gbcmode
	cmp r1,#0
	moveq r0,#0
	
	ands r0,r0,#1
	strb_ r0,vrambank
	
	
	
 .if RESIZABLE
 	ldr_ addy,xgb_vram
 	sub addy,addy,#0x8000
 .else
	ldr addy,=XGB_VRAM-0x8000
 .endif
	addne addy,addy,r0,lsl#13	
	str_ addy,memmap_tbl+32
@	mov addy,#AGB_VRAM
@	addne addy,addy,r0,lsl#13
@@	sub addy,addy,#0x2000
@	str addy,agb_vrambank
	ldr addy,=DIRTY_ROWS
	addne addy,addy,#24
	str_ addy,dirty_rows
	ldr addy,=DIRTY_TILES
	addne addy,addy,#384
	str_ addy,dirty_tiles
	mov pc,lr
@----------------------------------------------------------------------------
FF4F_R:@		VBK - VRAM Bank - CGB Mode Only
@----------------------------------------------------------------------------
	ldrb_ r0,vrambank
	mov pc,lr

@----------------------------------------------------------------------------
FF4B_R:@		WINX - Window X
@----------------------------------------------------------------------------
	ldrb_ r0,windowX
	mov pc,lr
@----------------------------------------------------------------------------
FF4B_W:@		WINX - Window X
@----------------------------------------------------------------------------
	ldrb_ r1,windowX
	cmp r0,r1
	bxeq lr
	
	stmfd sp!,{r0,lr}
	bl tobuffer
	ldr r0,[sp]
	strb_ r0,windowX
	bl newmode
	ldmfd sp!,{r0,pc}

@----------------------------------------------------------------------------
vram_W2:
@----------------------------------------------------------------------------
	mov addy,addy,lsr#16
	cmp addy,#0x9800
	bpl VRAM_nameD
@----------------------------------------------------------------------------
vram_W:
@----------------------------------------------------------------------------
	ldr_ r2,memmap_tbl+32
	strb r0,[r2,addy]
	cmp addy,#0x9800
	bpl VRAM_name0
@----------------------------------------------------------------------------
@VRAM_chr;	8000-97FF
@----------------------------------------------------------------------------
	sub r1,addy,#0x8000
	ldr_ r2,dirty_rows
	strb r2,[r2,r1,lsr#8]
	ldr_ r2,dirty_tiles
	strb r2,[r2,r1,lsr#4]
	bx lr
@	
@
@	bic addy,addy,#1
@	ldrb r0,[r2,addy]!	;read 1st plane
@	ldrb r1,[r2,#1]		;read 2nd plane
@	sub addy,addy,#0x8000
@
@	adr r2,chr_decode
@	ldr r0,[r2,r0,lsl#2]
@	ldr r1,[r2,r1,lsl#2]
@	orr r0,r0,r1,lsl#1
@
@	add addy,addy,addy
@
@@f(2x) =
@@{
@@	0...FFF: sprite 0, bg 0000
@@	1000...1FFF: sprite 1000, bg 1000, bg 9000
@@       2000...2FFF: bg 8000
@@}
@	ldr r2,agb_vrambank		;AGB BG tileset
@	tst addy,#0x2000
@	addeq r1,r2,#0x10000	;0x06010000=OBJ
@	streq r0,[r1,addy]		;OBJ
@	addne r2,r2,#0x6000
@@	addeq r2,r2,#0x0000		;0x06004000/8000=BG
@	str r0,[r2,addy]		;BG
@
@	tst addy,#0x1000
@	addne r2,r2,#0x8000
@	strne r0,[r2,addy]		;BG
@
@	mov pc,lr



@----------------------------------------------------------------------------
VRAM_name0:	@(9800-9FFF)
@----------------------------------------------------------------------------
@	bx lr

@3,1,3,1,3,1,3,1, 1,3,1,1,1, 1,1,1,1,1, 3, 1,1,1,3 1,1,3 
	
	ldrb_ r2,gbcmode
	cmp r2,#0
 .if RESIZABLE
	ldr_ r2,xgb_vram
 .else
	ldr r2,=XGB_VRAM
 .endif
	sub addy,addy,#0x8000
	ldrb r0,[r2,addy]
	addne r2,r2,#0x2000
	ldrneb r1,[r2,addy]
	moveq r1,#0

	tst addy,#0x400
	ldr r2,=VRAM_BASE+26*2048
	addne r2,r2,#3*2048
	bic addy,addy,#0xFC00
	add addy,r2,addy,lsl#1

	and r2,r1,#0x68
	orr r0,r0,r2,lsl#5
	and r2,r1,#0x7
	add r2,r2,#0x8
	orr r0,r0,r2,lsl#12
	
	@store tile
	strh r0,[addy]
	
	@test for high priority now since r1 gets destroyed
	tst r1,#0x80
	@Setup and store color 0 tile
	add r2,r2,#512+4096*7
	mov r1,#0x800
	strh r2,[addy,r1]
	
	mov r1,#0x1000
	@if was not a high priority tile, use a transparent tile.
	biceq r0,r2,#0xFF
	@store high priority tile
	strh r0,[addy,r1]
	bx lr

@----------------------------------------------------------------------------
VRAM_nameD:	@(9800-9FFF)    Bloody Hack for Push16.
@----------------------------------------------------------------------------
	stmfd sp!,{addy,lr}
	bl VRAM_name0
	ldmfd sp!,{addy,lr}
	add addy,addy,#1
	tst addy,#0x2000 @For games which stack crash, prevent the VRAM code from seeing the write to A000
	beq VRAM_name0
	bx lr
@	
@	ldr r2,memmap_tbl+32
@	ldrb r1,vrambank
@	tst r1,#1
@	movne pc,lr  ;hack for GBC mode...
@	
@	
@	sub addy,addy,#1
@	ldrb r0,[r2,addy]!	;read 1st char
@	ldrb r1,[r2,#1]		;read 2nd char
@
@	ldr r2,agb_nt0
@	bic addy,addy,#0xf800	;AND $07ff
@	add addy,addy,addy	;lsl#1
@	tst addy,#0x0800	;for WIN color.
@	addne addy,addy,#0x1800
@	orr r0,r0,#0x300
@	orr r1,r1,#0x300
@	strh r0,[r2,addy]!	;write tile#
@	strh r1,[r2,#2]		;write tile#
@
@	bic r0,r0,#0x100	;for BG color.
@	bic r1,r1,#0x100	;for BG color.
@	add r2,r2,#0x1800
@	strh r0,[r2]		;write tile#
@	strh r1,[r2,#2]		;write tile#
@	mov pc,lr

@----------------------------------------------------------------------------

FF68_R:	@BCPS - BG Color Palette Specification
	ldrb_ r0,BCPS_index
	bx lr
FF69_R:	@BCPD - BG Color Palette Data
	ldrb_ r1,BCPS_index
	and r1,r1,#0x3F
	ldr r0,=gbc_palette
	ldrb r0,[r0,r1]
	bx lr
FF6A_R:	@OCPS - OBJ Color Palette Specification
	ldrb_ r0,OCPS_index
	bx lr
FF6B_R:	@OCPD - OBJ Color Palette Data
	ldrb_ r1,OCPS_index
	and r1,r1,#0x3F
	ldr r0,=gbc_palette+64
	ldrb r0,[r0,r1]
	bx lr

FF68_W:	@BCPS - BG Color Palette Specification
	strb_ r0,BCPS_index
	bx lr
FF69_W:	@BCPD - BG Color Palette Data
	ldrb_ r1,BCPS_index
	and r2,r1,#0x3F
	ldr addy,=gbc_palette
	strb r0,[addy,r2]
	tst r1,#0x80
	addne r1,r1,#1
	strneb_ r1,BCPS_index
	bx lr
@FF69_W	;BCPD - BG Color Palette Data
@	ldrb r1,BCPS_index
@	and r2,r1,#0x3F
@	ldr addy,=gbc_palette
@	add addy,addy,r2
@	ldrb r2,[addy]
@	strb r0,[addy]
@	tst r1,#0x80
@	addne r1,r1,#1
@	strneb r1,BCPS_index
@	and r1,r1,#0x3E
@in_ff69
@	cmp r2,r0
@	bxeq lr
@store_palette
@	ldr addy,=gbc_palette
@	ldr r0,scanline
@	add r0,r0,#8
@	orr r0,r0,r1,lsl#8
@	ldrh r2,[addy,r1]
@	orr r0,r0,r2,lsl#16
@	ldr addy,=palrptr
@	ldr r1,[addy],#4
@	ldr r2,[addy]
@	cmp r1,r2
@	ldr r1,=palbuff
@	str r0,[r1,r2]
@	add r2,r2,#4
@	bic r2,r2,#0x200
@	str r2,[addy]
@	bxne lr
@	ldr r1,=REG_BASE+REG_DISPSTAT
@	ldrh r2,[r1]
@	bic r2,r2,#0xFF00
@	and r0,r0,#0xFF
@	orr r2,r2,r0,lsl#8
@	strh r2,[r1]
@	bx lr
FF6A_W:	@OCPS - OBJ Color Palette Specification
	strb_ r0,OCPS_index
	bx lr
FF6B_W:	@OCPD - OBJ Color Palette Data
	ldrb_ r1,OCPS_index
	and r2,r1,#0x3F
	ldr addy,=gbc_palette+64
	strb r0,[addy,r2]
	tst r1,#0x80
	addne r1,r1,#1
	strneb_ r1,OCPS_index
	bx lr
@FF6B_W	;OCPD - OBJ Color Palette Data
@	ldrb r1,OCPS_index
@	and r2,r1,#0x3F
@	ldr addy,=gbc_palette+64
@	add addy,addy,r2
@	ldrb r2,[addy]
@	strb r0,[addy]
@	tst r1,#0x80
@	addne r1,r1,#1
@	strneb r1,OCPS_index
@	and r1,r1,#0x3E
@	add r1,r1,#0x40
@	b in_ff69
@@	adr addy,agb_pal+256
@@	mov r1,r2,lsr#3
@@	mov r1,r1,lsl#5
@@	and r2,r2,#0x07
@@	add r2,r2,r1
@@	strb r0,[addy,r2]
@@	bx lr

copyoam:
	stmfd sp!,{r0,r1,r2,addy,lr}
	ldr_ r1,gboambuff
	ldr_ r0,active_gboambuff
	mov r2,#160/4
	bl_long copy_
	ldmfd sp!,{r0,r1,r2,addy,pc}

OAM_R:
	cmp addy,#0xFE00
	bmi echo_R
	ldr_ r1,gboambuff
	ldrb r0,[r1,r2]
	mov pc,lr
OAM_W:
	cmp addy,#0xFE00
	bmi echo_W
	mov r1,#2
	strb_ r1,gboamdirty
	ldr_ r1,gboambuff
	strb r0,[r1,r2]
	mov pc,lr


@----------------------------------------------------------------------------
@no, you're not going in a READ_ONLY area!
fpstext: .ascii "FPS:    "
fpsenabled: .byte 0
fpschk:	.byte 0
	.byte 0
		.byte 0

@----------------------------------------------------------------------------

gbc_palette:	.skip 128	@CGB $FF68-$FF6D???
gbc_palette2:	.skip 128

@----------------------------------------------------------------------------
 .align
 .pool
 .section .iwram, "ax", %progbits
 .subsection 101
 .align
 .pool

FPSValue:
	.word 0
AGBinput:		@this label here for main.c to use
	.word 0 @AGBjoypad (why is this in lcd.s again?  um.. i forgot)
EMUinput:	.word 0 @EMUjoypad (this is what GB sees)

lcdstate:
	.byte 0 @lcdctrl  ff40
	.byte 0 @lcdstat
	.byte 0 @scrollX
	.byte 0 @scrollY
	
	.byte 0 @scanline
	.byte 0 @lcdyc
	.byte 0 @[unused] dma start address
	.byte 0 @bgpalette

	.byte 0 @ob0palette
	.byte 0 @ob1palette
	.byte 0 @windowX
	.byte 0 @windowY
	
	.byte 0 @BCPS_index  ;actually ff68
	.byte 0 @doublespeed
	.byte 0 @OCPS_index  ;actually ff6a
	.byte 0 @vrambank

	.word 0 @dma_src, dma_dest

	.word 0 @bigbuffer
	.word 0 @bg01cnt
	.word 0 @bg23cnt
	.word 0 @xyscroll
	.word 0 @xyscroll2
	.word 0 @dispcntdata
	.word 0 @windata
	.word 0 @dispcntaddr
	.word 0 @windowyscroll
	.word 0 @buffer_lastscanline
	
	.byte 0 @lcdctrl0midframe
lcdctrl0frame_:
	.byte 0 @lcdctrl0frame
	.byte 0 @rendermode
ui_border_visible:	.byte 0 @_ui_border_visible
	.word 0 @ui_border_cnt_bic
	.word 0 @ui_border_cnt_orr
	.word 0 @ui_border_scroll2
	.word 0 @ui_border_scroll3
ui_x:	.word 0 @_ui_x
ui_y:	.word 0 @_ui_y
ui_border_request:	.word 0 @_ui_border_request # 4
ui_border_screen:	.word 0 @_ui_border_screen # 4
ui_border_buffer:	.word 0 @_ui_border_buffer # 4
sgb_palette_number: .byte 0 @_sgb_palette_number
gammavalue:	.byte 0 @_gammavalue
darkness:	.byte 0 @_darkness
	.byte 0

@ .section .iwram, "ax", %progbits
@ .subsection 115
@ .align
@ .pool

	.word DISPCNTBUFF		@dispcntbase
	.word DISPCNTBUFF2		@dispcntbase2
	.word BG0CNT_SCROLL_BUFF	@bigbufferbase
	.word BG0CNT_SCROLL_BUFF2	@bigbufferbase2

	.byte 0				@gboamdirty
	.byte 0				@consume_dirty
	.byte 0				@consume_buffer
	.byte 0				@vblank_happened


	.word GBOAMBUFF1		@gboambuff
	.word GBOAMBUFF2		@active_gboambuff
	.word DIRTY_TILES		@dirty_tiles
	.word DIRTY_ROWS		@dirty_rows

palettebank:	.word 0				@_palettebank


@...update load/savestate if you move things around in here
@----------------------------------------------------------------------------
	@.end
