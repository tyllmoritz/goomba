	INCLUDE equates.h
	INCLUDE memory.h
	INCLUDE lcd.h
	INCLUDE sound.h
	INCLUDE cart.h
	INCLUDE gbz80.h
	INCLUDE gbz80mac.h
	INCLUDE sgb.h
	
	EXPORT _E0
	EXPORT _E2
	EXPORT _F0
	EXPORT _F2
	
	EXPORT IO_reset
	EXPORT IO_R
	EXPORT IO_High_R
	EXPORT IO_W
	EXPORT IO_High_W
	
	EXPORT io_read_tbl
	EXPORT io_write_tbl
	
	EXPORT joypad_write_ptr
	EXPORT joy0_W
	EXPORT joycfg
	EXPORT suspend
	EXPORT refreshNESjoypads
;	EXPORT serialinterrupt
;	EXPORT resetSIO
	EXPORT thumbcall_r1
	EXPORT gettime
	EXPORT vbaprint
	EXPORT waitframe
	EXPORT LZ77UnCompVram
	EXPORT CheckGBAVersion
;	EXPORT gbpadress
	EXPORT _FF70W
	EXPORT FF41_R_ptr
	EXPORT FF44_R_ptr
	EXPORT jump_r0
 [ RESIZABLE
	IMPORT add_exram
 ]


 AREA rom_code, CODE, READONLY ;-- - - - - - - - - - - - - - - - - - - - - -

	EXPORT breakpoint
breakpoint
	mov r11,r11
	bx lr



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

jump_r0
	bx r0
	

;----------------------------------------------------------------------------
	INCLUDE visoly.s
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

 AREA wram_code1, CODE, READWRITE ;-- - - - - - - - - - - - - - - - - - - - - -

;----------------------------------------------------------------------------
refreshNESjoypads	;call every frame
;exits with Z flag clear if update incomplete (waiting for other player)
;is my multiplayer code butt-ugly?  yes, I thought so.
;i'm not trying to win any contests here.
;----------------------------------------------------------------------------
	ldr r1,frame
	movs r0,r1,lsr#2 ;C=frame&2 (autofire alternates every other frame)
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
	
	str r0,joy0state
	bx lr

joycfg DCD 0x40ff01ff ;byte0=auto mask, byte1=(saves R)bit2=SwapAB, byte2=R auto mask
;bit 31=single/multi, 30,29=1P/2P, 27=(multi) link active, 24=reset signal received
ssba2ssab DCB 0x00,0x02,0x01,0x03, 0x04,0x06,0x05,0x07, 0x08,0x0a,0x09,0x0b, 0x0c,0xe0,0xd0,0x0f


;----------------------------------------------------------------------------
_F0;	LD A,($FF00+nn)
;----------------------------------------------------------------------------
	ldrb r2,[gb_pc],#1
	adr lr,_after_IO_High_R
;----------------------------------------------------------------------------
_IO_High_R	;I/O read
;----------------------------------------------------------------------------
	tst r2,#0x80
	adr r1,io_read_tbl
	ldreq pc,[r1,r2,lsl#2]
;----------------------------------------------------------------------------
_HRAM_R;		(FF80-FFFF)
;----------------------------------------------------------------------------
	adr r1,xgb_hram-0x80
	ldrb r0,[r1,r2]
_after_IO_High_R
	mov gb_a,r0,lsl#24
	fetch 12

;----------------------------------------------------------------------------
_F2;	LD A,($FF00+C)
;----------------------------------------------------------------------------
	mov r2,gb_bc,lsr#16
	and r2,r2,#0xFF
	adr lr,_after_IO_High_R_2
;----------------------------------------------------------------------------
_IO_High_R_2	;I/O read
;----------------------------------------------------------------------------
	tst r2,#0x80
	adr r1,io_read_tbl
	ldreq pc,[r1,r2,lsl#2]
;----------------------------------------------------------------------------
_HRAM_R_2;		(FF80-FFFF)
;----------------------------------------------------------------------------
	adr r1,xgb_hram-0x80
	ldrb r0,[r1,r2]
_after_IO_High_R_2
	mov gb_a,r0,lsl#24
	fetch 8


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
joypad_read_ptr
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
FF41_R_ptr
	DCD FF41_R	;STAT - LCDC Status
	DCD FF42_R	;SCY - Scroll Y
	DCD FF43_R	;SCX - Scroll X
FF44_R_ptr
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
_E0;	LD ($FF00+nn),A
;----------------------------------------------------------------------------
	ldrb r2,[gb_pc],#1
	mov r0,gb_a,lsr#24
	
	adr lr,_after_IO_High_W
;----------------------------------------------------------------------------
_IO_High_W	;I/O write
;----------------------------------------------------------------------------
	tst r2,#0x80
	adr r1,io_write_tbl
	ldreq pc,[r1,r2,lsl#2]
;----------------------------------------------------------------------------
_HRAM_W;	(FF80-FFFF)
;----------------------------------------------------------------------------
	adr r1,xgb_hram-0x80
	strb r0,[r1,r2]
	cmp r2,#0xFF
	beq HRAM_W_IE_
_after_IO_High_W
	fetch 12
;----------------------------------------------------------------------------
_E2;	LD ($FF00+C),A
;----------------------------------------------------------------------------
	mov r2,gb_bc,lsr#16
	and r2,r2,#0xFF
	mov r0,gb_a,lsr#24
	
	adr lr,_after_IO_High_W_2
;----------------------------------------------------------------------------
_IO_High_W_2	;I/O write
;----------------------------------------------------------------------------
	tst r2,#0x80
	adr r1,io_write_tbl
	ldreq pc,[r1,r2,lsl#2]
;----------------------------------------------------------------------------
_HRAM_W_2;	(FF80-FFFF)
;----------------------------------------------------------------------------
	adr r1,xgb_hram-0x80
	strb r0,[r1,r2]
	cmp r2,#0xFF
	beq HRAM_W_IE_
_after_IO_High_W_2
	fetch 8


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
	adr r1,xgb_hram-0x80
	strb r0,[r1,r2]
	cmp r2,#0xFF
	bxne lr
HRAM_W_IE_
	strb r0,gb_ie
	b immediate_check_irq

;----------------------------------------------------------------------------
HRAM_R;		(FF80-FFFF)
;----------------------------------------------------------------------------
	adr r1,xgb_hram-0x80
	ldrb r0,[r1,r2]
	bx lr
;----------------------------------------------------------------------------
_FF70W;		SVBK - CGB Mode Only - WRAM Bank
;----------------------------------------------------------------------------
	strb r0,rambank
	and r0,r0,#7
	cmp r0,#2
	bge select_gbc_ram
	ldr r1,memmap_tbl+48
	str r1,memmap_tbl+52
	ldr r1,=wram_W
	str r1,writemem_tbl+52
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
	ldr r1,=wram_W_2
	str r1,writemem_tbl+52

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
;----------------------------------------------------------------------------
joy0_R		;FF00
;----------------------------------------------------------------------------
	ldrb r0,joy0serial
	mov pc,lr
;----------------------------

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

 AREA rom_code_, CODE, READONLY ;-- - - - - - - - - - - - - - - - - - - - - -
;----------------------------------------------------------------------------
IO_reset
;----------------------------------------------------------------------------
	mov r0,#0
	str r0,joy0state
	str r0,joy0serial
	strb r0,stctrl

	ldrb r0,sgbmode
	movs r0,r0
	ldreq r0,=joy0_W
	ldrne r0,=joy0_W_SGB
	ldr r1,=joypad_write_ptr
	str r0,[r1]
	ldreq r0,=joy0_R
	ldrne r0,=joy0_R_SGB
	ldr r1,=joypad_read_ptr
	str r0,[r1]
	
	bx lr

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
	beq_long map0123_
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
	 DCB 0 
	 DCB 0
	 DCB 0


	END
