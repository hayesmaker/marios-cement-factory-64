Lives: {
	numLivesLost:
		.byte $00

	xPosition:
		.byte $00

	LifePosX:
		.byte 33, 31, 29

	Initialise: {
		//Remove all Misses
		//reset lives
		lda #0
		sta numLivesLost
		jsr clearLivesUI

		rts
	}

	clearLivesUI: {
		//Clear MISS Gfx
		ldx #29
		jsr RemoveMiss

		ldx #31
		jsr RemoveMiss

		ldx #33
		jsr RemoveMiss

		//Clear MISS Text
		lda Tiles.EMPTY
		ldx #30
		ldy #4
		jsr Map.SwitchCharAtXY

		lda Tiles.EMPTY
		ldx #31
		ldy #4
		jsr Map.SwitchCharAtXY

		lda Tiles.EMPTY
		ldx #32
		ldy #4
		jsr Map.SwitchCharAtXY

		rts
	}

	AddLife: {
		jsr clearLivesUI
		
		//reset lives
		lda #0
		sta numLivesLost
		
		rts
	}

	LoseLife: {
		ldy numLivesLost
		ldx LifePosX, y
		jsr AddMiss

		inc numLivesLost
		lda numLivesLost
		cmp #3
		bne !skip+
			lda #0
			sta Game.STATE_IN_PROGRESS
			//GAME OVER
		!skip:
		rts
	}

	AddMiss: {
		stx xPosition

		lda #171
		ldx xPosition
		ldy #2
		jsr Map.SwitchCharAtXY

		lda #173
		ldx xPosition
		ldy #3
		jsr Map.SwitchCharAtXY

		lda #172
		ldx xPosition
		inx
		ldy #2
		jsr Map.SwitchCharAtXY

		lda #174
		ldx xPosition
		inx
		ldy #3
		jsr Map.SwitchCharAtXY

		lda #175
		ldx #30
		ldy #4
		jsr Map.SwitchCharAtXY

		lda #176
		ldx #31
		ldy #4
		jsr Map.SwitchCharAtXY

		lda #177
		ldx #32
		ldy #4
		jsr Map.SwitchCharAtXY

		rts
	}


	//set X to charIndexX of Miss graphic tile
	RemoveMiss: {
		stx xPosition

		lda Tiles.EMPTY
		ldx xPosition
		ldy #2
		jsr Map.SwitchCharAtXY

		lda Tiles.EMPTY
		ldx xPosition
		ldy #3
		jsr Map.SwitchCharAtXY

		lda Tiles.EMPTY
		ldx xPosition
		inx
		ldy #2
		jsr Map.SwitchCharAtXY

		lda Tiles.EMPTY
		ldx xPosition
		inx
		ldy #3
		jsr Map.SwitchCharAtXY

		rts
	}

}