CRATES: {
	PosX:
		.byte $00, $00
	PosY:
		.byte 90

	//Crates Positions Table - Refactor to use this 
	PositionsTableIndex1:
		.byte $00	
	PositionsTable1:
			  //120 //93 //73
		.byte $78, $5D, $49, $49, 53

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

		ldx #0
		stx PositionsTableIndex1	
		rts
	}

	DrawSprite: {
        //set player position X & Y
        lda PosX + 0
        sta VIC.SPRITE_0_X

        lda VIC.SPRITE_MSB
        and #%11111110
        sta VIC.SPRITE_MSB

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

		ldx PositionsTableIndex1
		cpx #5 //todo Create label
		bne !Loop+

		ldx #0
    !Loop:    
		clc
		lda PositionsTable1, x
		sta PosX

		lda #$00
		sta PosX + 1

		jsr DrawSprite
		inx
		stx PositionsTableIndex1

	
		rts
	}
}