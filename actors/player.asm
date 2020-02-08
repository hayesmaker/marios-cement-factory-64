PLAYER: {
	Pos_X:   //120
		.byte 236, $00
	Pos_Y:
		.byte 120

	Player_X: //0    1    2    3    4    5
		.byte 104, 132, 156, 190, 215, 238
	Player_X_MB:
		.byte 0, 0, 0, 0, 0, 0	
	Player_Y:
		.byte 120, 120, 120, 120, 120, 120
		
	Player_PosX_Index:
		.byte 0
	Player_PosY_Index:
		.byte 0    

	DefaultFrame:
		.byte $41, $41

	DebounceFlag:
		.byte $00
    DebounceFireFlag:
        .byte $00    

    //player state
    CanOpen:
        .byte $00


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


		ldx #0
		stx Player_PosX_Index
		stx Player_PosY_Index

		lda Player_X
		sta Pos_X
		lda Player_X_MB
		sta Pos_X + 1

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
        lda Pos_Y
        sta VIC.SPRITE_1_Y

        lda DefaultFrame + 0
        sta SPRITE_POINTERS + 1

        rts
    }

    Update: {		    	
		jsr PlayerControl
		jsr DrawSprite
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
        //inc $d021
        
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
        //can fire?
            //hand switch
        lda Tiles.EMPTY
        ldx Tiles.HAND_1_UP + 1
        ldy Tiles.HAND_1_UP + 2
        jsr MAPLOADER.SwitchCharAtXY

        //hand switch
        lda Tiles.HAND_1_DOWN + 0
        ldx Tiles.HAND_1_DOWN + 1
        ldy Tiles.HAND_1_DOWN + 2
        jsr MAPLOADER.SwitchCharAtXY

        rts
    }

    DoLeft: {
        dex
        stx Player_PosX_Index       
        lda Player_X, x
        sta Pos_X

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