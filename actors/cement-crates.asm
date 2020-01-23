CRATES: {
	PosX:
		.byte $00, $40, $00
	PosY:
		.byte $40

	Speed:
		.byte $80, $00	

	Initialise: {
		lda #$00
		sta VIC.SPRITE_COLOR_0

		lda #$40
		sta SPRITE_POINTERS + 0

		lda VIC.SPRITE_ENABLE 
		ora #%00000001
		sta VIC.SPRITE_ENABLE

		lda #$00
		sta VIC.SPRITE_MULTICOLOR

		lda #$40
		sta VIC.SPRITE_0_X
		sta VIC.SPRITE_0_Y
		rts
	}

	DrawSprite: {
		//set player position X & Y
		lda PosX + 1
		sta VIC.SPRITE_0_X

		lda PosX + 2
		beq !+
		lda VIC.SPRITE_MSB
		ora #%00000001
		jmp !EndMSB+
	!:
		lda VIC.SPRITE_MSB
		and #%11111110
	!EndMSB:
		sta VIC.SPRITE_MSB
		lda PosY
		sta VIC.SPRITE_0_Y	
		rts
	}

	Update: {
		clc
		lda PosX
		adc Speed
		sta PosX
		lda PosX + 1
		adc Speed + 1
		sta PosX + 1
		lda PosX + 2
		adc #$00
		and #$01
		sta PosX + 2
		rts
	}
}