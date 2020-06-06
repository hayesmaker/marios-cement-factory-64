Crates: {
	PosY:
		.byte 85

	//@deprecated
	FramesTable1:
		.byte $40, $40, $40

	//Full / Empty Crate Frames
	FullCrate:
		.byte $40
	EmptyCrate:
		.byte $58
	CurrentCrate1:
		.byte EmptyCrate
	CurrentCrate2:
		.byte EmptyCrate
	OpenCrateFull:
		.byte $56, $57, $58
	OpenCrateEmpty:
		.byte $58, $57, $58			 			
	
	PositionsTableIndex1:
		.byte 0	
	PositionsTable1_LB:
		.byte $78, $5D, $49
	PositionsTable1_HB:	
		.byte $00, $00, $00

	.label OPEN_CRATE_POS = 2
	OpenCrateIndex1:
		.byte 0
	OpenCrateFrames:
		.byte $56, $57, $58
	OpenCrateIndex2:
		.byte 0
	
	//@deprecated
	FramesTable2:
		.byte $40, $40, $40		
	PositionsTableIndex2:
		.byte 0
	PositionsTable2_LB:            
		.byte $E0, $FB, $10
	PositionsTable2_HB:
		.byte $00, $00, $01

	shouldFill:
		.byte $00	

		// TODO: Decide to use this or make labels to specifc indexes for actions?
		// ActionsTable:
		// .byte $00, $00, $00, $01, $02, $00		

	Initialise: {
		lda #$00
		sta VIC.SPRITE_COLOR_1
		sta VIC.SPRITE_COLOR_2
		sta shouldFill

		lda EmptyCrate
		sta CurrentCrate1
		sta CurrentCrate2

		lda #$40
		sta Game.SPRITE_POINTERS + 1
		sta Game.SPRITE_POINTERS + 2

		lda VIC.SPRITE_ENABLE 
		ora #%00000010
		sta VIC.SPRITE_ENABLE

		lda VIC.SPRITE_ENABLE 
		ora #%00000100
		sta VIC.SPRITE_ENABLE

		lda #$00
		sta VIC.SPRITE_MULTICOLOR

		ldx #0
		stx OpenCrateIndex1
		stx OpenCrateIndex2
		stx PositionsTableIndex1
		stx PositionsTableIndex2	
		rts
	}

	DrawSprite1: {
        //crate 1 = sprite 1
        //crate 2 = sprite 2
        ldy PositionsTableIndex1
        bne !skip+
        	jsr ShowOffScreenCement1
        	jmp !getXPos+
        !skip:
        	jsr HideOffScreenCement1
        !getXPos:
        ldy PositionsTableIndex1
        lda PositionsTable1_LB, y
        
        // !showSprite:
        sta VIC.SPRITE_1_X
        lda VIC.SPRITE_MSB
        and #%11111101
        sta VIC.SPRITE_MSB

       	ldy PositionsTableIndex1
        lda PositionsTable1_HB, y
        beq !+
	        lda VIC.SPRITE_MSB
	        ora #%00000010
	        sta VIC.SPRITE_MSB
    	!:
        lda PosY
        sta VIC.SPRITE_1_Y

    	//Dont do this if pouring cement?...
    	//...we dont call draw after frame is drawn for pouring so this should be ok
        //Crate1 Do Frames
        
        lda CurrentCrate1
        sta Game.SPRITE_POINTERS + 1

        rts
    }

    DrawSprite2: {
		ldy PositionsTableIndex2
        bne !skip+
        	jsr ShowOffScreenCement2
        	jmp !getXPos+
        !skip:
        	jsr HideOffScreenCement2
        !getXPos:
        ldy PositionsTableIndex2
        lda PositionsTable2_LB, y
        
        // !showSprite:
        sta VIC.SPRITE_2_X
        lda VIC.SPRITE_MSB
        and #%11111011
        sta VIC.SPRITE_MSB

       	ldy PositionsTableIndex2
        lda PositionsTable2_HB, y
        beq !+
	        lda VIC.SPRITE_MSB
	        ora #%00000100
	        sta VIC.SPRITE_MSB
    	!:
        lda PosY
        sta VIC.SPRITE_2_Y

    	//Dont do this if pouring cement?...
    	//...we dont call draw after frame is drawn for pouring so this should be ok
        //Crate2 Set Sprite Frame
       	lda CurrentCrate2
        sta Game.SPRITE_POINTERS + 2

		rts
	}

    OpenCrateDoor1: {
    	lda Tiles.CRATE_DOOR_1 + 0
    	ldx Tiles.CRATE_DOOR_1 + 1
    	ldy Tiles.CRATE_DOOR_1 + 2
    	jsr Map.SwitchCharAtXY
    	rts
    }

    CloseCrateDoor1: {
    	lda Tiles.EMPTY
    	ldx Tiles.CRATE_DOOR_1 + 1
    	ldy Tiles.CRATE_DOOR_1 + 2
    	jsr Map.SwitchCharAtXY
    	rts
    }


    OpenCrateDoor2: {
    	lda Tiles.CRATE_DOOR_2 + 0
    	ldx Tiles.CRATE_DOOR_2 + 1
    	ldy Tiles.CRATE_DOOR_2 + 2
    	jsr Map.SwitchCharAtXY
    	rts
    }

    CloseCrateDoor2: {
    	lda Tiles.EMPTY
    	ldx Tiles.CRATE_DOOR_2 + 1
    	ldy Tiles.CRATE_DOOR_2 + 2
    	jsr Map.SwitchCharAtXY
    	rts
    }

    ShowOffScreenCement1: {
    	lda #$B2
    	ldx #5
    	ldy #5
    	jsr Map.SwitchCharAtXY

    	lda #$B3
    	ldx #5
    	ldy #6
    	jsr Map.SwitchCharAtXY

    	rts
    }

    HideOffScreenCement1: {

    	lda Tiles.EMPTY
    	ldx #5
    	ldy #5
    	jsr Map.SwitchCharAtXY

    	lda Tiles.EMPTY
    	ldx #5
    	ldy #6
    	jsr Map.SwitchCharAtXY

    	rts
    }

    ShowOffScreenCement2: {
    	lda #$BA
    	ldx #34
    	ldy #5
    	jsr Map.SwitchCharAtXY

    	lda #$BB
    	ldx #34
    	ldy #6
    	jsr Map.SwitchCharAtXY

    	rts
    }

    HideOffScreenCement2: {
    	lda Tiles.EMPTY
    	ldx #34
    	ldy #5
    	jsr Map.SwitchCharAtXY

    	lda Tiles.EMPTY
    	ldx #34
    	ldy #6
    	jsr Map.SwitchCharAtXY

    	rts
    }


	Update1: {
		lda PLAYER.IsPlayerDead
    	bne !return+
		ldx PositionsTableIndex1
		inx
		stx PositionsTableIndex1
		//check if at max position index and reset to 0 if necessary
		cpx #3 //todo Create label
		bne !skip+
			ldx #0
			stx PositionsTableIndex1
			jsr checkFill
			lda shouldFill
			bne !isFull+
				lda EmptyCrate
				jmp !setCrate+
			!isFull:
				lda #0
				sta shouldFill
				lda FullCrate
			!setCrate:
				sta CurrentCrate1
			//stx noRefillCement1
		!skip:
		//Crate1 Updates	
		// jsr CheckIsOpen1
		// jsr CheckPourCement1

		jsr CheckCrateOpenTimeout1

		// lda noRefillCement1
		// bne !return+
			//inc $d020
		jsr DrawSprite1
		!return:
		rts
	}

	Update2: {
		lda PLAYER.IsPlayerDead
    	bne !return+
		ldx PositionsTableIndex2
		inx
		stx PositionsTableIndex2
		//check if at max position index and reset to 0 if necessary
		cpx #3 //todo Create label
		bne !skip+
			ldx #0
			stx PositionsTableIndex2
			jsr checkFill
			lda shouldFill
			bne !isFull+
				lda EmptyCrate
				jmp !setCrate+
			!isFull:
				lda #0
				sta shouldFill
				lda FullCrate
			!setCrate:
				sta CurrentCrate2
		!skip:
		//Crate1 Updates	
		jsr CheckCrateOpenTimeout2
		jsr DrawSprite2
		!return:
		rts
	}

	
	CheckCrateOpenTimeout1: {
		lda PositionsTableIndex1
		cmp #OPEN_CRATE_POS
		bne !return+
			//Start open crate timer
			//CratePourTimer:			.byte 0, 10, 10
			lda #1
			sta Game.CratePourTimer1 + 0
			lda Game.CratePourTimer1 + 2
			sta Game.CratePourTimer1 + 1
		!return:
		rts
	}

	CheckCrateOpenTimeout2: {
		lda PositionsTableIndex2
		cmp #OPEN_CRATE_POS
		bne !return+
			//Start open crate timer
			//CratePourTimer:			.byte 0, 10, 10
			lda #1
			sta Game.CratePourTimer2 + 0
			lda Game.CratePourTimer2 + 2
			sta Game.CratePourTimer2 + 1
		!return:
		rts
	}

	pourInterval1: {
  		ldy OpenCrateIndex1
  		lda CurrentCrate1
  		cmp FullCrate
  		bne !isEmpty+
  			lda OpenCrateFull,y
  			jmp !setFrame+
  		!isEmpty:
  			lda OpenCrateEmpty,y
  		!setFrame:
  		sta Game.SPRITE_POINTERS + 1

		ldy OpenCrateIndex1
		bne !skip+
			//First Open state
			jsr OpenCrateDoor1
			jmp !setInterval+
		!skip:
		cpy #1
		bne !skip+
			lda CurrentCrate1
			cmp FullCrate
			bne !doOpen+
				jsr Mixers.PourCement1
			!doOpen:
			jmp !setInterval+
		!skip:
		cpy #2
		bne !skip+
			//End Timer
			jsr CloseCrateDoor1
			lda #0
			sta OpenCrateIndex1
			sta Game.CratePourTimer1 + 0
			lda Game.CratePourTimer1 + 2
			sta Game.CratePourTimer1 + 1
			jmp !return+
		!skip:
		!setInterval:
		inc OpenCrateIndex1
		lda Game.CratePourTimer1 + 2
		sta Game.CratePourTimer1 + 1

		!return:
		rts
	}

	pourInterval2: {
  		ldy OpenCrateIndex2
  		lda CurrentCrate2
  		cmp FullCrate
  		bne !isEmpty+
  			lda OpenCrateFull,y
  			jmp !setFrame+
  		!isEmpty:
  			lda OpenCrateEmpty,y
  		!setFrame:
  		sta Game.SPRITE_POINTERS + 2

		ldy OpenCrateIndex2
		bne !skip+
			//First Open state
			jsr OpenCrateDoor2
			jmp !setInterval+
		!skip:
		cpy #1
		bne !skip+
			lda CurrentCrate2
			cmp FullCrate
			bne !doOpen+
				jsr Mixers.PourCement3
			!doOpen:
			jmp !setInterval+
		!skip:
		cpy #2
		bne !skip+
			//End Timer
			jsr CloseCrateDoor2
			lda #0
			sta OpenCrateIndex2
			sta Game.CratePourTimer2 + 0
			lda Game.CratePourTimer2 + 2
			sta Game.CratePourTimer2 + 1
			jmp !return+
		!skip:
		!setInterval:
		inc OpenCrateIndex2
		lda Game.CratePourTimer2 + 2
		sta Game.CratePourTimer2 + 1

		!return:
		rts
	}

	checkFill:{
		jsr Game.Random
		cmp #150
		bcc !doFill+
		jmp !return+
		!doFill:
			lda #1
			sta shouldFill
			//inc $d020
		!return:
		rts
	}
}