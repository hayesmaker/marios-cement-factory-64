PLAYER: {
	
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

    
    FramesTableIndex:
        .byte $00
    FramesTable: 
        .byte $00, $00, $ff, $ff, $00, $00, $00, $00
        .byte $00, $00, $50, $51, $00, $00, $00, $00
        .byte $41, $42, $43, $44, $45, $46, $00, $00
        .byte $47, $48, $49, $4a, $4b, $4c, $00, $00
        .byte $00, $4d, $4e, $4f, $00, $00, $00, $00
        .byte $00, $00, $ff, $ff, $00, $00, $00, $00

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

		lda DefaultFrame + 1
		sta DefaultFrame + 0
		sta SPRITE_POINTERS + 0

		lda VIC.SPRITE_ENABLE 
		ora #%00000001
		sta VIC.SPRITE_ENABLE

		lda #$00
		sta VIC.SPRITE_MULTICOLOR
        //initialise debounce flags
        sta DebounceFlag
        sta DebounceFireFlag

        ldy #2
        sty Player_PosY_Index

		ldy #1
		sty Player_PosX_Index
		
		rts
	}

    DrawSprite: {
        //x position index: Player_PosX_Index
        //x pixel coords table: Player_X
        ldy Player_PosX_Index
        lda Player_X, y
        sta VIC.SPRITE_0_X

        //crate 1 msb code
        lda VIC.SPRITE_MSB
        and #%11111110
        sta VIC.SPRITE_MSB

        ldy Player_PosX_Index
        lda Player_X_MB, y
        beq !+
        lda VIC.SPRITE_MSB
        ora #%00000001
        sta VIC.SPRITE_MSB
    !:
        ldy Player_PosY_Index
        lda Player_Y, y
        sta VIC.SPRITE_0_Y


        //y * 8 + x = table index
        lda FramesTableIndex
        tay
        lda FramesTable, y
        sta SPRITE_POINTERS + 0

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
		jsr CheckCharUpdates
		jsr DrawSprite
        
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
        sta PushButtonTimer + 0

        lda PushButtonTimer + 2
        sta PushButtonTimer + 1

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
            jsr MAPLOADER.SwitchCharAtXY

            //hand switch
            lda Tiles.EMPTY + 0
            ldx Tiles.HAND_1_DOWN + 1
            ldy Tiles.HAND_1_DOWN + 2
            jsr MAPLOADER.SwitchCharAtXY
        !:
        cmp #$02
        bne !+
            lda Tiles.HAND_2_UP + 0
            ldx Tiles.HAND_2_UP + 1
            ldy Tiles.HAND_2_UP + 2
            jsr MAPLOADER.SwitchCharAtXY

            //hand switch
            lda Tiles.EMPTY + 0
            ldx Tiles.HAND_2_DOWN + 1
            ldy Tiles.HAND_2_DOWN + 2
            jsr MAPLOADER.SwitchCharAtXY

        !:
        cmp #$03
        bne !+
            lda Tiles.HAND_3_UP + 0
            ldx Tiles.HAND_3_UP + 1
            ldy Tiles.HAND_3_UP + 2
            jsr MAPLOADER.SwitchCharAtXY

            //hand switch
            lda Tiles.EMPTY + 0
            ldx Tiles.HAND_3_DOWN + 1
            ldy Tiles.HAND_3_DOWN + 2
            jsr MAPLOADER.SwitchCharAtXY

         !:
        cmp #$04
        bne !+
            lda Tiles.HAND_4_UP + 0
            ldx Tiles.HAND_4_UP + 1
            ldy Tiles.HAND_4_UP + 2
            jsr MAPLOADER.SwitchCharAtXY

            //hand switch
            lda Tiles.EMPTY + 0
            ldx Tiles.HAND_4_DOWN + 1
            ldy Tiles.HAND_4_DOWN + 2
            jsr MAPLOADER.SwitchCharAtXY   
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

    Switch2Up: {
        //SWITCH_2_UP:
        lda Tiles.SWITCH_2_UP + 0
        ldx Tiles.SWITCH_2_UP + 1
        ldy Tiles.SWITCH_2_UP + 2
        jsr MAPLOADER.SwitchCharAtXY
        
        //SWITCH_2_DOWN:
        lda Tiles.EMPTY
        ldx Tiles.SWITCH_2_DOWN + 1
        ldy Tiles.SWITCH_2_DOWN + 2
        jsr MAPLOADER.SwitchCharAtXY

         //TRAP_1_OPEN
        lda Tiles.EMPTY
        ldx Tiles.TRAP_2_OPEN + 1
        ldy Tiles.TRAP_2_OPEN + 2
        jsr MAPLOADER.SwitchCharAtXY

        //TRAP_1_CLOSED
        lda Tiles.TRAP_2_CLOSED + 0
        ldx Tiles.TRAP_2_CLOSED + 1
        ldy Tiles.TRAP_2_CLOSED + 2
        jsr MAPLOADER.SwitchCharAtXY

        lda Tiles.TRAP_2_CLOSED_2 + 0
        ldx Tiles.TRAP_2_CLOSED_2 + 1
        ldy Tiles.TRAP_2_CLOSED_2 + 2

        jsr MAPLOADER.SwitchCharAtXY

        rts
    }

    Switch4Up: {
        //SWITCH_1_UP:
        lda Tiles.SWITCH_4_UP + 0
        ldx Tiles.SWITCH_4_UP + 1
        ldy Tiles.SWITCH_4_UP + 2
        jsr MAPLOADER.SwitchCharAtXY
        
        //SWITCH_1_DOWN:
        lda Tiles.EMPTY
        ldx Tiles.SWITCH_4_DOWN + 1
        ldy Tiles.SWITCH_4_DOWN + 2
        jsr MAPLOADER.SwitchCharAtXY

         //TRAP_1_OPEN
        lda Tiles.EMPTY
        ldx Tiles.TRAP_4_OPEN + 1
        ldy Tiles.TRAP_4_OPEN + 2
        jsr MAPLOADER.SwitchCharAtXY

        //TRAP_1_CLOSED
        lda Tiles.TRAP_4_CLOSED + 0
        ldx Tiles.TRAP_4_CLOSED + 1
        ldy Tiles.TRAP_4_CLOSED + 2
        jsr MAPLOADER.SwitchCharAtXY

        lda Tiles.TRAP_4_CLOSED_2 + 0
        ldx Tiles.TRAP_4_CLOSED_2 + 1
        ldy Tiles.TRAP_4_CLOSED_2 + 2

        jsr MAPLOADER.SwitchCharAtXY

        rts
    }

    Switch3Up: {
        //SWITCH_1_UP:
        lda Tiles.SWITCH_3_UP + 0
        ldx Tiles.SWITCH_3_UP + 1
        ldy Tiles.SWITCH_3_UP + 2
        jsr MAPLOADER.SwitchCharAtXY
        
        //SWITCH_1_DOWN:
        lda Tiles.EMPTY
        ldx Tiles.SWITCH_3_DOWN + 1
        ldy Tiles.SWITCH_3_DOWN + 2
        jsr MAPLOADER.SwitchCharAtXY

         //TRAP_1_OPEN
        lda Tiles.EMPTY
        ldx Tiles.TRAP_3_OPEN + 1
        ldy Tiles.TRAP_3_OPEN + 2
        jsr MAPLOADER.SwitchCharAtXY

        //TRAP_1_CLOSED
        lda Tiles.TRAP_3_CLOSED + 0
        ldx Tiles.TRAP_3_CLOSED + 1
        ldy Tiles.TRAP_3_CLOSED + 2
        jsr MAPLOADER.SwitchCharAtXY

        lda Tiles.TRAP_3_CLOSED_2 + 0
        ldx Tiles.TRAP_3_CLOSED_2 + 1
        ldy Tiles.TRAP_3_CLOSED_2 + 2

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
        jsr Mixers.CheckMixerDrop1

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
        
        rts
    }

    OpenHopper2: {
        jsr ResetTimers
        lda #ONE
        sta PushButtonTimer + 0
        lda Tiles.EMPTY
        ldx Tiles.HAND_2_UP + 1
        ldy Tiles.HAND_2_UP + 2
        jsr MAPLOADER.SwitchCharAtXY
        //hand switch
        lda Tiles.HAND_2_DOWN + 0
        ldx Tiles.HAND_2_DOWN + 1
        ldy Tiles.HAND_2_DOWN + 2
        jsr MAPLOADER.SwitchCharAtXY
        //REMOVE SWITCH_2_UP:
        lda Tiles.EMPTY + 0
        ldx Tiles.SWITCH_2_UP + 1
        ldy Tiles.SWITCH_2_UP + 2
        jsr MAPLOADER.SwitchCharAtXY
        //DRAW SWITCH_2_DOWN:
        lda Tiles.SWITCH_2_DOWN + 0
        ldx Tiles.SWITCH_2_DOWN + 1
        ldy Tiles.SWITCH_2_DOWN + 2
        jsr MAPLOADER.SwitchCharAtXY
        //TRAP_2_OPEN
        lda Tiles.TRAP_2_OPEN + 0
        ldx Tiles.TRAP_2_OPEN + 1
        ldy Tiles.TRAP_2_OPEN + 2
        jsr MAPLOADER.SwitchCharAtXY
        //TRAP_2_CLOSED
        lda Tiles.EMPTY + 0
        ldx Tiles.TRAP_2_CLOSED + 1
        ldy Tiles.TRAP_2_CLOSED + 2
        jsr MAPLOADER.SwitchCharAtXY
        rts
    }

    OpenHopper3: {
        jsr ResetTimers
        lda #ONE
        sta PushButtonTimer + 0
        lda Tiles.EMPTY
        ldx Tiles.HAND_3_UP + 1
        ldy Tiles.HAND_3_UP + 2
        jsr MAPLOADER.SwitchCharAtXY
        //hand switch
        lda Tiles.HAND_3_DOWN + 0
        ldx Tiles.HAND_3_DOWN + 1
        ldy Tiles.HAND_3_DOWN + 2
        jsr MAPLOADER.SwitchCharAtXY
        //SWITCH_3_UP:
        lda Tiles.EMPTY + 0
        ldx Tiles.SWITCH_3_UP + 1
        ldy Tiles.SWITCH_3_UP + 2
        jsr MAPLOADER.SwitchCharAtXY
        //SWITCH_3_DOWN:
        lda Tiles.SWITCH_3_DOWN + 0
        ldx Tiles.SWITCH_3_DOWN + 1
        ldy Tiles.SWITCH_3_DOWN + 2
        jsr MAPLOADER.SwitchCharAtXY
        //TRAP_3_OPEN
        lda Tiles.TRAP_3_OPEN + 0
        ldx Tiles.TRAP_3_OPEN + 1
        ldy Tiles.TRAP_3_OPEN + 2
        jsr MAPLOADER.SwitchCharAtXY
        //TRAP_3_CLOSED
        lda Tiles.EMPTY + 0
        ldx Tiles.TRAP_3_CLOSED + 1
        ldy Tiles.TRAP_3_CLOSED + 2
        jsr MAPLOADER.SwitchCharAtXY
        rts
    }

    OpenHopper4: {
        jsr ResetTimers
        lda #ONE
        sta PushButtonTimer + 0
        lda Tiles.EMPTY
        ldx Tiles.HAND_4_UP + 1
        ldy Tiles.HAND_4_UP + 2
        jsr MAPLOADER.SwitchCharAtXY
        //hand switch
        lda Tiles.HAND_4_DOWN + 0
        ldx Tiles.HAND_4_DOWN + 1
        ldy Tiles.HAND_4_DOWN + 2
        jsr MAPLOADER.SwitchCharAtXY
        //SWITCH_1_UP:
        lda Tiles.EMPTY + 0
        ldx Tiles.SWITCH_4_UP + 1
        ldy Tiles.SWITCH_4_UP + 2
        jsr MAPLOADER.SwitchCharAtXY
        //SWITCH_1_DOWN:
        lda Tiles.SWITCH_4_DOWN + 0
        ldx Tiles.SWITCH_4_DOWN + 1
        ldy Tiles.SWITCH_4_DOWN + 2
        jsr MAPLOADER.SwitchCharAtXY
        //TRAP_1_OPEN
        lda Tiles.TRAP_4_OPEN + 0
        ldx Tiles.TRAP_4_OPEN + 1
        ldy Tiles.TRAP_4_OPEN + 2
        jsr MAPLOADER.SwitchCharAtXY
        //TRAP_1_CLOSED
        lda Tiles.EMPTY + 0
        ldx Tiles.TRAP_4_CLOSED + 1
        ldy Tiles.TRAP_4_CLOSED + 2
        jsr MAPLOADER.SwitchCharAtXY
        rts
    }

    DoLeft: {
        dex
        stx Player_PosX_Index       
        //jsr ResetTimers
        rts

    }

    DoRight: {
        inx 
        stx Player_PosX_Index
        rts
    }

    CharsPosition10: {
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

    CharsPosition01: {
            lda PushButtonTimer + 0
            bne !return+
            //inc $d020
            //add hand
            lda Tiles.HAND_1_UP + 0
            ldx Tiles.HAND_1_UP + 1
            ldy Tiles.HAND_1_UP + 2
            jsr MAPLOADER.SwitchCharAtXY
        !return:    
        rts    
    }


    CharsPosition11: {
            //removehands
            lda Tiles.EMPTY
            ldx Tiles.HAND_2_UP + 1
            ldy Tiles.HAND_2_UP + 2
            jsr MAPLOADER.SwitchCharAtXY

            lda Tiles.EMPTY
            ldx Tiles.HAND_2_DOWN + 1
            ldy Tiles.HAND_2_DOWN + 2
            jsr MAPLOADER.SwitchCharAtXY

        rts    
    }

    CharsPosition02: {
            lda PushButtonTimer + 0
            bne !return+
            //inc $d020
            //add hand
            lda Tiles.HAND_2_UP + 0
            ldx Tiles.HAND_2_UP + 1
            ldy Tiles.HAND_2_UP + 2
            jsr MAPLOADER.SwitchCharAtXY
        !return:    
        rts    
    }


    CharsPosition12: {
            //removehands
            lda Tiles.EMPTY
            ldx Tiles.HAND_3_UP + 1
            ldy Tiles.HAND_3_UP + 2
            jsr MAPLOADER.SwitchCharAtXY

            lda Tiles.EMPTY
            ldx Tiles.HAND_3_DOWN + 1
            ldy Tiles.HAND_3_DOWN + 2
            jsr MAPLOADER.SwitchCharAtXY

        rts    
    }

    CharsPosition03: {
            lda PushButtonTimer + 0
            bne !return+
            //inc $d020
            //add hand
            lda Tiles.HAND_3_UP + 0
            ldx Tiles.HAND_3_UP + 1
            ldy Tiles.HAND_3_UP + 2
            jsr MAPLOADER.SwitchCharAtXY
        !return:    
        rts    
    }

    CharsPosition13: {
            //removehands
            lda Tiles.EMPTY
            ldx Tiles.HAND_4_UP + 1
            ldy Tiles.HAND_4_UP + 2
            jsr MAPLOADER.SwitchCharAtXY

            lda Tiles.EMPTY
            ldx Tiles.HAND_4_DOWN + 1
            ldy Tiles.HAND_4_DOWN + 2
            jsr MAPLOADER.SwitchCharAtXY

        rts    
    }

    CharsPosition04: {
            lda PushButtonTimer + 0
            bne !return+
            //inc $d020
            //add hand
            lda Tiles.HAND_4_UP + 0
            ldx Tiles.HAND_4_UP + 1
            ldy Tiles.HAND_4_UP + 2
            jsr MAPLOADER.SwitchCharAtXY
        !return:    
        rts    
    }

}