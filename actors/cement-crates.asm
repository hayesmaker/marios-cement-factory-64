CRATES: {
	PosX:
		.byte $40, $00
	PosY:
		.byte $40

	Crate1_PosX:
		.byte $00
			
	Speed:
		.byte $10, $00	

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
		
		rts
	}

	DrawSprite: {
		//set player position X & Y
		lda PosX + 0
		sta VIC.SPRITE_0_X
	
		lda PosX + 1
		beq !+
		lda VIC.SPRITE_MSB
		ora #%00000001
		sta VIC.SPRITE_MSB
	!:
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

		jsr DrawSprite

		rts
	}
}