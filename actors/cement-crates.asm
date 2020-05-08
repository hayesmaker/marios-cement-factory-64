CRATES: {
	PosY:
		.byte 85

	FramesTable1:
		.byte $40, $40, $40, $56, $57, $58, $59
	FramesTable2:
		.byte $40, $40, $40, $56, $57, $58, $5A
	PositionsTableIndex1:
		.byte 0	
	PositionsTable1_LB:
			  //120//93 //73
		.byte $78, $5D, $49, $49, $49, $49
	PositionsTable1_HB:	
		.byte $00, $00, $00, $00, $00, $00
			
	PositionsTableIndex2:
		.byte 0
	PositionsTable2_LB: //271              
		.byte $E0, $FB, $10, $10, $10, $10
	PositionsTable2_HB:
		.byte $00, $00, $01, $01, $01, $01

		// TODO: Decide to use this or make labels to specifc indexes for actions?
		// ActionsTable:
		// .byte $00, $00, $00, $01, $02, $00		

	Initialise: {
		lda #$00
		sta VIC.SPRITE_COLOR_1
		sta VIC.SPRITE_COLOR_2

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
		stx PositionsTableIndex1
		stx PositionsTableIndex2	
		rts
	}

	DrawSprite: {
        // crate 1 pos x
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
        // bne !showSprite+
        // 	//hide hte 
        // 	lda VIC.SPRITE_ENABLE
        // 	and #%11111101
        // 	sta VIC.SPRITE_ENABLE
        // 	jmp !crate2+
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
        sta VIC.SPRITE_2_Y

        !crate2:
        //crate 2 pos x
        ldy PositionsTableIndex2
        bne !skip+
        	jsr ShowOffScreenCement2
        	jmp !getXPos+
        !skip:
        	jsr HideOffScreenCement2
        !getXPos:
        ldy PositionsTableIndex2
        lda PositionsTable2_LB, y
        sta VIC.SPRITE_2_X
        //crate 2 high bite
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
        //Crate1
        lda PositionsTableIndex1
        tay
        lda FramesTable1, y
        sta Game.SPRITE_POINTERS + 1

        //Crate2
        lda PositionsTableIndex2
        tay
        lda FramesTable2, y
        sta Game.SPRITE_POINTERS + 2

        rts
    }

    OpenCrateDoor: {
    	lda Tiles.CRATE_DOOR_1 + 0
    	ldx Tiles.CRATE_DOOR_1 + 1
    	ldy Tiles.CRATE_DOOR_1 + 2
    	jsr Map.SwitchCharAtXY
    	rts
    }

    CloseCrateDoor: {
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
		cpx #6 //todo Create label
		bne !skip+

			ldx #0
			stx PositionsTableIndex1
		
		!skip:
		//Crate1 Updates	
		jsr CheckIsOpen1
		jsr CheckPourCement1
		jsr DrawSprite
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
		cpx #6 //todo Create label
		bne !skip+
			ldx #0
			stx PositionsTableIndex2
		!skip:
		//Crate1 Updates	
		jsr CheckIsOpen2
		jsr CheckPourCement2
		jsr DrawSprite
		!return:
		rts
	}

	CheckIsOpen2: {

		lda PositionsTableIndex2
		cmp #3
		bne !closeCheck+
		jsr OpenCrateDoor2

		!closeCheck:
		cmp #5
		bne !dontclose+

		jsr CloseCrateDoor2

		!dontclose:

		rts;	
	}


	CheckIsOpen1: {

		lda PositionsTableIndex1
		cmp #3
		bne !closeCheck+
		jsr OpenCrateDoor

		!closeCheck:
		cmp #5
		bne !dontclose+

		jsr CloseCrateDoor

		!dontclose:

		rts;	
	}

	CheckPourCement1: {
		lda PositionsTableIndex1
		cmp #4
		bne !return+
		jsr Mixers.PourCement1
		// !checkClear:

		// cmp #6
		// bne !skip+

		// jsr Mixers.AddCement1
		// !skip:
		!return:
		rts
	}

	CheckPourCement2: {
		lda PositionsTableIndex2
		cmp #4
		bne !return+
		jsr Mixers.PourCement3
		// !checkClear:

		// cmp #6
		// bne !skip+

		// jsr Mixers.AddCement3
		!return:
		rts
	}
}