	VERSION_IN_ROM = 1
	GBAMPVERSION = 0

	#include "macro.h"

		@GBLL DEBUG
		@GBLL SAFETY
		@GBLL PROFILE
		@GBLL SPEEDHACKS
		@GBLL MOVIEPLAYER
		@GBLL RESIZABLE
		@GBLL RUMBLE
		@GBLL SAVESTATES

		@GBLL SRAM_32

		@GBLL LITTLESOUNDDJ

 SRAM_32		= 0

 DEBUG		= 0
 PROFILE		= 0
 SPEEDHACKS		= 0
 LITTLESOUNDDJ   = 0

 .if GBAMPVERSION
 MOVIEPLAYER		= 1
 RESIZABLE		= 1
 RUMBLE	= 0
 .else
 MOVIEPLAYER		= 0
 RESIZABLE		= 0
 RUMBLE	= 1
 .endif

 SAVESTATES	= 0

@BUILD		SETS "DEBUG"/"GBA"	(defined at cmdline)
@----------------------------------------------------------------------------

 XGB_RAM		= 0x3005400
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

 BG0CNT_SCROLL_BUFF2	= DISPCNTBUFF-144*24
 WINDOWBUFF2	= BG0CNT_SCROLL_BUFF2-144*2
 DISPCNTBUFF2	= WINDOWBUFF2-144*2

@WXBUFF1	EQU DISPCNTBUFF-144
@YSCROLLBUFF1	EQU WXBUFF1-144
@XSCROLLBUFF1	EQU YSCROLLBUFF1-144
@LCDCBUFF1	EQU XSCROLLBUFF1-144
@WXBUFF2	EQU LCDCBUFF1-144
@YSCROLLBUFF2	EQU WXBUFF2-144
@XSCROLLBUFF2	EQU YSCROLLBUFF2-144
@LCDCBUFF2	EQU XSCROLLBUFF2-144

 MULTIBOOT_LIMIT	= DISPCNTBUFF2-0	@How much data is left for Multiboot to work.

 openFiles	= DISPCNTBUFF2-1200
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
 REG_BLDMOD		= 0x50
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

 start_map 0,globalptr	@gb-z80.s
 _m_ opz,256*4
 _m_ readmem_tbl,16*4
 _m_ writemem_tbl,16*4
 _m_ memmap_tbl,16*4
 _m_ cpuregs,8*4
 _m_ gb_ime,1
 _m_ gb_ie,1
 _m_ gb_if,1
 _m_ gb_ic,1  @not actually used
 _m_ lastbank,4
 _m_ dividereg,4
 _m_ timercounter,4
 _m_ timermodulo,1
 _m_ timerctrl,1
 _m_ stctrl,1
 _m_ debugstop,1 @align
 _m_ nexttimeout,4
 _m_ nexttimeout_alt,4
 _m_ scanlinehook,4
 _m_ frame,4
 _m_ cyclesperscanline,4
 .if SPEEDHACKS
 _m_ numspeedhacks,4
 _m_ speedhacks_p,4
 .endif
 .if PROFILE
 _m_ profiler,4
 .endif
 _m_ rambank,1
 _m_ gbcmode,1
 _m_ sgbmode,1
 _m_ hackflags,1
 _m_ doubletimer_,1
 _m_ gbamode,1
 _m_ request_gb_type_,1
 _m_ novblankwait_,1
 _m_ hblankposition,4

 .if RESIZABLE
 _m_ xgb_sram,4
 _m_ xgb_sramsize,4
 _m_ xgb_vram,4
 _m_ xgb_vramsize,4
 _m_ gbc_exram,4
 _m_ gbc_exramsize,4
 _m_ end_of_exram,4
 .endif
			@lcd.s (wram_globals1)
 _m_ fpsvalue,4
 _m_ AGBjoypad,4
 _m_ XGBjoypad,4

 _m_ lcdctrl,1
 _m_ lcdstat,1
 _m_ scrollX,1
 _m_ scrollY,1

 _m_ scanline,1
 _m_ lcdyc,1
 _m_ ,1
 _m_ bgpalette,1

 _m_ ob0palette,1
 _m_ ob1palette,1
 _m_ windowX,1
 _m_ windowY,1

 _m_ BCPS_index,1
 _m_ doublespeed,1
 _m_ OCPS_index,1
 _m_ vrambank,1

 _m_ dma_src,2
 _m_ dma_dest,2

	_m_ bigbuffer,4
		_m_ bg01cnt,4
		_m_ bg23cnt,4
	_m_ xyscroll,4
	_m_ xyscroll2,4
	_m_ dispcntdata,4
		_m_ windata,4
	_m_ dispcntaddr,4
	_m_ windowyscroll,4
	_m_ buffer_lastscanline,4

 _m_ lcdctrl0midframe,1
 _m_ lcdctrl0frame,1
 _m_ rendermode,1
 _m_ _ui_border_visible,1

 _m_ ui_border_cnt_bic,4
 _m_ ui_border_cnt_orr,4
 _m_ ui_border_scroll2,4
 _m_ ui_border_scroll3,4
 _m_ _ui_x,4
 _m_ _ui_y,4
 _m_ _ui_border_request,4
 _m_ _ui_border_screen,4
 _m_ _ui_border_buffer,4

 _m_ _sgb_palette_number,1
 _m_ _gammavalue,1
 _m_ _darkness,1
 _m_ ,1

			@lcd.s (wram_globals1)

 _m_ dispcntbase,4
 _m_ dispcntbase2,4
 _m_ bigbufferbase,4
 _m_ bigbufferbase2,4

 _m_ gboamdirty,1
 _m_ consume_dirty,1
 _m_ consume_buffer,1
 _m_ vblank_happened,1

 _m_ gboambuff,4
 _m_ active_gboambuff,4
 _m_ dirty_tiles,4
 _m_ dirty_rows,4

 _m_ _palettebank,4


			@cart.s (wram_globals2)
 _m_ bank0,4
 _m_ bank1,4
 _m_ srambank,4
 _m_ mapperdata,32
 _m_ sramwptr,4

 _m_ biosbase,4
 _m_ rombase,4
 _m_ romnumber,4
 _m_ emuflags,4  @NOT ACTUALLY USED!

 _m_ rommask,4
 _m_ rammask,4

 _m_ cartflags,1
 _m_ sramsize,1
 _m_ ,2
			@io.s (wram_globals3)
 _m_ joy0state,1
 _m_ joy1state,1
 _m_ joy2state,1
 _m_ joy3state,1
 _m_ joy0serial,1
 _m_ joy1serial,1
	_m_ ,2

			@sgb.s (wram_globals4)
 _m_ packetcursor,4
 _m_ packetbitcursor,4
 _m_ packetstate,1
 _m_ player_turn,1
 _m_ player_mask,1
 _m_ sgb_mask,1

 _m_ update_border_palette,1
 _m_ ,3
 _m_ sgb_hack_frame,4


			@gbz80.s (wram_globals5)
 _m_ fiveminutes_,4
   _m_ sleeptime_,4
    _m_ dontstop_,1
 _m_ ,3

   
   

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
 SINGLE_SPEED_HBLANK = 204*CYCLE  @should be 204
 DOUBLE_SPEED_HBLANK = 408*CYCLE


 WINDOW_TOP = 8
 WINDOW_LEFT = 40

@----------------------------------------------------------------------------

		@.end
