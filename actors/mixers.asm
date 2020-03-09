Mixers: {

	//left hand mixers
	//upper
	Hopper1:
		.byte $00, $00, $00

	//lower
	Hopper2:
		.byte $00, $00, $00

	//right hand mixers
	//upper 
	Hopper3:
		.byte $00, $00, $00

	//lower	
	Hopper4:
		.byte $00, $00, $00

	CementsPoured:
		.byte $00, $00, $00, $00

	OddEvenTick:
		.byte $00				

	
	Initialise: {
		lda #$00
		ldy #$00
		sta CementsPoured, y
		sta OddEvenTick

		iny 
		sta CementsPoured, y

		iny 
		sta CementsPoured, y

		iny 
		sta CementsPoured, y


		jsr ClearMixers
		rts
	}

	CheckMixerDrop1: {
		lda #2
		tay
		lda Hopper1, y

		beq !return+

			//@todo pour cement from Mixer 1 to Mixer 3 (Left Mixers)
			//inc $d020

		!return:
		rts
	}


	Update: {
		
		// inc OddEvenTick
		// lda OddEvenTick
		// and #$01
		// beq !alternate+
		// // 	//inc $d020 //change border colour
		//  	jsr Update1
		// !alternate:
		//Check pouring
		//Top Mixers
		//check 1 pour
		
		ldy #0
		lda CementsPoured, y
		beq !next+
			clc
			adc #1
			sta CementsPoured, y
			cmp #6
			bne !next+
				jsr AddCement1
			
		!next:
		//check 3 pour


		//lower Mixers
		//check 2 pour


		//check 4 pour

		!return:
		rts

	}


	Update1: {
		jsr UpdateMixer1
		jsr DrawTubes1
		rts		
	}

	Update2: {
		jsr UpdateMixer2
		jsr DrawTubes2
		rts		
	}

	Update3: {
		jsr UpdateMixer3
		jsr DrawTubes3
		rts		
	}

	Update4: {
		jsr UpdateMixer4
		jsr DrawTubes4
		rts		
	}


	//todo: Refactor this to be a single UpdateMixer
	UpdateMixer1: {
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


	//todo: Refactor this to be dynamic
	UpdateMixer3: {
		// Hopper1:
		// .byte $00, $00, $00
		//check tube at pos2
		ldy #2
		lda Hopper3, y
		bne !check+

		//check tube at pos1
		ldy #1
		lda Hopper3, y
		beq !check+

		//1 found at pos 1 push middle tube to pos2
		lda #0
		sta Hopper3, y
		lda #1
		ldy #2
		sta Hopper3, y

		!check:

			ldy #1
			lda Hopper3, y
			bne !skip+

		ldy #0
		lda Hopper3, y
		beq !skip+
		//check middle isnt full
		//push top tube to pos1
		lda #0
		sta Hopper3, y
		lda #1
		ldy #1
		sta Hopper3, y

		!skip:
		rts
	}



	//todo: Refactor this to be a single UpdateMixer
	UpdateMixer2: {
		// Hopper1:
		// .byte $00, $00, $00
		//check tube at pos2
		ldy #2
		lda Hopper2, y
		bne !check+

		//check tube at pos1
		ldy #1
		lda Hopper2, y
		beq !check+

		//1 found at pos 1 push middle tube to pos2
		lda #0
		sta Hopper2, y
		lda #1
		ldy #2
		sta Hopper2, y

		!check:

			ldy #1
			lda Hopper2, y
			bne !skip+

		ldy #0
		lda Hopper2, y
		beq !skip+
		//check middle isnt full
		//push top tube to pos1
		lda #0
		sta Hopper2, y
		lda #1
		ldy #1
		sta Hopper2, y

		!skip:
		rts
	}


	//todo: Refactor this to be dynamic
	UpdateMixer4: {
		// Hopper1:
		// .byte $00, $00, $00
		//check tube at pos2
		ldy #2
		lda Hopper4, y
		bne !check+

		//check tube at pos1
		ldy #1
		lda Hopper4, y
		beq !check+

		//1 found at pos 1 push middle tube to pos2
		lda #0
		sta Hopper4, y
		lda #1
		ldy #2
		sta Hopper4, y

		!check:

			ldy #1
			lda Hopper4, y
			bne !skip+

		ldy #0
		lda Hopper4, y
		beq !skip+
		//check middle isnt full
		//push top tube to pos1
		lda #0
		sta Hopper4, y
		lda #1
		ldy #1
		sta Hopper4, y

		!skip:
		rts
	}

	/**
	* @todo Refactor
	* Draw TUBES In Mixers 1 , 3
	*/
	DrawTubes1: {
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

	DrawTubes3: {
		ldy #0
		lda Hopper3, y

		beq !remove+
		// Add Cement At 1
		ldx Tiles.Cements.Hopper3.PosX + 0
		ldy Tiles.Cements.Hopper3.PosY + 0
		jsr AddCementAtXY
		jmp !next+

	!remove: 
		ldx Tiles.Cements.Hopper3.PosX + 0
		ldy Tiles.Cements.Hopper3.PosY + 0
		jsr ClearCementAtXY
	
	!next:
		ldy #01
		lda Hopper3, y

		beq !remove+
		// Add Cement At 1
		ldx Tiles.Cements.Hopper3.PosX + 0
		ldy Tiles.Cements.Hopper3.PosY + 1
		jsr AddCementAtXY
		jmp !next+

	!remove: 
		ldx Tiles.Cements.Hopper3.PosX + 0
		ldy Tiles.Cements.Hopper3.PosY + 1
		jsr ClearCementAtXY

	!next:
		ldy #02
		lda Hopper3, y

		beq !remove+
		// Add Cement At 1
		ldx Tiles.Cements.Hopper3.PosX + 0
		ldy Tiles.Cements.Hopper3.PosY + 2
		jsr AddCementAtXY
		jmp !next+

	!remove: 
		ldx Tiles.Cements.Hopper3.PosX + 0
		ldy Tiles.Cements.Hopper3.PosY + 2
		jsr ClearCementAtXY	

	!next:
		rts
	}



	/**
	* @todo Refactor
	* Draw TUBES In Mixers 2 , 4
	*/
	DrawTubes2: {
		ldy #0
		lda Hopper2, y

		beq !remove+
		// Add Cement At 1
		ldx Tiles.Cements.Hopper2.PosX + 0
		ldy Tiles.Cements.Hopper2.PosY + 0
		jsr AddCementAtXY
		jmp !next+

	!remove: 
		ldx Tiles.Cements.Hopper2.PosX + 0
		ldy Tiles.Cements.Hopper2.PosY + 0
		jsr ClearCementAtXY
	
	!next:
		ldy #01
		lda Hopper1, y

		beq !remove+
		// Add Cement At 1
		ldx Tiles.Cements.Hopper2.PosX + 0
		ldy Tiles.Cements.Hopper2.PosY + 1
		jsr AddCementAtXY
		jmp !next+

	!remove: 
		ldx Tiles.Cements.Hopper2.PosX + 0
		ldy Tiles.Cements.Hopper2.PosY + 1
		jsr ClearCementAtXY

	!next:
		ldy #02
		lda Hopper1, y

		beq !remove+
		// Add Cement At 1
		ldx Tiles.Cements.Hopper2.PosX + 0
		ldy Tiles.Cements.Hopper2.PosY + 2
		jsr AddCementAtXY
		jmp !next+

	!remove: 
		ldx Tiles.Cements.Hopper2.PosX + 0
		ldy Tiles.Cements.Hopper2.PosY + 2
		jsr ClearCementAtXY	

	!next:
		rts
	}

	DrawTubes4: {
		ldy #0
		lda Hopper3, y

		beq !remove+
		// Add Cement At 1
		ldx Tiles.Cements.Hopper4.PosX + 0
		ldy Tiles.Cements.Hopper4.PosY + 0
		jsr AddCementAtXY
		jmp !next+

	!remove: 
		ldx Tiles.Cements.Hopper4.PosX + 0
		ldy Tiles.Cements.Hopper4.PosY + 0
		jsr ClearCementAtXY
	
	!next:
		ldy #01
		lda Hopper3, y

		beq !remove+
		// Add Cement At 1
		ldx Tiles.Cements.Hopper4.PosX + 0
		ldy Tiles.Cements.Hopper4.PosY + 1
		jsr AddCementAtXY
		jmp !next+

	!remove: 
		ldx Tiles.Cements.Hopper4.PosX + 0
		ldy Tiles.Cements.Hopper4.PosY + 1
		jsr ClearCementAtXY

	!next:
		ldy #02
		lda Hopper3, y

		beq !remove+
		// Add Cement At 1
		ldx Tiles.Cements.Hopper4.PosX + 0
		ldy Tiles.Cements.Hopper4.PosY + 2
		jsr AddCementAtXY
		jmp !next+

	!remove: 
		ldx Tiles.Cements.Hopper4.PosX + 0
		ldy Tiles.Cements.Hopper4.PosY + 2
		jsr ClearCementAtXY	

	!next:
		rts
	}




	PourCement3: {
		lda Tiles.CEMENT_NEW_RIGHT_1 + 0
		ldx Tiles.CEMENT_NEW_RIGHT_1 + 1
		ldy Tiles.CEMENT_NEW_RIGHT_1 + 2
		jsr MAPLOADER.SwitchCharAtXY

		lda Tiles.CEMENT_NEW_RIGHT_2 + 0
		ldx Tiles.CEMENT_NEW_RIGHT_2 + 1
		ldy Tiles.CEMENT_NEW_RIGHT_2 + 2
		jsr MAPLOADER.SwitchCharAtXY
		rts
	}

	AddCement3: {
		//Clear Cement Pouring TopRight
		lda Tiles.EMPTY + 0
		ldx Tiles.CEMENT_NEW_RIGHT_1 + 1
		ldy Tiles.CEMENT_NEW_RIGHT_1 + 2
		jsr MAPLOADER.SwitchCharAtXY

		lda Tiles.EMPTY + 0
		ldx Tiles.CEMENT_NEW_RIGHT_2 + 1
		ldy Tiles.CEMENT_NEW_RIGHT_2 + 2
		jsr MAPLOADER.SwitchCharAtXY
		
		//Add Cement to Hopper1
		lda #1
		ldy #0
		sta Hopper3, y

		jsr DrawTubes3
		rts
	}

	PourCement1: {
		//add pour flag at 0
		lda #1
		ldy #0
		sta CementsPoured, y

		//render the two poured cement chars
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
		//clear the pour flag
		lda #0
		ldy #0
		sta CementsPoured, y
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

		jsr DrawTubes1
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