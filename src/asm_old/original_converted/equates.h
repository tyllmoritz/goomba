 GBAMPVERSION = 0
 VERSION_IN_ROM = 0

		@GBLL DEBUG
		@GBLL SAFETY
		@GBLL PROFILE
		@GBLL SPEEDHACKS
		@GBLL MOVIEPLAYER
		@GBLL RESIZABLE
		@GBLL RUMBLE
		@GBLL SAVESTATES

		@GBLL LITTLESOUNDDJ

 DEBUG		= 0
 PROFILE		= 0
 SPEEDHACKS		= 0
 LITTLESOUNDDJ   = 0

 .if GBAMPVERSION
 MOVIEPLAYER		= 0
 RESIZABLE		= 0
 RUMBLE	= 0
 .else
 MOVIEPLAYER		= 0
 RESIZABLE		= 0
 RUMBLE	= 0
 .endif

 SAVESTATES	= 0

@BUILD		SETS "DEBUG"/"GBA"	(defined at cmdline)
@----------------------------------------------------------------------------

 XGB_RAM		= 0x3005280
 XGB_HRAM	= XGB_RAM+0x2000
 CHR_DECODE	= XGB_HRAM+0x80
@?		EQU CHR_DECODE+0x400

@statck starts at 0x03007700

 BORDER_PALETTE = 0x06006F80

				@This area can probably be overwritten when making a savestate.
  .if RESIZABLE

 SCROLLBUFF1		= 0x06002000-160*16
 SCROLLBUFF2		= SCROLLBUFF1-160*16
 BG0CNTBUFF		= SCROLLBUFF2-164*8
 WINBUFF		= BG0CNTBUFF-160*8

	.if SPEEDHACKS
 speedhacks  = 0x2040000-512
 MAPPED_RGB		= speedhacks-16*4	@mapped GB palette.
	.else
 MAPPED_RGB		= 0x2040000-16*4	@mapped GB palette.
	.endif
@palbuff			EQU MAPPED_RGB - 512

 INSTANT_PAGES = MAPPED_RGB-1024
 openFiles       = INSTANT_PAGES-1200
 lfnName			= openFiles-256
@fatBuffer	EQU lfnName-512
 globalBuffer    = lfnName-512
 fatBuffer	= globalBuffer-512
 SramName		= fatBuffer-256


@77552

@10664 bytes for these:
 DISPCNTBUFF		= SramName-164*2

 END_OF_EXRAM	= DISPCNTBUFF-0000	@How much data is left for Multiboot to work.
 DMA1BUFF		= DISPCNTBUFF
 fatWriteBuffer = fatBuffer


  
  .else
 MAX_RECENT_TILES = 96  @if you change this, change RECENT_TILES as well!

@VRAM areas:
@0x600 bytes at 06006200
@0x80 bytes at 06006f00
@0x400 bytes at 0600cc00
@0x4000 at 06014000
@0x300 at 06007D00-06008000

@SGB border areas coincide with the GBA areas reserved for them
 SNES_VRAM	= 0x06004220 @one tile ahead, too bad if games don't write low tiles then high tiles, also overlaps with recent_tiles...
 SNES_MAP	= 0x06006780 @overlaps with recent_tiles, map must be updated in reverse order
 RECENT_TILES	= 0x06006200 @DIRTY_TILES-(MAX_RECENT_TILES*16)



 MEM_END	= 0x02040000

 XGB_SRAM	= MEM_END-0x8000
 XGB_VRAM	= XGB_SRAM-0x4000
 GBC_EXRAM	= XGB_VRAM-0x6000
 SGB_PACKET	= GBC_EXRAM-112
 INSTANT_PAGES	= 0x0600cc00 @SGB_PACKET-1024
 SGB_PALETTE	= SGB_PACKET-16*4

 DIRTY_ROWS = SGB_PALETTE-48
 DIRTY_TILES = DIRTY_ROWS-768-4
 RECENT_TILENUM	= DIRTY_TILES-(MAX_RECENT_TILES+2)*2

 SGB_PALS	= RECENT_TILENUM-4096
 SGB_ATFS	= SGB_PALS-4096
 sgb_attributes = SGB_ATFS-360


 GBOAMBUFF1	= sgb_attributes-160
 GBOAMBUFF2	= GBOAMBUFF1-160

 BG0CNT_SCROLL_BUFF	= GBOAMBUFF2-144*24
 WINDOWBUFF	= BG0CNT_SCROLL_BUFF-144*2
 DISPCNTBUFF	= WINDOWBUFF-144*2
 WXBUFF1	= DISPCNTBUFF-144
 YSCROLLBUFF1	= WXBUFF1-144
 XSCROLLBUFF1	= YSCROLLBUFF1-144
 LCDCBUFF1	= XSCROLLBUFF1-144
 WXBUFF2	= LCDCBUFF1-144
 YSCROLLBUFF2	= WXBUFF2-144
 XSCROLLBUFF2	= YSCROLLBUFF2-144
 LCDCBUFF2	= XSCROLLBUFF2-144

 MULTIBOOT_LIMIT	= LCDCBUFF2-0	@How much data is left for Multiboot to work.

 openFiles	= LCDCBUFF2-1200
 lfnName	= openFiles-256
 globalBuffer	= lfnName-512
 fatBuffer	= globalBuffer-512
 SramName	= fatBuffer-256
 fatWriteBuffer	= fatBuffer



@MEM_END	EQU 0x02040000
@GBOAMBUFF1	EQU -160
@GBOAMBUFF2	EQU -160
@SCROLLBUFF	EQU -144*16
@BG0CNTBUFF	EQU -144*8
@DISPCNTBUFF	EQU -144*2
@XSCROLLBUFF1	EQU -144
@XSCROLLBUFF2	EQU -144
@YSCROLLBUFF1	EQU -144
@YSCROLLBUFF2	EQU -144
@LCDCONTROLBUFF1	EQU -144
@LCDCONTROLBUFF2	EQU -144  ;0x1200 + 0x140
@XGB_SRAM	EQU -0x8000
@XGB_VRAM	EQU -0x4000
@GBC_EXRAM	EQU -0x6000
@INSTANT_PAGES	EQU -1024
@MAPPED_RGB	EQU -16*4
@openFiles	EQU -1200
@lfnName	EQU -256
@globalBuffer	EQU -512
@fatBuffer	EQU -512
@SramName	EQU -256
@MULTIBOOT_LIMIT	EQU -0	;How much data is left for Multiboot to work.

@speedhacks  EQU -512

  .endif



 AGB_IRQVECT		= 0x3007FFC
 AGB_PALETTE		= 0x5000000
 AGB_VRAM		= 0x6000000
 AGB_OAM			= 0x7000000
 AGB_SRAM		= 0xE000000

@map1        0x06001000
@map2        0x06001800
@map1 blocks 0x06002000
@map2 blocks 0x06002800

 AGB_BG			= AGB_VRAM+0xA000
 AGB_BG_GBMODE		= AGB_VRAM+0x4000

 DEBUGSCREEN		= AGB_VRAM+0x7800

 REG_BASE		= 0x4000000
 REG_DISPCNT		= 0x00
 REG_DISPSTAT	= 0x04
 REG_VCOUNT		= 0x06
 REG_BG0CNT		= 0x08
 REG_BG1CNT		= 0x0A
 REG_BG2CNT		= 0x0C
 REG_BG3CNT		= 0x0E
 REG_BG0HOFS		= 0x10
 REG_BG0VOFS		= 0x12
 REG_BG1HOFS		= 0x14
 REG_BG1VOFS		= 0x16
 REG_BG2HOFS		= 0x18
 REG_BG2VOFS		= 0x1A
 REG_BG3HOFS		= 0x1C
 REG_BG3VOFS		= 0x1E
 REG_WIN0H		= 0x40
 REG_WIN1H		= 0x42
 REG_WIN0V		= 0x44
 REG_WIN1V		= 0x46
 REG_WININ		= 0x48
 REG_WINOUT		= 0x4A
 REG_BLDCNT		= 0x50
 REG_BLDALPHA	= 0x52
 REG_BLDY		= 0x54
 REG_SG1CNT_L	= 0x60
 REG_SG1CNT_H	= 0x62
 REG_SG1CNT_X	= 0x64
 REG_SG2CNT_L	= 0x68
 REG_SG2CNT_H	= 0x6C
 REG_SG3CNT_L	= 0x70
 REG_SG3CNT_H	= 0x72
 REG_SG3CNT_X	= 0x74
 REG_SG4CNT_L	= 0x78
 REG_SG4CNT_H	= 0x7c
 REG_SGCNT_L		= 0x80
 REG_SGCNT_H		= 0x82
 REG_SGCNT_X		= 0x84
 REG_SGBIAS		= 0x88
 REG_SGWR0_L		= 0x90
 REG_FIFO_A_L	= 0xA0
 REG_FIFO_A_H	= 0xA2
 REG_FIFO_B_L	= 0xA4
 REG_FIFO_B_H	= 0xA6
 REG_DM0SAD		= 0xB0
 REG_DM0DAD		= 0xB4
 REG_DM0CNT_L	= 0xB8
 REG_DM0CNT_H	= 0xBA
 REG_DM1SAD		= 0xBC
 REG_DM1DAD		= 0xC0
 REG_DM1CNT_L	= 0xC4
 REG_DM1CNT_H	= 0xC6
 REG_DM2SAD		= 0xC8
 REG_DM2DAD		= 0xCC
 REG_DM2CNT_L	= 0xD0
 REG_DM2CNT_H	= 0xD2
 REG_DM3SAD		= 0xD4
 REG_DM3DAD		= 0xD8
 REG_DM3CNT_L	= 0xDC
 REG_DM3CNT_H	= 0xDE
 REG_TM0D		= 0x100
 REG_TM0CNT		= 0x102
 REG_IE			= 0x200
 REG_IME			= 0x208
 REG_IF			= 0x4000202
 REG_P1			= 0x4000130
 REG_P1CNT		= 0x132
 REG_WAITCNT		= 0x4000204

 REG_SIOMULTI0	= 0x20 @+100
 REG_SIOMULTI1	= 0x22 @+100
 REG_SIOMULTI2	= 0x24 @+100
 REG_SIOMULTI3	= 0x26 @+100
 REG_SIOCNT		= 0x28 @+100
 REG_SIOMLT_SEND	= 0x2a @+100
 REG_RCNT		= 0x34 @+100

		@r0,r1,r2=temp regs
 gb_flg		.req r3 @bit 31=N, Z=1 if bits 0-7=0
 gb_a		.req r4 @bits 0-15=0
 gb_bc		.req r5 @bits 0-15=0
 gb_de		.req r6 @bits 0-15=0
 gb_hl		.req r7 @bits 0-15=0
 cycles		.req r8
 gb_pc		.req r9
 globalptr	.req r10 @=wram_globals* ptr
 gb_optbl	.req r10
 gb_sp		.req r11
 addy		.req r12 @keep this at r12 (scratch for APCS)
		@r13=SP
		@r14=LR
		@r15=PC
@----------------------------------------------------------------------------

@ MAP 0,gb_zpage
@xgb_ram # 0x2000
@xgb_hram # 0x80
@chr_decode # 0x400

@everything in wram_globals* areas:

	@GBLA _address
 _address = 0
 opz = _address 
 _address = _address+256*4 @gb-z80.s
 readmem_tbl = _address 
 _address = _address+16*4
 writemem_tbl = _address 
 _address = _address+16*4
 memmap_tbl = _address 
 _address = _address+16*4
 cpuregs = _address 
 _address = _address+8*4
 gb_ime = _address 
 _address = _address+1
 gb_ie = _address 
 _address = _address+1
 gb_if = _address 
 _address = _address+1
 gb_ic = _address 
 _address = _address+1  @not actually used
 lastbank = _address 
 _address = _address+4
 dividereg = _address 
 _address = _address+4
 timercounter = _address 
 _address = _address+4
 timermodulo = _address 
 _address = _address+1
 timerctrl = _address 
 _address = _address+1
 stctrl = _address 
 _address = _address+1
 debugstop = _address 
 _address = _address+1 @align
 nexttimeout = _address 
 _address = _address+4
 nexttimeout_alt = _address 
 _address = _address+4
 scanlinehook = _address 
 _address = _address+4
 frame = _address 
 _address = _address+4
 cyclesperscanline = _address 
 _address = _address+4
 .if SPEEDHACKS
 numspeedhacks = _address 
 _address = _address+4
 speedhacks_p = _address 
 _address = _address+4
 .endif
 .if PROFILE
 profiler = _address 
 _address = _address+4
 .endif
 rambank = _address 
 _address = _address+1
 gbcmode = _address 
 _address = _address+1
 sgbmode = _address 
 _address = _address+1
 hackflags = _address 
 _address = _address+1
 doubletimer_ = _address 
 _address = _address+1
 gbamode = _address 
 _address = _address+1
 request_gb_type_ = _address 
 _address = _address+1
 novblankwait_ = _address 
 _address = _address+1

 .if RESIZABLE
 xgb_sram = _address 
 _address = _address+4
 xgb_sramsize = _address 
 _address = _address+4
 xgb_vram = _address 
 _address = _address+4
 xgb_vramsize = _address 
 _address = _address+4
 gbc_exram = _address 
 _address = _address+4
 gbc_exramsize = _address 
 _address = _address+4
 end_of_exram = _address 
 _address = _address+4
 .endif
			@lcd.s (wram_globals1)
 fpsvalue = _address 
 _address = _address+4
 AGBjoypad = _address 
 _address = _address+4
 XGBjoypad = _address 
 _address = _address+4

 lcdctrl = _address 
 _address = _address+1
 lcdstat = _address 
 _address = _address+1
 scrollX = _address 
 _address = _address+1
 scrollY = _address 
 _address = _address+1

 scanline = _address 
 _address = _address+1
 lcdyc = _address 
 _address = _address+1
 _address = _address+1
 bgpalette = _address 
 _address = _address+1

 ob0palette = _address 
 _address = _address+1
 ob1palette = _address 
 _address = _address+1
 windowX = _address 
 _address = _address+1
 windowY = _address 
 _address = _address+1

 BCPS_index = _address 
 _address = _address+1
 doublespeed = _address 
 _address = _address+1
 OCPS_index = _address 
 _address = _address+1
 vrambank = _address 
 _address = _address+1

 dma_src = _address 
 _address = _address+2
 dma_dest = _address 
 _address = _address+2

			@cart.s (wram_globals2)
 bank0 = _address 
 _address = _address+4
 bank1 = _address 
 _address = _address+4
 srambank = _address 
 _address = _address+4
 mapperdata = _address 
 _address = _address+32
 sramwptr = _address 
 _address = _address+4

 biosbase = _address 
 _address = _address+4
 rombase = _address 
 _address = _address+4
 romnumber = _address 
 _address = _address+4
 emuflags = _address 
 _address = _address+4  @NOT ACTUALLY USED!

 rommask = _address 
 _address = _address+4
 rammask = _address 
 _address = _address+4

 cartflags = _address 
 _address = _address+1
 sramsize = _address 
 _address = _address+1
 _address = _address+2
			@io.s (wram_globals3)
 joy0state = _address 
 _address = _address+1
 joy1state = _address 
 _address = _address+1
 joy2state = _address 
 _address = _address+1
 joy3state = _address 
 _address = _address+1
 joy0serial = _address 
 _address = _address+1
 joy1serial = _address 
 _address = _address+1
 _address = _address+2

			@sgb.s (wram_globals4)
 packetcursor = _address 
 _address = _address+4
 packetbitcursor = _address 
 _address = _address+4
 packetstate = _address 
 _address = _address+1
 player_turn = _address 
 _address = _address+1
 player_mask = _address 
 _address = _address+1
 sgb_mask = _address 
 _address = _address+1

 update_border_palette = _address 
 _address = _address+1
 _address = _address+3
 sgb_hack_frame = _address 
 _address = _address+4


			@gbz80.s (wram_globals5)
 fiveminutes_ = _address 
 _address = _address+4
 sleeptime_ = _address 
 _address = _address+4
 dontstop_ = _address 
 _address = _address+1
 _address = _address+3

   
   

@----------------------------------------------------------------------------
@IRQ_VECTOR EQU 0xfffe ; IRQ/BRK interrupt vector address
@RES_VECTOR EQU 0xfffc ; RESET interrupt vector address
@NMI_VECTOR EQU 0xfffa ; NMI interrupt vector address
@-----------------------------------------------------------cartflags
 MBC_RAM		= 0x01 @ram in cart
 MBC_SAV		= 0x02 @battery in cart
 MBC_TIM		= 0x04 @timer in cart
 MBC_RUM		= 0x08 @rumble in cart
 MBC_TIL		= 0x10 @tilt in cart

@-----------------------------------------------------------hackflags
 USEPPUHACK	= 1	@use $2002 hack
 CPUHACK	= 2	@don't use JMP hack
@?		EQU 16
@FOLLOWMEM       EQU 32  ;0=follow sprite, 1=follow mem

				@bits 8-5=scale type

				@bits 16-31=sprite follow val

@----------------------------------------------------------------------------
 CYC_SHIFT		= 4
 CYCLE			= 1<<CYC_SHIFT @one cycle (455*CYCLE cycles per scanline)

@cycle flags- (stored in cycles reg for speed)

 BRANCH			= 0x01 @branch instruction encountered
@				EQU 0x02
@				EQU 0x04
@				EQU 0x08
 CYC_MASK		= CYCLE-1	@Mask

 SINGLE_SPEED = 456*CYCLE
 DOUBLE_SPEED = 912*CYCLE

 WINDOW_TOP = 8
 WINDOW_LEFT = 40

@----------------------------------------------------------------------------

	.macro ldr_ reg,label
	ldr \reg,[globalptr,#\label]
	.endm
	
	.macro ldrb_ reg,label
	ldrb \reg,[globalptr,#\label]
	.endm
	
	.macro ldrh_ reg,label
	ldrh \reg,[globalptr,#\label]
	.endm
	
	.macro str_ reg,label
	str \reg,[globalptr,#\label]
	.endm
	
	.macro strb_ reg,label
	strb \reg,[globalptr,#\label]
	.endm
	
	.macro strh_ reg,label
	strh \reg,[globalptr,#\label]
	.endm



	.macro ldreq_ reg,label
	ldreq \reg,[globalptr,#\label]
	.endm
	
	.macro ldreqb_ reg,label
	ldreqb \reg,[globalptr,#\label]
	.endm
	
	.macro streq_ reg,label
	streq \reg,[globalptr,#\label]
	.endm
	
	.macro streqb_ reg,label
	streqb \reg,[globalptr,#\label]
	.endm
	



	.macro ldrne_ reg,label
	ldrne \reg,[globalptr,#\label]
	.endm
	
	.macro ldrneb_ reg,label
	ldrneb \reg,[globalptr,#\label]
	.endm
	
	.macro strne_ reg,label
	strne \reg,[globalptr,#\label]
	.endm
	
	.macro strneb_ reg,label
	strneb \reg,[globalptr,#\label]
	.endm
	


	.macro ldrhi_ reg,label
	ldrhi \reg,[globalptr,#\label]
	.endm
	
	.macro ldrhib_ reg,label
	ldrhib \reg,[globalptr,#\label]
	.endm
	
	.macro strhi_ reg,label
	strhi \reg,[globalptr,#\label]
	.endm
	
	.macro strhib_ reg,label
	strhib \reg,[globalptr,#\label]
	.endm


	.macro ldrmi_ reg,label
	ldrmi \reg,[globalptr,#\label]
	.endm
	
	.macro ldrmib_ reg,label
	ldrmib \reg,[globalptr,#\label]
	.endm
	
	.macro strmi_ reg,label
	strmi \reg,[globalptr,#\label]
	.endm
	
	.macro strmib_ reg,label
	strmib \reg,[globalptr,#\label]
	.endm

	.macro ldrpl_ reg,label
	ldrpl \reg,[globalptr,#\label]
	.endm
	
	.macro ldrplb_ reg,label
	ldrplb \reg,[globalptr,#\label]
	.endm
	
	.macro strpl_ reg,label
	strpl \reg,[globalptr,#\label]
	.endm
	
	.macro strplb_ reg,label
	strplb \reg,[globalptr,#\label]
	.endm


	.macro ldrgt_ reg,label
	ldrgt \reg,[globalptr,#\label]
	.endm
	
	.macro ldrgtb_ reg,label
	ldrgtb \reg,[globalptr,#\label]
	.endm
	
	.macro strgt_ reg,label
	strgt \reg,[globalptr,#\label]
	.endm
	
	.macro strgtb_ reg,label
	strgtb \reg,[globalptr,#\label]
	.endm


	.macro ldrge_ reg,label
	ldrge \reg,[globalptr,#\label]
	.endm
	
	.macro ldrgeb_ reg,label
	ldrgeb \reg,[globalptr,#\label]
	.endm
	
	.macro strge_ reg,label
	strge \reg,[globalptr,#\label]
	.endm
	
	.macro strgeb_ reg,label
	strgeb \reg,[globalptr,#\label]
	.endm


	.macro ldrlt_ reg,label
	ldrlt \reg,[globalptr,#\label]
	.endm
	
	.macro ldrltb_ reg,label
	ldrltb \reg,[globalptr,#\label]
	.endm
	
	.macro strlt_ reg,label
	strlt \reg,[globalptr,#\label]
	.endm
	
	.macro strltb_ reg,label
	strltb \reg,[globalptr,#\label]
	.endm


	.macro ldrle_ reg,label
	ldrle \reg,[globalptr,#\label]
	.endm
	
	.macro ldrleb_ reg,label
	ldrleb \reg,[globalptr,#\label]
	.endm
	
	.macro strle_ reg,label
	strle \reg,[globalptr,#\label]
	.endm
	
	.macro strleb_ reg,label
	strleb \reg,[globalptr,#\label]
	.endm


	.macro ldrlo_ reg,label
	ldrlo \reg,[globalptr,#\label]
	.endm
	
	.macro ldrlob_ reg,label
	ldrlob \reg,[globalptr,#\label]
	.endm
	
	.macro strlo_ reg,label
	strlo \reg,[globalptr,#\label]
	.endm
	
	.macro strlob_ reg,label
	strlob \reg,[globalptr,#\label]
	.endm
	






	.macro adr_ reg,label
	add \reg,globalptr,#\label
	.endm
	
	.macro adrl_ reg,label
	add \reg,globalptr,#((\label) & 0xFF00)
	add \reg,\reg,#((\label) & 0x00FF)
	.endm
	
	


 .if VERSION_IN_ROM
	.macro bl_long label
	mov lr,pc
	ldr pc,=\label
	.endm

	.macro bleq_long label
	moveq lr,pc
	ldreq pc,=\label
	.endm

	.macro bllo_long label
	movlo lr,pc
	ldrlo pc,=\label
	.endm

	.macro blhi_long label
	movhi lr,pc
	ldrhi pc,=\label
	.endm

	.macro bllt_long label
	movlt lr,pc
	ldrlt pc,=\label
	.endm

	.macro blgt_long label
	movgt lr,pc
	ldrgt pc,=\label
	.endm

	.macro blne_long label
	movne lr,pc
	ldrne pc,=\label
	.endm

	.macro blcc_long label
	movcc lr,pc
	ldrcc pc,=\label
	.endm

	.macro blpl_long label
	movpl lr,pc
	ldrpl pc,=\label
	.endm

	.macro b_long label
	ldr pc,=\label
	.endm

	.macro bcc_long label
	ldrcc pc,=\label
	.endm

	.macro bhs_long label
	ldrhs pc,=\label
	.endm

	.macro beq_long label
	ldreq pc,=\label
	.endm

	.macro bne_long label
	ldrne pc,=\label
	.endm

	.macro blo_long label
	ldrlo pc,=\label
	.endm

	.macro bhi_long label
	ldrhi pc,=\label
	.endm

	.macro bgt_long label
	ldrgt pc,=\label
	.endm

	.macro blt_long label
	ldrlt pc,=\label
	.endm

	.macro bcs_long label
	ldrcs pc,=\label
	.endm

	.macro bmi_long label
	ldrmi pc,=\label
	.endm

	.macro bpl_long label
	ldrpl pc,=\label
	.endm

	.else

	.macro bl_long label
	bl \label
	.endm

	.macro bleq_long label
	bleq \label
	.endm

	.macro bllo_long label
	bllo \label
	.endm

	.macro blhi_long label
	blhi \label
	.endm

	.macro bllt_long label
	bllt \label
	.endm

	.macro blgt_long label
	blgt \label
	.endm

	.macro blne_long label
	blne \label
	.endm

	.macro blcc_long label
	blcc \label
	.endm

	.macro blpl_long label
	blpl \label
	.endm

	.macro b_long label
	b \label
	.endm

	.macro bcc_long label
	bcc \label
	.endm

	.macro bhs_long label
	bhs \label
	.endm

	.macro beq_long label
	beq \label
	.endm

	.macro bne_long label
	bne \label
	.endm

	.macro blo_long label
	blo \label
	.endm

	.macro bhi_long label
	bhi \label
	.endm

	.macro bgt_long label
	bgt \label
	.endm

	.macro blt_long label
	blt \label
	.endm

	.macro bcs_long label
	bcs \label
	.endm

	.macro bmi_long label
	bmi \label
	.endm

	.macro bpl_long label
	bpl \label
	.endm
 .endif


