CRATES: {
	PosX:
		.byte $00, $00
	PosY:
		.byte 90

	FramesTable:
		.byte $40, $40, $40, $56, $57, $58, $58
	//Crate 1 Positions Table
	PositionsTableIndex1:
		.byte 0	
	PositionsTable1_LB:
			  //120//93 //73
		.byte $78, $5D, $49, $49, $49, $49, $35
	PositionsTable1_HB:	
		.byte $00, $00, $00, $00, $00, $00, $00	
			
	PositionsTableIndex2:
		.byte 0
	PositionsTable2_LB:
		.byte 224, 251, 180, 180, 180, 180, 200
	PositionsTable2_MB:
		.byte $00, $00, $00, $00, $00, $00, $00				

		// TODO: Decide to use this or make labels to specifc indexes for actions?
		// ActionsTable:
		// .byte $00, $00, $00, $01, $02, $00		

	Initialise: {
		lda #$00
		sta VIC.SPRITE_COLOR_1
		sta VIC.SPRITE_COLOR_2

		lda #$40
		sta SPRITE_POINTERS + 1
		sta SPRITE_POINTERS + 2

		lda VIC.SPRITE_ENABLE 
		ora #%00000001
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
        lda PositionsTableIndex1
        tay
        lda PositionsTable1_LB, y
        sta VIC.SPRITE_1_X

        lda VIC.SPRITE_MSB
        and #%11111110
        sta VIC.SPRITE_MSB

       	lda PositionsTableIndex1
        tay
        lda PositionsTable1_HB, y
        beq !+
        lda VIC.SPRITE_MSB
        ora #%00000001
        sta VIC.SPRITE_MSB
    !:
        lda PosY
        sta VIC.SPRITE_1_Y
        sta VIC.SPRITE_2_Y

        //crate 2 pos x
        lda PositionsTableIndex2
        tay
        lda PositionsTable2_LB, y
        sta VIC.SPRITE_2_X

        //Crate1
        lda PositionsTableIndex1
        tay
        lda FramesTable, y
        sta SPRITE_POINTERS + 1

        //Crate2
        lda PositionsTableIndex2
        tay
        lda FramesTable, y
        sta SPRITE_POINTERS + 2

        rts
    }

    OpenCrateDoor: {
    	lda Tiles.CRATE_DOOR_1 + 0
    	ldx Tiles.CRATE_DOOR_1 + 1
    	ldy Tiles.CRATE_DOOR_1 + 2
    	jsr MAPLOADER.SwitchCharAtXY
    	rts
    }

    CloseCrateDoor: {
    	lda Tiles.EMPTY
    	ldx Tiles.CRATE_DOOR_1 + 1
    	ldy Tiles.CRATE_DOOR_1 + 2
    	jsr MAPLOADER.SwitchCharAtXY
    	rts
    }

	Update: {
		ldx PositionsTableIndex1
		inx
		stx PositionsTableIndex1
		//check if at max position index and reset to 0 if necessary
		cpx #7 //todo Create label
		bne !skip+

			ldx #0
			stx PositionsTableIndex1
		
		!skip:
		//Crate1 Updates	
		jsr CheckIsOpen
		jsr CheckPourCement
		jsr DrawSprite
		ldx PositionsTableIndex1

		//increment crate position
		
		rts
	}

	CheckIsOpen: {

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

	CheckPourCement: {
		lda PositionsTableIndex1
		cmp #4
		bne !checkClear+
		jsr Tubes.PourCement1
		!checkClear:

		cmp #6
		bne !skip+

		jsr Tubes.AddCement1
		!skip:
		rts
	}
}