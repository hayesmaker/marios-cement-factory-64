ELEVATORS: {
	Positions:
		.fill 5, 0

	Initialise: {
		lda #$00
		sta VIC.SPRITE_COLOR_1
		sta VIC.SPRITE_COLOR_2

		lda #$41
		sta SPRITE_POINTERS + 1

		lda #$41 //todo: remove to save 2bytes :()
		sta SPRITE_POINTERS + 2

		lda VIC.SPRITE_ENABLE 
		ora #%00000001
		sta VIC.SPRITE_ENABLE

		lda #$00
		sta VIC.SPRITE_MULTICOLOR


		ldx #0
		stx Elevator1_Pos_Index
		ldx #5
		stx Elevator2_Pos_Index
		rts
	}

	DrawSprite: {
        //set player position X & Y
        lda Pos1_X + 0
        sta VIC.SPRITE_1_X

        lda VIC.SPRITE_MSB
        and #%11111110
        sta VIC.SPRITE_MSB

        lda Pos1_X + 1
        beq !+
        lda VIC.SPRITE_MSB
        ora #%00000001
        sta VIC.SPRITE_MSB
    !:
        lda Pos1_Y
        sta VIC.SPRITE_1_Y
        rts
    }

    Update: {
		ldx Elevator1_Pos_Index
		cpx #5
		bne !Loop+
		ldx #0
	!Loop:	
		clc
		lda Elevator_PosY, x
		sta Pos1_Y
		jsr DrawSprite
		inx
		stx Elevator1_Pos_Index
		rts
	}

	//Todo: Use Tables for this shit bruh
    DrawSprite2: {
        //set player position X & Y
        lda Pos2_X + 0
        sta VIC.SPRITE_2_X

        lda VIC.SPRITE_MSB
        and #%11111110
        sta VIC.SPRITE_MSB

        lda Pos2_X + 1
        beq !+
        lda VIC.SPRITE_MSB
        ora #%00000001
        sta VIC.SPRITE_MSB
    !:
        lda Pos2_Y
        sta VIC.SPRITE_2_Y
        rts
    }

	Update2: {
		ldx Elevator2_Pos_Index
		cpx #5
		bne !Loop+
		ldx #0
	!Loop:	
		clc
		lda Elevator2_PosY, x
		sta Pos2_Y
		jsr DrawSprite2
		inx
		stx Elevator2_Pos_Index
		rts
	}
}