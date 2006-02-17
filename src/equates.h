		GBLL DEBUG
		GBLL SAFETY
		GBLL PROFILE
		GBLL SPEEDHACKS
		GBLL MOVIEPLAYER
		GBLL RESIZABLE
		GBLL RUMBLE
		GBLL SAVESTATES

DEBUG		SETL {FALSE}
PROFILE		SETL {FALSE}
SPEEDHACKS		SETL {FALSE}

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

XGB_RAM			EQU 0x3005000
XGB_HRAM		EQU XGB_RAM+0x2000
CHR_DECODE		EQU XGB_HRAM+0x80
OAM_BUFFER1		EQU CHR_DECODE+0x400
OAM_BUFFER2		EQU OAM_BUFFER1+0x140	;0x200
GBOAM_BUFFER	EQU OAM_BUFFER2+0x140	;must be on a 0x00 boundary.
;?				EQU GBOAM_BUFFER+0xA0

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

SCROLLBUFF1		EQU 0x06002000-160*16
SCROLLBUFF2		EQU SCROLLBUFF1-160*16
BG0CNTBUFF		EQU SCROLLBUFF2-164*8
WINBUFF		EQU BG0CNTBUFF-160*8

XGB_SRAM		EQU 0x2040000-0x8000	;IMPORTANT!! XGB_SRAM in GBA.H points here.  keep it current if you fuck with this
XGB_VRAM		EQU XGB_SRAM-0x4000
GBC_EXRAM   EQU XGB_VRAM-0x6000
	[ SPEEDHACKS
speedhacks  EQU GBC_EXRAM-512
MAPPED_RGB		EQU speedhacks-16*4	;mapped GB palette.
	|
MAPPED_RGB		EQU GBC_EXRAM-16*4	;mapped GB palette.
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
  
  
  ]



AGB_IRQVECT		EQU 0x3007FFC
AGB_PALETTE		EQU 0x5000000
AGB_VRAM		EQU 0x6000000
AGB_OAM			EQU 0x7000000
AGB_SRAM		EQU 0xE000000

;map1        0x06001000
;map2        0x06001800
;map1 blocks 0x06002000
;map2 blocks 0x06002800

AGB_BG			EQU AGB_VRAM+0xA000
AGB_BG_GBMODE		EQU AGB_VRAM+0x4000

DEBUGSCREEN		EQU AGB_VRAM+0xD800

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
REG_BLDCNT		EQU 0x50
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
gb_zpage	RN r11 ;=XGB_RAM
addy		RN r12 ;keep this at r12 (scratch for APCS)
		;r13=SP
		;r14=LR
		;r15=PC
;----------------------------------------------------------------------------

 MAP 0,gb_zpage
xgb_ram # 0x2000
xgb_hram # 0x80
chr_decode # 0x400
oam_buffer1 # 0x200
oam_buffer2 # 0x200
oam_buffer3 # 0x200

;everything in wram_globals* areas:

 MAP 0,globalptr	;gb-z80.s
opz # 256*4
readmem_tbl # 16*4
writemem_tbl # 16*4
memmap_tbl # 16*4
cpuregs # 7*4
gb_sp # 4
gb_ime # 1
gb_ie # 1
gb_if # 1
gb_ic # 1
lastbank # 4
dividereg # 4
timercounter # 4
timermodulo # 1
timerctrl # 1
stctrl # 1
debugstop # 1 ;align
nexttimeout # 4
scanlinehook # 4
scanline # 4
frame # 4
cyclesperscanline # 4
 [ SPEEDHACKS
numspeedhacks # 4
speedhacks_p # 4
 ]
 [ PROFILE
profiler # 4
 ]
rambank # 1
doublespeed # 1
gbmode # 1
hackflags # 1
doubletimer # 1
 # 3
 [ RESIZABLE
xgb_sram # 4
xgb_sramsize # 4
xgb_vram # 4
xgb_vramsize # 4
gbc_exram # 4
gbc_exramsize # 4
end_of_exram # 4
 ]
			;lcd.s (wram_globals1)
fpsvalue # 4
AGBjoypad # 4
XGBjoypad # 4

scrollX # 1
scrollY # 1
windowX # 1
windowY # 1
lcdyc_r # 1
lcdyc # 1
lcdstat # 1
lcdctrl # 1
lcdctrl0frame # 1
ppuctrl1 # 1
gbpalette # 1
ob0palette # 1
ob1palette # 1
vrambank # 1
BCPS_index # 1
OCPS_index # 1
dma_src # 2
dma_dest # 2
agb_vrambank # 4
 
			;cart.s (wram_globals2)
mapperdata # 32
sramwptr # 4

biosbase # 4
rombase # 4
romnumber # 4
emuflags # 4

rommask # 4
rammask # 4

cartflags # 1
sramsize # 1
bank0 # 1
bank1 # 1


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

;----------------------------------------------------------------------------

		END
