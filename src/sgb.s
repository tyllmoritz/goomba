	INCLUDE equates.h
	INCLUDE memory.h
	INCLUDE lcd.h
	INCLUDE sound.h
	INCLUDE cart.h
	INCLUDE gbz80.h
	INCLUDE gbz80mac.h
	
	IMPORT _00
	IMPORT move_ui

	EXPORT auto_border
	EXPORT joy0_W_SGB
	EXPORT joy0_R_SGB
	EXPORT g_update_border_palette
	EXPORT sgb_reset
	EXPORT g_sgb_mask


 AREA wram_globals4, CODE, READWRITE
	DCD 0	;packetcursor
	DCD 0   ;packetbitcursor
	DCB 0	;packetstate   ;0=invalid, 1=reset, 2=awaiting_stopbit, 3=awaiting_reset
	DCB 0	;player_turn
	DCB 0	;player_mask
g_sgb_mask	DCB 0	;sgb_mask
g_update_border_palette
	DCB 0   ;update_border_palette
auto_border
	DCB 1	;autoborder
	DCB 0	;autoborderstate
	DCB 0	;borderpartsadded
	
	DCD 0   ;sgb_hack_frame
	DCD 0	;auto_border_reboot_frame
	
	DCB 0	;lineslow
	DCB 0
	DCB 0
	DCB 0

 AREA rom_code7, CODE, READONLY ;-- - - - - - - - - - - - - - - - - - - - - -

sgb_speedhack_nop
	;firxt check if six (?) frames have passed
	ldr r0,sgb_hack_frame
	ldr r1,frame
	;if frame>=sgb_hack_frame+6, unhack
	add r0,r0,#6
	cmp r1,r0
	bge unhack
	;next byte is not a nop, and previous two bytes are?
	ldrb r1,[gb_pc,#1]
	movs r1,r1
	beq_long _00
	ldrb r0,[gb_pc,#-1]
	ldrb r2,[gb_pc,#-2]
	orrs r0,r0,r2
	bne_long _00
	;check which register pair is decremented
	cmp r1,#0x0B ;BC?
	moveq gb_bc,#0x00010000
	cmp r1,#0x1B ;DE?
	moveq gb_de,#0x00010000
	cmp r1,#0x2B ;HL?
	moveq gb_hl,#0x00010000
	b_long _00
unhack
	ldr r0,=_00
	str r0,[gb_optbl]
	bx r0

sgb_reset
	stmfd sp!,{lr}

	ldr r0,=_00
	str r0,[gb_optbl]

	mov r0,#0
	str r0,packetcursor
	str r0,packetbitcursor
	str r0,packetstate ;also erases player_turn, player_mask, sgb_mask
	strb r0,update_border_palette
	strb r0,borderpartsadded
	str r0,sgb_hack_frame
	
	mvn r0,#0
	strb r0,joy0serial
	
	mov r0,#0
	ldr r1,=SGB_PALS
	mov r2,#4096/4
	bl filler_
	ldr r1,=SGB_ATFS
	mov r2,#4096/4
	bl filler_
	ldr r1,=sgb_attributes
	mov r2,#360/4
	bl filler_

	;don't remove border after we went through everything to add it
	ldrb r0,autoborderstate
	cmp r0,#2
	beq %f0
	
	mov r0,#0
	;erase SGB border
	ldr r1,=0x06006800
	mov r2,#0x800/4
	bl filler_
	;erase SGB border tiles
	ldr r1,=0x06004200
	mov r2,#0x2000/4
	bl filler_
	
	ldrb r1,_ui_border_visible
	bic r1,r1,#2
	strb r1,_ui_border_visible
0
	
	bl move_ui
	bl_long update_ui_border_masks
	mov r0,#255
	str r0,auto_border_reboot_frame
	
	;erase SGB packet for no reason
	mov r0,#0
	ldr r1,=SGB_PACKET
	mov r2,#0x112/4
	bl filler_
	
	ldmfd sp!,{pc}


;----------------------------------------------------------------------------
joy0_R_SGB		;FF00
;----------------------------------------------------------------------------
	ldrb r0,joy0serial
	ldrb r1,lineslow
	orr r1,r1,#0x04
	strb r1,lineslow
	mov pc,lr

;----------------------------------------------------------------------------
joy0_W_SGB		;FF00
;----------------------------------------------------------------------------
	and r0,r0,#0x30

	ldrb r2,player_turn
	;handle lines low for player control switching
	ldrb r1,lineslow
	cmp r0,#0x10
	orreq r1,r1,#0x02
	cmp r0,#0x20
	orreq r1,r1,#0x01
	cmp r0,#0x00
	moveq r1,#0
	cmp r0,#0x30
	bne %f0
	cmp r1,#0x07
	bicne r1,r1,#0x04
	moveq r1,#0
	addeq r2,r2,#1
0
	strb r1,lineslow
	ldrb r1,player_mask
	and r2,r2,r1
	strb r2,player_turn
	
	adrl r1,joy0state
	ldrb r1,[r1,r2]

;	ldrb r2,autoborderstate
;	cmp r2,#1
;	eoreq r1,r1,#0x08

	cmp r0,#0x30
	orr r0,r0,#0xC0
	orreq r0,r0,#0x0F
	subeq r0,r0,r2
	beq %f0
	tst r0,#0x10		;direction
	orreq r0,r0,r1,lsr#4
	and r1,r1,#0x0F
	tst r0,#0x20		;buttons
	orreq r0,r0,r1
	eor r0,r0,#0x0F
0
	ldrb r1,joy0serial
	strb r0,joy0serial
;----------------------------------------------------------------------------
SGB_transfer_bit
;----------------------------------------------------------------------------
;r0 = current write
;r1 = previous write
	ands r0,r0,#0x30
	and r1,r1,#0x30
	beq resetpacket
	cmp r0,#0x30
	bxeq lr
	;current = 10 or 20, if previous isn't equal to current or 30, invalid packet.
	cmp r0,r1
	bxeq lr
	cmp r1,#0x30
	bne invalidpacket
	tst r0,#0x20 ;write a zero, otherwise write a 1
	ldr addy,=SGB_PACKET
	ldr r0,packetcursor
	ldr r1,packetbitcursor
	ldr r2,[addy,r0]
	bicne r2,r2,r1 ;write the zero
	orreq r2,r2,r1 ;write the one
	str r2,[addy,r0]
	movs r1,r1
	beq stopbit
	adds r1,r1,r1
	addcs r1,r1,#1
	str r1,packetbitcursor
	bxcc lr
	
	add r0,r0,#4
	str r0,packetcursor
	tst r0,#0x0F
	bxne lr
	mov r1,#0
	str r1,packetbitcursor
	mov r2,#2
	strb r2,packetstate
	
	bx lr
stopbit
	;if not expecting stop bit, flag as invalid
	ldrb r2,packetstate
	cmp r2,#2
	bne invalidpacket
	
	;if the stop bit is a 1, flag as invalid
	ldrb r2,joy0serial
	tst r2,#0x10 ;eq if a zero
	bne invalidpacket
	
	;if cursor is not >=16, and 16 byte aligned, flag as invalid (shouldn't happen)
	tst r0,#0x0F
	bne invalidpacket_
	cmp r0,#0x10
	blt invalidpacket_
	
	;get size
	ldrb r2,[addy]
	and r1,r2,#0x07
	mov r1,r1,lsl#4
	cmp r0,r1
	;cursor past end of packet?  Invalid
	bgt invalidpacket
	beq finishpacket	
	;packet waiting for the next reset
	mov r2,#3
	strb r2,packetstate
	bx lr
	
invalidpacket_ mov r11,r11 ;this shouldn't happen
invalidpacket ;this will happen
	mov r0,#0
	str r0,packetcursor
	str r0,packetbitcursor
	strb r0,packetstate
	bx lr

resetpacket
	ldrb r2,packetstate
	cmp r2,#3
	beq nextpacketpart
	
	mov r0,#1
	strb r0,packetstate
	str r0,packetbitcursor
	mov r0,#0
	str r0,packetcursor
	bx lr
nextpacketpart
	mov r0,#1
	strb r0,packetstate
	str r0,packetbitcursor
	bx lr

finishpacket
	;r2 = packet type and size (byte 0 of packet)
	;r1 = size in bytes (up to 112)
	;addy = address of first byte inside packet
	
	mov r0,#0
	str r0,packetcursor
	str r0,packetbitcursor
	strb r0,packetstate
	strb r0,lineslow

	
	;SGB speedhack to remove 6 frame delay
	adr r0,sgb_speedhack_nop
	str r0,[gb_optbl]
	ldr r0,frame
	str r0,sgb_hack_frame
	
	and r0,r2,#0xF8
	ldr pc,[pc,r0,lsr#1]
NULL
	bx lr
	DCD PAL01,PAL23,PAL03,PAL12,ATTR_BLK,ATTR_LIN,ATTR_DIV,ATTR_CHR
	DCD SOUND,SOU_TRN,PAL_SET,PAL_TRN,ATRC_EN,TEST_EN,ICON_EN,DATA_SND
	DCD DATA_TRN,MLT_REQ,JUMP,CHR_TRN,PCT_TRN,ATTR_TRN,ATTR_SET,MASK_EN
	DCD OBJ_TRN,NULL,NULL,NULL,NULL,NULL,NULL,NULL

MLT_REQ   ;Controller 2 Request
	ldrb r0,[addy,#1]
	and r0,r0,#3
	cmp r0,#2 ;requests 3 players?  shouldn't happen, but make it 4.
	moveq r0,#3
	strb r0,player_mask
	bx lr
PAL01     ;Set SGB Palette 0,1 Data
	ldr r2,=SGB_PALETTE+2
1
	mov r0,#2
2
	stmfd sp!,{r0}
	;set background color
	ldr r1,=SGB_PALETTE
	ldrb r0,[addy,#1]!
	strb r0,[r1]
	strb r0,[r1,#8]
	strb r0,[r1,#16]
	strb r0,[r1,#24]
	ldrb r0,[addy,#1]!
	strb r0,[r1,#1]
	strb r0,[r1,#9]
	strb r0,[r1,#17]
	strb r0,[r1,#25]
	;3 colors, 6 bytes
	mov r1,#6
0
	ldrb r0,[addy,#1]!
	strb r0,[r2],#1
	subs r1,r1,#1
	bne %b0
	;skip transparent color
	ldmfd sp!,{r0}
	add r2,r2,r0
	mov r1,#6
0
	ldrb r0,[addy,#1]!
	strb r0,[r2],#1
	subs r1,r1,#1
	bne %b0
	b update_sgb_palette
PAL23     ;Set SGB Palette 2,3 Data
	ldr r2,=SGB_PALETTE+16+2
	b %b1
PAL12     ;Set SGB Palette 1,2 Data
	ldr r2,=SGB_PALETTE+8+2
	b %b1
PAL03     ;Set SGB Palette 0,3 Data
	ldr r2,=SGB_PALETTE+2
	mov r0,#16+2
	b %b2

ATTR_BLK  ;"Block" Area Designation Mode
ATTR_LIN  ;"Line" Area Designation Mode
ATTR_DIV  ;"Divide" Area Designation Mode
ATTR_CHR  ;"1CHR" Area Designation Mode
SOUND     ;Sound On/Off
SOU_TRN   ;Transfer Sound PRG/DATA
	bx lr
PAL_SET   ;Set SGB Palette Indirect
	stmfd sp!,{r3-r4,lr}
	ldr r2,=SGB_PALETTE
	ldr r3,=SGB_PALS
	mov r4,#4
0
	ldrb r0,[addy,#1]!
	ldrb r1,[addy,#1]!
	orr r0,r0,r1,lsl#8
	bic r0,r0,#0xFE00
	add r1,r3,r0,lsl#3
	ldr r0,[r1],#4
	str r0,[r2],#4
	ldr r0,[r1],#4
	str r0,[r2],#4
	subs r4,r4,#1
	bne %b0
	;copy first color 0 to rest of palettes (yes, this is necessary)
	ldrh r0,[r2,#-32]
	strh r0,[r2,#-24]
	strh r0,[r2,#-16]
	strh r0,[r2,#-8]
	
	ldrb r0,[addy,#1]!
	;cancel mask
	tst r0,#0x40
	movne r1,#0
	strneb r1,sgb_mask
	tst r0,#0x80
	andne r0,r0,#0x3F
	blne set_atf
	bl update_sgb_palette
	ldmfd sp!,{r3-r4,pc}
PAL_TRN   ;Set System Color Palette Data
	ldr r1,=SGB_PALS
sgb_vram_transfer
	mov r2,#4096
sgb_vram_transfer2
	;r1 = dest
	;r2 = byte count
	
	;r3 = lcdc
	;r4 = vram base
	;r5 = address on tilemap
	;r6 = bytes remaining in tile
	;r7 = tiles remaining in tilemap row
	;addy = address of tile in vram
	stmfd sp!,{r3-r7,lr}

	mov r7,#20
	ldr r4,=XGB_VRAM
	ldrb r3,lcdctrl
	tst r3,#0x08
	ldreq r5,=XGB_VRAM+0x1800
	ldrne r5,=XGB_VRAM+0x1C00
1
	ldrb r0,[r5],#1
	;correct for the messed up tile numbers thing on the GB
	tst r0,#0x80
	tsteq r3,#0x10
	addeq r0,r0,#0x100
	;get tile address
	add addy,r4,r0,lsl#4
	mov r6,#16
3
	ldr r0,[addy],#4
	str r0,[r1],#4
	subs r6,r6,#4
	bne %b3
	
	subs r7,r7,#1
	moveq r7,#20
	addeq r5,r5,#12
	
	subs r2,r2,#16
	bgt %b1

	ldmfd sp!,{r3-r7,pc}

ATRC_EN   ;Enable/disable Attraction Mode
TEST_EN   ;Speed Function
ICON_EN   ;SGB Function
DATA_SND  ;SUPER NES WRAM Transfer 1
DATA_TRN  ;SUPER NES WRAM Transfer 2
JUMP      ;Set SNES Program Counter
	bx lr
CHR_TRN   ;Transfer Character Font Data
	stmfd sp!,{lr}
	ldrb r0,[addy,#1]
	and r0,r0,#1
	
	;###
	ldrb r1,borderpartsadded
	mov r2,#1
	orr r1,r1,r2,lsl r0
	strb r1,borderpartsadded
	cmp r1,#7
	moveq r1,#0
	ldrne r1,frame
	addne r1,r1,#255
	str r1,auto_border_reboot_frame	
	;###
	
	
	ldr r1,=SNES_VRAM
	add r1,r1,r0,lsl#12
	stmfd sp!,{r0}
	bl sgb_vram_transfer
	ldmfd sp!,{r0}
	bl convert_snes_vram
	ldmfd sp!,{pc}
PCT_TRN   ;Set Screen Data Color Data
	stmfd sp!,{lr}

	;###
	ldrb r1,borderpartsadded
	orr r1,r1,#4
	strb r1,borderpartsadded
	tst r1,#3
	movne r1,#0
	strne r1,auto_border_reboot_frame	
	;###

	ldr r1,=SNES_MAP
	mov r2,#0x880
	bl sgb_vram_transfer2
	bl draw_sgb_border
	ldmfd sp!,{pc}
ATTR_TRN  ;Set Attribute from ATF
	ldr r1,=SGB_ATFS
	b sgb_vram_transfer
ATTR_SET  ;Set Data to ATF
	ldrb r0,[addy,#1]!
	;cancel mask
	tst r0,#0x40
	movne r1,#0
	strneb r1,sgb_mask
	and r0,r0,#0x3F
set_atf
	stmfd sp!,{r3-r4,lr}
	;r0 = atf #
	mov r1,#90
	ldr r3,=SGB_ATFS
	mla r2,r0,r1,r3
	ldr r3,=sgb_attributes
	mov r4,#5*18
0
	ldrb r0,[r2],#1
	mov r1,r0,lsr#6
	strb r1,[r3],#1
	mov r1,r0,lsr#4
	bic r1,r1,#0xFC
	strb r1,[r3],#1
	mov r1,r0,lsr#2
	bic r1,r1,#0xFC
	strb r1,[r3],#1
	bic r1,r0,#0xFC
	strb r1,[r3],#1
	subs r4,r4,#1
	bne %b0
	ldmfd sp!,{r3-r4,pc}
MASK_EN   ;Game Boy Window Mask
	ldrb r0,[addy,#1]!
	and r0,r0,#3
	strb r0,sgb_mask
	bx lr
	
	
OBJ_TRN   ;Super NES OBJ Mode
	bx lr






convert_snes_vram
	;converts the SGB border from SNES to GBA tile format
	;r0 = page number, 0 or 1 (tiles 0-127, or tiles 128-255)
	stmfd sp!,{r3-r7,lr}
	mov r7,#128
	ldr r6,=0x06004200
	add r6,r6,r0,lsl#12
	ldr r5,=SNES_VRAM
	add r5,r5,r0,lsl#12
	ldr r4,=CHR_DECODE
0
	ldrb r0,[r5],#1  ;first plane
	ldrb r1,[r5],#1  ;second plane
	ldrb r2,[r5,#16-2]  ;third plane
	ldrb r3,[r5,#17-2]  ;fourth plane
	ldr r0,[r4,r0,lsl#2]
	ldr r1,[r4,r1,lsl#2]
	ldr r2,[r4,r2,lsl#2]
	ldr r3,[r4,r3,lsl#2]
	orr r0,r0,r1,lsl#1
	orr r0,r0,r2,lsl#2
	orr r0,r0,r3,lsl#3
	str r0,[r6],#4
	tst r6,#0x1F
	bne %b0
	add r5,r5,#16
	subs r7,r7,#1
	bne %b0
	ldmfd sp!,{r3-r7,pc}



draw_sgb_border
	stmfd sp!,{r3-r7,lr}
	
	;transfer map
	
	;6f00
	;6f00-80
	
	mov r7,#32*28
	ldr r6,=0x06006800+0x700
	ldr r5,=SNES_MAP+0x700
0
	ldrh r0,[r5,#-2]!
	and r1,r0,#255 ;tile number
	add r1,r1,#16
	mov r2,r0,lsr#14
	orr r1,r1,r2,lsl#10 ;flipping
	mov r2,r0,lsr#10
	and r2,r2,#0x3
	add r2,r2,#1
	orr r1,r1,r2,lsl#12
	strh r1,[r6,#-2]!
	subs r7,r7,#1
	bne %b0
	
	mov r0,#1
	strb r0,update_border_palette
	ldrb r0,_ui_border_visible
	orr r0,r0,#2
	strb r0,_ui_border_visible
	bl move_ui
	
;	;copy palette into that unused area of border ram
;	mov r7,#128
;	ldr r6,=BORDER_PALETTE
;	ldr r5,=SNES_MAP+0x800
;	ldr r4,=0x05000020 ;REMOVEME throw it in the GBA palette as well
;0
;	ldr r0,[r5],#4
;	str r0,[r6],#4
;	str r0,[r4],#4
;	subs r7,r7,#4
;	bne %b0
;	
;	ldrb r0,_border_visible
;	orr r0,r0,#2
;	strb r0,_border_visible
;	bl move_ui
	
	ldmfd sp!,{r3-r7,lr}
	bx lr







	END
