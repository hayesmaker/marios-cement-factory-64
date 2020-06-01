PLAYER: {
	
	Player_X: //0    1    2    3    4    5
		.byte 106, 130, 156, 190, 215, 238
	Player_X_MB:
		.byte 0, 0, 0, 0, 0, 0            	
	Player_Y: //*                    //* //* = dead 
		.byte 70, 88, 119, 153, 179, 208
		
	Player_PosX_Index:
		.byte 0
	Player_PosY_Index:
		.byte 2  

	DefaultFrame:
		.byte $41, $41

    SquashedFrameLow:
        .byte $54, $55        
    SquashedFrameHigh:
        .byte $52, $53        

	DebounceFlag:
		.byte $00
    DebounceFireFlag:
        .byte $00

    ShouldTakeLiftUp:
        .byte 0
    ShouldTakeLiftDown:
        .byte 0

    IsPlayerDead:
        .byte $00
    // AddMissFlag:
    //     .byte $00    

    FallCountIndex:
        .byte $00
    CrushedSpriteShown:
        .byte $00

    isVisible:
        .byte $01         

    //player state
    CanOpen:
        .byte $01

    
    FramesTableIndex:
        .byte $00
    FramesTable: 
        .byte $00, $00, $52, $53, $00, $00, $00, $00
        .byte $00, $00, $50, $51, $00, $00, $00, $00
        .byte $41, $42, $43, $44, $45, $46, $00, $00
        .byte $47, $48, $49, $4a, $4b, $4c, $00, $00
        .byte $00, $4d, $4e, $4f, $00, $00, $00, $00
        .byte $00, $00, $54, $54, $00, $00, $00, $00
        //.byte $00, $00, $54, $54, $00, $00, $00, $00

    ActionTable: 
        .byte $00, $00, $00, $00, $00, $00, $00, $00
        .byte $00, $00, $00, $00, $00, $00, $00, $00
        .byte $01, $10, $00, $00, $12, $03, $00, $00
        .byte $02, $11, $00, $00, $13, $04, $00, $00
        .byte $00, $00, $00, $00, $00, $00, $00, $00
        .byte $00, $00, $00, $00, $00, $00, $00, $00
    
	// .label STATE_FALL				= %00000010
	// .label STATE_WALK_LEFT 			= %00000100
	// .label STATE_WALK_RIGHT			= %00001000


	Initialise: {
		lda #$00
		sta VIC.SPRITE_COLOR_0
        sta VIC.SPRITE_COLOR_5

		lda DefaultFrame + 1
		sta DefaultFrame + 0
		sta Game.SPRITE_POINTERS + 0

        //player sprite enable    
		lda VIC.SPRITE_ENABLE 
		ora #%00000001
		sta VIC.SPRITE_ENABLE

        //block 1 enable sprite player msb
        lda VIC.SPRITE_MSB
        and #%11111110
        sta VIC.SPRITE_MSB

        //player crushed sprite enable
        //lda VIC.SPRITE_ENABLE
        //ora #%00100000
        //sta VIC.SPRITE_ENABLE

		lda #$00
		sta VIC.SPRITE_MULTICOLOR
        //initialise debounce flags
        sta DebounceFlag
        sta DebounceFireFlag

        ldy #2
        sty Player_PosY_Index

		ldy #1
		sty Player_PosX_Index
        sty isVisible

        lda #0
        //sta AddMissFlag
        sta CrushedSpriteShown

        jsr HidesSquashSprite
		
		rts
	}

    DrawSprite: {
        lda CrushedSpriteShown
        bne !return+
        //x position index: Player_PosX_Index
        //x pixel coords table: Player_X
        ldy Player_PosX_Index
        lda Player_X, y
        sta VIC.SPRITE_0_X

        //check if player is crushed at top
        lda Player_PosY_Index
        bne !skip+
            //inc $d020
            lda CrushedSpriteShown
            bne !skip+
                lda #1
                sta CrushedSpriteShown
                jsr DrawSpriteCrushedTop
                jmp !return+
        !skip:
        //check if player is crushed at bottom
        ldy Player_PosY_Index
        cpy #5
        bne !skip+
            lda CrushedSpriteShown
            bne !skip+
                lda #1
                sta CrushedSpriteShown
                jsr DrawSpriteFallen
                jmp !return+

        !skip:
        lda Player_Y, y
        sta VIC.SPRITE_0_Y
        //y * 8 + x = table index
        lda FramesTableIndex
        tay
        lda FramesTable, y
        sta Game.SPRITE_POINTERS + 0

        !return:
        rts
    }

    DrawSpriteFallen: {
        lda #184
        sta VIC.SPRITE_0_X
        //Player on right - show front half
        lda #160
        sta VIC.SPRITE_5_X

        //show crushed front half sprite
        lda VIC.SPRITE_ENABLE 
        ora #%00100001
        sta VIC.SPRITE_ENABLE

        ldy Player_PosY_Index
        lda Player_Y, y
        sta VIC.SPRITE_5_Y
        sta VIC.SPRITE_0_Y

        lda SquashedFrameLow + 0
        sta Game.SPRITE_POINTERS + 5

        lda SquashedFrameLow + 1
        sta Game.SPRITE_POINTERS + 0

        rts
    }

    DrawSpriteCrushedTop: {
        //inc $d020
        ldy Player_PosY_Index
        lda Player_Y, y
        sta VIC.SPRITE_5_Y
        sta VIC.SPRITE_0_Y

        lda #184
        sta VIC.SPRITE_5_X
        //Player on right - show front half
        lda #160
        sta VIC.SPRITE_0_X

        //show crushed front half sprite
        lda VIC.SPRITE_ENABLE 
        ora #%00100001
        sta VIC.SPRITE_ENABLE

        lda SquashedFrameHigh + 1
        sta Game.SPRITE_POINTERS + 5

        lda SquashedFrameHigh + 0
        sta Game.SPRITE_POINTERS + 0
        !return:
        rts
    }

    MoveWithLiftY1: {
        //y regsiter passed in from Elevators (DrawLoopIndex)
        lda IsPlayerDead
        bne !return+

        lda Player_PosX_Index
        cmp #2
        bne !return+
        
        dey 
        cpy Player_PosY_Index
        bne !return+
        //Lift is Present
            lda Player_PosY_Index
            clc
            adc #1 
            sta Player_PosY_Index 
        
        !return:
        
        rts
    }


    MoveWithLiftY2: {
        lda IsPlayerDead
        bne !return+
        //y register passed in from Elevators (DrawLoopIndex)
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

    SetFrameNumber: {
        lda Player_PosY_Index
        asl
        asl
        asl
        clc
        adc Player_PosX_Index
        sta FramesTableIndex
        rts
    }
 
    Update: {		    	
		jsr PlayerControl
		jsr SetFrameNumber
		jsr DrawSprite
        jsr CheckLiftDeath
        jsr CheckCharUpdates
        rts
	}

    LoseLife: {
        // lda #1
        // sta AddMissFlag
        jsr HidesSquashSprite
        jsr HideHandChars

        jsr Mixers.ClearTopMixers
        jsr Mixers.ClearPouredCementsTop
        jsr Respawn
        jsr Score.DisableBonus
        jsr Lives.LoseLife
        
        

        rts
    }

    CheckLiftDeath: {
        //CHECK IF ALREADY DEAD
        lda IsPlayerDead
        bne !return+
        // CHECK IF IN LIFT ZONE

        lda Player_PosY_Index
        bne !skip+
            //crush player top
            jsr PlayerFall
        !skip:

        lda Player_PosX_Index
        cmp #2
        beq !liftPossible+
        cmp #3
        beq !liftPossible2+
        jmp !return+
        !liftPossible:
            jsr CheckIfLiftPresent_Left
            jmp !return+
        !liftPossible2:
            jsr CheckIfLiftPresent_Right

        !return:
        rts
    }

    CheckIfLiftPresent_Left: {

        lda Elevators.LeftDataIndex
        clc
        adc #3
        sec 
        sbc Player_PosY_Index
        tay 

        lda TitleScreen.GameMode
        cmp #TitleScreen.GAME_A
        bne !skip+
            lda Elevators.liftData_leftA, y
            jmp !end+
        !skip:
            lda Elevators.liftData_leftB, y
        !end:
        bne !next+
            //no lift here
            jsr PlayerFall
        !next:
        rts
    }

    CheckIfLiftPresent_Right: {
        lda Elevators.RightDataIndex
        clc
        adc Player_PosY_Index
        tay
        dey 
        lda TitleScreen.GameMode
        cmp #TitleScreen.GAME_A
        bne !skip+
            lda Elevators.liftData_rightA, y
            jmp !end+
        !skip:
            lda Elevators.liftData_rightB, y
        !end:
        bne !next+
            //no lift
            jsr PlayerFall
            
        !next:
        rts
    }

    PlayerFall: {
        //start fall timer
        lda #1
        sta Game.FallGuyTimer + 0
        lda Game.FallGuyTimer + 2
        sta Game.FallGuyTimer + 1
        //disable control
        lda #1
        sta IsPlayerDead

        lda #9
        sta FallCountIndex

        rts
    }

    NextFall: {
        lda FallCountIndex
        bne !skip+
            lda #0
            sta Game.FallGuyTimer + 0
            jsr LoseLife            
            jmp !return+
        !skip:
        //reset timer for next tick
        //@todo accelerate timer when player should blink
        lda Game.FallGuyTimer + 2
        sta Game.FallGuyTimer + 1
        
        lda Player_PosY_Index
        beq !blink+
        cmp #5
        beq !blink+
            inc Player_PosY_Index
            jsr Sounds.SFX_FALL 
            jmp !return+
        !blink:  
        lda isVisible
        beq !toggleOn+
            jsr BlinkPlayerOff
            jmp !return+
        !toggleOn:
            jsr BlinkPlayerOn
        !return:
            dec FallCountIndex    
        rts
    }

    Respawn: {
        //reset vars
        lda #0
        sta IsPlayerDead
        lda #0
        sta CrushedSpriteShown
       
        lda #1
        sta isVisible
        //start position
        ldy #2
        sty Player_PosY_Index
        ldy #1
        sty Player_PosX_Index
        //reset player frame no.
        jsr SetFrameNumber
        //re-init timers
        lda Game.GameTimerTick + 1
        sta Game.GameTimerTick
        rts
    }

    HideHandChars: {

        //left
        lda Tiles.EMPTY
        ldx Tiles.HAND_1_UP + 1
        ldy Tiles.HAND_1_UP + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.HAND_1_DOWN + 1
        ldy Tiles.HAND_1_DOWN + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.HAND_2_UP + 1
        ldy Tiles.HAND_2_UP + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.HAND_2_DOWN + 1
        ldy Tiles.HAND_2_DOWN + 2
        jsr Map.SwitchCharAtXY

        //right
        lda Tiles.EMPTY
        ldx Tiles.HAND_3_UP + 1
        ldy Tiles.HAND_3_UP + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.HAND_3_DOWN + 1
        ldy Tiles.HAND_3_DOWN + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.HAND_4_UP + 1
        ldy Tiles.HAND_4_UP + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.EMPTY
        ldx Tiles.HAND_4_DOWN + 1
        ldy Tiles.HAND_4_DOWN + 2
        jsr Map.SwitchCharAtXY

        rts
    }

    /*
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
    */

    BlinkPlayerOff: {
        lda #0
        sta isVisible
        
        lda VIC.SPRITE_ENABLE 
        and #%11011110
        sta VIC.SPRITE_ENABLE
        rts
    }

    HidesSquashSprite: {
        lda VIC.SPRITE_ENABLE 
        and #%11011111
        sta VIC.SPRITE_ENABLE
        rts
    }

    BlinkPlayerOn: {
        lda #1
        sta isVisible

        jsr Sounds.SFX_SPLAT
        lda VIC.SPRITE_ENABLE 
        ora #%00100001
        sta VIC.SPRITE_ENABLE

        rts
    }



    /**
    * @subroutine CheckCharUpdates
    **/
	CheckCharUpdates: {

	    lda FramesTableIndex
	    tay
	    lda ActionTable, y

	    cmp #$01
	    beq !position1+

        cmp #$10
        beq !position10+

        cmp #$02
        beq !position2+

        cmp #$11
        beq !position11+

        cmp #$03
        beq !position3+

        cmp #$12
        beq !position12+

        cmp #04
        beq !position4+

        cmp #$13
        beq !position13+

        jmp !return+

	    !position1:
	        jsr CharsPosition01
	        jmp !return+
	    !position10:
	        jsr CharsPosition10
	        jmp !return+
        !position2:
            jsr CharsPosition02
            jmp !return+
        !position11:
            jsr CharsPosition11
            jmp !return+
        !position3:
            jsr CharsPosition03
            jmp !return+
        !position12:
            jsr CharsPosition12
            jmp !return+
        !position4:
            jsr CharsPosition04
            jmp !return+
        !position13:
            jsr CharsPosition13
            jmp !return+           
        !return:
            rts
	}

    ResetTimers: {
        lda #0
        sta Game.PushButtonTimer + 0

        lda Game.PushButtonTimer + 2
        sta Game.PushButtonTimer + 1

        //jsr Switch1Up

        rts
    }

    //Called from IRQ Timers
    TimerButton1Reset: {
        //inc $d020
        lda FramesTableIndex
        tay
        lda ActionTable, y
        cmp #$01
        bne !+
            lda Tiles.HAND_1_UP + 0
            ldx Tiles.HAND_1_UP + 1
            ldy Tiles.HAND_1_UP + 2
            jsr Map.SwitchCharAtXY

            //hand switch
            lda Tiles.EMPTY + 0
            ldx Tiles.HAND_1_DOWN + 1
            ldy Tiles.HAND_1_DOWN + 2
            jsr Map.SwitchCharAtXY
        !:
        cmp #$02
        bne !+
            lda Tiles.HAND_2_UP + 0
            ldx Tiles.HAND_2_UP + 1
            ldy Tiles.HAND_2_UP + 2
            jsr Map.SwitchCharAtXY

            //hand switch
            lda Tiles.EMPTY + 0
            ldx Tiles.HAND_2_DOWN + 1
            ldy Tiles.HAND_2_DOWN + 2
            jsr Map.SwitchCharAtXY

        !:
        cmp #$03
        bne !+
            lda Tiles.HAND_3_UP + 0
            ldx Tiles.HAND_3_UP + 1
            ldy Tiles.HAND_3_UP + 2
            jsr Map.SwitchCharAtXY

            //hand switch
            lda Tiles.EMPTY + 0
            ldx Tiles.HAND_3_DOWN + 1
            ldy Tiles.HAND_3_DOWN + 2
            jsr Map.SwitchCharAtXY

         !:
        cmp #$04
        bne !+
            lda Tiles.HAND_4_UP + 0
            ldx Tiles.HAND_4_UP + 1
            ldy Tiles.HAND_4_UP + 2
            jsr Map.SwitchCharAtXY

            //hand switch
            lda Tiles.EMPTY + 0
            ldx Tiles.HAND_4_DOWN + 1
            ldy Tiles.HAND_4_DOWN + 2
            jsr Map.SwitchCharAtXY   
        !:   
            //@todo: only switch up at the mixer player is at.
            jsr Switch1Up
            jsr Switch2Up
            jsr Switch3Up
            jsr Switch4Up
        rts
    }

    Switch1Up: {
    	//SWITCH_1_UP:
        lda Tiles.SWITCH_1_UP + 0
        ldx Tiles.SWITCH_1_UP + 1
        ldy Tiles.SWITCH_1_UP + 2
        jsr Map.SwitchCharAtXY
        
        //SWITCH_1_DOWN:
        lda Tiles.EMPTY
        ldx Tiles.SWITCH_1_DOWN + 1
        ldy Tiles.SWITCH_1_DOWN + 2
        jsr Map.SwitchCharAtXY

         //TRAP_1_OPEN
        lda Tiles.EMPTY
        ldx Tiles.TRAP_1_OPEN + 1
        ldy Tiles.TRAP_1_OPEN + 2
        jsr Map.SwitchCharAtXY

        //TRAP_1_CLOSED
        lda Tiles.TRAP_1_CLOSED + 0
        ldx Tiles.TRAP_1_CLOSED + 1
        ldy Tiles.TRAP_1_CLOSED + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.TRAP_1_CLOSED_2 + 0
        ldx Tiles.TRAP_1_CLOSED_2 + 1
        ldy Tiles.TRAP_1_CLOSED_2 + 2

        jsr Map.SwitchCharAtXY

        rts
    }

    Switch2Up: {
        //SWITCH_2_UP:
        lda Tiles.SWITCH_2_UP + 0
        ldx Tiles.SWITCH_2_UP + 1
        ldy Tiles.SWITCH_2_UP + 2
        jsr Map.SwitchCharAtXY
        
        //SWITCH_2_DOWN:
        lda Tiles.EMPTY
        ldx Tiles.SWITCH_2_DOWN + 1
        ldy Tiles.SWITCH_2_DOWN + 2
        jsr Map.SwitchCharAtXY

         //TRAP_1_OPEN
        lda Tiles.EMPTY
        ldx Tiles.TRAP_2_OPEN + 1
        ldy Tiles.TRAP_2_OPEN + 2
        jsr Map.SwitchCharAtXY

        //TRAP_1_CLOSED
        lda Tiles.TRAP_2_CLOSED + 0
        ldx Tiles.TRAP_2_CLOSED + 1
        ldy Tiles.TRAP_2_CLOSED + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.TRAP_2_CLOSED_2 + 0
        ldx Tiles.TRAP_2_CLOSED_2 + 1
        ldy Tiles.TRAP_2_CLOSED_2 + 2

        jsr Map.SwitchCharAtXY

        rts
    }

    Switch4Up: {
        //SWITCH_1_UP:
        lda Tiles.SWITCH_4_UP + 0
        ldx Tiles.SWITCH_4_UP + 1
        ldy Tiles.SWITCH_4_UP + 2
        jsr Map.SwitchCharAtXY
        
        //SWITCH_1_DOWN:
        lda Tiles.EMPTY
        ldx Tiles.SWITCH_4_DOWN + 1
        ldy Tiles.SWITCH_4_DOWN + 2
        jsr Map.SwitchCharAtXY

         //TRAP_1_OPEN
        lda Tiles.EMPTY
        ldx Tiles.TRAP_4_OPEN + 1
        ldy Tiles.TRAP_4_OPEN + 2
        jsr Map.SwitchCharAtXY

        //TRAP_1_CLOSED
        lda Tiles.TRAP_4_CLOSED + 0
        ldx Tiles.TRAP_4_CLOSED + 1
        ldy Tiles.TRAP_4_CLOSED + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.TRAP_4_CLOSED_2 + 0
        ldx Tiles.TRAP_4_CLOSED_2 + 1
        ldy Tiles.TRAP_4_CLOSED_2 + 2

        jsr Map.SwitchCharAtXY

        rts
    }

    Switch3Up: {
        //SWITCH_1_UP:
        lda Tiles.SWITCH_3_UP + 0
        ldx Tiles.SWITCH_3_UP + 1
        ldy Tiles.SWITCH_3_UP + 2
        jsr Map.SwitchCharAtXY
        
        //SWITCH_1_DOWN:
        lda Tiles.EMPTY
        ldx Tiles.SWITCH_3_DOWN + 1
        ldy Tiles.SWITCH_3_DOWN + 2
        jsr Map.SwitchCharAtXY

         //TRAP_1_OPEN
        lda Tiles.EMPTY
        ldx Tiles.TRAP_3_OPEN + 1
        ldy Tiles.TRAP_3_OPEN + 2
        jsr Map.SwitchCharAtXY

        //TRAP_1_CLOSED
        lda Tiles.TRAP_3_CLOSED + 0
        ldx Tiles.TRAP_3_CLOSED + 1
        ldy Tiles.TRAP_3_CLOSED + 2
        jsr Map.SwitchCharAtXY

        lda Tiles.TRAP_3_CLOSED_2 + 0
        ldx Tiles.TRAP_3_CLOSED_2 + 1
        ldy Tiles.TRAP_3_CLOSED_2 + 2

        jsr Map.SwitchCharAtXY

        rts
    }

    PlayerControl: {
        .label JOY_PORT_2 = $dc00
        .label JOY_LT = %00100
        .label JOY_RT = %01000
        .label JOY_FIRE = %10000

        lda IsPlayerDead //0 / 1
        beq !control+
            jmp !end+
        !control:
        lda JOY_PORT_2
        sta JOY_ZP

        lda JOY_ZP
        and #JOY_FIRE
        beq !fireButtonPressed+

        lda #$00
        sta DebounceFireFlag
        jmp !movement+
    
    !fireButtonPressed:
       lda DebounceFireFlag
       bne !movement+
    !:
    !Fire:
        lda JOY_ZP
        and #JOY_FIRE
        bne !movement+

        ldy FramesTableIndex
        lda ActionTable, y
        cmp #$01
        bne !+
            jsr OpenHopper1   //top left mixer
        !:
        cmp #$02
        bne !+
            jsr OpenHopper2
        !:
        cmp #$03
        bne !+
            jsr OpenHopper3   //top right mixer
        !:    
        cmp #$04
        bne !+
            jsr OpenHopper4  
        !:
        inc DebounceFireFlag
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
        ldy FramesTableIndex
        dey
        lda FramesTable, y
        beq !+
    	   ldx Player_PosX_Index
           jsr DoLeft
    !:
    !Right:

        lda JOY_ZP
        and #JOY_RT
        bne !end+

        lda Player_PosY_Index
        cmp #1
        beq !end+

        inc DebounceFlag              
        //move player  right
        ldy FramesTableIndex
        iny
        lda FramesTable, y
        beq !end+

        ldx Player_PosX_Index
        jsr DoRight

    !end:
        rts
    }

    OpenHopper1: {
        jsr ResetTimers

        //@todo jsr CheckMixerDrop1
        jsr Mixers.PlayerDrop2

        lda #ONE
        sta Game.PushButtonTimer + 0
        lda Tiles.EMPTY
        ldx Tiles.HAND_1_UP + 1
        ldy Tiles.HAND_1_UP + 2
        jsr Map.SwitchCharAtXY
        //hand switch
        lda Tiles.HAND_1_DOWN + 0
        ldx Tiles.HAND_1_DOWN + 1
        ldy Tiles.HAND_1_DOWN + 2
        jsr Map.SwitchCharAtXY
        //SWITCH_1_UP:
        lda Tiles.EMPTY + 0
        ldx Tiles.SWITCH_1_UP + 1
        ldy Tiles.SWITCH_1_UP + 2
        jsr Map.SwitchCharAtXY
        //SWITCH_1_DOWN:
        lda Tiles.SWITCH_1_DOWN + 0
        ldx Tiles.SWITCH_1_DOWN + 1
        ldy Tiles.SWITCH_1_DOWN + 2
        jsr Map.SwitchCharAtXY
        //TRAP_1_OPEN
        lda Tiles.TRAP_1_OPEN + 0
        ldx Tiles.TRAP_1_OPEN + 1
        ldy Tiles.TRAP_1_OPEN + 2
        jsr Map.SwitchCharAtXY
        //TRAP_1_CLOSED
        lda Tiles.EMPTY + 0
        ldx Tiles.TRAP_1_CLOSED + 1
        ldy Tiles.TRAP_1_CLOSED + 2
        jsr Map.SwitchCharAtXY
        
        rts
    }

    OpenHopper2: {
        jsr ResetTimers    
        jsr Mixers.PlayerDrop5

        lda #ONE
        sta Game.PushButtonTimer + 0
        lda Tiles.EMPTY
        ldx Tiles.HAND_2_UP + 1
        ldy Tiles.HAND_2_UP + 2
        jsr Map.SwitchCharAtXY
        //hand switch
        lda Tiles.HAND_2_DOWN + 0
        ldx Tiles.HAND_2_DOWN + 1
        ldy Tiles.HAND_2_DOWN + 2
        jsr Map.SwitchCharAtXY
        //REMOVE SWITCH_2_UP:
        lda Tiles.EMPTY + 0
        ldx Tiles.SWITCH_2_UP + 1
        ldy Tiles.SWITCH_2_UP + 2
        jsr Map.SwitchCharAtXY
        //DRAW SWITCH_2_DOWN:
        lda Tiles.SWITCH_2_DOWN + 0
        ldx Tiles.SWITCH_2_DOWN + 1
        ldy Tiles.SWITCH_2_DOWN + 2
        jsr Map.SwitchCharAtXY
        //TRAP_2_OPEN
        lda Tiles.TRAP_2_OPEN + 0
        ldx Tiles.TRAP_2_OPEN + 1
        ldy Tiles.TRAP_2_OPEN + 2
        jsr Map.SwitchCharAtXY
        //TRAP_2_CLOSED
        lda Tiles.EMPTY + 0
        ldx Tiles.TRAP_2_CLOSED + 1
        ldy Tiles.TRAP_2_CLOSED + 2
        jsr Map.SwitchCharAtXY
        rts
    }

    OpenHopper3: {
        jsr ResetTimers
        jsr Mixers.PlayerDrop4
        
        lda #ONE
        sta Game.PushButtonTimer + 0
        lda Tiles.EMPTY
        ldx Tiles.HAND_3_UP + 1
        ldy Tiles.HAND_3_UP + 2
        jsr Map.SwitchCharAtXY
        //hand switch
        lda Tiles.HAND_3_DOWN + 0
        ldx Tiles.HAND_3_DOWN + 1
        ldy Tiles.HAND_3_DOWN + 2
        jsr Map.SwitchCharAtXY
        //SWITCH_3_UP:
        lda Tiles.EMPTY + 0
        ldx Tiles.SWITCH_3_UP + 1
        ldy Tiles.SWITCH_3_UP + 2
        jsr Map.SwitchCharAtXY
        //SWITCH_3_DOWN:
        lda Tiles.SWITCH_3_DOWN + 0
        ldx Tiles.SWITCH_3_DOWN + 1
        ldy Tiles.SWITCH_3_DOWN + 2
        jsr Map.SwitchCharAtXY
        //TRAP_3_OPEN
        lda Tiles.TRAP_3_OPEN + 0
        ldx Tiles.TRAP_3_OPEN + 1
        ldy Tiles.TRAP_3_OPEN + 2
        jsr Map.SwitchCharAtXY
        //TRAP_3_CLOSED
        lda Tiles.EMPTY + 0
        ldx Tiles.TRAP_3_CLOSED + 1
        ldy Tiles.TRAP_3_CLOSED + 2
        jsr Map.SwitchCharAtXY
        rts
    }

    OpenHopper4: {
        jsr ResetTimers
        jsr Mixers.PlayerDrop6

        lda #ONE
        sta Game.PushButtonTimer + 0
        lda Tiles.EMPTY
        ldx Tiles.HAND_4_UP + 1
        ldy Tiles.HAND_4_UP + 2
        jsr Map.SwitchCharAtXY
        //hand switch
        lda Tiles.HAND_4_DOWN + 0
        ldx Tiles.HAND_4_DOWN + 1
        ldy Tiles.HAND_4_DOWN + 2
        jsr Map.SwitchCharAtXY
        //SWITCH_1_UP:
        lda Tiles.EMPTY + 0
        ldx Tiles.SWITCH_4_UP + 1
        ldy Tiles.SWITCH_4_UP + 2
        jsr Map.SwitchCharAtXY
        //SWITCH_1_DOWN:
        lda Tiles.SWITCH_4_DOWN + 0
        ldx Tiles.SWITCH_4_DOWN + 1
        ldy Tiles.SWITCH_4_DOWN + 2
        jsr Map.SwitchCharAtXY
        //TRAP_1_OPEN
        lda Tiles.TRAP_4_OPEN + 0
        ldx Tiles.TRAP_4_OPEN + 1
        ldy Tiles.TRAP_4_OPEN + 2
        jsr Map.SwitchCharAtXY
        //TRAP_1_CLOSED
        lda Tiles.EMPTY + 0
        ldx Tiles.TRAP_4_CLOSED + 1
        ldy Tiles.TRAP_4_CLOSED + 2
        jsr Map.SwitchCharAtXY
        rts
    }

    DoLeft: {
        dex
        stx Player_PosX_Index       
        jsr Sounds.SFX_MOVE
        //jsr ResetTimers
        rts

    }

    DoRight: {
        inx 
        stx Player_PosX_Index
        jsr Sounds.SFX_MOVE
        rts
    }

    CharsPosition10: {
            //removehands
            lda Tiles.EMPTY
            ldx Tiles.HAND_1_UP + 1
            ldy Tiles.HAND_1_UP + 2
            jsr Map.SwitchCharAtXY

            lda Tiles.EMPTY
            ldx Tiles.HAND_1_DOWN + 1
            ldy Tiles.HAND_1_DOWN + 2
            jsr Map.SwitchCharAtXY

        rts    
    }

    CharsPosition01: {
            lda Game.PushButtonTimer + 0
            bne !return+
            //inc $d020
            //add hand
            lda Tiles.HAND_1_UP + 0
            ldx Tiles.HAND_1_UP + 1
            ldy Tiles.HAND_1_UP + 2
            jsr Map.SwitchCharAtXY
        !return:    
        rts    
    }


    CharsPosition11: {
            //removehands
            lda Tiles.EMPTY
            ldx Tiles.HAND_2_UP + 1
            ldy Tiles.HAND_2_UP + 2
            jsr Map.SwitchCharAtXY

            lda Tiles.EMPTY
            ldx Tiles.HAND_2_DOWN + 1
            ldy Tiles.HAND_2_DOWN + 2
            jsr Map.SwitchCharAtXY

        rts    
    }

    CharsPosition02: {
            lda Game.PushButtonTimer + 0
            bne !return+
            //inc $d020
            //add hand
            lda Tiles.HAND_2_UP + 0
            ldx Tiles.HAND_2_UP + 1
            ldy Tiles.HAND_2_UP + 2
            jsr Map.SwitchCharAtXY
        !return:    
        rts    
    }


    CharsPosition12: {
            //removehands
            lda Tiles.EMPTY
            ldx Tiles.HAND_3_UP + 1
            ldy Tiles.HAND_3_UP + 2
            jsr Map.SwitchCharAtXY

            lda Tiles.EMPTY
            ldx Tiles.HAND_3_DOWN + 1
            ldy Tiles.HAND_3_DOWN + 2
            jsr Map.SwitchCharAtXY

        rts    
    }

    CharsPosition03: {
            lda Game.PushButtonTimer + 0
            bne !return+
            //inc $d020
            //add hand
            lda Tiles.HAND_3_UP + 0
            ldx Tiles.HAND_3_UP + 1
            ldy Tiles.HAND_3_UP + 2
            jsr Map.SwitchCharAtXY
        !return:    
        rts    
    }

    CharsPosition13: {
            //removehands
            lda Tiles.EMPTY
            ldx Tiles.HAND_4_UP + 1
            ldy Tiles.HAND_4_UP + 2
            jsr Map.SwitchCharAtXY

            lda Tiles.EMPTY
            ldx Tiles.HAND_4_DOWN + 1
            ldy Tiles.HAND_4_DOWN + 2
            jsr Map.SwitchCharAtXY

        rts    
    }

    CharsPosition04: {
            lda Game.PushButtonTimer + 0
            bne !return+
            //inc $d020
            //add hand
            lda Tiles.HAND_4_UP + 0
            ldx Tiles.HAND_4_UP + 1
            ldy Tiles.HAND_4_UP + 2
            jsr Map.SwitchCharAtXY
        !return:    
        rts    
    }
}