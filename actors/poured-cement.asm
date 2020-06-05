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

    /*
    00001000 - 3 Poured Cement  0     0   2  |  1    3
    00010000 - 4 * EMPTY *      1     1   3  |  2    4
    01000000 - 6 * EMPTY *      2
    10000000 - 7 * EMPTY *      3
    */    
	
    //@todo ADD A Second Sprite to handle right poured cements seperately
    //@todo OR use char sprites for poured cements here (requires redrawing tiles)
	Initialise: {
		lda #$00
		sta VIC.SPRITE_COLOR_3
        //lda #RED
        sta VIC.SPRITE_COLOR_4
        //lda #YELLOW
        sta VIC.SPRITE_COLOR_6
        //lda #GREEN
        sta VIC.SPRITE_COLOR_7


        lda #$00
		sta VIC.SPRITE_MULTICOLOR
		sta PositionFrameIndex	
        sta HopperIndex
        sta SpillCountIndex

		lda FRAME_ID
		sta Game.SPRITE_POINTERS + 3
        sta Game.SPRITE_POINTERS + 4
        sta Game.SPRITE_POINTERS + 6
        sta Game.SPRITE_POINTERS + 7

		rts
	}

    /*
    00001000 - 4 Poured Cement  0     0   2  |  1    3
    00010000 - 5 * EMPTY *      1     1   3  |  2    4
    01000000 - 7 * EMPTY *      2
    10000000 - 8 * EMPTY *      3
    */    
    HideSprite: {
        cmp #0
        bne !skip+
            lda VIC.SPRITE_ENABLE 
            and #%11110111
            sta VIC.SPRITE_ENABLE
        !skip:
        cmp #1
        bne !skip+
            lda VIC.SPRITE_ENABLE 
            and #%11101111
            sta VIC.SPRITE_ENABLE
        !skip:
        cmp #2
        bne !skip+
            lda VIC.SPRITE_ENABLE 
            and #%10111111
            sta VIC.SPRITE_ENABLE
        !skip:
        cmp #3
        bne !skip+
            lda VIC.SPRITE_ENABLE 
            and #%01111111
            sta VIC.SPRITE_ENABLE
        !skip:
        rts
    }

    
    ShowSprite: {
        //set accumulator
        //to position index
        /*
        00001000 - 4 Poured Cement  0     0   2  |  1    3
        00010000 - 5 * EMPTY *      1     1   3  |  2    4
        01000000 - 7 * EMPTY *      2
        10000000 - 8 * EMPTY *      3
        */    
        sta PositionFrameIndex  
        cmp #0
        bne !skip+
            lda VIC.SPRITE_ENABLE 
            ora #%00001000
            sta VIC.SPRITE_ENABLE
            jsr drawSprite1
        !skip:
        cmp #1
        bne !skip+
            lda VIC.SPRITE_ENABLE 
            ora #%00010000
            sta VIC.SPRITE_ENABLE
            jsr drawSprite2
        !skip:
        cmp #2
        bne !skip+
            lda VIC.SPRITE_ENABLE 
            ora #%01000000
            sta VIC.SPRITE_ENABLE
            jsr drawSprite3
        !skip:
        cmp #3
        bne !skip+
            lda VIC.SPRITE_ENABLE 
            ora #%10000000
            sta VIC.SPRITE_ENABLE
            jsr drawSprite4
        !skip:
        
        rts
    }



    drawSprite1: {
        /*
            00001000 - 4 Poured Cement  0     0   2  |  1    3
            00010000 - 5 * EMPTY *      1     1   3  |  2    4
            01000000 - 7 * EMPTY *      2
            10000000 - 8 * EMPTY *      3
        */    
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
        rts
    }

    drawSprite2: {
        /*
            00001000 - 4 Poured Cement  0     0   2  |  1    3
            00010000 - 5 * EMPTY *      1     1   3  |  2    4
            01000000 - 7 * EMPTY *      2
            10000000 - 8 * EMPTY *      3
        */    
        //x position index: Player_PosX_Index
        //x pixel coords table: Player_X
        ldy PositionFrameIndex
        lda Positions_X_LB, y
        sta VIC.SPRITE_4_X
        //crate 1 msb code
        lda VIC.SPRITE_MSB
        and #%11101111
        sta VIC.SPRITE_MSB

        ldy PositionFrameIndex
        lda Positions_X_HB, y
        beq !+
        lda VIC.SPRITE_MSB
        ora #%00010000
        sta VIC.SPRITE_MSB
    !:
        ldy PositionFrameIndex
        lda Positions_Y, y
        sta VIC.SPRITE_4_Y
        rts
    }


    drawSprite3: {
        /*
        00001000 - 4 Poured Cement  0     0   2  |  1    3
        00010000 - 5 * EMPTY *      1     1   3  |  2    4
        01000000 - 7 * EMPTY *      2
        10000000 - 8 * EMPTY *      3
        */    
        //x position index: Player_PosX_Index
        //x pixel coords table: Player_X
        ldy PositionFrameIndex
        lda Positions_X_LB, y
        sta VIC.SPRITE_6_X
        //crate 1 msb code
        lda VIC.SPRITE_MSB
        and #%10111111
        sta VIC.SPRITE_MSB

        ldy PositionFrameIndex
        lda Positions_X_HB, y
        beq !+
        lda VIC.SPRITE_MSB
        ora #%01000000
        sta VIC.SPRITE_MSB
    !:
        ldy PositionFrameIndex
        lda Positions_Y, y
        sta VIC.SPRITE_6_Y
        rts
    }


    drawSprite4: {
        /*
        00001000 - 4 Poured Cement  0     0   2  |  1    3
        00010000 - 5 * EMPTY *      1     1   3  |  2    4
        01000000 - 7 * EMPTY *      2
        10000000 - 8 * EMPTY *      3
        */    
        //x position index: Player_PosX_Index
        //x pixel coords table: Player_X
        ldy PositionFrameIndex
        lda Positions_X_LB, y
        sta VIC.SPRITE_7_X
        //crate 1 msb code
        lda VIC.SPRITE_MSB
        and #%01111111
        sta VIC.SPRITE_MSB

        ldy PositionFrameIndex
        lda Positions_X_HB, y
        beq !+
        lda VIC.SPRITE_MSB
        ora #%10000000
        sta VIC.SPRITE_MSB
    !:
        ldy PositionFrameIndex
        lda Positions_Y, y
        sta VIC.SPRITE_7_Y
        rts
    }

    /* cHAR GRAPHICS CEMENT SPILLS AMINS */
    SpillCement: {
        lda #1
        sta Game.CementSpillTimer + 0
        lda Game.CementSpillTimer + 2
        sta Game.CementSpillTimer + 1
        //disable control
        lda #1
        sta PLAYER.IsPlayerDead
            
        lda #0
        sta Game.AlarmTimer + 0   

        jsr Sounds.SFX_CRUNCH

        lda HopperIndex
        cmp #1
        bne !skip+
            jsr HidePour
            jsr ShowSpill1
            lda #10
            jmp !return+
        !skip:
        cmp #2
        bne !skip+
            lda #0
            jsr HideSprite
            jsr ShowSpill2
            lda #9
        !skip:
        cmp #3
        bne !skip+
            jsr HidePour
            jsr ShowSpill1
            lda #10
            jmp !return+
        !skip:
        cmp #4
        bne !return+
            lda #2
            jsr HideSprite
            jsr ShowSpill2
            lda #9
        !return:        
        sta SpillCountIndex
        rts
    }

    NextSpill: {
                //
        ldx SpillCountIndex
        dex
        stx SpillCountIndex
        bne !skip+
            jsr HideDeadDriver
            lda #0
            sta Game.CementSpillTimer + 0
            jsr ShowDrivers
            jsr RemoveDeadDriverRight
            jsr RemoveDeadDriverLeft
            jsr PLAYER.LoseLife
            jmp !return+
        !skip:
        //reset timer for next tick
        //@todo accelerate timer when player should blink
        lda Game.CementSpillTimer + 2
        sta Game.CementSpillTimer + 1
        //todo start fall
        lda SpillCountIndex
        cmp #9
        bne !skip+
            jsr Sounds.SFX_CRUNCH
            jsr ShowSpill2
        !skip:
        lda SpillCountIndex
        cmp #8
        bne !skip+
            jsr Sounds.SFX_CRUNCH
            jsr ShowSpill3
        !skip:
        lda SpillCountIndex
        cmp #7
        bne !skip+
            jsr Sounds.SFX_CRUNCH
           jsr HideDriver
           jsr ShowDeadDriver
        !skip:
        lda SpillCountIndex
        cmp #6
        bne !skip+
            jsr HideDeadDriver
        !skip:
        lda SpillCountIndex
        cmp #5
        bne !skip+
            jsr Sounds.SFX_CRUNCH
            jsr ShowDeadDriver
        !skip:
        lda SpillCountIndex
        cmp #4
        bne !skip+
            jsr HideDeadDriver
        !skip:            
        lda SpillCountIndex
        cmp #3
        bne !skip+
            jsr Sounds.SFX_CRUNCH
            jsr ShowDeadDriver
        !skip:
        lda SpillCountIndex        
        cmp #2
        bne !skip+
            jsr HideDeadDriver
        !skip:
        lda SpillCountIndex
        cmp #1
        bne !skip+
            jsr Sounds.SFX_CRUNCH
            jsr ShowDeadDriver
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
        lda HopperIndex
        cmp #3
        bne !skip+
            lda Tiles.EMPTY
            ldx Tiles.CEMENT_NEW_RIGHT_1 + 1
            ldy Tiles.CEMENT_NEW_RIGHT_1 + 2
            jsr Map.SwitchCharAtXY

            lda Tiles.EMPTY
            ldx Tiles.CEMENT_NEW_RIGHT_2 + 1
            ldy Tiles.CEMENT_NEW_RIGHT_2 + 2
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
        cmp #3
        bne !skip+
            lda Tiles.CEMENT_SPILL_1_RIGHT_1 + 0
            ldx Tiles.CEMENT_SPILL_1_RIGHT_1 + 1
            ldy Tiles.CEMENT_SPILL_1_RIGHT_1 + 2
            jsr Map.SwitchCharAtXY

            lda Tiles.CEMENT_SPILL_1_RIGHT_2 + 0
            ldx Tiles.CEMENT_SPILL_1_RIGHT_2 + 1
            ldy Tiles.CEMENT_SPILL_1_RIGHT_2 + 2
            jsr Map.SwitchCharAtXY

        !skip:

        rts
    }


    //@todo replace with macro
    ShowLeftSpill2: {
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

        rts
    }

    ShowRightSpill2: {
        lda Tiles.EMPTY
        ldx Tiles.CEMENT_SPILL_1_RIGHT_1 + 1
        ldy Tiles.CEMENT_SPILL_1_RIGHT_1 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.CEMENT_SPILL_1_RIGHT_2 + 1
        ldy Tiles.CEMENT_SPILL_1_RIGHT_2 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.CEMENT_SPILL_2_RIGHT_1 + 0
        ldx Tiles.CEMENT_SPILL_2_RIGHT_1 + 1
        ldy Tiles.CEMENT_SPILL_2_RIGHT_1 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.CEMENT_SPILL_2_RIGHT_2 + 0
        ldx Tiles.CEMENT_SPILL_2_RIGHT_2 + 1
        ldy Tiles.CEMENT_SPILL_2_RIGHT_2 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.CEMENT_SPILL_2_RIGHT_3 + 0
        ldx Tiles.CEMENT_SPILL_2_RIGHT_3 + 1
        ldy Tiles.CEMENT_SPILL_2_RIGHT_3 + 2
        jsr Map.SwitchCharAtXY

        rts
    }

    ShowSpill2: {
        lda HopperIndex
        cmp #1
        bne !skip+
            jsr ShowLeftSpill2
        !skip:
        lda HopperIndex
        cmp #2
        bne !skip+
            jsr ShowLeftSpill2
        !skip:
        lda HopperIndex
        cmp #3 
        bne !skip+
            jsr ShowRightSpill2 
        !skip:
        lda HopperIndex
        cmp #4
        bne !skip+
            jsr ShowRightSpill2
        !skip:
        rts
    }

    ShowLeftSpill3: {
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

        rts
    }

    ShowRightSpill3: {
        lda Tiles.EMPTY
        ldx Tiles.CEMENT_SPILL_2_RIGHT_1 + 1
        ldy Tiles.CEMENT_SPILL_2_RIGHT_1 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.CEMENT_SPILL_2_RIGHT_2 + 1
        ldy Tiles.CEMENT_SPILL_2_RIGHT_2 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.CEMENT_SPILL_2_RIGHT_3 + 1
        ldy Tiles.CEMENT_SPILL_2_RIGHT_3 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.CEMENT_SPILL_3_RIGHT_1 + 0
        ldx Tiles.CEMENT_SPILL_3_RIGHT_1 + 1
        ldy Tiles.CEMENT_SPILL_3_RIGHT_1 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.CEMENT_SPILL_3_RIGHT_2 + 0
        ldx Tiles.CEMENT_SPILL_3_RIGHT_2 + 1
        ldy Tiles.CEMENT_SPILL_3_RIGHT_2 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.CEMENT_SPILL_3_RIGHT_3 + 0
        ldx Tiles.CEMENT_SPILL_3_RIGHT_3 + 1
        ldy Tiles.CEMENT_SPILL_3_RIGHT_3 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.CEMENT_SPILL_3_RIGHT_3 + 0
        ldx Tiles.CEMENT_SPILL_3_RIGHT_3 + 1
        ldy Tiles.CEMENT_SPILL_3_RIGHT_3 + 2
        jsr Map.SwitchCharAtXY

        rts
    }

    ShowSpill3: {
        lda HopperIndex
        cmp #1
        bne !skip+
            jsr ShowLeftSpill3
        !skip:
        lda HopperIndex
        cmp #2
        bne !skip+
            jsr ShowLeftSpill3
        !skip:
        lda HopperIndex
        cmp #3
        bne !skip+
            jsr ShowRightSpill3
        !skip:
        lda HopperIndex
        cmp #4
        bne !skip+
            jsr ShowRightSpill3
        !skip:
        rts
    }

    HideLeftDriver: {
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
        rts
    }

    HideRightDriver: {

        lda Tiles.EMPTY
        ldx Tiles.CEMENT_SPILL_3_RIGHT_1 + 1
        ldy Tiles.CEMENT_SPILL_3_RIGHT_1 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.CEMENT_SPILL_3_RIGHT_2 + 1
        ldy Tiles.CEMENT_SPILL_3_RIGHT_2 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.CEMENT_SPILL_3_RIGHT_3 + 1
        ldy Tiles.CEMENT_SPILL_3_RIGHT_3 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.DRIVER_RIGHT_1 + 1
        ldy Tiles.DRIVER_RIGHT_1 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.DRIVER_RIGHT_2 + 1
        ldy Tiles.DRIVER_RIGHT_2 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.DRIVER_RIGHT_3 + 1
        ldy Tiles.DRIVER_RIGHT_3 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.DRIVER_RIGHT_4 + 1
        ldy Tiles.DRIVER_RIGHT_4 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.DRIVER_RIGHT_5 + 1
        ldy Tiles.DRIVER_RIGHT_5 + 2
        jsr Map.SwitchCharAtXY
        rts
        
    }

    HideDriver: {
        lda HopperIndex
        cmp #1
        bne !skip+
            jsr HideLeftDriver
        !skip:
        lda HopperIndex
        cmp #2
        bne !skip+
            jsr HideLeftDriver
        !skip:
        lda HopperIndex
        cmp #3
        bne !skip+
            jsr HideRightDriver
        !skip:    
        lda HopperIndex
        cmp #4
        bne !skip+
            jsr HideRightDriver
        !skip:
        rts
    }

    ShowDeadDriver: {
        lda HopperIndex
        cmp #1
        bne !skip+
            jsr DrawDeadDriverLeft
        !skip:
        lda HopperIndex
        cmp #2
        bne !skip+
            jsr DrawDeadDriverLeft
        !skip:
        lda HopperIndex
        cmp #3
        bne !skip+
            jsr DrawDeadDriverRight
        !skip:
        lda HopperIndex
        cmp #4
        bne !skip+
            jsr DrawDeadDriverRight
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



    DrawDeadDriverRight: {

        lda Tiles.DRIVER_DEAD_RIGHT_1 + 0
        ldx Tiles.DRIVER_DEAD_RIGHT_1 + 1
        ldy Tiles.DRIVER_DEAD_RIGHT_1 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.DRIVER_DEAD_RIGHT_2 + 0
        ldx Tiles.DRIVER_DEAD_RIGHT_2 + 1
        ldy Tiles.DRIVER_DEAD_RIGHT_2 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.DRIVER_DEAD_RIGHT_3 + 0
        ldx Tiles.DRIVER_DEAD_RIGHT_3 + 1
        ldy Tiles.DRIVER_DEAD_RIGHT_3 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.DRIVER_DEAD_RIGHT_4 + 0
        ldx Tiles.DRIVER_DEAD_RIGHT_4 + 1
        ldy Tiles.DRIVER_DEAD_RIGHT_4 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.DRIVER_DEAD_RIGHT_5 + 0
        ldx Tiles.DRIVER_DEAD_RIGHT_5 + 1
        ldy Tiles.DRIVER_DEAD_RIGHT_5 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.DRIVER_DEAD_RIGHT_6 + 0
        ldx Tiles.DRIVER_DEAD_RIGHT_6 + 1
        ldy Tiles.DRIVER_DEAD_RIGHT_6 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.DRIVER_DEAD_RIGHT_7 + 0
        ldx Tiles.DRIVER_DEAD_RIGHT_7 + 1
        ldy Tiles.DRIVER_DEAD_RIGHT_7 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.DRIVER_DEAD_RIGHT_8 + 0
        ldx Tiles.DRIVER_DEAD_RIGHT_8 + 1
        ldy Tiles.DRIVER_DEAD_RIGHT_8 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.DRIVER_DEAD_RIGHT_9 + 0
        ldx Tiles.DRIVER_DEAD_RIGHT_9 + 1
        ldy Tiles.DRIVER_DEAD_RIGHT_9 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.DRIVER_DEAD_RIGHT_10 + 0
        ldx Tiles.DRIVER_DEAD_RIGHT_10 + 1
        ldy Tiles.DRIVER_DEAD_RIGHT_10 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.DRIVER_DEAD_RIGHT_11 + 0
        ldx Tiles.DRIVER_DEAD_RIGHT_11 + 1
        ldy Tiles.DRIVER_DEAD_RIGHT_11 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.DRIVER_DEAD_RIGHT_12 + 0
        ldx Tiles.DRIVER_DEAD_RIGHT_12 + 1
        ldy Tiles.DRIVER_DEAD_RIGHT_12 + 2
        jsr Map.SwitchCharAtXY

        rts
    }



    HideDeadDriver: {
        lda HopperIndex
        cmp #1
        bne !skip+
            jsr RemoveDeadDriverLeft
        !skip:
        lda HopperIndex
        cmp #2
        bne !skip+
            jsr RemoveDeadDriverLeft
        !skip:
        lda HopperIndex
        cmp #3
        bne !skip+
            //hide right dead driver
            jsr RemoveDeadDriverRight
        !skip:
        lda HopperIndex
        cmp #4
        bne !skip+
            //hide right dead driver
            jsr RemoveDeadDriverRight
        !skip:
        rts
    }

    RemoveDeadDriverLeft: {
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


    //@todo call right dead driver chars
    RemoveDeadDriverRight: {
        lda Tiles.EMPTY
        ldx Tiles.DRIVER_DEAD_RIGHT_1 + 1
        ldy Tiles.DRIVER_DEAD_RIGHT_1 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.DRIVER_DEAD_RIGHT_2 + 1
        ldy Tiles.DRIVER_DEAD_RIGHT_2 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.DRIVER_DEAD_RIGHT_3 + 1
        ldy Tiles.DRIVER_DEAD_RIGHT_3 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.DRIVER_DEAD_RIGHT_4 + 1
        ldy Tiles.DRIVER_DEAD_RIGHT_4 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.DRIVER_DEAD_RIGHT_5 + 1
        ldy Tiles.DRIVER_DEAD_RIGHT_5 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.DRIVER_DEAD_RIGHT_6 + 1
        ldy Tiles.DRIVER_DEAD_RIGHT_6 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.DRIVER_DEAD_RIGHT_7 + 1
        ldy Tiles.DRIVER_DEAD_RIGHT_7 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.DRIVER_DEAD_RIGHT_8 + 1
        ldy Tiles.DRIVER_DEAD_RIGHT_8 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.DRIVER_DEAD_RIGHT_9 + 1
        ldy Tiles.DRIVER_DEAD_RIGHT_9 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.DRIVER_DEAD_RIGHT_10 + 1
        ldy Tiles.DRIVER_DEAD_RIGHT_10 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.DRIVER_DEAD_RIGHT_11 + 1
        ldy Tiles.DRIVER_DEAD_RIGHT_11 + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.DRIVER_DEAD_RIGHT_12 + 1
        ldy Tiles.DRIVER_DEAD_RIGHT_12 + 2
        jsr Map.SwitchCharAtXY

        rts
    }

}