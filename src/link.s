	[ {FALSE}
	INCLUDE equates.h
	INCLUDE io.h

 AREA wram_code1, CODE, READWRITE ;-- - - - - - - - - - - - - - - - - - - - - -

	EXPORT resetSIO
	EXPORT serialinterrupt
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
resetSIO	;r0=joycfg
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
	strh r1,[r2,#REG_RCNT]

	tst r0,#0x80000000
	moveq r1,#0x2000
	movne r1,   #0x6000
	addne r1,r1,#0x0002	;16bit multiplayer, 57600bps
	strh r1,[r2,#REG_SIOCNT]

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

;gbpadress DCD 0x04000000
;joycfg DCD 0x40ff01ff ;byte0=auto mask, byte1=(saves R)bit2=SwapAB, byte2=R auto mask
;bit 31=single/multi, 30,29=1P/2P, 27=(multi) link active, 24=reset signal received
nrplayers DCD 0		;Number of players in multilink.
;ssba2ssab DCB 0x00,0x02,0x01,0x03, 0x04,0x06,0x05,0x07, 0x08,0x0a,0x09,0x0b, 0x0c,0xe0,0xd0,0x0f


	]
