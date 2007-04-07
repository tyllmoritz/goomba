 GBAMPVERSION = 0
 VERSION_IN_ROM = 0

		GBLL DEBUG
		GBLL SAFETY
		GBLL PROFILE
		GBLL SPEEDHACKS
		GBLL MOVIEPLAYER
		GBLL RESIZABLE
		GBLL RUMBLE
		GBLL SAVESTATES

		GBLL LITTLESOUNDDJ

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

XGB_RAM		EQU 0x3005280
XGB_HRAM	EQU XGB_RAM+0x2000
CHR_DECODE	EQU XGB_HRAM+0x80
;?		EQU CHR_DECODE+0x400

;statck starts at 0x03007700

BORDER_PALETTE EQU 0x06006F80

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
MAX_RECENT_TILES EQU 96  ;if you change this, change RECENT_TILES as well!

;VRAM areas:
;0x600 bytes at 06006200
;0x80 bytes at 06006f00
;0x400 bytes at 0600cc00
;0x4000 at 06014000
;0x300 at 06007D00-06008000

;SGB border areas coincide with the GBA areas reserved for them
SNES_VRAM	EQU 0x06004220 ;one tile ahead, too bad if games don't write low tiles then high tiles, also overlaps with recent_tiles...
SNES_MAP	EQU 0x06006780 ;overlaps with recent_tiles, map must be updated in reverse order
RECENT_TILES	EQU 0x06006200 ;DIRTY_TILES-(MAX_RECENT_TILES*16)



MEM_END	EQU 0x02040000

XGB_SRAM	EQU MEM_END-0x8000
XGB_VRAM	EQU XGB_SRAM-0x4000
GBC_EXRAM	EQU XGB_VRAM-0x6000
SGB_PACKET	EQU GBC_EXRAM-112
INSTANT_PAGES	EQU 0x0600cc00 ;SGB_PACKET-1024
SGB_PALETTE	EQU SGB_PACKET-16*4

DIRTY_ROWS EQU SGB_PALETTE-48
DIRTY_TILES EQU DIRTY_ROWS-768-4
RECENT_TILENUM	EQU DIRTY_TILES-(MAX_RECENT_TILES+2)*2

SGB_PALS	EQU RECENT_TILENUM-4096
SGB_ATFS	EQU SGB_PALS-4096
sgb_attributes EQU SGB_ATFS-360


GBOAMBUFF1	EQU sgb_attributes-160
GBOAMBUFF2	EQU GBOAMBUFF1-160

BG0CNT_SCROLL_BUFF	EQU GBOAMBUFF2-144*24
WINDOWBUFF	EQU BG0CNT_SCROLL_BUFF-144*2
DISPCNTBUFF	EQU WINDOWBUFF-144*2
WXBUFF1	EQU DISPCNTBUFF-144
YSCROLLBUFF1	EQU WXBUFF1-144
XSCROLLBUFF1	EQU YSCROLLBUFF1-144
LCDCBUFF1	EQU XSCROLLBUFF1-144
WXBUFF2	EQU LCDCBUFF1-144
YSCROLLBUFF2	EQU WXBUFF2-144
XSCROLLBUFF2	EQU YSCROLLBUFF2-144
LCDCBUFF2	EQU XSCROLLBUFF2-144

MULTIBOOT_LIMIT	EQU LCDCBUFF2-0	;How much data is left for Multiboot to work.

openFiles	EQU LCDCBUFF2-1200
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

;map1        0x06001000
;map2        0x06001800
;map1 blocks 0x06002000
;map2 blocks 0x06002800

AGB_BG			EQU AGB_VRAM+0xA000
AGB_BG_GBMODE		EQU AGB_VRAM+0x4000

DEBUGSCREEN		EQU AGB_VRAM+0x7800

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

; MAP 0,gb_zpage
;xgb_ram # 0x2000
;xgb_hram # 0x80
;chr_decode # 0x400

;everything in wram_globals* areas:

	GBLA _address
opz EQU _address 
_address SETA _address+256*4 ;gb-z80.s
readmem_tbl EQU _address 
_address SETA _address+16*4
writemem_tbl EQU _address 
_address SETA _address+16*4
memmap_tbl EQU _address 
_address SETA _address+16*4
cpuregs EQU _address 
_address SETA _address+8*4
gb_ime EQU _address 
_address SETA _address+1
gb_ie EQU _address 
_address SETA _address+1
gb_if EQU _address 
_address SETA _address+1
gb_ic EQU _address 
_address SETA _address+1  ;not actually used
lastbank EQU _address 
_address SETA _address+4
dividereg EQU _address 
_address SETA _address+4
timercounter EQU _address 
_address SETA _address+4
timermodulo EQU _address 
_address SETA _address+1
timerctrl EQU _address 
_address SETA _address+1
stctrl EQU _address 
_address SETA _address+1
debugstop EQU _address 
_address SETA _address+1 ;align
nexttimeout EQU _address 
_address SETA _address+4
nexttimeout_alt EQU _address 
_address SETA _address+4
scanlinehook EQU _address 
_address SETA _address+4
frame EQU _address 
_address SETA _address+4
cyclesperscanline EQU _address 
_address SETA _address+4
 [ SPEEDHACKS
numspeedhacks EQU _address 
_address SETA _address+4
speedhacks_p EQU _address 
_address SETA _address+4
 ]
 [ PROFILE
profiler EQU _address 
_address SETA _address+4
 ]
rambank EQU _address 
_address SETA _address+1
gbcmode EQU _address 
_address SETA _address+1
sgbmode EQU _address 
_address SETA _address+1
hackflags EQU _address 
_address SETA _address+1
doubletimer_ EQU _address 
_address SETA _address+1
gbamode EQU _address 
_address SETA _address+1
request_gb_type_ EQU _address 
_address SETA _address+1
novblankwait_ EQU _address 
_address SETA _address+1

 [ RESIZABLE
xgb_sram EQU _address 
_address SETA _address+4
xgb_sramsize EQU _address 
_address SETA _address+4
xgb_vram EQU _address 
_address SETA _address+4
xgb_vramsize EQU _address 
_address SETA _address+4
gbc_exram EQU _address 
_address SETA _address+4
gbc_exramsize EQU _address 
_address SETA _address+4
end_of_exram EQU _address 
_address SETA _address+4
 ]
			;lcd.s (wram_globals1)
fpsvalue EQU _address 
_address SETA _address+4
AGBjoypad EQU _address 
_address SETA _address+4
XGBjoypad EQU _address 
_address SETA _address+4

lcdctrl EQU _address 
_address SETA _address+1
lcdstat EQU _address 
_address SETA _address+1
scrollX EQU _address 
_address SETA _address+1
scrollY EQU _address 
_address SETA _address+1

scanline EQU _address 
_address SETA _address+1
lcdyc EQU _address 
_address SETA _address+1
_address SETA _address+1
bgpalette EQU _address 
_address SETA _address+1

ob0palette EQU _address 
_address SETA _address+1
ob1palette EQU _address 
_address SETA _address+1
windowX EQU _address 
_address SETA _address+1
windowY EQU _address 
_address SETA _address+1

BCPS_index EQU _address 
_address SETA _address+1
doublespeed EQU _address 
_address SETA _address+1
OCPS_index EQU _address 
_address SETA _address+1
vrambank EQU _address 
_address SETA _address+1

dma_src EQU _address 
_address SETA _address+2
dma_dest EQU _address 
_address SETA _address+2

			;cart.s (wram_globals2)
bank0 EQU _address 
_address SETA _address+4
bank1 EQU _address 
_address SETA _address+4
srambank EQU _address 
_address SETA _address+4
mapperdata EQU _address 
_address SETA _address+32
sramwptr EQU _address 
_address SETA _address+4

biosbase EQU _address 
_address SETA _address+4
rombase EQU _address 
_address SETA _address+4
romnumber EQU _address 
_address SETA _address+4
emuflags EQU _address 
_address SETA _address+4  ;NOT ACTUALLY USED!

rommask EQU _address 
_address SETA _address+4
rammask EQU _address 
_address SETA _address+4

cartflags EQU _address 
_address SETA _address+1
sramsize EQU _address 
_address SETA _address+1
_address SETA _address+2
			;io.s (wram_globals3)
joy0state EQU _address 
_address SETA _address+1
joy1state EQU _address 
_address SETA _address+1
joy2state EQU _address 
_address SETA _address+1
joy3state EQU _address 
_address SETA _address+1
joy0serial EQU _address 
_address SETA _address+1
joy1serial EQU _address 
_address SETA _address+1
_address SETA _address+2

			;sgb.s (wram_globals4)
packetcursor EQU _address 
_address SETA _address+4
packetbitcursor EQU _address 
_address SETA _address+4
packetstate EQU _address 
_address SETA _address+1
player_turn EQU _address 
_address SETA _address+1
player_mask EQU _address 
_address SETA _address+1
sgb_mask EQU _address 
_address SETA _address+1

update_border_palette EQU _address 
_address SETA _address+1
_address SETA _address+3
sgb_hack_frame EQU _address 
_address SETA _address+4


			;gbz80.s (wram_globals5)
fiveminutes_ EQU _address 
_address SETA _address+4
sleeptime_ EQU _address 
_address SETA _address+4
dontstop_ EQU _address 
_address SETA _address+1
_address SETA _address+3

   
   

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

WINDOW_TOP EQU 8
WINDOW_LEFT EQU 40

;----------------------------------------------------------------------------

	MACRO
	ldr_ $reg,$label
	ldr $reg,[globalptr,#$label]
	MEND
	
	MACRO
	ldrb_ $reg,$label
	ldrb $reg,[globalptr,#$label]
	MEND
	
	MACRO
	ldrh_ $reg,$label
	ldrh $reg,[globalptr,#$label]
	MEND
	
	MACRO
	str_ $reg,$label
	str $reg,[globalptr,#$label]
	MEND
	
	MACRO
	strb_ $reg,$label
	strb $reg,[globalptr,#$label]
	MEND
	
	MACRO
	strh_ $reg,$label
	strh $reg,[globalptr,#$label]
	MEND



	MACRO
	ldreq_ $reg,$label
	ldreq $reg,[globalptr,#$label]
	MEND
	
	MACRO
	ldreqb_ $reg,$label
	ldreqb $reg,[globalptr,#$label]
	MEND
	
	MACRO
	streq_ $reg,$label
	streq $reg,[globalptr,#$label]
	MEND
	
	MACRO
	streqb_ $reg,$label
	streqb $reg,[globalptr,#$label]
	MEND
	



	MACRO
	ldrne_ $reg,$label
	ldrne $reg,[globalptr,#$label]
	MEND
	
	MACRO
	ldrneb_ $reg,$label
	ldrneb $reg,[globalptr,#$label]
	MEND
	
	MACRO
	strne_ $reg,$label
	strne $reg,[globalptr,#$label]
	MEND
	
	MACRO
	strneb_ $reg,$label
	strneb $reg,[globalptr,#$label]
	MEND
	


	MACRO
	ldrhi_ $reg,$label
	ldrhi $reg,[globalptr,#$label]
	MEND
	
	MACRO
	ldrhib_ $reg,$label
	ldrhib $reg,[globalptr,#$label]
	MEND
	
	MACRO
	strhi_ $reg,$label
	strhi $reg,[globalptr,#$label]
	MEND
	
	MACRO
	strhib_ $reg,$label
	strhib $reg,[globalptr,#$label]
	MEND


	MACRO
	ldrmi_ $reg,$label
	ldrmi $reg,[globalptr,#$label]
	MEND
	
	MACRO
	ldrmib_ $reg,$label
	ldrmib $reg,[globalptr,#$label]
	MEND
	
	MACRO
	strmi_ $reg,$label
	strmi $reg,[globalptr,#$label]
	MEND
	
	MACRO
	strmib_ $reg,$label
	strmib $reg,[globalptr,#$label]
	MEND

	MACRO
	ldrpl_ $reg,$label
	ldrpl $reg,[globalptr,#$label]
	MEND
	
	MACRO
	ldrplb_ $reg,$label
	ldrplb $reg,[globalptr,#$label]
	MEND
	
	MACRO
	strpl_ $reg,$label
	strpl $reg,[globalptr,#$label]
	MEND
	
	MACRO
	strplb_ $reg,$label
	strplb $reg,[globalptr,#$label]
	MEND


	MACRO
	ldrgt_ $reg,$label
	ldrgt $reg,[globalptr,#$label]
	MEND
	
	MACRO
	ldrgtb_ $reg,$label
	ldrgtb $reg,[globalptr,#$label]
	MEND
	
	MACRO
	strgt_ $reg,$label
	strgt $reg,[globalptr,#$label]
	MEND
	
	MACRO
	strgtb_ $reg,$label
	strgtb $reg,[globalptr,#$label]
	MEND


	MACRO
	ldrge_ $reg,$label
	ldrge $reg,[globalptr,#$label]
	MEND
	
	MACRO
	ldrgeb_ $reg,$label
	ldrgeb $reg,[globalptr,#$label]
	MEND
	
	MACRO
	strge_ $reg,$label
	strge $reg,[globalptr,#$label]
	MEND
	
	MACRO
	strgeb_ $reg,$label
	strgeb $reg,[globalptr,#$label]
	MEND


	MACRO
	ldrlt_ $reg,$label
	ldrlt $reg,[globalptr,#$label]
	MEND
	
	MACRO
	ldrltb_ $reg,$label
	ldrltb $reg,[globalptr,#$label]
	MEND
	
	MACRO
	strlt_ $reg,$label
	strlt $reg,[globalptr,#$label]
	MEND
	
	MACRO
	strltb_ $reg,$label
	strltb $reg,[globalptr,#$label]
	MEND


	MACRO
	ldrle_ $reg,$label
	ldrle $reg,[globalptr,#$label]
	MEND
	
	MACRO
	ldrleb_ $reg,$label
	ldrleb $reg,[globalptr,#$label]
	MEND
	
	MACRO
	strle_ $reg,$label
	strle $reg,[globalptr,#$label]
	MEND
	
	MACRO
	strleb_ $reg,$label
	strleb $reg,[globalptr,#$label]
	MEND


	MACRO
	ldrlo_ $reg,$label
	ldrlo $reg,[globalptr,#$label]
	MEND
	
	MACRO
	ldrlob_ $reg,$label
	ldrlob $reg,[globalptr,#$label]
	MEND
	
	MACRO
	strlo_ $reg,$label
	strlo $reg,[globalptr,#$label]
	MEND
	
	MACRO
	strlob_ $reg,$label
	strlob $reg,[globalptr,#$label]
	MEND
	






	MACRO
	adr_ $reg,$label
	add $reg,globalptr,#$label
	MEND
	
	MACRO
	adrl_ $reg,$label
	add $reg,globalptr,#(($label) :AND: 0xFF00)
	add $reg,$reg,#(($label) :AND: 0x00FF)
	MEND
	
	


 [ VERSION_IN_ROM
	MACRO
	bl_long $label
	mov lr,pc
	ldr pc,=$label
	MEND

	MACRO
	bleq_long $label
	moveq lr,pc
	ldreq pc,=$label
	MEND

	MACRO
	bllo_long $label
	movlo lr,pc
	ldrlo pc,=$label
	MEND

	MACRO
	blhi_long $label
	movhi lr,pc
	ldrhi pc,=$label
	MEND

	MACRO
	bllt_long $label
	movlt lr,pc
	ldrlt pc,=$label
	MEND

	MACRO
	blgt_long $label
	movgt lr,pc
	ldrgt pc,=$label
	MEND

	MACRO
	blne_long $label
	movne lr,pc
	ldrne pc,=$label
	MEND

	MACRO
	blcc_long $label
	movcc lr,pc
	ldrcc pc,=$label
	MEND

	MACRO
	blpl_long $label
	movpl lr,pc
	ldrpl pc,=$label
	MEND

	MACRO
	b_long $label
	ldr pc,=$label
	MEND

	MACRO
	bcc_long $label
	ldrcc pc,=$label
	MEND

	MACRO
	bhs_long $label
	ldrhs pc,=$label
	MEND

	MACRO
	beq_long $label
	ldreq pc,=$label
	MEND

	MACRO
	bne_long $label
	ldrne pc,=$label
	MEND

	MACRO
	blo_long $label
	ldrlo pc,=$label
	MEND

	MACRO
	bhi_long $label
	ldrhi pc,=$label
	MEND

	MACRO
	bgt_long $label
	ldrgt pc,=$label
	MEND

	MACRO
	blt_long $label
	ldrlt pc,=$label
	MEND

	MACRO
	bcs_long $label
	ldrcs pc,=$label
	MEND

	MACRO
	bmi_long $label
	ldrmi pc,=$label
	MEND

	MACRO
	bpl_long $label
	ldrpl pc,=$label
	MEND

	|

	MACRO
	bl_long $label
	bl $label
	MEND

	MACRO
	bleq_long $label
	bleq $label
	MEND

	MACRO
	bllo_long $label
	bllo $label
	MEND

	MACRO
	blhi_long $label
	blhi $label
	MEND

	MACRO
	bllt_long $label
	bllt $label
	MEND

	MACRO
	blgt_long $label
	blgt $label
	MEND

	MACRO
	blne_long $label
	blne $label
	MEND

	MACRO
	blcc_long $label
	blcc $label
	MEND

	MACRO
	blpl_long $label
	blpl $label
	MEND

	MACRO
	b_long $label
	b $label
	MEND

	MACRO
	bcc_long $label
	bcc $label
	MEND

	MACRO
	bhs_long $label
	bhs $label
	MEND

	MACRO
	beq_long $label
	beq $label
	MEND

	MACRO
	bne_long $label
	bne $label
	MEND

	MACRO
	blo_long $label
	blo $label
	MEND

	MACRO
	bhi_long $label
	bhi $label
	MEND

	MACRO
	bgt_long $label
	bgt $label
	MEND

	MACRO
	blt_long $label
	blt $label
	MEND

	MACRO
	bcs_long $label
	bcs $label
	MEND

	MACRO
	bmi_long $label
	bmi $label
	MEND

	MACRO
	bpl_long $label
	bpl $label
	MEND
 ]


