Mixers: {

	//left hand mixers
	//upper
	Hopper1:
			  //t  //m  //b 
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
			  //tl  bl  tr   br
		.byte $00, $00, $00, $00

	NumPoured1: .byte $00
	NumPoured2: .byte $00
	NumPoured3: .byte $00
	NumPoured4: .byte $00
	NumPoured5: .byte $00
	NumPoured6: .byte $00

	PourTick1: .byte $00
	PourTick2: .byte $00
	PourTick3: .byte $00
	PourTick4: .byte $00
	PourTick5: .byte $00
	PourTick6: .byte $00

	TwoStep1: .byte $00
	TwoStep2: .byte $00
	TwoStep3: .byte $00
	TwoStep4: .byte $00		

	OddEvenTick:
		.byte $00

	POUR_DELAY: //3 OR 6?
		.byte $04			

	
	Initialise: {
		lda #$00

		sta NumPoured1
		sta NumPoured2
		sta NumPoured3
		sta NumPoured4
		sta NumPoured5
		sta NumPoured6		

		sta PourTick1
		sta PourTick2
		sta PourTick3
		sta PourTick4
		sta PourTick5
		sta PourTick6

		sta TwoStep1
		sta TwoStep2
		sta TwoStep3
		sta TwoStep4

		jsr ClearMixers
		rts
	}

	PlayerDrop2: {
		lda #2
		tay
		lda Hopper1, y

		beq !return+
			lda #0
			jsr PouredCement.ShowSprite	

			//increase cements poured to mixer 2
			inc NumPoured2

			//Remove the Tube from Hopper 1
			ldy #2
			lda #0
			sta Hopper1, y

			jsr DrawTubes1
		!return:
		rts
	}

	PlayerDrop4: {
		lda #2
		tay
		lda Hopper3, y

		beq !return+
			//show the pouring cement
			lda #2
			jsr PouredCement.ShowSprite

			//increase the cements poured to mixer 4
			inc NumPoured4

			//clear the tube from hopper 3
			ldy #2
			lda #0
			sta Hopper3, y

			jsr DrawTubes3
		!return:
		rts
	}


	Update: {
		inc TwoStep1
		lda TwoStep1
		cmp #2
		bne !next+
			lda #0
			sta TwoStep1
			jsr Update1
		!next:
		inc TwoStep2
		lda TwoStep2
		cmp #2
		bne !next+
			lda #0
			sta TwoStep2
			jsr Update2
		!next:
		inc TwoStep3
		lda TwoStep3
		cmp #2
		bne !next+
			lda #0
			sta TwoStep3
			jsr Update3
		!next:		
		inc TwoStep4
		lda TwoStep4
		cmp #2
			bne !next+
			lda #0
			sta TwoStep4
			jsr Update4
		
		//Check if poured cement
		!next:	
		lda NumPoured1
		beq !next+
			inc PourTick1
			lda PourTick1
			cmp #3
			bne !next+
				lda #0
				sta PourTick1
				jsr AddCement1
				jsr DrawTubes1
		!next:
		lda NumPoured2
		beq !next+
			inc PourTick2
			lda PourTick2
			cmp #3
			bne !next+
				lda #0
				sta PourTick2
				jsr AddCement2
				jsr DrawTubes2
		!next: 
		lda NumPoured3
		beq !next+
			inc PourTick3
			lda PourTick3
			cmp #3
			bne !next+
				lda #0
				sta PourTick3
				jsr AddCement3
				jsr DrawTubes3
		!next:				
		lda NumPoured4
		beq !next+
			inc PourTick4
			lda PourTick4
			cmp #3
			bne !next+
				lda #0
				sta PourTick4
				jsr AddCement4
				jsr DrawTubes4
		!next:
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
		lda Hopper2, y

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
		lda Hopper2, y

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
		lda Hopper4, y

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
		lda Hopper4, y

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
		lda Hopper4, y

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

	PourCement1: {
		inc NumPoured1

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


	PourCement3: {
		lda #1
		ldy #2
		sta CementsPoured, y

		inc NumPoured3

		//start pour timer
		// lda #1
		// sta CementPourTimer3 + 0
		// lda CementPourTimer3 + 2
		// sta CementPourTimer3 + 1

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

	//Public: Add Cement to a Hopper at index

	AddCement1: {
		//remove NumPoured count
		dec NumPoured1


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

		//jsr DrawTubes1
		rts
	}

	AddCement2: {
		//remove cement from poured cements
		dec NumPoured2
		lda NumPoured2
		bne !skip+
			jsr PouredCement.HideSprite
		!skip:
		lda #1
		ldy #0
		sta Hopper2, y
		
		jsr DrawTubes2

		rts
	}


	AddCement3: {
		//remove cement from poured cements
		dec NumPoured3

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

		//jsr DrawTubes3
		rts
	}

	AddCement4: {
		//remove 1 from poured cement stack
		dec NumPoured4
		lda NumPoured4
		bne !skip+
			jsr PouredCement.HideSprite
		!skip:

		//Add a Tube to next Hopper
		lda #1
		ldy #0
		sta Hopper4, y

		jsr DrawTubes4

		//!return:
		rts
	}

	//Privates:
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