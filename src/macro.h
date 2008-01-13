
	MACRO
	start_map $base, $register
	GBLA _map_address_
_map_address_ SETA $base
	MEND

	MACRO
	_m_ $label,$size
	[ "$label" = ""
	|
$label EQU _map_address_
	]
_map_address_ SETA _map_address_ + $size
	MEND

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

	END
