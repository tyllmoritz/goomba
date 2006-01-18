	AREA wram_code3, CODE, READWRITE

	INCLUDE equates.h
	INCLUDE memory.h
	INCLUDE lcd.h
	INCLUDE cart.h
	INCLUDE io.h

	IMPORT DoRumble

	EXPORT mbc0init
	EXPORT mbc1init
	EXPORT mbc2init
	EXPORT mbc3init
	EXPORT mbc4init
	EXPORT mbc5init
	EXPORT mbc6init
	EXPORT mbc7init
	EXPORT mmm01init
	EXPORT huc1init
	EXPORT huc3init
;----------------------------------------------------------------------------
RamSelect
;----------------------------------------------------------------------------
	ldrb r0,mapperdata+2
;----------------------------------------------------------------------------
RamEnable
;----------------------------------------------------------------------------
	strb r0,mapperdata+2
	and r0,r0,#0x0F
	cmp r0,#0x0A
	adrne r1,empty_W
	ldreq r1,sramwptr
	str r1,writemem_tbl+40
	str r1,writemem_tbl+44
	adrne r1,empty_R
	adreq r1,mem_RA0
	str r1,readmem_tbl+40
	str r1,readmem_tbl+44
	ldrb r0,mapperdata+4		;rambank
	b mapAB_

;----------------------------------------------------------------------------
mbc0init
;----------------------------------------------------------------------------
	DCD void,void,void,void
	mov pc,lr

;----------------------------------------------------------------------------
mbc1init
;----------------------------------------------------------------------------
	DCD RamEnable,MBC1map0,MBC1map1,MBC1mode
	mov pc,lr
;----------------------------------------------------------------------------
MBC1map0
;----------------------------------------------------------------------------
	ands r0,r0,#0x1f
	moveq r0,#1
	strb r0,mapperdata
	ldrb r1,mapperdata+1
	orr r0,r0,r1,lsl#5
	b map4567_
;----------------------------------------------------------------------------
MBC1map1
;----------------------------------------------------------------------------
	and r0,r0,#0x03
	strb r0,mapperdata+5		;Ram/Rom bank select.
	ldrb r0,mapperdata+3
;----------------------------------------------------------------------------
MBC1mode
;----------------------------------------------------------------------------
	strb r0,mapperdata+3
	tst r0,#1
	ldrb r0,mapperdata+5
	mov r1,#0
	streqb r0,mapperdata+1		;16Mbit Rom
	strneb r1,mapperdata+1		;4Mbit Rom
	streqb r1,mapperdata+4		;8kByte Ram
	strneb r0,mapperdata+4		;32kbyte Ram

	ldrb r0,mapperdata
	ldrb r1,mapperdata+1
	orr r0,r0,r1,lsl#5
	str lr,[sp,#-4]!
	bl map4567_
	ldr lr,[sp],#4
	b RamSelect

;----------------------------------------------------------------------------
mbc2init
;----------------------------------------------------------------------------
	DCD MBC2RamEnable,MBC2map,void,void
	mov pc,lr
;----------------------------------------------------------------------------
MBC2map
;----------------------------------------------------------------------------
	tst addy,#0x0100
	moveq pc,lr
	ands r0,r0,#0xf
	moveq r0,#1
	b map4567_
;----------------------------------------------------------------------------
MBC2RamEnable
	tst addy,#0x0100
	beq RamEnable
	mov pc,lr

;----------------------------------------------------------------------------
mbc3init
;----------------------------------------------------------------------------
	DCD RamEnable,map4567_,mbc3bank,mbc3latchtime
	mov pc,lr
;----------------------------------------------------------------------------
mbc3latchtime
;----------------------------------------------------------------------------
	ldrb r1,mapperdata+3
	strb r0,mapperdata+3
	eor r1,r1,r0
	and r1,r1,r0
	cmp r1,#1
	movne pc,lr
	stmfd sp!,{r3,lr}
	bl gettime
	ldmfd sp!,{r3,lr}
	mov pc,lr
;----------------------------------------------------------------------------
mbc3bank
;----------------------------------------------------------------------------
	strb r0,mapperdata+4
	tst r0,#8
	beq RamSelect
	adr r1,empty_W
	str r1,writemem_tbl+40
	str r1,writemem_tbl+44
	adr r1,empty_R
	cmp r0,#0x8
	adreq r1,clk_sec
	cmp r0,#0x9
	adreq r1,clk_min
	cmp r0,#0xA
	adreq r1,clk_hrs
	cmp r0,#0xB
	adreq r1,clk_dayL
	cmp r0,#0xC
	adreq r1,clk_dayH
	str r1,readmem_tbl+40
	str r1,readmem_tbl+44
	mov pc,lr

;------------------------------
clk_sec
	ldrb r0,mapperdata+30
	b calctime
;------------------------------
clk_min
	ldrb r0,mapperdata+29
	b calctime
;------------------------------
clk_hrs
	ldrb r0,mapperdata+28
	and r0,r0,#0x3F
	b calctime
;------------------------------
clk_dayL
	ldrb r0,mapperdata+26
	b calctime
clk_dayH
	mov r0,#0
calctime
	and r1,r0,#0xf
	mov r0,r0,lsr#4
	add r0,r0,r0,lsl#2
	add r0,r1,r0,lsl#1 
	mov pc,lr
;------------------------------
	

;----------------------------------------------------------------------------
mbc5init
;----------------------------------------------------------------------------
	DCD RamEnable,MBC5map0,MBC5RAMB,void
	mov pc,lr
;----------------------------------------------------------------------------
MBC5map0
;----------------------------------------------------------------------------
	tst addy,#0x1000
	andne r0,r0,#0x01
	strneb r0,mapperdata+1
	streqb r0,mapperdata
	ldr r0,mapperdata
	b map4567_
;----------------------------------------------------------------------------
MBC5RAMB
;----------------------------------------------------------------------------
	strb r0,mapperdata+4
;	tst r0,#0x08		;rumble motor.
	and r0,r0,#0x8
	ldr r1,=DoRumble
	str r0,[r1]

	b RamSelect

;----------------------------------------------------------------------------
mbc7init
;----------------------------------------------------------------------------
	DCD void,MBC7map,MBC7RAMB,void
	mov pc,lr
;----------------------------------------------------------------------------
MBC7map
;----------------------------------------------------------------------------
	ands r0,r0,#0x7f
	moveq r0,#1
	strb r0,mapperdata
	b map4567_
;----------------------------------------------------------------------------
MBC7RAMB
;----------------------------------------------------------------------------
	strb r0,mapperdata+4
	cmp r0,#9
	movmi r0,#0xA
	movpl r0,#0
	strb r0,mapperdata+2
	b RamSelect

;----------------------------------------------------------------------------
huc1init
;----------------------------------------------------------------------------
	DCD RamEnable,HUC1map0,MBC1map1,MBC1mode
;	DCD RamEnable,HUC1map0,MBC5RAMB,void
	mov pc,lr
;----------------------------------------------------------------------------
HUC1map0
;----------------------------------------------------------------------------
	ands r0,r0,#0x3f
	moveq r0,#1
	strb r0,mapperdata
;	ldrb r1,mapperdata+1
;	orr r0,r0,r1,lsl#5
	b map4567_

;----------------------------------------------------------------------------
huc3init
;----------------------------------------------------------------------------
	DCD RamEnable,map4567_,MBC5RAMB,void
	mov pc,lr

;----------------------------------------------------------------------------
mmm01init
mbc4init
mbc6init
;----------------------------------------------------------------------------
	DCD RamEnable,map4567_,void,void
	mov pc,lr

;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
	END
