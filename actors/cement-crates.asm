CRATES: {
	PosX:
		.byte $00, $00
	PosY:
		.byte 90

	//Crate 1 Positions Table
	PositionsTableIndex1:
		.byte $00	
	PositionsTable1:
			  //120//93 //73
		.byte $78, $5D, $49, $49, $49, $49, $35

	FramesTable1:
		.byte $40, $40, $40, $56, $57, $58, $58	

		//use this or make labels to specifc indexes for actions?
	//ActionsTable:
		//.byte $00, $00, $00, $01, $02, $00		

	Initialise: {
		lda #$00
		sta VIC.SPRITE_COLOR_0

		lda #$40
		sta SPRITE_POINTERS + 0

		lda VIC.SPRITE_ENABLE 
		ora #%00000001
		sta VIC.SPRITE_ENABLE

		lda #$00
		sta VIC.SPRITE_MULTICOLOR

		ldx #0
		stx PositionsTableIndex1	
		rts
	}

	DrawSprite: {
        //set player position X & Y
        lda PosX + 0
        sta VIC.SPRITE_0_X

        lda VIC.SPRITE_MSB
        and #%11111110
        sta VIC.SPRITE_MSB

        lda PosX + 1
        beq !+
        lda VIC.SPRITE_MSB
        ora #%00000001
        sta VIC.SPRITE_MSB
    !:
        lda PosY
        sta VIC.SPRITE_0_Y

        lda PositionsTableIndex1
        tay
        lda FramesTable1, y
        sta SPRITE_POINTERS + 0

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
		jsr SetPosition
		jsr CheckIsOpen
		jsr CheckPourCement
		jsr DrawSprite

		ldx PositionsTableIndex1
		inx
		stx PositionsTableIndex1
	}

	SetPosition: {
		ldx PositionsTableIndex1
		cpx #7 //todo Create label
		bne !Loop+

		ldx #0
		stx PositionsTableIndex1
    !Loop:    
		clc
		lda PositionsTable1, x
		sta PosX

		lda #$00
		sta PosX + 1
	
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