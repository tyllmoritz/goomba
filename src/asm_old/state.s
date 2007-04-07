	INCLUDE equates.h
	INCLUDE memory.h
	INCLUDE lcd.h
	INCLUDE sound.h
	INCLUDE cart.h
	INCLUDE gbz80.h
	INCLUDE gbz80mac.h
	INCLUDE sgb.h

 AREA rom_code2, CODE, READONLY ;-- - - - - - - - - - - - - - - - - - - - - -

;20
save_emu
	;r0 = dest
	ldr_ r1,frame
	str r1,[r0],#4
	ldr r1,cycles
	str r1,[r0],#4
	ldr_ r1,dividereg
	str r1,[r0],#4
	ldr_ r1,timercounter
	str r1,[r0],#4
	ldrb_ r1,gb_ime
	strb r1,[r0],#1
	ldrb_ r1,gbcmode
	strb r1,[r0],#1
	ldrb_ r1,sgbmode
	strb r1,[r0],#1
	ldrb_ r1,doubletimer_
	strb r1,[r0],#1
	bx lr
load_emu
	;r0 = src
	ldr r1,[r0],#4
	str_ r1,frame
	ldr r1,[r0],#4
	str r1,cycles
	ldr r1,[r0],#4
	str_ r1,dividereg
	ldr r1,[r0],#4
	str_ r1,timercounter
	ldrb r1,[r0],#1
	strb_ r1,gb_ime
	ldrb r1,[r0],#1
	strb_ r1,gbcmode
	ldrb r1,[r0],#1
	strb_ r1,sgbmode
	ldrb r1,[r0],#1
	strb_ r1,doubletimer_
	bx lr

;12
save_cpu
	;r0 = destination address
	stmfd sp!,{r0-addy,lr}
	mov addy,r0
	
	adr_ r1,cpuregs
	ldmia r1,{gb_flg-gb_pc}	;restore GB-Z80 state
	;force the bottom bits to be zero for no reason, this really isn't necessary
	ldr r2,#0xFFFF
	bic gb_a,gb_a,r2
	bic gb_a,gb_a,#0xFF0000
	bic gb_bc,gb_bc,r2
	bic gb_de,gb_de,r2
	bic gb_hl,gb_hl,r2
		
	encodeFLG
	orr r0,r0,gb_a,lsr#16
	orr r0,r0,gb_bc
	str r0,[addy],#4
	orr r0,gb_hl,gb_de,lsr#16
	str r0,[addy],#4
	ldr r0,gb_sp
	ldr_ r1,lastbank
	sub r1,gb_pc,r1
	mov r1,r1,lsl#16
	orr r0,r1,r0,lsr#16
	str r0,[addy],#4
	
	ldmfd sp!,{r0-addy,pc}

load_cpu
	stmfd sp!,{r0-addy,lr}
	mov addy,r0
	ldrb r0,[addy],#1
	decodeFLG
	ldrb r0,[addy],#1
	mov gb_a,r0,lsl#24
	ldrh r0,[addy],#2 ;4
	mov gb_bc,r0,lsl#16
	ldrh r0,[addy],#2
	mov gb_de,r0,lsl#16
	ldrh r0,[addy],#2 ;4
	mov gb_hl,r0,lsl#16
	ldrh r0,[addy],#2
	mov r0,r0,lsl#16
	str r0,gb_sp
	mov r0,#0
	str_ r0,lastbank
	ldrh r0,[addy],#2 ;4
	mov gb_pc,r0
	;you must fix PC afterwards by calling flush or something, not doing it now because mapper information may not be loaded yet
	ldmfd sp!,{r0-addy,pc}

;256
load_io
	;NOT SAVED:
	;sound information
	
	
	;r0 = address to read from (becomes r3)
	stmfd sp!,{r0-addy,lr}
	mov r3,r0
	
	add r1,r3,#0x80
	ldr r0,=XGB_HRAM
	mov r2,#0x80/4
	bl copy_
	
	ldrb r0,[r3,#0x00]
	strb_ r0,joy0serial
	ldrb r0,[r3,#0x02]
	strb_ r0,stctrl
	ldrb r0,[r3,#0x06]
	strb_ r0,timermodulo
	ldrb r0,[r3,#0x07]
	strb_ r0,timerctrl
	ldrb r0,[r3,#0x0F]
	strb_ r0,gb_if

	ldr r0,[r3,#0x40]
	str_ r0,lcdctrl
	ldr r0,[r3,#0x44]
	str_ r0,scanline
	ldr r0,[r3,#0x48]
	str_ r0,ob0palette
	
	ldrb r0,[r3,#0x4D]
	strb_ r0,doublespeed
	ldrb r0,[r3,#0x4F]
	strb_ r0,vrambank
	ldrb r0,[r3,#0x51]
	strb_ r0,dma_src+0
	ldrb r0,[r3,#0x52]
	strb_ r0,dma_src+1
	ldrb r0,[r3,#0x53]
	strb_ r0,dma_dest+0
	ldrb r0,[r3,#0x54]
	strb_ r0,dma_dest+1
	ldrb r0,[r3,#0x68]
	strb_ r0,BCPS_index
	ldrb r0,[r3,#0x6A]
	strb_ r0,OCPS_index
	ldrb r0,[r3,#0x70]
	strb_ r0,rambank
	ldrb r0,[r3,#0xFF]
	strb_ r0,gb_ie
	
	ldmfd sp!,{r0-addy,pc}

save_io
	;NOT SAVED:
	;sound information

	;r0 = address to dump to (becomes r3)	
	stmfd sp!,{r0-addy,lr}
	mov r3,r0
	mov r1,r0
	mov r0,#0
	mov r2,0x100/4
	bl filler_

	add r0,r3,#0x80
	ldr r1,=XGB_HRAM
	mov r2,#0x80/4
	bl copy_
	
	ldrb_ r0,joy0serial
	strb r0,[r3,#0x00]
	ldrb_ r0,stctrl
	strb r0,[r3,#0x02]
	ldrb_ r0,timermodulo
	strb r0,[r3,#0x06]
	ldrb_ r0,timerctrl
	strb r0,[r3,#0x07]
	ldrb_ r0,gb_if
	strb r0,[r3,#0x0F]

	ldr_ r0,lcdctrl
	str r0,[r3,#0x40]
	ldr_ r0,scanline
	str r0,[r3,#0x44]
	ldr_ r0,ob0palette
	str r0,[r3,#0x48]
	
	ldrb_ r0,doublespeed
	strb r0,[r3,#0x4D]
	ldrb_ r0,vrambank
	strb r0,[r3,#0x4F]
	ldrb_ r0,dma_src+0
	strb r0,[r3,#0x51]
	ldrb_ r0,dma_src+1
	strb r0,[r3,#0x52]
	ldrb_ r0,dma_dest+0
	strb r0,[r3,#0x53]
	ldrb_ r0,dma_dest+1
	strb r0,[r3,#0x54]
	ldrb_ r0,BCPS_index
	strb r0,[r3,#0x68]
	ldrb_ r0,OCPS_index
	strb r0,[r3,#0x6A]
	ldrb_ r0,rambank
	strb r0,[r3,#0x70]
	ldrb_ r0,gb_ie
	strb r0,[r3,#0xFF]

	ldmfd sp!,{r0-addy,pc}



	END





