MixerCements: {
	PositionFrameIndex:
		.byte $00

	Positions_X_LB:
		.byte 80, $00, $00, $00
	Positions_X_HB:
		.byte $00, $00, $00, $00	
	Positions_Y:
		.byte 149, $00, $00, $00

	FRAME_ID:
		.byte $5B
	
	Initialise: {
		lda #$00
		sta VIC.SPRITE_COLOR_3
		sta VIC.SPRITE_MULTICOLOR
		sta PositionFrameIndex	

		lda $40
		sta SPRITE_POINTERS + 3

		lda VIC.SPRITE_ENABLE 
		ora #%00000001
		sta VIC.SPRITE_ENABLE

        //initialise debounce flags 	
        //sta DebounceFlag
        //sta DebounceFireFlag
		rts
	}

    DrawSprite: {
        //x position index: Player_PosX_Index
        //x pixel coords table: Player_X
        ldy PositionFrameIndex
        lda Positions_X_LB, y
        sta VIC.SPRITE_3_X

        //crate 1 msb code
        lda VIC.SPRITE_MSB
        and #%11110111
        sta VIC.SPRITE_MSB

        ldy PositionFrameIndex
        lda Positions_X_HB, y
        beq !+
        lda VIC.SPRITE_MSB
        ora #%00001000
        sta VIC.SPRITE_MSB
    !:
        ldy PositionFrameIndex
        lda Positions_Y, y
        sta VIC.SPRITE_3_Y
        //y * 8 + x = table index
        lda FRAME_ID
        sta SPRITE_POINTERS + 3

        rts
    }

}