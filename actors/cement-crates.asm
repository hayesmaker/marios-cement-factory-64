CRATES: {
	PosX:   //120
		.byte $00, $00
	PosY:
		.byte $52

	
	Crate1_PosX:
			 //120 //93 //73
		.byte $78, $5D, $49
	Crate1_PosX_MB:
		.byte $00, $00, $00	
	Crate1_PosY:
		.byte $52

	Crate1_Pos_Index:
		.byte 0	
			
	Speed:
		.byte $00, $00



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
	  	cpx #3
        bne !+
        ldx #0

    !:    
		clc
		lda Crate1_PosX, x
		sta PosX

		lda Crate1_PosX_MB, x
		sta PosX + 1

		jsr DrawSprite
		inx

	
		rts
	}
}