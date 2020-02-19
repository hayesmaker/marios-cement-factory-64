PLAYER: {
	Pos_X:   //120
		.byte 236, $00
	Player_X: //0    1    2    3    4    5
		.byte 104, 132, 156, 190, 215, 238
	Player_X_MB:
		.byte 0, 0, 0, 0, 0, 0            	
	Player_Y:
		.byte 60, 88, 120, 152, 184
		
	Player_PosX_Index:
		.byte 0
	Player_PosY_Index:
		.byte 2  

	DefaultFrame:
		.byte $41, $41

	DebounceFlag:
		.byte $00
    DebounceFireFlag:
        .byte $00

    ShouldTakeLiftUp:
        .byte 0
    ShouldTakeLiftDown:
        .byte 0

    //player state
    CanOpen:
        .byte $01


	// .label STATE_FALL				= %00000010
	// .label STATE_WALK_LEFT 			= %00000100
	// .label STATE_WALK_RIGHT			= %00001000


	Initialise: {
		lda #$00
		sta VIC.SPRITE_COLOR_1
		sta VIC.SPRITE_COLOR_2

		lda DefaultFrame + 1
		sta DefaultFrame + 0
		sta SPRITE_POINTERS + 1

		lda VIC.SPRITE_ENABLE 
		ora #%00000001
		sta VIC.SPRITE_ENABLE

		lda #$00
		sta VIC.SPRITE_MULTICOLOR

        ldy #2
        sty Player_PosY_Index

		ldx #0
		stx Player_PosX_Index
        stx ShouldTakeLiftUp
        stx ShouldTakeLiftDown
        
		lda Player_X
		sta Pos_X
		lda Player_X_MB
		sta Pos_X + 1

		rts
	}

    MoveWithLiftY1: {
        //accumulator passed in from Elevators (DrawLoopIndex)
        tay
        
        lda Player_PosX_Index
        cmp #2
        bne !return+
        
        dey
        cpy Player_PosY_Index
        bne !return+

        lda Player_PosY_Index
        clc
        adc #1 
        sta Player_PosY_Index 
        
        !return:
        
        rts
    }


    MoveWithLiftY2: {
        //accumulator passed in from Elevators (DrawLoopIndex)
        tay
        
        lda Player_PosX_Index
        cmp #3
        bne !return+
        
        iny
        cpy Player_PosY_Index
        bne !return+

        lda Player_PosY_Index
        sec
        sbc #1 
        sta Player_PosY_Index 
        
        !return:
        
        rts
    }

	DrawSprite: {
		//.label CURRENT_FRAME = TEMP2
        //set player position X & Y
        lda Pos_X + 0
        sta VIC.SPRITE_1_X

        lda VIC.SPRITE_MSB
        and #%11111110
        sta VIC.SPRITE_MSB

        lda Pos_X + 1
        beq !+
        lda VIC.SPRITE_MSB
        ora #%00000001
        sta VIC.SPRITE_MSB
    !:
        ldy Player_PosY_Index
        lda Player_Y, y
        sta VIC.SPRITE_1_Y

        lda DefaultFrame + 0
        sta SPRITE_POINTERS + 1

        rts
    }

    /**
    * Called from Elevators update.
    * Moves player if on lift
    *
    * @sub CheckMovement
    *
    **/
    DoMovement: {
        lda ShouldTakeLiftUp
        bne !MoveUp+
        
        lda ShouldTakeLiftDown
        bne !MoveDown+

        jmp !end+
    !MoveDown:
        ldx Player_PosY_Index
        inx
        stx Player_PosY_Index
        jmp !end+
    !MoveUp:
        ldx Player_PosY_Index
        dex
        stx Player_PosY_Index
    !end:
        jsr ResetLiftChecks
        rts
    }

    ResetLiftChecks: {
        lda #ZERO
        sta ShouldTakeLiftUp
        sta ShouldTakeLiftDown
        rts
    }


    /**
    * If Player is on a lift, move player when lift moves
    *
    * @sub CheckMovement
    **/
    CheckMovement: {

        lda Player_PosX_Index
        cmp #2
        beq !LeftLiftZone+
        cmp #3
        beq !RightLiftZone+
        jmp !end+

    !LeftLiftZone:
        //inc $d020
        
        lda ELEVATORS.LeftDataIndex
        clc
        adc Player_PosY_Index
        tay
        
        lda ELEVATORS.Data_L,y
        beq !end+ //todo: Player Dies Here

        //Player's on Lift
        lda #ONE
        sta ShouldTakeLiftDown
        lda #ZERO
        sta ShouldTakeLiftUp

        jmp !end+

    !RightLiftZone:
        //inc $d021
        lda ELEVATORS.RightDataIndex
        clc
        adc Player_PosY_Index
        tay
        //dey
        lda ELEVATORS.Data_R,y
        beq !end+ //todo: Player Dies Here

        //Player's on Lift
        lda #ONE
        sta ShouldTakeLiftUp
        lda #ZERO
        sta ShouldTakeLiftDown

    !end:
        rts
    }

    Update: {		    	
		jsr PlayerControl
        //jsr ResetLiftChecks
        //jsr CheckLiftMovement
		jsr DrawSprite
        
        rts
	}

    ResetTimers: {
        lda #0
        sta PushButtonTimer + 0

        lda PushButtonTimer + 2
        sta PushButtonTimer + 1

        //jsr Switch1Up

        rts
    }

    //Called from IRQ Timers
    TimerButton1Reset: {
        //inc $d020

        lda Player_PosX_Index
        bne !+

        lda Tiles.HAND_1_UP + 0
        ldx Tiles.HAND_1_UP + 1
        ldy Tiles.HAND_1_UP + 2
        jsr MAPLOADER.SwitchCharAtXY

        //hand switch
        lda Tiles.EMPTY + 0
        ldx Tiles.HAND_1_DOWN + 1
        ldy Tiles.HAND_1_DOWN + 2
        jsr MAPLOADER.SwitchCharAtXY

    !:   
        jsr Switch1Up

        rts
    }

    Switch1Up: {
    	//SWITCH_1_UP:
        lda Tiles.SWITCH_1_UP + 0
        ldx Tiles.SWITCH_1_UP + 1
        ldy Tiles.SWITCH_1_UP + 2
        jsr MAPLOADER.SwitchCharAtXY
        
        //SWITCH_1_DOWN:
        lda Tiles.EMPTY
        ldx Tiles.SWITCH_1_DOWN + 1
        ldy Tiles.SWITCH_1_DOWN + 2
        jsr MAPLOADER.SwitchCharAtXY

         //TRAP_1_OPEN
        lda Tiles.EMPTY
        ldx Tiles.TRAP_1_OPEN + 1
        ldy Tiles.TRAP_1_OPEN + 2
        jsr MAPLOADER.SwitchCharAtXY

        //TRAP_1_CLOSED
        lda Tiles.TRAP_1_CLOSED + 0
        ldx Tiles.TRAP_1_CLOSED + 1
        ldy Tiles.TRAP_1_CLOSED + 2
        jsr MAPLOADER.SwitchCharAtXY

        lda Tiles.TRAP_1_CLOSED_2 + 0
        ldx Tiles.TRAP_1_CLOSED_2 + 1
        ldy Tiles.TRAP_1_CLOSED_2 + 2

        jsr MAPLOADER.SwitchCharAtXY

        rts
    }



    PlayerControl: {
        .label JOY_PORT_2 = $dc00
        .label JOY_LT = %00100
        .label JOY_RT = %01000
        .label JOY_FIRE = %10000

       lda JOY_PORT_2
       sta JOY_ZP

       lda DebounceFireFlag
       beq !+

       lda JOY_ZP
       and #[JOY_FIRE]
       cmp #[JOY_FIRE]
       bne !movement+

       lda #$00
       sta DebounceFireFlag

    !:
    !Fire:
        lda JOY_ZP
        and #JOY_FIRE
        bne !+

        inc DebounceFireFlag
        lda CanOpen
        beq !+
        jsr DoFire       
    !:
    !movement:   
        //Check if we need debounce
        lda DebounceFlag
        beq !+
        //Otherwise check if we can turn it off
        lda JOY_ZP
        and #[JOY_LT + JOY_RT]
        cmp #[JOY_LT + JOY_RT]
        bne !end+

        lda #$00
        sta DebounceFlag    
    !:
    !Left:
        lda JOY_ZP
        and #JOY_LT
        bne !+

        inc DebounceFlag

        //move player left
        ldx Player_PosX_Index
        beq !+

    	jsr DoLeft

        //Char Tile Updates
        ldx Player_PosX_Index
        cpx #1
        beq !end+
        bpl !end+
            jsr LeftCharUpates
        jmp !end+

    !:
    !Right:

        lda JOY_ZP
        and #JOY_RT
        bne !end+

        inc DebounceFlag              
        //move player  right
        ldx Player_PosX_Index
        cpx #5
        beq !end+

        jsr DoRight

        //Char Tile Updates
        ldx Player_PosX_Index
        cpx #2
        beq !end+
        bpl !end+

            jsr RightCharUpdates
    !end:
        rts
    }

    DoFire: {
        //inc $d020
        //can fire?
        //hand switch
        jsr ResetTimers

        lda #ONE
        sta PushButtonTimer + 0

        lda Tiles.EMPTY
        ldx Tiles.HAND_1_UP + 1
        ldy Tiles.HAND_1_UP + 2
        jsr MAPLOADER.SwitchCharAtXY

        //hand switch
        lda Tiles.HAND_1_DOWN + 0
        ldx Tiles.HAND_1_DOWN + 1
        ldy Tiles.HAND_1_DOWN + 2
        jsr MAPLOADER.SwitchCharAtXY

        //SWITCH_1_UP:
        lda Tiles.EMPTY + 0
        ldx Tiles.SWITCH_1_UP + 1
        ldy Tiles.SWITCH_1_UP + 2
        jsr MAPLOADER.SwitchCharAtXY

        //SWITCH_1_DOWN:
        lda Tiles.SWITCH_1_DOWN + 0
        ldx Tiles.SWITCH_1_DOWN + 1
        ldy Tiles.SWITCH_1_DOWN + 2
        jsr MAPLOADER.SwitchCharAtXY

        //TRAP_1_OPEN
        lda Tiles.TRAP_1_OPEN + 0
        ldx Tiles.TRAP_1_OPEN + 1
        ldy Tiles.TRAP_1_OPEN + 2
        jsr MAPLOADER.SwitchCharAtXY

        //TRAP_1_CLOSED
        lda Tiles.EMPTY + 0
        ldx Tiles.TRAP_1_CLOSED + 1
        ldy Tiles.TRAP_1_CLOSED + 2
        jsr MAPLOADER.SwitchCharAtXY
        
        


        //


        rts
    }

    DoLeft: {
        dex
        stx Player_PosX_Index       
        lda Player_X, x
        sta Pos_X

        jsr ResetTimers

        //todo: update frame
        lda DefaultFrame + 1
        clc
        adc Player_PosX_Index
        sta DefaultFrame + 0
        rts

    }

    DoRight: {
        inx 
        stx Player_PosX_Index 
        lda Player_X, x
        sta Pos_X

        //jsr ResetTimers

        //todo: update frame
        lda DefaultFrame + 1
        clc
        adc Player_PosX_Index
        sta DefaultFrame + 0
        rts
    }

    RightCharUpdates: {
            //todo: enable CanOpen on PosX_Index=5
            lda #0
            sta CanOpen

            //removehands
            lda Tiles.EMPTY
            ldx Tiles.HAND_1_UP + 1
            ldy Tiles.HAND_1_UP + 2
            jsr MAPLOADER.SwitchCharAtXY

            lda Tiles.EMPTY
            ldx Tiles.HAND_1_DOWN + 1
            ldy Tiles.HAND_1_DOWN + 2
            jsr MAPLOADER.SwitchCharAtXY

        rts    
    }

    LeftCharUpates: {
        lda #1
            sta CanOpen

            //add hand
            lda Tiles.HAND_1_UP + 0
            ldx Tiles.HAND_1_UP + 1
            ldy Tiles.HAND_1_UP + 2
            jsr MAPLOADER.SwitchCharAtXY
        rts    
    }
}