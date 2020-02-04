PLAYER: {
	Pos_X:   //120
		.byte 100, $00
	Pos_Y:
		.byte 120

	Player_X:
		.byte 100, 88, 132, 165, 189
	Player_Y:
		.byte 120, 120, 120, 120, 120
		
	Player_PosX_Index:
		.byte 0
	Player_PosY_Index:
		.byte 0

	DefaultFrame:
		.byte $40, $40

	DebounceFlag:
		.byte $00	



	// .label STATE_FALL				= %00000010
	// .label STATE_WALK_LEFT 			= %00000100
	// .label STATE_WALK_RIGHT			= %00001000


	Initialise: {
		lda #$00
		sta VIC.SPRITE_COLOR_1
		sta VIC.SPRITE_COLOR_2

		lda #$41
		sta SPRITE_POINTERS + 1

		lda VIC.SPRITE_ENABLE 
		ora #%00000001
		sta VIC.SPRITE_ENABLE

		lda #$00
		sta VIC.SPRITE_MULTICOLOR


		ldx #0
		stx Player_PosX_Index
		stx Player_PosY_Index
		rts
	}

	DrawSprite: {
		.label CURRENT_FRAME = TEMP2
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
        rts
    }

    Update: {		    	
		jsr PlayerControl
		rts
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

        //todo: move player left
        dec $d020

        lda #$41
        sta DefaultFrame

        jmp !end+

    !:
    !Right:

        lda JOY_ZP
        and #JOY_RT
        bne !end+

        inc DebounceFlag
        //TODO: move player right
        inc $d020

        lda #$40
        sta DefaultFrame
        jmp !end+


    !end:
        rts
    }
}