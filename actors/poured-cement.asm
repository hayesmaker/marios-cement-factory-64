PouredCement: {
	PositionFrameIndex:
		.byte $00

	Positions_X_LB:
		.byte $50, $50, $18, $18
	Positions_X_HB:
		.byte $00, $00, $01, $01	
	Positions_Y:
		.byte $95, $B5, $95, $B5

	FRAME_ID:
		.byte $5B

    //Either 1,2,3,4
    HopperIndex:
        .byte $00

    SpillCountIndex:
        .byte $00    
	
    //@todo ADD A Second Sprite to handle right poured cements seperately
    //@todo OR use char sprites for poured cements here (requires redrawing tiles)
	Initialise: {
		lda #$00
		sta VIC.SPRITE_COLOR_3
		sta VIC.SPRITE_MULTICOLOR
		sta PositionFrameIndex	
        sta HopperIndex
        sta SpillCountIndex

		lda $40
		sta SPRITE_POINTERS + 3

		lda VIC.SPRITE_ENABLE 
		ora #%00001000
		sta VIC.SPRITE_ENABLE

        //initialise debounce flags 	
        //sta DebounceFlag
        //sta DebounceFireFlag
		rts
	}

    HideSprite: {
        lda VIC.SPRITE_ENABLE 
        and #%11110111
        sta VIC.SPRITE_ENABLE
        rts
    }
    
    ShowSprite: {
        //set accumulator
        //to position index
        sta PositionFrameIndex  

        lda VIC.SPRITE_ENABLE 
        ora #%00001000
        sta VIC.SPRITE_ENABLE

        jsr DrawSprite

        rts
    }

    DrawSprite: {
        //x position index: Player_PosX_Index
        //x pixel coords table: Player_X
        ldy PositionFrameIndex
        lda Positions_X_LB, y
        sta VIC.SPRITE_3_X

        //crate 1 msb code
        lda VIC.SPRITE_MSB
        and #%11110111
        sta VIC.SPRITE_MSB

        ldy PositionFrameIndex
        lda Positions_X_HB, y
        beq !+
        lda VIC.SPRITE_MSB
        ora #%00001000
        sta VIC.SPRITE_MSB
    !:
        ldy PositionFrameIndex
        lda Positions_Y, y
        sta VIC.SPRITE_3_Y
        //y * 8 + x = table index
        lda FRAME_ID
        sta SPRITE_POINTERS + 3

        rts
    }

    SpillCement: {
        lda #1
        sta CementSpillTimer + 0
        lda CementSpillTimer + 2
        sta CementSpillTimer + 1
        //disable control
        lda #1
        sta PLAYER.IsPlayerDead

        

        lda #10
        sta SpillCountIndex

        rts
    }

    NextSpill: {
                //
        ldx SpillCountIndex
        dex
        stx SpillCountIndex
        bne !skip+
            lda #0
            sta CementSpillTimer + 0
            jsr ShowDrivers
            jsr PLAYER.LoseLife
            jmp !return+
        !skip:
        //reset timer for next tick
        //@todo accelerate timer when player should blink
        lda CementSpillTimer + 2
        sta CementSpillTimer + 1
        //todo start fall
        lda SpillCountIndex
        cmp #9
        bne !skip+
            jsr HidePour
            jsr ShowSpill1
        !skip:
        cmp #8
        bne !skip+
            jsr ShowSpill2
        !skip:
        cmp #7
        bne !skip+
            jsr ShowSpill3
        !skip:
        cmp #6
        bne !skip+
            jsr HideDriver
            jsr ShowDeadDriver
        !skip:
        cmp #5
        bne !skip+
            jsr HideDeadDriver
        !skip:
        cmp #4
        bne !skip+
            jsr ShowDeadDriver
        !skip:            
        cmp #3
        bne !skip+
            jsr HideDeadDriver
        !skip:        
        cmp #2
        bne !skip+
            jsr ShowDeadDriver
        !skip:
        cmp #1
        bne !skip+
            jsr HideDeadDriver
        !skip:
        !return:
        rts
    }

    HidePour: {
        lda HopperIndex
        cmp #1
        bne !skip+
            lda Tiles.EMPTY + 0
            ldx Tiles.CEMENT_NEW_LEFT_1 + 1
            ldy Tiles.CEMENT_NEW_LEFT_1 + 2
            jsr Map.SwitchCharAtXY

            lda Tiles.EMPTY + 0
            ldx Tiles.CEMENT_NEW_LEFT_2 + 1
            ldy Tiles.CEMENT_NEW_LEFT_2 + 2
            jsr Map.SwitchCharAtXY
        !skip:
        cmp #3
        bne !skip+
            lda Tiles.EMPTY + 0
            ldx Tiles.CEMENT_NEW_RIGHT_1 + 1
            ldy Tiles.CEMENT_NEW_RIGHT_1 + 2
            jsr Map.SwitchCharAtXY
        !skip:
        rts
    }

    /*
      
    */

    ShowSpill1: {
        lda HopperIndex
        cmp #1
        bne !skip+
            lda Tiles.CEMENT_SPILL_1_LEFT_1 + 0
            ldx Tiles.CEMENT_SPILL_1_LEFT_1 + 1
            ldy Tiles.CEMENT_SPILL_1_LEFT_1 + 2
            jsr Map.SwitchCharAtXY

            lda Tiles.CEMENT_SPILL_1_LEFT_2 + 0
            ldx Tiles.CEMENT_SPILL_1_LEFT_2 + 1
            ldy Tiles.CEMENT_SPILL_1_LEFT_2 + 2
            jsr Map.SwitchCharAtXY
        !skip:
        cmp #2
        bne !skip+


        !skip:

        rts
    }

    ShowSpill2: {
        lda HopperIndex
        cmp #1
        bne !skip+
            lda Tiles.EMPTY
            ldx Tiles.CEMENT_SPILL_1_LEFT_1 + 1
            ldy Tiles.CEMENT_SPILL_1_LEFT_1 + 2
            jsr Map.SwitchCharAtXY

            lda Tiles.EMPTY
            ldx Tiles.CEMENT_SPILL_1_LEFT_2 + 1
            ldy Tiles.CEMENT_SPILL_1_LEFT_2 + 2
            jsr Map.SwitchCharAtXY

            lda Tiles.CEMENT_SPILL_2_LEFT_1 + 0
            ldx Tiles.CEMENT_SPILL_2_LEFT_1 + 1
            ldy Tiles.CEMENT_SPILL_2_LEFT_1 + 2
            jsr Map.SwitchCharAtXY

            lda Tiles.CEMENT_SPILL_2_LEFT_2 + 0
            ldx Tiles.CEMENT_SPILL_2_LEFT_2 + 1
            ldy Tiles.CEMENT_SPILL_2_LEFT_2 + 2

            lda Tiles.CEMENT_SPILL_2_LEFT_3 + 0
            ldx Tiles.CEMENT_SPILL_2_LEFT_3 + 1
            ldy Tiles.CEMENT_SPILL_2_LEFT_3 + 2
            jsr Map.SwitchCharAtXY
        !skip:

        rts
    }

    ShowSpill3: {
        lda HopperIndex
        cmp #1
        bne !skip+
            lda Tiles.EMPTY
            ldx Tiles.CEMENT_SPILL_2_LEFT_1 + 1
            ldy Tiles.CEMENT_SPILL_2_LEFT_1 + 2
            jsr Map.SwitchCharAtXY

            lda Tiles.EMPTY
            ldx Tiles.CEMENT_SPILL_2_LEFT_2 + 1
            ldy Tiles.CEMENT_SPILL_2_LEFT_2 + 2
            jsr Map.SwitchCharAtXY

            lda Tiles.EMPTY
            ldx Tiles.CEMENT_SPILL_2_LEFT_3 + 1
            ldy Tiles.CEMENT_SPILL_2_LEFT_3 + 2
            jsr Map.SwitchCharAtXY

            lda Tiles.CEMENT_SPILL_3_LEFT_1 + 0
            ldx Tiles.CEMENT_SPILL_3_LEFT_1 + 1
            ldy Tiles.CEMENT_SPILL_3_LEFT_1 + 2
            jsr Map.SwitchCharAtXY

            lda Tiles.CEMENT_SPILL_3_LEFT_2 + 0
            ldx Tiles.CEMENT_SPILL_3_LEFT_2 + 1
            ldy Tiles.CEMENT_SPILL_3_LEFT_2 + 2
            jsr Map.SwitchCharAtXY

            lda Tiles.CEMENT_SPILL_3_LEFT_3 + 0
            ldx Tiles.CEMENT_SPILL_3_LEFT_3 + 1
            ldy Tiles.CEMENT_SPILL_3_LEFT_3 + 2
            jsr Map.SwitchCharAtXY

            lda Tiles.CEMENT_SPILL_3_LEFT_3 + 0
            ldx Tiles.CEMENT_SPILL_3_LEFT_3 + 1
            ldy Tiles.CEMENT_SPILL_3_LEFT_3 + 2
            jsr Map.SwitchCharAtXY
        !skip:

        rts
    }

    HideDriver: {
        lda HopperIndex
        cmp #1
        bne !skip+
            lda Tiles.EMPTY
            ldx Tiles.CEMENT_SPILL_3_LEFT_1 + 1
            ldy Tiles.CEMENT_SPILL_3_LEFT_1 + 2
            jsr Map.SwitchCharAtXY

            lda Tiles.EMPTY
            ldx Tiles.CEMENT_SPILL_3_LEFT_2 + 1
            ldy Tiles.CEMENT_SPILL_3_LEFT_2 + 2
            jsr Map.SwitchCharAtXY

            lda Tiles.EMPTY
            ldx Tiles.CEMENT_SPILL_3_LEFT_3 + 1
            ldy Tiles.CEMENT_SPILL_3_LEFT_3 + 2
            jsr Map.SwitchCharAtXY

            lda Tiles.EMPTY
            ldx Tiles.CEMENT_SPILL_3_LEFT_3 + 1
            ldy Tiles.CEMENT_SPILL_3_LEFT_3 + 2

            lda Tiles.EMPTY
            ldx Tiles.DRIVER_LEFT_1 + 1
            ldy Tiles.DRIVER_LEFT_1 + 2
            jsr Map.SwitchCharAtXY

            lda Tiles.EMPTY
            ldx Tiles.DRIVER_LEFT_2 + 1
            ldy Tiles.DRIVER_LEFT_2 + 2
            jsr Map.SwitchCharAtXY

            lda Tiles.EMPTY
            ldx Tiles.DRIVER_LEFT_3 + 1
            ldy Tiles.DRIVER_LEFT_3 + 2
            jsr Map.SwitchCharAtXY

            lda Tiles.EMPTY
            ldx Tiles.DRIVER_LEFT_4 + 1
            ldy Tiles.DRIVER_LEFT_4 + 2
            jsr Map.SwitchCharAtXY

            lda Tiles.EMPTY
            ldx Tiles.DRIVER_LEFT_5 + 1
            ldy Tiles.DRIVER_LEFT_5 + 2
            jsr Map.SwitchCharAtXY
        !skip:    
        rts
    }

    ShowDeadDriver: {
        lda HopperIndex
        cmp #1
        bne !skip+
            jsr DrawDeadDriverLeft
        !skip: 

        rts
    }

    ShowDrivers: {

        lda Tiles.DRIVER_LEFT_1 + 0
        ldx Tiles.DRIVER_LEFT_1 + 1
        ldy Tiles.DRIVER_LEFT_1 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.DRIVER_LEFT_2 + 0
        ldx Tiles.DRIVER_LEFT_2 + 1
        ldy Tiles.DRIVER_LEFT_2 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.DRIVER_LEFT_3 + 0
        ldx Tiles.DRIVER_LEFT_3 + 1
        ldy Tiles.DRIVER_LEFT_3 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.DRIVER_LEFT_4 + 0
        ldx Tiles.DRIVER_LEFT_4 + 1
        ldy Tiles.DRIVER_LEFT_4 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.DRIVER_LEFT_5 + 0
        ldx Tiles.DRIVER_LEFT_5 + 1
        ldy Tiles.DRIVER_LEFT_5 + 2
        jsr Map.SwitchCharAtXY

        rts
    }

    DrawDeadDriverLeft: {

        lda Tiles.DRIVER_DEAD_LEFT_1 + 0
        ldx Tiles.DRIVER_DEAD_LEFT_1 + 1
        ldy Tiles.DRIVER_DEAD_LEFT_1 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.DRIVER_DEAD_LEFT_2 + 0
        ldx Tiles.DRIVER_DEAD_LEFT_2 + 1
        ldy Tiles.DRIVER_DEAD_LEFT_2 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.DRIVER_DEAD_LEFT_3 + 0
        ldx Tiles.DRIVER_DEAD_LEFT_3 + 1
        ldy Tiles.DRIVER_DEAD_LEFT_3 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.DRIVER_DEAD_LEFT_4 + 0
        ldx Tiles.DRIVER_DEAD_LEFT_4 + 1
        ldy Tiles.DRIVER_DEAD_LEFT_4 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.DRIVER_DEAD_LEFT_5 + 0
        ldx Tiles.DRIVER_DEAD_LEFT_5 + 1
        ldy Tiles.DRIVER_DEAD_LEFT_5 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.DRIVER_DEAD_LEFT_6 + 0
        ldx Tiles.DRIVER_DEAD_LEFT_6 + 1
        ldy Tiles.DRIVER_DEAD_LEFT_6 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.DRIVER_DEAD_LEFT_7 + 0
        ldx Tiles.DRIVER_DEAD_LEFT_7 + 1
        ldy Tiles.DRIVER_DEAD_LEFT_7 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.DRIVER_DEAD_LEFT_8 + 0
        ldx Tiles.DRIVER_DEAD_LEFT_8 + 1
        ldy Tiles.DRIVER_DEAD_LEFT_8 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.DRIVER_DEAD_LEFT_9 + 0
        ldx Tiles.DRIVER_DEAD_LEFT_9 + 1
        ldy Tiles.DRIVER_DEAD_LEFT_9 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.DRIVER_DEAD_LEFT_10 + 0
        ldx Tiles.DRIVER_DEAD_LEFT_10 + 1
        ldy Tiles.DRIVER_DEAD_LEFT_10 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.DRIVER_DEAD_LEFT_11 + 0
        ldx Tiles.DRIVER_DEAD_LEFT_11 + 1
        ldy Tiles.DRIVER_DEAD_LEFT_11 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.DRIVER_DEAD_LEFT_12 + 0
        ldx Tiles.DRIVER_DEAD_LEFT_12 + 1
        ldy Tiles.DRIVER_DEAD_LEFT_12 + 2
        jsr Map.SwitchCharAtXY

        rts
    }

    HideDeadDriver: {
        lda HopperIndex
        cmp #1
        bne !skip+
            jsr RemoveDriverLeft
        !skip:


        rts
    }

    RemoveDriverLeft: {
        lda Tiles.EMPTY
        ldx Tiles.DRIVER_DEAD_LEFT_1 + 1
        ldy Tiles.DRIVER_DEAD_LEFT_1 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.DRIVER_DEAD_LEFT_2 + 1
        ldy Tiles.DRIVER_DEAD_LEFT_2 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.DRIVER_DEAD_LEFT_3 + 1
        ldy Tiles.DRIVER_DEAD_LEFT_3 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.DRIVER_DEAD_LEFT_4 + 1
        ldy Tiles.DRIVER_DEAD_LEFT_4 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.DRIVER_DEAD_LEFT_5 + 1
        ldy Tiles.DRIVER_DEAD_LEFT_5 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.DRIVER_DEAD_LEFT_6 + 1
        ldy Tiles.DRIVER_DEAD_LEFT_6 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.DRIVER_DEAD_LEFT_7 + 1
        ldy Tiles.DRIVER_DEAD_LEFT_7 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.DRIVER_DEAD_LEFT_8 + 1
        ldy Tiles.DRIVER_DEAD_LEFT_8 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.DRIVER_DEAD_LEFT_9 + 1
        ldy Tiles.DRIVER_DEAD_LEFT_9 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.DRIVER_DEAD_LEFT_10 + 1
        ldy Tiles.DRIVER_DEAD_LEFT_10 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.DRIVER_DEAD_LEFT_11 + 1
        ldy Tiles.DRIVER_DEAD_LEFT_11 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.DRIVER_DEAD_LEFT_12 + 1
        ldy Tiles.DRIVER_DEAD_LEFT_12 + 2
        jsr Map.SwitchCharAtXY

        rts
    }

}