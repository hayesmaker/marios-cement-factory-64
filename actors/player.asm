PLAYER: {
	Pos_X:   //120
		.byte 100, $00
	Pos_Y:
		.byte 120

	Player_X:
		.byte 60, 88, 132, 165, 189
	Player_Y:
		.byte 189, 165, 132, 88, 60
		
	Player_PosX_Index:
		.byte 0
	Player_PosY_Index:
		.byte 0	


	Initialise: {
		lda #$00
		sta VIC.SPRITE_COLOR_1
		sta VIC.SPRITE_COLOR_2

		lda #$41
		sta SPRITE_POINTERS + 1

		lda VIC.SPRITE_ENABLE 
		ora #%00000001
		sta VIC.SPRITE_ENABLE

		lda #$00
		sta VIC.SPRITE_MULTICOLOR


		ldx #0
		stx Player_PosX_Index
		stx Player_PosY_Index
		rts
	}

	DrawSprite: {
        //set player position X & Y
        lda Pos_X + 0
        sta VIC.SPRITE_1_X

        lda VIC.SPRITE_MSB
        and #%11111110
        sta VIC.SPRITE_MSB

        lda Pos_X + 1
        beq !+
        lda VIC.SPRITE_MSB
        ora #%00000001
        sta VIC.SPRITE_MSB
    !:
        lda Pos_Y
        sta VIC.SPRITE_1_Y
        rts
    }

    Update: {
		
		rts
	}
}