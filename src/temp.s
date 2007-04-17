writes to registers:
	lcdc
	x
	y
	wx
	wy
	
	ldcd, wx, wy can trigger 'mode changes'
modes:
	0 - no window
		window disabled in lcdc
		|| wx > 166
		|| scanline < wy
	1 - no BG
		window enabled in lcdc
		&& wx <=7
		&& scanline >= wy
	2 - split
		window enabled in lcdc
		&& wx > 7
		&& wx <= 166
		&& scanline >= wy

writes to registers:
	lcdc
		fill scanlines
		update mode
	x
		if mode != 1
			flush buffers
	y
		if mode != 1
			flush buffers
	wx
		update mode
		if mode != 0
			flush buffers
	wy
		update mode
		if mode changes, flush buffers
	













nowindow_update_scroll
	ldrb r0,[scrollY]
	;get y pos
	sub r0,r0,#8
	mov r11,r0,lsl#16
	;get x pos
	ldrb r0,[scrollX]
	sub r0,r0,#40
	mov r0,r0,lsl#16
	orr r11,r11,r0,lsr#16

nobg_update_scroll
	;Y window
	ldr r11,[wyscroll]
	;X window
	ldrb r0,[windowX]
	sub r0,r0,#40+7
	mov r0,r0,lsl#16
	orr r11,r11,r0,lsr#16
	
	;Y window scroll
	orr r11,r5,r0,lsr#16

split_update_scroll
	;get wx
	ldrb r0,[windowX]

	;wx to screen scroll
	rsb r0,r0,#0
	sub r0,r0,#(40-7)
	mov r12,r0,lsl#16
	orr r12,r5,r12,lsr#16

	;wx to GBA window position
	rsb r0,r0,#0
	mov r0,r0,lsl#8
	orr r0,r0,#0x00C8

	;get y pos
	ldrb r0,[r1,#144*2]
	sub r0,r0,#8
	mov r11,r0,lsl#16
	
	;get x pos
	ldrb r0,[r1,#144*1]
	sub r0,r0,#40
	mov r0,r0,lsl#16
	orr r11,r11,r0,lsr#16



nowindow_loop
	;fill dispcntbuff
	strh r8,[r2],#2

	stmia r3!,{r9,r10,r11}
	str r11,[r3],#4
	str r11,[r3],#8

	subs r7,r7,#1
	bne nowindow_loop

nobg_loop
	;fill dispcntbuff
	strh r8,[r2],#2
	
	stmia r3!,{r9,r10,r11}
	str r11,[r3],#4
	str r11,[r3],#8
	
	subs r7,r7,#1
	bne nobg_loop


split_bgwin_loop
	;fill dispcnt, bgxcnt buffs
	strh r8,[r2],#2

	;store gba window0
	strh r0,[r2,lr]
	
	stmia r3!,{r9,r10,r11,r12}
	stmia r3!,{r11,r12}
	
	;next byte
	subs r7,r7,#1
	bne split_bgwin_loop
