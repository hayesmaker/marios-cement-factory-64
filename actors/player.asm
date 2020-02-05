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

    
       //Check if we need debounce
       lda DebounceFlag
       beq !Left+
       //Otherwise check if we can turn it off
       lda JOY_ZP
       and #[JOY_LT + JOY_RT]
       cmp #[JOY_LT + JOY_RT]
       bne !end+

       lda #$00
       sta DebounceFlag

    !Left:
        lda JOY_ZP
        and #JOY_LT
        bne !+

        inc DebounceFlag

        //move player left
        ldx Player_PosX_Index
        beq !+
    	dex
		stx Player_PosX_Index    	
    	lda Player_X, x
    	sta Pos_X

    	//todo: update frame
		lda DefaultFrame + 1
		clc
		adc Player_PosX_Index
        sta DefaultFrame + 0
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

        inx 
        stx Player_PosX_Index 
    	lda Player_X, x
    	sta Pos_X

    	//todo: update frame
		lda DefaultFrame + 1
		clc
		adc Player_PosX_Index
        sta DefaultFrame + 0
    !end:
        rts
    }
}