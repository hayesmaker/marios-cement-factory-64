Tubes: {

	Hopper1:
		.byte $00, $00, $00	

	Hopper2:
		.byte $00, $00, $00

	Hopper3:
		.byte $00, $00, $00

	Hopper4:
		.byte $00, $00, $00		

	
	Initialise: {
		jsr ClearMixers
		rts
	}

	Update: {
		jsr UpdateMixer
		jsr DrawTubes
		rts		
	}

	UpdateMixer: {
		// Hopper1:
		// .byte $00, $00, $00
		//check tube at pos2
		ldy #2
		lda Hopper1, y
		bne !check+

		//check tube at pos1
		ldy #1
		lda Hopper1, y
		beq !check+

		//1 found at pos 1 push middle tube to pos2
		lda #0
		sta Hopper1, y
		lda #1
		ldy #2
		sta Hopper1, y


		!check:

			ldy #1
			lda Hopper1, y
			bne !skip+

		
		ldy #0
		lda Hopper1, y
		beq !skip+
		//check middle isnt full
		//push top tube to pos1
		lda #0
		sta Hopper1, y
		lda #1
		ldy #1
		sta Hopper1, y

		!skip:
		rts
	}

	DrawTubes: {
		ldy #0
		lda Hopper1, y

		beq !remove+
		// Add Cement At 1
		ldx Tiles.Cements.Hopper1.PosX + 0
		ldy Tiles.Cements.Hopper1.PosY + 0
		jsr AddCementAtXY
		jmp !next+

	!remove: 
		ldx Tiles.Cements.Hopper1.PosX + 0
		ldy Tiles.Cements.Hopper1.PosY + 0
		jsr ClearCementAtXY
	
	!next:
		ldy #01
		lda Hopper1, y

		beq !remove+
		// Add Cement At 1
		ldx Tiles.Cements.Hopper1.PosX + 0
		ldy Tiles.Cements.Hopper1.PosY + 1
		jsr AddCementAtXY
		jmp !next+

	!remove: 
		ldx Tiles.Cements.Hopper1.PosX + 0
		ldy Tiles.Cements.Hopper1.PosY + 1
		jsr ClearCementAtXY

	!next:
		ldy #02
		lda Hopper1, y

		beq !remove+
		// Add Cement At 1
		ldx Tiles.Cements.Hopper1.PosX + 0
		ldy Tiles.Cements.Hopper1.PosY + 2
		jsr AddCementAtXY
		jmp !next+

	!remove: 
		ldx Tiles.Cements.Hopper1.PosX + 0
		ldy Tiles.Cements.Hopper1.PosY + 2
		jsr ClearCementAtXY	

	!next:
		rts
	}

	PourCement1: {
		lda Tiles.CEMENT_NEW_LEFT_1 + 0
		ldx Tiles.CEMENT_NEW_LEFT_1 + 1
		ldy Tiles.CEMENT_NEW_LEFT_1 + 2
		jsr MAPLOADER.SwitchCharAtXY

		lda Tiles.CEMENT_NEW_LEFT_2 + 0
		ldx Tiles.CEMENT_NEW_LEFT_2 + 1
		ldy Tiles.CEMENT_NEW_LEFT_2 + 2
		jsr MAPLOADER.SwitchCharAtXY
		rts
	}

	AddCement1: {
		//Clear Cement Pouring TopLeft
		lda Tiles.EMPTY + 0
		ldx Tiles.CEMENT_NEW_LEFT_1 + 1
		ldy Tiles.CEMENT_NEW_LEFT_1 + 2
		jsr MAPLOADER.SwitchCharAtXY

		lda Tiles.EMPTY + 0
		ldx Tiles.CEMENT_NEW_LEFT_2 + 1
		ldy Tiles.CEMENT_NEW_LEFT_2 + 2
		jsr MAPLOADER.SwitchCharAtXY
		
		//Add Cement to Hopper1
		lda #1
		ldy #0
		sta Hopper1, y

		jsr DrawTubes
		rts
	}

	AddCementAtXY: {
		.label leftXIndex = TEMP1
		.label leftYIndex = TEMP2
		stx leftXIndex
		sty leftYIndex

		lda Tiles.Cements.FRAMES + 0
		ldx leftXIndex
		ldy leftYIndex
		jsr MAPLOADER.SwitchCharAtXY

		lda Tiles.Cements.FRAMES + 1
		ldx leftXIndex
		inx
		ldy leftYIndex
		jsr MAPLOADER.SwitchCharAtXY

		lda Tiles.Cements.FRAMES + 2
		ldx leftXIndex
		inx
		inx
		ldy leftYIndex
		jsr MAPLOADER.SwitchCharAtXY

		rts
	}

	ClearCementAtXY: {
		.label leftXIndex = TEMP1
		.label leftYIndex = TEMP2
		stx leftXIndex
		sty leftYIndex

		lda Tiles.HOPPER_LEFT_EMPTY
		ldx leftXIndex
		ldy leftYIndex
		jsr MAPLOADER.SwitchCharAtXY

		lda Tiles.EMPTY
		ldx leftXIndex
		inx
		ldy leftYIndex
		jsr MAPLOADER.SwitchCharAtXY

		lda Tiles.HOPPER_RIGHT_EMPTY
		ldx leftXIndex
		inx
		inx
		ldy leftYIndex
		jsr MAPLOADER.SwitchCharAtXY

		rts
	}
	//Create a Clear Hopper by index (0,1,2,3) subroutine
	ClearMixers: {
		//1-2
		ldx Tiles.Cements.Hopper1.PosX + 0
		ldy Tiles.Cements.Hopper1.PosY + 0
		jsr ClearCementAtXY

		ldx Tiles.Cements.Hopper1.PosX + 0
		ldy Tiles.Cements.Hopper1.PosY + 1
		jsr ClearCementAtXY

		ldx Tiles.Cements.Hopper1.PosX + 0
		ldy Tiles.Cements.Hopper1.PosY + 2
		jsr ClearCementAtXY

		ldx Tiles.Cements.Hopper2.PosX + 0
		ldy Tiles.Cements.Hopper2.PosY + 0
		jsr ClearCementAtXY

		ldx Tiles.Cements.Hopper2.PosX + 0
		ldy Tiles.Cements.Hopper2.PosY + 1
		jsr ClearCementAtXY

		ldx Tiles.Cements.Hopper2.PosX + 0
		ldy Tiles.Cements.Hopper2.PosY + 2
		jsr ClearCementAtXY

		//3-4
		ldx Tiles.Cements.Hopper3.PosX + 0
		ldy Tiles.Cements.Hopper3.PosY + 0
		jsr ClearCementAtXY

		ldx Tiles.Cements.Hopper3.PosX + 0
		ldy Tiles.Cements.Hopper3.PosY + 1
		jsr ClearCementAtXY

		ldx Tiles.Cements.Hopper3.PosX + 0
		ldy Tiles.Cements.Hopper3.PosY + 2
		jsr ClearCementAtXY

		ldx Tiles.Cements.Hopper4.PosX + 0
		ldy Tiles.Cements.Hopper4.PosY + 0
		jsr ClearCementAtXY

		ldx Tiles.Cements.Hopper4.PosX + 0
		ldy Tiles.Cements.Hopper4.PosY + 1
		jsr ClearCementAtXY

		ldx Tiles.Cements.Hopper4.PosX + 0
		ldy Tiles.Cements.Hopper4.PosY + 2
		jsr ClearCementAtXY

		rts
	}

}