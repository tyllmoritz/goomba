	INCLUDE equates.h
	INCLUDE memory.h
	INCLUDE lcd.h
	INCLUDE sound.h
	INCLUDE cart.h
	INCLUDE gbz80.h
	INCLUDE gbz80mac.h
	INCLUDE sgb.h
	EXPORT IO_reset
	EXPORT IO_R
	EXPORT IO_High_R
	EXPORT IO_W
	EXPORT IO_High_W
	EXPORT joypad_write_ptr
	EXPORT joy0_W
	EXPORT joycfg
	EXPORT suspend
	EXPORT refreshNESjoypads
	EXPORT serialinterrupt
	EXPORT resetSIO
	EXPORT thumbcall_r1
	EXPORT gettime
	EXPORT vbaprint
	EXPORT waitframe
	EXPORT LZ77UnCompVram
	EXPORT CheckGBAVersion
	EXPORT gbpadress
	EXPORT _FF70W
 [ RESIZABLE
	IMPORT add_exram
 ]


 AREA rom_code, CODE, READONLY ;-- - - - - - - - - - - - - - - - - - - - - -

vbaprint
	swi 0xFF0000		;!!!!!!! Doesn't work on hardware !!!!!!!
	bx lr
LZ77UnCompVram
	swi 0x120000
	bx lr
waitframe
VblWait
	mov r0,#0				;don't wait if not necessary
	mov r1,#1				;VBL wait
	swi 0x040000			; Turn of CPU until VBLIRQ if not too late allready.
	bx lr
CheckGBAVersion
	ldr r0,=0x5AB07A6E		;Fool proofing
	mov r12,#0
	swi 0x0D0000			;GetBIOSChecksum
	ldr r1,=0xABBE687E		;Proto GBA
	cmp r0,r1
	moveq r12,#1
	ldr r1,=0xBAAE187F		;Normal GBA
	cmp r0,r1
	moveq r12,#2
	ldr r1,=0xBAAE1880		;Nintendo DS
	cmp r0,r1
	moveq r12,#4
	mov r0,r12
	bx lr

resetSIO
	b_long resetSIO_core

;----------------------------------------------------------------------------
IO_reset
;----------------------------------------------------------------------------
	ldrb r0,sgbmode
	movs r0,r0
	ldrne r0,=joy0_W_SGB
	ldrne r1,=joypad_write_ptr
	strne r0,[r1]
	
	mov r0,#0
	strb r0,stctrl
	bx lr
;----------------------------------------------------------------------------
suspend	;called from ui.c and 6502.s
;----------------------------------------------------------------------------
	mov r3,#REG_BASE

	ldr r1,=REG_P1CNT
	ldr r0,=0xc00c			;interrupt on start+sel
	strh r0,[r3,r1]

	ldrh r1,[r3,#REG_SGCNT_L]
	strh r3,[r3,#REG_SGCNT_L]	;sound off

	ldrh r0,[r3,#REG_DISPCNT]
	orr r0,r0,#0x80
	strh r0,[r3,#REG_DISPCNT]	;LCD off

	swi 0x030000

	ldrh r0,[r3,#REG_DISPCNT]
	bic r0,r0,#0x80
	strh r0,[r3,#REG_DISPCNT]	;LCD on

	strh r1,[r3,#REG_SGCNT_L]	;sound on

	bx lr

;----------------------------------------------------------------------------
thumbcall_r1 bx r1
;----------------------------------------------------------------------------
gettime	;called from ui.c and mappers.s
;----------------------------------------------------------------------------
	ldr r3,=0x080000c4		;base address for RTC
	mov r1,#1
	strh r1,[r3,#4]			;enable RTC
	mov r1,#7
	strh r1,[r3,#2]			;enable write

	mov r1,#1
	strh r1,[r3]
	mov r1,#5
	strh r1,[r3]			;State=Command

	mov r2,#0x65			;r2=Command, YY:MM:DD 00 hh:mm:ss
	mov addy,#8
RTCLoop1
	mov r1,#2
	and r1,r1,r2,lsr#6
	orr r1,r1,#4
	strh r1,[r3]
	mov r1,r2,lsr#6
	orr r1,r1,#5
	strh r1,[r3]
	mov r2,r2,lsl#1
	subs addy,addy,#1
	bne RTCLoop1

	mov r1,#5
	strh r1,[r3,#2]			;enable read
	mov r2,#0
	mov addy,#32
RTCLoop2
	mov r1,#4
	strh r1,[r3]
	mov r1,#5
	strh r1,[r3]
	ldrh r1,[r3]
	and r1,r1,#2
	mov r2,r2,lsr#1
	orr r2,r2,r1,lsl#30
	subs addy,addy,#1
	bne RTCLoop2

	mov r0,#0
	mov addy,#24
RTCLoop3
	mov r1,#4
	strh r1,[r3]
	mov r1,#5
	strh r1,[r3]
	ldrh r1,[r3]
	and r1,r1,#2
	mov r0,r0,lsr#1
	orr r0,r0,r1,lsl#22
	subs addy,addy,#1
	bne RTCLoop3
	str r2,mapperdata+24
	str r0,mapperdata+28

	bx lr
;----------------------------------------------------------------------------
	INCLUDE visoly.s

 AREA wram_code1, CODE, READWRITE ;-- - - - - - - - - - - - - - - - - - - - - -
;----------------------------------------------------------------------------
IO_R		;I/O read
;----------------------------------------------------------------------------
	and r2,addy,#0xFF
	cmp addy,#0xFF00
	bmi OAM_R	;OAM, C000-DCFF mirror.
;----------------------------------------------------------------------------
IO_High_R	;I/O read
;----------------------------------------------------------------------------
	tst r2,#0x80
	ldreq pc,[pc,r2,lsl#2]
	b HRAM_R
;----------------------------------------------------------------------------
io_read_tbl
	DCD joy0_R	;$FF00: Joypad 0 read
	DCD _FF01R	;SB - Serial Transfer Data
	DCD _FF02R	;SC - Serial Transfer Ctrl
	DCD void
	DCD _FF04R	;DIV - Divider Register
	DCD _FF05R	;TIMA - Timer counter
	DCD _FF06R	;TMA - Timer Modulo
	DCD _FF07R	;TAC - Timer Control
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD _FF0FR	;IF Interrupt flags.

	DCD _FF10R	;Sound channel 1
	DCD _FF11R
	DCD _FF12R
	DCD _FF13R
	DCD _FF14R
	DCD void
	DCD _FF16R	;Sound channel 2
	DCD _FF17R
	DCD _FF18R
	DCD _FF19R
	DCD _FF1AR	;Sound channel 3
	DCD _FF1BR
	DCD _FF1CR
	DCD _FF1DR
	DCD _FF1ER
	DCD void

	DCD _FF20R	;Sound channel 4
	DCD _FF21R
	DCD _FF22R
	DCD _FF23R
	DCD _FF24R
	DCD _FF25R
	DCD _FF26R
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void

	DCD _FF30R	;Sound channel 3 wave ram
	DCD _FF30R
	DCD _FF30R
	DCD _FF30R
	DCD _FF30R
	DCD _FF30R
	DCD _FF30R
	DCD _FF30R
	DCD _FF30R
	DCD _FF30R
	DCD _FF30R
	DCD _FF30R
	DCD _FF30R
	DCD _FF30R
	DCD _FF30R
	DCD _FF30R

	DCD FF40_R	;LCDC - LCD Control
	DCD FF41_R	;STAT - LCDC Status
	DCD FF42_R	;SCY - Scroll Y
	DCD FF43_R	;SCX - Scroll X
	DCD FF44_R	;LY - LCD Y-Coordinate
	DCD FF45_R	;LYC - LCD Y Compare
	DCD void	;DMA - DMA Transfer and Start Address (W?)
	DCD FF47_R	;BGP - BG Palette Data - Non CGB Mode Only
	DCD FF48_R	;OBP0 - Object Palette 0 Data - Non CGB Mode Only
	DCD FF49_R	;OBP1 - Object Palette 1 Data - Non CGB Mode Only
	DCD FF4A_R	;WY - Window Y Position
	DCD FF4B_R	;WX - Window X Position minus 7
	DCD void
	DCD FF4D_R	;KEY1 - bit 7, Read current speed of CPU - CGB Mode Only
	DCD void
	DCD FF4F_R	;VBK - VRAM Bank - CGB Mode Only

	DCD void
	DCD FF51_R	;HDMA1
	DCD FF52_R	;HDMA2
	DCD FF53_R	;HDMA3
	DCD FF54_R	;HDMA4
	DCD FF55_R	;HDMA5
	DCD _FF56R	;RP - Infrared Port
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void

	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD FF68_R	;BCPS - BG Color Palette Specification  CGB Mode Only
	DCD FF69_R	;BCPD - BG Color Palette Data
	DCD FF6A_R	;OCPS - OBJ Color Palette Specification
	DCD FF6B_R	;OCPD - OBJ Color Palette Data
	DCD void
	DCD void
	DCD void
	DCD void

	DCD _FF70R	;SVBK - WRAM Bank - CGB Mode Only
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void


;OAM_R
;	cmp addy,#0xFE00
;	ldrpl r1,=GBOAM_BUFFER
;	ldrplb r0,[r1,r2]
;	movpl pc,lr
;	sub addy,addy,#0x2000		;C000-DCFF mirror.
;	b mem_RC0
;OAM_W
;	cmp addy,#0xFE00
;	ldrpl r1,=GBOAM_BUFFER
;	strplb r0,[r1,r2]
;	movpl pc,lr
;	sub addy,addy,#0x2000		;C000-DCFF mirror.
;	b wram_W

;----------------------------------------------------------------------------
IO_W		;I/O write
;----------------------------------------------------------------------------
	and r2,addy,#0xFF
	cmp addy,#0xFF00
	bmi OAM_W	;OAM, C000-DCFF mirror.
;----------------------------------------------------------------------------
IO_High_W	;I/O write
;----------------------------------------------------------------------------
	tst r2,#0x80
	ldreq pc,[pc,r2,lsl#2]
	b HRAM_W
;----------------------------------------------------------------------------
io_write_tbl
joypad_write_ptr
	DCD joy0_W	;$FF00: Joypad write
	DCD _FF01W	;SB - Serial Transfer Data
	DCD _FF02W	;SC - Serial Transfer Ctrl
	DCD void
	DCD _FF04W	;DIV - Divider Register
	DCD _FF05W	;TIMA - Timer counter
	DCD _FF06W	;TMA - Timer Modulo
	DCD _FF07W	;TAC - Timer Control
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD _FF0FW	;IF Interrupt flags.

	DCD _FF10W	;Sound channel 1
	DCD _FF11W
	DCD _FF12W
	DCD _FF13W
	DCD _FF14W
	DCD void
	DCD _FF16W	;Sound channel 2
	DCD _FF17W
	DCD _FF18W
	DCD _FF19W
	DCD _FF1AW	;Sound channel 3
	DCD _FF1BW
	DCD _FF1CW
	DCD _FF1DW
	DCD _FF1EW
	DCD void

	DCD _FF20W	;Sound channel 4
	DCD _FF21W
	DCD _FF22W
	DCD _FF23W
	DCD _FF24W
	DCD _FF25W
	DCD _FF26W
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void

	DCD _FF30W	;Sound channel 3 wave ram
	DCD _FF30W
	DCD _FF30W
	DCD _FF30W
	DCD _FF30W
	DCD _FF30W
	DCD _FF30W
	DCD _FF30W
	DCD _FF30W
	DCD _FF30W
	DCD _FF30W
	DCD _FF30W
	DCD _FF30W
	DCD _FF30W
	DCD _FF30W
	DCD _FF30W

	DCD FF40_W	;LCDC - LCD Control
	DCD FF41_W	;STAT - LCDC Status
	DCD FF42_W	;SCY - Scroll Y
	DCD FF43_W	;SCX - Scroll X
	DCD void  	;LY - LCD Y-Coordinate
	DCD FF45_W	;LYC - LCD Y Compare
	DCD FF46_W	;DMA - DMA Transfer and Start Address
	DCD FF47_W	;BGP - BG Palette Data - Non CGB Mode Only
	DCD FF48_W	;OBP0 - Obj Palette 0 Data - Non CGB Mode Only
	DCD FF49_W	;OBP1 - Obj Palette 1 Data - Non CGB Mode Only
	DCD FF4A_W	;WY - Window Y Position
	DCD FF4B_W	;WX - Window X Position minus 7
	DCD void
	DCD FF4D_W	;KEY1 - Prepare Speed Switch - CGB Mode Only
	DCD void
	DCD FF4F_W	;VBK - VRAM Bank - CGB Mode Only

	DCD _FF50W	;BIOS bank select
	DCD FF51_W	;HDMA1
	DCD FF52_W	;HDMA2
	DCD FF53_W	;HDMA3
	DCD FF54_W	;HDMA4
	DCD FF55_W	;HDMA5
	DCD _FF56W	;RP - Infrared Port
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void

	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD FF68_W	;BCPS - BG Color Palette Specification
	DCD FF69_W	;BCPD - BG Color Palette Data
	DCD FF6A_W	;OCPS - OBJ Color Palette Specification
	DCD FF6B_W	;OCPD - OBJ Color Palette Data
	DCD void
	DCD void
	DCD void
	DCD void

	DCD _FF70W	;SVBK - WRAM Bank - CGB Mode Only
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void
	DCD void

;----------------------------------------------------------------------------
HRAM_W;		(FF80-FFFF)
;----------------------------------------------------------------------------
	ldr r1,=XGB_HRAM-0x80
	strb r0,[r1,r2]
	cmp r2,#0xFF
	movne pc,lr
	strb r0,gb_ie		;0xFFFF=Interrupt Enable.
	ldrb r1,gb_if
	ands r1,r1,r0
	moveq pc,lr
	ldrb r0,gb_ime
	movs r0,r0
	moveq pc,lr
	
	;different ugly hack which doesn't mess up timing,
	;this is necessary because goomba can't handle GB interrupts from within a memory write
	sub cycles,cycles,#1024*CYCLE  ;this just makes it go somewhere else instead of the next instruction
	ldr r0,nexttimeout
	str r0,nexttimeout_alt
	ldr r0,=no_more_irq_hack
	str r0,nexttimeout
	bx lr

no_more_irq_hack
	add cycles,cycles,#1024*CYCLE
	ldr r0,nexttimeout_alt
	str r0,nexttimeout
	b checkIRQ


;----------------------------------------------------------------------------
HRAM_R;		(FF80-FFFF)
;----------------------------------------------------------------------------
	ldr r1,=XGB_HRAM-0x80
	ldrb r0,[r1,r2]
	mov pc,lr
;----------------------------------------------------------------------------
_FF01W;		SB - Serial Transfer Data
;----------------------------------------------------------------------------
	mov pc,lr
;----------------------------------------------------------------------------
_FF02W;		SC - Serial Transfer Ctrl
;----------------------------------------------------------------------------
	strb r0,stctrl
	and r0,r0,#0x81
	cmp r0,#0x81		;Are going to transfer on internal clock?
	ldreqb r0,gb_if		;IRQ flags
	orreq r0,r0,#8		;8=Serial
	streqb r0,gb_if
	mov pc,lr
;----------------------------------------------------------------------------
_FF56W;		RP - Infrared Port
;----------------------------------------------------------------------------
	mov pc,lr
;----------------------------------------------------------------------------
_FF04W;		DIV - Divider Register
;----------------------------------------------------------------------------
	mov r0,#0		;any write resets the reg.
	str r0,dividereg
	mov pc,lr
;----------------------------------------------------------------------------
_FF05W;		TIMA - Timer counter
;----------------------------------------------------------------------------
	strb r0,timercounter+3
	mov pc,lr
;----------------------------------------------------------------------------
_FF06W;		TMA - Timer Modulo
;----------------------------------------------------------------------------
	strb r0,timermodulo
	mov pc,lr
;----------------------------------------------------------------------------
_FF07W;		TAC - Timer Control
;----------------------------------------------------------------------------
	strb r0,timerctrl
	mov pc,lr
;----------------------------------------------------------------------------
_FF0FW
;----------------------------------------------------------------------------
	strb r0,gb_if
	mov pc,lr
;----------------------------------------------------------------------------
_FF50W;		Undocumented BIOS banking
;----------------------------------------------------------------------------
	cmp r0,#1
	mov r0,#0
	beq map0123_
	mov pc,lr
;----------------------------------------------------------------------------
_FF70W;		SVBK - CGB Mode Only - WRAM Bank
;----------------------------------------------------------------------------
	strb r0,rambank
	and r0,r0,#7
	cmp r0,#2
	bge select_gbc_ram
	ldr r1,memmap_tbl+48
	str r1,memmap_tbl+52
	mov pc,lr
select_gbc_ram
 [ RESIZABLE
	ldr r1,gbc_exram
	subs r1,r1,#0xD000+0x2000
	bmi add_exram_
 |	
	ldr r1,=GBC_EXRAM-0xD000-0x2000
 ]
	add r1,r1,r0,lsl#12
	;D000
	str r1,memmap_tbl+52
	mov pc,lr
 [ RESIZABLE
add_exram_
	stmfd sp!,{r0-addy,lr}
	ldr r1,=add_exram
	bl thumbcall_r1
	ldmfd sp!,{r0-addy,lr}
	ldr r1,lastbank
	sub gb_pc,gb_pc,r1
	encodePC
	b select_gbc_ram
 ]

;----------------------------------------------------------------------------
_FF70R;		SVBK - CGB Mode Only - WRAM Bank
;----------------------------------------------------------------------------
	ldrb r0,rambank
	mov pc,lr


;----------------------------------------------------------------------------
_FF01R;		SB - Serial Transfer Data
;----------------------------------------------------------------------------
	mov r0,#0xff		;When no GB attached
	mov pc,lr
;----------------------------------------------------------------------------
_FF02R;		SC - Serial Transfer Ctrl
;----------------------------------------------------------------------------
	ldrb r0,stctrl
;	mov r0,#0x00		;0x80 when transfering, 0x00 when finnished.
	mov pc,lr		;Rc Pro Am ,wants 0x80, Cosmo Tank wants 0x00.
;----------------------------------------------------------------------------
_FF56R;		RP - Infrared Port
;----------------------------------------------------------------------------
	mov r0,#0
	mov pc,lr
;----------------------------------------------------------------------------
_FF04R;		DIV - Divider Register
;----------------------------------------------------------------------------
	ldrb r0,dividereg+3
	mov pc,lr
;----------------------------------------------------------------------------
_FF05R;		TIMA - Timer counter
;----------------------------------------------------------------------------
	ldrb r0,timercounter+3
	mov pc,lr
;----------------------------------------------------------------------------
_FF06R;		TMA - Timer Modulo
;----------------------------------------------------------------------------
	ldrb r0,timermodulo
	mov pc,lr
;----------------------------------------------------------------------------
_FF07R;		TAC - Timer Control
;----------------------------------------------------------------------------
	ldrb r0,timerctrl
	mov pc,lr
;----------------------------------------------------------------------------
_FF0FR
;----------------------------------------------------------------------------
	ldrb r0,gb_if
	mov pc,lr
;----------------------------------------------------------------------------
serialinterrupt
;----------------------------------------------------------------------------
	mov r3,#REG_BASE
	add r3,r3,#0x100

	mov r0,#0x1
serWait	subs r0,r0,#1
	bne serWait
	mov r0,#0x100		;time to wait.
	ldrh r1,[r3,#REG_SIOCNT]
	tst r1,#0x80		;Still transfering?
	bne serWait

	tst r1,#0x40		;communication error? resend?
	bne sio_err

	ldr r0,[r3,#REG_SIOMULTI0]	;Both SIOMULTI0&1
	ldr r1,[r3,#REG_SIOMULTI2]	;Both SIOMULTI2&3

	and r2,r0,#0xff00	;From Master
	cmp r2,#0xaa00
	beq resetrequest	;$AAxx means Master GBA wants to restart

	ldr r2,sending
	tst r2,#0x10000
	beq sio_err
	strne r0,received0	;store only if we were expecting something
	strne r1,received1	;store only if we were expecting something
	eor r2,r2,r0		;Check if master sent what we expected
	ands r2,r2,#0xff00
	strne r0,received2	;otherwise print value.
	strne r1,received3	;otherwise print value.

;	mov r3,#AGB_PALETTE
;	mov r1,#-1		;white
;	strh r1,[r3]		;BG palette
sio_err
	strb r3,sending+2	;send completed, r3b=0
	bx lr

resetrequest
;	mov r3,r1,asr#16
;	cmp r3,#-1
;	moveq r3,#3		;up to 3 players.
;	movne r3,#4		;all 4 players
;	cmp r1,#-1
;	moveq r3,#2		;only 2 players.
;	mov r3,#3
;	str r3,nrplayers

	ldr r2,joycfg
	strh r0,received0
	orr r2,r2,#0x01000000
	bic r2,r2,#0x08000000
	str r2,joycfg
	bx lr

sending DCD 0
lastsent DCD 0
received0 DCD 0
received1 DCD 0
received2 DCD 0
received3 DCD 0
;---------------------------------------------
xmit	;send byte in r0
;returns REG_SIOCNT in r1, received P1/P2 in r2, received P3/P4 in r3, Z set if successful, r4-r5 destroyed
;---------------------------------------------
	ldr r3,sending
	tst r3,#0x10000		;last send completed?
	movne pc,lr

	mov r5,#REG_BASE
	add r5,r5,#0x100
	ldrh r1,[r5,#REG_SIOCNT]
	tst r1,#0x80		;clear to send?
	movne pc,lr

	ldrb r4,frame
	eor r4,r4,#0x55
	bic r4,r4,#0x80
	orr r0,r0,r4,lsl#8	;r0=new data to send

	ldr r2,received0
	ldr r3,received1
	cmp r2,#-1		;Check for uninitialized
	eoreq r2,r2,#0xf00
	ldr r4,nrplayers
	cmp r4,#2
	beq players2
	cmp r4,#3
	beq players3
players4
	eor r4,r2,r3,lsr#16	;P1 & P4
	tst r4,#0xff00		;not in sync yet?
	beq players3
	ldr r1,lastsent
	eor r4,r1,r3,lsr#16	;Has P4 missed an interrupt?
	tst r4,#0xff00
	streq r1,sending	;Send the value before this.
	b iofail
players3
	eor r4,r2,r3		;P1 & P3
	tst r4,#0xff00		;not in sync yet?
	beq players2
	ldr r1,lastsent
	eor r4,r1,r3		;Has P3 missed an interrupt?
	tst r4,#0xff00
	streq r1,sending	;Send the value before this.
	b iofail
players2
	eor r4,r2,r2,lsr#16	;P1 & P2
	tst r4,#0xff00		;in sync yet?
	beq checkold
	ldr r1,lastsent
	eor r4,r1,r2,lsr#16	;Has P2 missed an interrupt?
	tst r4,#0xff00
	streq r1,sending	;Send the value before this.
	b iofail
checkold
	ldr r4,sending
	ldr r1,lastsent
	eor r4,r4,r1		;Did we send an old value last time?
	tst r4,#0xff00
	bne iogood		;bne
	ldr r1,sending
	str r0,sending
	str r1,lastsent
iofail	orrs r4,r4,#1		;Z=0 fail
	b notyet
iogood	ands r4,r4,#0		;Z=1 ok
notyet	ldr r1,sending
	streq r1,lastsent
	movne r0,r1		;resend last.

	orr r0,r0,#0x10000
	str r0,sending
	strh r0,[r5,#REG_SIOMLT_SEND]	;put data in buffer
	ldrh r1,[r5,#REG_SIOCNT]
	tst r1,#0x4			;Check if we're Master.
	bne endSIO

multip	ldrh r1,[r5,#REG_SIOCNT]
	tst r1,#0x8			;Check if all machines are in multi mode.
	beq multip

	orr r1,r1,#0x80			;Set send bit
	strh r1,[r5,#REG_SIOCNT]	;start send

endSIO
	teq r4,#0
	mov pc,lr
;----------------------------------------------------------------------------
resetSIO_core	;r0=joycfg
;----------------------------------------------------------------------------
	bic r0,r0,#0x0f000000
	str r0,joycfg

	mov r2,#2		;only 2 players.
	mov r1,r0,lsr#29
	cmp r1,#0x6
	moveq r2,#4		;all 4 players
	cmp r1,#0x5
	moveq r2,#3		;3 players.
	str r2,nrplayers

	mov r2,#REG_BASE
	add r2,r2,#0x100

	mov r1,#0
;	strh r1,[r2,#REG_RCNT]

	tst r0,#0x80000000
	moveq r1,#0x2000
	movne r1,   #0x6000
	addne r1,r1,#0x0002	;16bit multiplayer, 57600bps
;	strh r1,[r2,#REG_SIOCNT]

	bx lr
;----------------------------------------------------------------------------
refreshNESjoypads	;call every frame
;exits with Z flag clear if update incomplete (waiting for other player)
;is my multiplayer code butt-ugly?  yes, I thought so.
;i'm not trying to win any contests here.
;----------------------------------------------------------------------------
	mov r6,lr		;return with this..

;	ldr r0,=SerCounter
;	ldr r0,[r0]
;	mov r1,#4
;	bl debug_
;	ldr r0,received1
;	mov r1,#5
;	bl debug_
;	ldr r0,received2
;	mov r1,#7
;	bl debug_
;	ldr r0,received3
;	mov r1,#8
;	bl debug_
;	ldr r0,sending
;	mov r1,#10
;	bl debug_
;	ldr r0,lastsent
;	mov r1,#11
;	bl debug_

		ldr r4,frame
		movs r0,r4,lsr#2 ;C=frame&2 (autofire alternates every other frame)
	ldr r1,XGBjoypad
	and r0,r1,#0xf0
		ldr r2,joycfg
		andcs r1,r1,r2
		movcss addy,r1,lsr#9	;R?
		andcs r1,r1,r2,lsr#16
	and r1,r1,#0x0f		;startselectBA
	tst r2,#0x400			;Swap A/B?
	adrne addy,ssba2ssab
	ldrneb r1,[addy,r1]	;startselectBA
	orr r0,r1,r0		;r0=joypad state

	tst r2,#0x80000000
	bne multi

no4scr	tst r2,#0x20000000
	streqb r0,joy0state
	strneb r0,joy1state
	ands r0,r0,#0		;Z=1
	mov pc,r6
multi				;r2=joycfg
	tst r2,#0x08000000	;link active?
	beq link_sync

	bl xmit			;send joypad data for NEXT frame
	movne pc,r6		;send was incomplete!

	strb r2,joy0state		;master is player 1
	mov r2,r2,lsr#16
	strb r2,joy1state		;slave1 is player 2
	ldr r4,nrplayers
	cmp r4,#3
	bmi fin
	strb r3,joy2state
	mov r3,r3,lsr#16
	strhib r3,joy3state
fin	ands r0,r0,#0		;Z=1
	mov pc,r6

link_sync
	mov r1,#0x8000
	str r1,lastsent
	tst r2,#0x03000000
	beq stage0
	tst r2,#0x02000000
	beq stage1
stage2
	mov r0,#0x2200
	bl xmit			;wait til other side is ready to go

	moveq r1,#0x8000
	streq r1,lastsent
	ldr r2,joycfg
	biceq r2,r2,#0x03000000
	orreq r2,r2,#0x08000000
	str r2,joycfg

	b badmonkey
stage1		;other GBA wants to reset
	bl sendreset		;one last time..
	bne badmonkey

	orr r2,r2,#0x02000000	;on to stage 2..
	str r2,joycfg

	ldr r0,romnumber
	tst r4,#0x4		;who are we?
	beq sg1
	ldrb r3,received0	;slaves uses master's timing flags
	bic r1,r1,#USEPPUHACK+CPUHACK
	orr r1,r1,r3
sg1	
	bl_long loadcart		;game reset

	mov r1,#0
	str r1,sending		;reset sequence numbers
	str r1,received0
	str r1,received1
badmonkey
	orrs r0,r0,#1		;Z=0 (incomplete xfer)
	mov pc,r6
stage0	;self-initiated link reset
	bl sendreset		;keep sending til we get a reply
	b badmonkey
sendreset       ;exits with r1=emuflags, r4=REG_SIOCNT, Z=1 if send was OK
	mov r5,#REG_BASE
	add r5,r5,#0x100

        ldr r1,emuflags
	and r0,r1,#USEPPUHACK+CPUHACK
	orr r0,r0,#0xaa00		;$AAxx, xx=timing flags

	ldrh r4,[r5,#REG_SIOCNT]
	tst r4,#0x80			;ok to send?
	movne pc,lr

	strh r0,[r5,#REG_SIOMLT_SEND]
	orr r4,r4,#0x80
	strh r4,[r5,#REG_SIOCNT]	;send!
	mov pc,lr

gbpadress DCD 0x04000000
joycfg DCD 0x40ff01ff ;byte0=auto mask, byte1=(saves R)bit2=SwapAB, byte2=R auto mask
;bit 31=single/multi, 30,29=1P/2P, 27=(multi) link active, 24=reset signal received
nrplayers DCD 0		;Number of players in multilink.
ssba2ssab DCB 0x00,0x02,0x01,0x03, 0x04,0x06,0x05,0x07, 0x08,0x0a,0x09,0x0b, 0x0c,0xe0,0xd0,0x0f

;----------------------------------------------------------------------------
joy0_W		;FF00
;----------------------------------------------------------------------------
	orr r0,r0,#0xCF
	mov r2,#0x0
	ldrb r1,joy0state
	tst r0,#0x10		;Direction
	orreq r2,r2,r1,lsr#4
	tst r0,#0x20		;Buttons
	orreq r2,r2,r1

	and r2,r2,#0x0F
	eor r2,r2,r0
	ldrb r1,joy0serial
	strb r2,joy0serial
	
	bx lr
;
;	
;	ldrb r2,sgbmode
;	movs r2,r2
;	bxeq lr
;	b SGB_transfer_bit

;----------------------------------------------------------------------------
joy0_R		;FF00
;----------------------------------------------------------------------------
	ldrb r0,joy0serial
	mov pc,lr
;----------------------------

FF51_R	;HDMA1
	ldrb r0,dma_src+1
	mov pc,lr
FF52_R	;HDMA2
	ldrb r0,dma_src
	mov pc,lr
FF53_R	;HDMA3
	ldrb r0,dma_dest+1
	mov pc,lr
FF54_R	;HDMA4
	ldrb r0,dma_dest
	mov pc,lr
FF55_R	;HDMA5
	mov r0,#0xFF
	mov pc,lr


FF51_W	;HDMA1  Src High
	strb r0,dma_src+1
	mov pc,lr
FF52_W	;HDMA2  Src Low
	bic r0,r0,#0xF
	strb r0,dma_src
	mov pc,lr
FF53_W	;HDMA3  Dest high
	bic r0,r0,#0xE0
	orr r0,r0,#0x80
	strb r0,dma_dest+1
	mov pc,lr
FF54_W	;HDMA4  Dest Low
	bic r0,r0,#0xF
	strb r0,dma_dest
	mov pc,lr
FF55_W	;HDMA5
	tst r0,#0x80
;	bxne lr
	bic r0,r0,#0x80
	
	beq hdma
	ldr r1,cyclesperscanline
	cmp r1,#DOUBLE_SPEED
	add r1,r0,#1
	moveq r1,r1,lsl#1
	mov r1,r1,lsl#7
	sub cycles,cycles,r1
hdma	
	
	stmfd sp!,{r0-addy,lr}
	
	ldr r3,dma_src
	mov r4,r3,lsr#16
	ldr r1,=0xFFFF
	and r3,r3,r1

	and r5,r0,#0x7F
	add r5,r5,#1
	mov r5,r5,lsl#4
	
dma5_loop
	mov addy,r3
	readmem
	mov addy,r4
	writemem
	add r3,r3,#1
	add r4,r4,#1
	bic r4,r4,#0xE000
	orr r4,r4,#0x8000
	
	subs r5,r5,#1
	bne dma5_loop

	orr r3,r3,r4,lsl#16
	str r3,dma_src
	
	ldmfd sp!,{r0-addy,lr}
	bx lr

FF4D_R	;KEY1 - bit 7, Read current speed of CPU - CGB Mode Only
	ldrb r0,doublespeed
	bx lr
FF4D_W	;KEY1 - prepare double speed
	ldrb r1,doublespeed
	bic r1,r1,#0x7F
	and r0,r0,#1
	orr r0,r0,r1
	strb r0,doublespeed
	bx lr


 AREA wram_globals3, CODE, READWRITE
	 DCB 0 ;joy0state
	 DCB 0 ;joy1state
	 DCB 0 ;joy2state
	 DCB 0 ;joy3state
	 DCB 0 ;joy0serial
	 DCB 0 ;joy1serial
	 DCB 0
	 DCB 0


	END
