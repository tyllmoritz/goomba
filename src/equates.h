	INCLUDE macro.h

		GBLL DEBUG
		GBLL SAFETY
		GBLL PROFILE
		GBLL SPEEDHACKS
		GBLL MOVIEPLAYER
		GBLL RESIZABLE
		GBLL RUMBLE
		GBLL SAVESTATES

		GBLL SRAM_32

		GBLL LITTLESOUNDDJ

;SRAM_32		SETL {FALSE}

DEBUG		SETL {FALSE}
PROFILE		SETL {FALSE}
SPEEDHACKS		SETL {FALSE}
LITTLESOUNDDJ   SETL {FALSE}

 [ GBAMPVERSION
MOVIEPLAYER		SETL {TRUE}
RESIZABLE		SETL {TRUE}
RUMBLE	SETL {FALSE}
 |
MOVIEPLAYER		SETL {FALSE}
RESIZABLE		SETL {FALSE}
RUMBLE	SETL {TRUE}
 ]

SAVESTATES	SETL {FALSE}

;BUILD		SETS "DEBUG"/"GBA"	(defined at cmdline)
;----------------------------------------------------------------------------

MAX_RECENT_TILES EQU 96  ;if you change this, change RECENT_TILES as well!
BG_CACHE_SIZE EQU 512


;statck starts at 0x03007700

BORDER_PALETTE EQU 0x0600EF80	;formerly 0x06006F80

				;This area can probably be overwritten when making a savestate.
  [ RESIZABLE

SCROLLBUFF1		EQU 0x06002000-160*16
SCROLLBUFF2		EQU SCROLLBUFF1-160*16
BG0CNTBUFF		EQU SCROLLBUFF2-164*8
WINBUFF		EQU BG0CNTBUFF-160*8

	[ SPEEDHACKS
speedhacks  EQU 0x2040000-512
MAPPED_RGB		EQU speedhacks-16*4	;mapped GB palette.
	|
MAPPED_RGB		EQU 0x2040000-16*4	;mapped GB palette.
	]
;palbuff			EQU MAPPED_RGB - 512

INSTANT_PAGES EQU MAPPED_RGB-1024

openFiles       EQU INSTANT_PAGES-1200
lfnName			EQU openFiles-256
;fatBuffer	EQU lfnName-512
globalBuffer    EQU lfnName-512
fatBuffer	EQU globalBuffer-512
SramName		EQU fatBuffer-256


;77552

;10664 bytes for these:
DISPCNTBUFF		EQU SramName-164*2

END_OF_EXRAM	EQU DISPCNTBUFF-0000	;How much data is left for Multiboot to work.
DMA1BUFF		EQU DISPCNTBUFF
fatWriteBuffer EQU fatBuffer


  
  |

;VRAM areas:
;0x600 bytes at 06006200
;0x80 bytes at 06006f00
;0x400 bytes at 0600cc00
;0x4000 at 06014000
;0x300 at 06007D00-06008000

;SGB border areas coincide with the GBA areas reserved for them
SNES_VRAM	EQU 0x0600C220 ;one tile ahead, too bad if games don't write low tiles then high tiles, also overlaps with recent_tiles...
SNES_MAP	EQU 0x0600E780 ;overlaps with recent_tiles, map must be updated in reverse order
RECENT_TILES	EQU 0x0600E200 ;DIRTY_TILES-(MAX_RECENT_TILES*16)

AGB_SGB_MAP		EQU 0x0600E800
AGB_SGB_VRAM	EQU 0x0600C200


MEM_END	EQU 0x02040000

XGB_SRAM	EQU MEM_END-0x8000
XGB_VRAM	EQU XGB_SRAM-0x4000
GBC_EXRAM	EQU XGB_VRAM-0x6000
SGB_PACKET	EQU GBC_EXRAM-112
INSTANT_PAGES	EQU 0x06004c00 ;SGB_PACKET-1024		;formerly 0x0600CC00
SGB_PALETTE	EQU SGB_PACKET-16*4

DIRTY_ROWS EQU SGB_PALETTE-48
DIRTY_TILES EQU DIRTY_ROWS-768-4
RECENT_TILENUM	EQU DIRTY_TILES-(MAX_RECENT_TILES+2)*2

BG_CACHE	EQU RECENT_TILENUM-BG_CACHE_SIZE

SGB_PALS	EQU BG_CACHE-4096
SGB_ATFS	EQU SGB_PALS-4096
sgb_attributes EQU SGB_ATFS-360


GBOAMBUFF1	EQU sgb_attributes-160
GBOAMBUFF2	EQU GBOAMBUFF1-160

BG0CNT_SCROLL_BUFF	EQU GBOAMBUFF2-144*24
WINDOWBUFF	EQU BG0CNT_SCROLL_BUFF-144*2
DISPCNTBUFF	EQU WINDOWBUFF-144*2

BG0CNT_SCROLL_BUFF2	EQU DISPCNTBUFF-144*24
WINDOWBUFF2	EQU BG0CNT_SCROLL_BUFF2-144*2
DISPCNTBUFF2	EQU WINDOWBUFF2-144*2

;WXBUFF1	EQU DISPCNTBUFF-144
;YSCROLLBUFF1	EQU WXBUFF1-144
;XSCROLLBUFF1	EQU YSCROLLBUFF1-144
;LCDCBUFF1	EQU XSCROLLBUFF1-144
;WXBUFF2	EQU LCDCBUFF1-144
;YSCROLLBUFF2	EQU WXBUFF2-144
;XSCROLLBUFF2	EQU YSCROLLBUFF2-144
;LCDCBUFF2	EQU XSCROLLBUFF2-144

	[ SPEEDHACKS
SPEEDHACK_FIND_JR_Z_BUF		EQU DISPCNTBUFF2-64
SPEEDHACK_FIND_JR_NZ_BUF	EQU SPEEDHACK_FIND_JR_Z_BUF-64
SPEEDHACK_FIND_JR_C_BUF		EQU SPEEDHACK_FIND_JR_NZ_BUF-64
SPEEDHACK_FIND_JR_NC_BUF	EQU SPEEDHACK_FIND_JR_C_BUF-64
MULTIBOOT_LIMIT	EQU SPEEDHACK_FIND_JR_NC_BUF-0	;How much data is left for Multiboot to work.
	|
MULTIBOOT_LIMIT	EQU DISPCNTBUFF2-0	;How much data is left for Multiboot to work.
	]



openFiles	EQU DISPCNTBUFF2-1200
lfnName	EQU openFiles-256
globalBuffer	EQU lfnName-512
fatBuffer	EQU globalBuffer-512
SramName	EQU fatBuffer-256
fatWriteBuffer	EQU fatBuffer



;MEM_END	EQU 0x02040000
;GBOAMBUFF1	EQU -160
;GBOAMBUFF2	EQU -160
;SCROLLBUFF	EQU -144*16
;BG0CNTBUFF	EQU -144*8
;DISPCNTBUFF	EQU -144*2
;XSCROLLBUFF1	EQU -144
;XSCROLLBUFF2	EQU -144
;YSCROLLBUFF1	EQU -144
;YSCROLLBUFF2	EQU -144
;LCDCONTROLBUFF1	EQU -144
;LCDCONTROLBUFF2	EQU -144  ;0x1200 + 0x140
;XGB_SRAM	EQU -0x8000
;XGB_VRAM	EQU -0x4000
;GBC_EXRAM	EQU -0x6000
;INSTANT_PAGES	EQU -1024
;MAPPED_RGB	EQU -16*4
;openFiles	EQU -1200
;lfnName	EQU -256
;globalBuffer	EQU -512
;fatBuffer	EQU -512
;SramName	EQU -256
;MULTIBOOT_LIMIT	EQU -0	;How much data is left for Multiboot to work.

;speedhacks  EQU -512

  ]



AGB_IRQVECT		EQU 0x3007FFC
AGB_PALETTE		EQU 0x5000000
AGB_VRAM		EQU 0x6000000
AGB_OAM			EQU 0x7000000
AGB_SRAM		EQU 0xE000000

REG_BASE		EQU 0x4000000
REG_DISPCNT		EQU 0x00
REG_DISPSTAT	EQU 0x04
REG_VCOUNT		EQU 0x06
REG_BG0CNT		EQU 0x08
REG_BG1CNT		EQU 0x0A
REG_BG2CNT		EQU 0x0C
REG_BG3CNT		EQU 0x0E
REG_BG0HOFS		EQU 0x10
REG_BG0VOFS		EQU 0x12
REG_BG1HOFS		EQU 0x14
REG_BG1VOFS		EQU 0x16
REG_BG2HOFS		EQU 0x18
REG_BG2VOFS		EQU 0x1A
REG_BG3HOFS		EQU 0x1C
REG_BG3VOFS		EQU 0x1E
REG_WIN0H		EQU 0x40
REG_WIN1H		EQU 0x42
REG_WIN0V		EQU 0x44
REG_WIN1V		EQU 0x46
REG_WININ		EQU 0x48
REG_WINOUT		EQU 0x4A
REG_BLDMOD		EQU 0x50
REG_BLDALPHA	EQU 0x52
REG_BLDY		EQU 0x54
REG_SG1CNT_L	EQU 0x60
REG_SG1CNT_H	EQU 0x62
REG_SG1CNT_X	EQU 0x64
REG_SG2CNT_L	EQU 0x68
REG_SG2CNT_H	EQU 0x6C
REG_SG3CNT_L	EQU 0x70
REG_SG3CNT_H	EQU 0x72
REG_SG3CNT_X	EQU 0x74
REG_SG4CNT_L	EQU 0x78
REG_SG4CNT_H	EQU 0x7c
REG_SGCNT_L		EQU 0x80
REG_SGCNT_H		EQU 0x82
REG_SGCNT_X		EQU 0x84
REG_SGBIAS		EQU 0x88
REG_SGWR0_L		EQU 0x90
REG_FIFO_A_L	EQU 0xA0
REG_FIFO_A_H	EQU 0xA2
REG_FIFO_B_L	EQU 0xA4
REG_FIFO_B_H	EQU 0xA6
REG_DM0SAD		EQU 0xB0
REG_DM0DAD		EQU 0xB4
REG_DM0CNT_L	EQU 0xB8
REG_DM0CNT_H	EQU 0xBA
REG_DM1SAD		EQU 0xBC
REG_DM1DAD		EQU 0xC0
REG_DM1CNT_L	EQU 0xC4
REG_DM1CNT_H	EQU 0xC6
REG_DM2SAD		EQU 0xC8
REG_DM2DAD		EQU 0xCC
REG_DM2CNT_L	EQU 0xD0
REG_DM2CNT_H	EQU 0xD2
REG_DM3SAD		EQU 0xD4
REG_DM3DAD		EQU 0xD8
REG_DM3CNT_L	EQU 0xDC
REG_DM3CNT_H	EQU 0xDE
REG_TM0D		EQU 0x100
REG_TM0CNT		EQU 0x102
REG_IE			EQU 0x200
REG_IME			EQU 0x208
REG_IF			EQU 0x4000202
REG_P1			EQU 0x4000130
REG_P1CNT		EQU 0x132
REG_WAITCNT		EQU 0x4000204

REG_SIOMULTI0	EQU 0x20 ;+100
REG_SIOMULTI1	EQU 0x22 ;+100
REG_SIOMULTI2	EQU 0x24 ;+100
REG_SIOMULTI3	EQU 0x26 ;+100
REG_SIOCNT		EQU 0x28 ;+100
REG_SIOMLT_SEND	EQU 0x2a ;+100
REG_RCNT		EQU 0x34 ;+100

		;r0,r1,r2=temp regs
gb_flg		RN r3 ;bit 31=N, Z=1 if bits 0-7=0
gb_a		RN r4 ;bits 0-15=0
gb_bc		RN r5 ;bits 0-15=0
gb_de		RN r6 ;bits 0-15=0
gb_hl		RN r7 ;bits 0-15=0
cycles		RN r8
gb_pc		RN r9
globalptr	RN r10 ;=wram_globals* ptr
gb_optbl	RN r10
gb_sp		RN r11
addy		RN r12 ;keep this at r12 (scratch for APCS)
		;r13=SP
		;r14=LR
		;r15=PC
;----------------------------------------------------------------------------

;everything in wram_globals* areas:

 MAP 0,globalptr	;gbz80.s
readmem_tbl_begin # -16*4
readmem_tbl_end # 16*4
 # -4
readmem_tbl_ # 0
 # 4
opz # 256*4
writemem_tbl # 16*4
memmap_tbl # 16*4
cpuregs # 8*4
gb_ime # 1
gb_ie # 1
gb_if # 1
 # 1  
rambank # 1
gbcmode # 1
sgbmode # 1
 # 1

dividereg # 4
timercounter # 4
timermodulo # 1
timerctrl # 1
stctrl # 1
 # 1
frame # 4
nexttimeout # 4
nexttimeout_alt # 4
scanlinehook # 4
lastbank # 4
cyclesperscanline # 4
timercyclesperscanline # 4
scanline_oam_position # 4
; [ PROFILE
;profiler # 4
; ]
doubletimer_ # 1
gbamode # 1
request_gb_type_ # 1
novblankwait_ # 1

 [ RESIZABLE
xgb_sram # 4
xgb_sramsize # 4
xgb_vram # 4
xgb_vramsize # 4
gbc_exram # 4
gbc_exramsize # 4
end_of_exram # 4
 ]
;#6 word (of 8)
			;lcd.s (wram_globals1)
fpsvalue # 4
AGBjoypad # 4
XGBjoypad # 4

lcdctrl # 1
lcdstat_save # 1
scrollX # 1
scrollY # 1

scanline # 1
lcdyc # 1
 # 1
bgpalette # 1

ob0palette # 1
ob1palette # 1
windowX # 1
windowY # 1

BCPS_index # 1
doublespeed # 1
OCPS_index # 1
vrambank # 1

dma_src # 2
dma_dest # 2
dirty_tiles # 4
dirty_rows # 4

bigbuffer	# 4
bg01cnt		# 4
bg23cnt		# 4
xyscroll	# 4
xyscroll2	# 4
dispcntdata	# 4
windata		# 4
dispcntaddr	# 4
windowyscroll	# 4
buffer_lastscanline	# 4

lcdctrl0midframe # 1
lcdctrl0frame # 1
rendermode # 1
_ui_border_visible # 1

_sgb_palette_number # 1
_gammavalue # 1
_darkness # 1
 # 1

ui_border_cnt_bic # 4
ui_border_cnt_orr # 4
ui_border_scroll2 # 4
ui_border_scroll3 # 4
_ui_x # 4
_ui_y # 4
_ui_border_request # 4
_ui_border_screen # 4
_ui_border_buffer # 4

dispcntbase # 4
dispcntbase2 # 4
bigbufferbase # 4
bigbufferbase2 # 4

gboamdirty # 1
consume_dirty # 1
consume_buffer # 1
vblank_happened # 1

gboambuff # 4
active_gboambuff # 4

_palettebank # 4

bg_cache_cursor # 4
bg_cache_base # 4
bg_cache_limit # 4
bg_cache_full # 1
bg_cache_updateok # 1
lcdhack	# 1
	# 1

;VRAM_name0_ptr # 4

			;cart.s (wram_globals2)
bank0 # 4
bank1 # 4
srambank # 4
mapperdata # 32
sramwptr # 4

biosbase # 4
rombase # 4
romnumber # 4
emuflags # 4  ;NOT ACTUALLY USED!

rommask # 4
rammask # 4

cartflags # 1
sramsize # 1
 # 2
			;io.s (wram_globals3)
joy0state # 1
joy1state # 1
joy2state # 1
joy3state # 1
joy0serial # 1
	# 1
	# 2

			;sgb.s (wram_globals4)
packetcursor # 4
packetbitcursor # 4
packetstate # 1
player_turn # 1
player_mask # 1
sgb_mask # 1

update_border_palette # 1
autoborder # 1
autoborderstate # 1
borderpartsadded # 1
sgb_hack_frame # 4
auto_border_reboot_frame # 4
lineslow # 1
 # 1
 # 1
 # 1

			;gbz80.s (wram_globals5)
fiveminutes_ # 4
sleeptime_   # 4
dontstop_    # 1
hackflags	 # 1
hackflags2	 # 1
 # 1
			;gbz80.s (wram_globals6)
xgb_ram	# 0x2000
xgb_hram # 0x80
chr_decode # 0x400

			;lcd.s (wram_globals7)
FF41_R_function # 4
FF41_R_vblank_function # 4


;----------------------------------------------------------------------------
;IRQ_VECTOR EQU 0xfffe ; IRQ/BRK interrupt vector address
;RES_VECTOR EQU 0xfffc ; RESET interrupt vector address
;NMI_VECTOR EQU 0xfffa ; NMI interrupt vector address
;-----------------------------------------------------------cartflags
MBC_RAM		EQU 0x01 ;ram in cart
MBC_SAV		EQU 0x02 ;battery in cart
MBC_TIM		EQU 0x04 ;timer in cart
MBC_RUM		EQU 0x08 ;rumble in cart
MBC_TIL		EQU 0x10 ;tilt in cart

;-----------------------------------------------------------hackflags
USEPPUHACK	EQU 1	;use $2002 hack
CPUHACK	EQU 2	;don't use JMP hack
;?		EQU 16
;FOLLOWMEM       EQU 32  ;0=follow sprite, 1=follow mem

				;bits 8-5=scale type

				;bits 16-31=sprite follow val

;----------------------------------------------------------------------------
CYC_SHIFT		EQU 4
CYCLE			EQU 1<<CYC_SHIFT ;one cycle (455*CYCLE cycles per scanline)

;cycle flags- (stored in cycles reg for speed)

BRANCH			EQU 0x01 ;branch instruction encountered
;				EQU 0x02
;				EQU 0x04
;				EQU 0x08
CYC_MASK		EQU CYCLE-1	;Mask

SINGLE_SPEED EQU 456*CYCLE
DOUBLE_SPEED EQU 912*CYCLE
SINGLE_SPEED_SCANLINE_OAM_POSITION EQU 172*CYCLE  ;should be 204
DOUBLE_SPEED_SCANLINE_OAM_POSITION EQU 172*2*CYCLE

;SINGLE_SPEED_HBLANK EQU 204*CYCLE  ;should be 204
;DOUBLE_SPEED_HBLANK EQU 408*CYCLE


WINDOW_TOP EQU 8
WINDOW_LEFT EQU 40

;----------------------------------------------------------------------------

		END
