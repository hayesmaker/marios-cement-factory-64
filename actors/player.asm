PLAYER: {
	PlayerX:
		.byte $00, $40, $00
	PlayerY:
		.byte $40

	PlayerWalkSpeed:
		.byte $80, $00	

	Initialise: {
		lda #$0a
		sta VIC.SPRITE_MULTICOLOR_1
		lda #$09
		sta VIC.SPRITE_MULTICOLOR_2

		lda #$05
		sta VIC.SPRITE_COLOR_0

		lda #$40
		sta SPRITE_POINTERS + 0

		lda VIC.SPRITE_ENABLE 
		ora #%00000001
		sta VIC.SPRITE_ENABLE

		lda VIC.SPRITE_MULTICOLOR
		ora #%00000001
		sta VIC.SPRITE_MULTICOLOR

		lda #$40
		sta VIC.SPRITE_0_X
		sta VIC.SPRITE_0_Y
		rts
	}

	DrawPlayer: {
		//set player position X & Y
		lda PlayerX + 1
		sta VIC.SPRITE_0_X

		lda PlayerX + 2
		beq !+
		lda VIC.SPRITE_MSB
		ora #%00000001
		jmp !EndMSB+
	!:
		lda VIC.SPRITE_MSB
		and #%11111110
	!EndMSB:
		sta VIC.SPRITE_MSB
		lda PlayerY
		sta VIC.SPRITE_0_Y	
		rts
	}

	PlayerControl: {
		clc
		lda PlayerX
		adc PlayerWalkSpeed
		sta PlayerX
		lda PlayerX + 1
		adc PlayerWalkSpeed + 1
		sta PlayerX + 1
		lda PlayerX + 2
		adc #$00
		and #$01
		sta PlayerX + 2
		rts
	}
}