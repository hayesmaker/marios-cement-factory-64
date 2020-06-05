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
	//todo do i need these
	// TwoStep5: .byte $00
	// TwoStep6: .byte $00


	
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

		//Clear Mixer Data
		lda #0
		ldy #2
		!loop:
			lda #0
			sta Hopper1, y
			sta Hopper2, y
			sta Hopper3, y
			sta Hopper4, y
			dey
			bpl !loop-
		//Clear Mixer graphics
		jsr ClearMixers
		rts
	}

	checkFullMixers: {
		.label TOP_COUNT_1 = TEMP12
		.label TOP_COUNT_2 = TEMP13
		lda #0
		sta TOP_COUNT_1
		lda #0
		sta TOP_COUNT_2

		ldx #0
		!loop:											
			lda Hopper1, x           //0(1) 1(2) 2(3)
			beq !skip+
				inc TOP_COUNT_1
			!skip:
			lda Hopper3, x
			beq !skip+
				inc TOP_COUNT_2
			!skip:
			cpx #2
			beq !break+
			inx
			jmp !loop-
		!break:

		lda TOP_COUNT_1
		cmp #3
		beq !alarmOn+
		lda TOP_COUNT_2
		cmp #3
		beq !alarmOn+
			lda #0
			sta Game.AlarmTimer + 0
			jmp !return+
		!alarmOn:
			lda Game.AlarmTimer + 0
			bne !return+
				lda #1
				sta Game.AlarmTimer + 0
				lda Game.AlarmTimer + 2
				sta Game.AlarmTimer + 1
		!return:
			//@returns a (0 off, 1 on)
		rts
	}

	Update: {
		lda PLAYER.IsPlayerDead
    	beq !skip+
    		jmp !return+
    	!skip:

    	//Check if any top mixers are full and play alarm
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
			//increase number to change pour delay
			cmp #3
			bne !next+
				lda #0
				sta PourTick1
				sta TwoStep1

				//@todo use 1 condition instead of 3
				ldy #0
				lda Hopper1, y
				beq !skip+
					ldy #1
					lda Hopper1,y
					beq !skip+
						ldy #2
						lda Hopper1,y
						beq !skip+							
							//do cement crash
							lda #0
							sta NumPoured1							
							lda #1
							sta PouredCement.HopperIndex
							jsr PouredCement.SpillCement
							
							jmp !draw+
				!skip:
				jsr AddCement1
				!draw:
				jsr DrawTubes1
		!next:
		lda NumPoured2
		beq !next+
			inc PourTick2
			lda PourTick2
			//increase number to change pour delay
			cmp #3
			bne !next+
				lda #0
				sta PourTick2
				sta TwoStep2

				ldy #0
				lda Hopper2, y
				beq !skip+
					ldy #1
					lda Hopper2,y
					beq !skip+
						ldy #2
						lda Hopper2,y
						beq !skip+
							//do cement crash
							lda #0
							sta NumPoured2
							lda #2
							sta PouredCement.HopperIndex
							jsr PouredCement.SpillCement
							
							jmp !draw+
				!skip:
				jsr AddCement2
				!draw:
				jsr DrawTubes2
		!next: 
		lda NumPoured3
		beq !next+
			inc PourTick3
			lda PourTick3
			//increase number to change pour delay
			cmp #3
			bne !next+
				lda #0
				sta PourTick3
				sta TwoStep3

				ldy #0
				lda Hopper3, y
				beq !skip+
					ldy #1
					lda Hopper3,y
					beq !skip+
						ldy #2
						lda Hopper3,y
						beq !skip+
							//do cement crash
							lda #0
							sta NumPoured3
							lda #3
							sta PouredCement.HopperIndex
							jsr PouredCement.SpillCement
							
							jmp !draw+
				!skip:
				jsr AddCement3
				!draw:
				jsr DrawTubes3
		!next:				
		lda NumPoured4
		beq !next+
			inc PourTick4
			lda PourTick4
			//increase number to change pour delay
			cmp #3
			bne !next+
				lda #0
				sta PourTick4
				sta TwoStep4

				ldy #0
				lda Hopper4, y
				beq !skip+
					ldy #1
					lda Hopper4,y
					beq !skip+
						ldy #2
						lda Hopper4,y
						beq !skip+							
							//do cement crash
							lda #0
							sta NumPoured4
							lda #4
							sta PouredCement.HopperIndex
							jsr PouredCement.SpillCement

							jmp !draw+
				!skip:
				jsr AddCement4
				!draw:
				jsr DrawTubes4
		!next:
		lda NumPoured5
		beq !next+
			inc PourTick5
			lda PourTick5
			//increase number to change pour delay
			cmp #3
			bne !next+
				lda #0
				sta PourTick5
				jsr AddCement5
		!next:
		lda NumPoured6
		beq !next+
			inc PourTick6
			lda PourTick6
			//increase number to change pour delay
			cmp #3
			bne !next+
				lda #0
				sta PourTick6
				jsr AddCement6
		!next:
		!return:
		rts

	}


	Update1: {
		lda PLAYER.IsPlayerDead
		bne !skip+
		jsr UpdateMixer1
		!skip:
		jsr DrawTubes1
		rts		
	}

	Update2: {
		lda PLAYER.IsPlayerDead
		bne !skip+
		jsr UpdateMixer2
		!skip:
		jsr DrawTubes2
		rts		
	}

	Update3: {
		lda PLAYER.IsPlayerDead
		bne !skip+
		jsr UpdateMixer3
		!skip:
		jsr DrawTubes3
		rts		
	}

	Update4: {
		lda PLAYER.IsPlayerDead
		bne !skip+
		jsr UpdateMixer4
		!skip:
		jsr DrawTubes4
		rts		
	}

	ClearTopMixers: {
		jsr ClearTopLeft
		jsr ClearTopRight
		jsr DrawTubes1
		jsr DrawTubes3
		rts
	}

	ClearTopLeft: {
		ldy #0
		lda #0
		sta Hopper1, y

		ldy #1
		lda #0
		sta Hopper1, y

		ldy #2
		lda #0
		sta Hopper1, y
		rts
	}

	ClearTopRight: {
		ldy #0
		lda #0
		sta Hopper3, y

		ldy #1
		lda #0
		sta Hopper3, y

		ldy #2
		lda #0
		sta Hopper3, y
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

	ClearPouredCementsTop: {
		lda #0
		sta NumPoured1
		sta NumPoured3
		sta NumPoured2
		sta NumPoured4

		lda #0
		jsr PouredCement.HideSprite
		lda #2
		jsr PouredCement.HideSprite

		lda Tiles.EMPTY + 0
		ldx Tiles.CEMENT_NEW_LEFT_1 + 1
		ldy Tiles.CEMENT_NEW_LEFT_1 + 2
		jsr Map.SwitchCharAtXY

		lda Tiles.EMPTY + 0
		ldx Tiles.CEMENT_NEW_LEFT_2 + 1
		ldy Tiles.CEMENT_NEW_LEFT_2 + 2
		jsr Map.SwitchCharAtXY

		lda Tiles.EMPTY + 0
		ldx Tiles.CEMENT_NEW_RIGHT_1 + 1
		ldy Tiles.CEMENT_NEW_RIGHT_1 + 2
		jsr Map.SwitchCharAtXY

		lda Tiles.EMPTY + 0
		ldx Tiles.CEMENT_NEW_RIGHT_2 + 1
		ldy Tiles.CEMENT_NEW_RIGHT_2 + 2
		jsr Map.SwitchCharAtXY

		rts
	}

	// Poured Cement initiated by Cement Crates
	PourCement1: {
		inc NumPoured1

		//render the two poured cement chars
		lda Tiles.CEMENT_NEW_LEFT_1 + 0
		ldx Tiles.CEMENT_NEW_LEFT_1 + 1
		ldy Tiles.CEMENT_NEW_LEFT_1 + 2
		jsr Map.SwitchCharAtXY

		lda Tiles.CEMENT_NEW_LEFT_2 + 0
		ldx Tiles.CEMENT_NEW_LEFT_2 + 1
		ldy Tiles.CEMENT_NEW_LEFT_2 + 2
		jsr Map.SwitchCharAtXY
		rts
	}

	// Poured Cement initiated by Cement Crates
	PourCement3: {
		inc NumPoured3

		lda Tiles.CEMENT_NEW_RIGHT_1 + 0
		ldx Tiles.CEMENT_NEW_RIGHT_1 + 1
		ldy Tiles.CEMENT_NEW_RIGHT_1 + 2
		jsr Map.SwitchCharAtXY

		lda Tiles.CEMENT_NEW_RIGHT_2 + 0
		ldx Tiles.CEMENT_NEW_RIGHT_2 + 1
		ldy Tiles.CEMENT_NEW_RIGHT_2 + 2
		jsr Map.SwitchCharAtXY
		rts
	}

	//PouredCement initiated by Player
	PlayerDrop2: {
		ldy #2
		lda Hopper1, y

		beq !return+
			jsr Score.onUpperMixer

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
		ldy #2
		lda Hopper3, y

		beq !return+
			jsr Score.onUpperMixer
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


	//PouredCement initiated by Player
	PlayerDrop5: {
		ldy#2
		lda Hopper2, y

		beq !return+
			jsr Score.onLowerMixer
			//show poured cement at position 1
			lda #1
			jsr PouredCement.ShowSprite	

			//increase cements poured to mixer 2
			inc NumPoured5

			//Remove the Tube from Hopper 2
			ldy #2
			lda #0
			sta Hopper2, y

			jsr DrawTubes2
		!return:
		rts
	}

	// 1   2
	// 3   4
	// 5   6
	//PouredCement initiated by Player
	PlayerDrop6: {
		//check if tube is in the hopper
		ldy#2
		lda Hopper4, y

		beq !return+
			jsr Score.onLowerMixer
			//show poured cement at position 1
			lda #3
			jsr PouredCement.ShowSprite	

			//increase cements poured to truck
			inc NumPoured6

			//Remove the Tube from Hopper 2
			ldy #2
			lda #0
			sta Hopper4, y

			jsr DrawTubes4
		!return:
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
		jsr Map.SwitchCharAtXY

		lda Tiles.EMPTY + 0
		ldx Tiles.CEMENT_NEW_LEFT_2 + 1
		ldy Tiles.CEMENT_NEW_LEFT_2 + 2
		jsr Map.SwitchCharAtXY
		
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
			lda #0
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
		jsr Map.SwitchCharAtXY

		lda Tiles.EMPTY + 0
		ldx Tiles.CEMENT_NEW_RIGHT_2 + 1
		ldy Tiles.CEMENT_NEW_RIGHT_2 + 2
		jsr Map.SwitchCharAtXY
		
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
			lda #2
			jsr PouredCement.HideSprite
		!skip:

		//Add a Tube to next Hopper
		lda #1
		ldy #0
		sta Hopper4, y

		jsr DrawTubes4
		rts
	}

	AddCement5: {		
		dec NumPoured5
		lda NumPoured5
		bne !skip+
			lda #1
			jsr PouredCement.HideSprite
		!skip:
		rts
	}

	AddCement6: {
		dec NumPoured6
		lda NumPoured6
		bne !skip+
			lda #3
			jsr PouredCement.HideSprite
		!skip:
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
		jsr Map.SwitchCharAtXY

		lda Tiles.Cements.FRAMES + 1
		ldx leftXIndex
		inx
		ldy leftYIndex
		jsr Map.SwitchCharAtXY

		lda Tiles.Cements.FRAMES + 2
		ldx leftXIndex
		inx
		inx
		ldy leftYIndex
		jsr Map.SwitchCharAtXY

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
		jsr Map.SwitchCharAtXY

		lda Tiles.EMPTY
		ldx leftXIndex
		inx
		ldy leftYIndex
		jsr Map.SwitchCharAtXY

		lda Tiles.HOPPER_RIGHT_EMPTY
		ldx leftXIndex
		inx
		inx
		ldy leftYIndex
		jsr Map.SwitchCharAtXY

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