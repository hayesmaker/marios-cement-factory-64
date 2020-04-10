TitleScreen: {

	.label screen_ram = $4c00
	.label sprite_pointers = screen_ram + $3f8

	.label GAME_A = $00
	.label GAME_B = $01
	.label PLAY_SELECTED = $04
	.label GAME_MODE_SELECTED = $03

	GameMode:
		.byte GAME_A

	FlashCounter:
		.byte $00
	DefaultFrame:
		.byte $40
	FrameA:
		.byte $41
	FrameB:
		.byte $42


	DebounceFlag:
		.byte $00
    DebounceFireFlag:
        .byte $00

    SelectorTableIndex:
    	.byte $04
    SelectorTable:
    	.byte 154, 170, 186, 202, 218
    SelectorTableWidth:
    	.byte $03,$03,$03,$03,$01	

	Initialise: {

		lda #RED
		sta VIC.SPRITE_COLOR_0
		sta VIC.SPRITE_COLOR_1
		lda #YELLOW
		sta VIC.SPRITE_COLOR_2

		//Multicolor mode sprites (1 for on 0 for hi-res)
		lda #%11111000
		sta $d01c 

		lda DefaultFrame + 0
		sta sprite_pointers + 0
		sta sprite_pointers + 1
		lda FrameA
		sta sprite_pointers + 2

		//double width
		lda #%00000011
		sta $D01D   
        //menu blink sprite enable    
		lda VIC.SPRITE_ENABLE 
		ora #%00000111
		sta VIC.SPRITE_ENABLE
        //block 1 enable sprite msb
        lda VIC.SPRITE_MSB
        and #%11111000
        sta VIC.SPRITE_MSB
        
        lda #104
        sta VIC.SPRITE_2_X
        lda #202
        sta VIC.SPRITE_2_Y


        lda #40
        sta VIC.SPRITE_0_X  

        lda #88
        sta VIC.SPRITE_1_X    

        ldy SelectorTableIndex
        lda SelectorTable, y
        sta VIC.SPRITE_0_Y
        sta VIC.SPRITE_1_Y 
   
		rts
	}

	DrawSprite: {            
		ldy SelectorTableIndex
        lda SelectorTable, y
        sta VIC.SPRITE_0_Y
        sta VIC.SPRITE_1_Y
        //double width
		lda SelectorTableWidth, y
		sta $D01D 

		//draw game A / B in menu
		lda FrameA
		clc
		adc GameMode
		sta sprite_pointers + 2 
		rts

	}

	Update: {
		jsr Control
		jsr Blink
		jsr DrawSprite
		rts
	}

	Blink: {
		//y position
		ldx #%00
		inc FlashCounter
		lda FlashCounter
		and #%00010000
		beq !NoFlash+
		ldx #%11
		!NoFlash:
		txa
		ora #%11111100
		sta VIC.SPRITE_ENABLE
		rts
	}


	Control: {
        .label JOY_PORT_2 = $dc00
        .label JOY_UP = %00001
        .label JOY_DN = %00010
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
        //doFire

        //CHANGE GAME MODE
        lda SelectorTableIndex
        cmp #PLAY_SELECTED
        bne !skip+
        	//jsr Entry
        !skip:
        cmp #GAME_MODE_SELECTED
        bne !skip+
        	lda GameMode
        	bne !+
        		lda #GAME_B
        		jmp !setGameMode+
        	!:
        		lda #GAME_A
        	!setGameMode:
        		sta GameMode
        		jsr DrawSprite
        !skip:
        //DO OTHER STUFF ON FIRE

        //Always call when fire pressed:
        inc DebounceFireFlag
    !movement:   
        //Check if we need debounce
        lda DebounceFlag
        beq !+
        //Otherwise check if we can turn it off
        lda JOY_ZP
        and #[JOY_LT + JOY_RT + JOY_UP + JOY_DN]
        cmp #[JOY_LT + JOY_RT + JOY_UP + JOY_DN]
        bne !end+

        lda #$00
        sta DebounceFlag
    !:
    !Up: 
    	lda JOY_ZP
    	and #JOY_UP
    	bne !+
    	inc DebounceFlag
    	//do up

    	lda SelectorTableIndex
    	beq !+
    	dec SelectorTableIndex
    	
    !:
    !Down:
    	lda JOY_ZP
    	and #JOY_DN
    	bne !+
    	inc DebounceFlag
    	//do down
    	lda SelectorTableIndex
    	cmp #04
    	beq !+
    	inc SelectorTableIndex
    	
    !:
    !Left:
        lda JOY_ZP
        and #JOY_LT
        bne !+

        inc DebounceFlag
        //move player left
    !:
    !Right:

        lda JOY_ZP
        and #JOY_RT
        bne !end+

        inc DebounceFlag              
        //move cursor right
    !end:
        rts
    }

}