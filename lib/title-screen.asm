TitleScreen: {

	.label screen_ram = $4c00
	.label sprite_pointers = screen_ram + $3f8

	.label GAME_A = $01
	.label GAME_B = $02
	
    .label OPTIONS_SELECTED = $00
    .label HISCORE_SELECTED = $01
    .label CREDITS_SELECTED = $02
    .label GAME_MODE_SELECTED = $03
    .label PLAY_SELECTED = $04

    .const TITLE_SCREEN_LEN = 100
    .const TITLE_TARGET_Y = 65
    .const defaultFrame = $40

    .label MAIN_MENU = $ff

    SCREEN_MODE:
        .byte MAIN_MENU
    
    *=* "Tween Table"
    titlesTween:
        easeOutBounce(0, TITLE_TARGET_Y, TITLE_SCREEN_LEN)
    *=* "End Tween Table"    

    isAnimating:
        .byte $01
    titlesTweenIndex:
        .byte $00
    //@deprecated
    InTitleScreen:
        .byte $00
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


    /*
        
    */    
    //
	Initialise: {

        lda #1
        sta InTitleScreen

        lda #MAIN_MENU
        sta SCREEN_MODE
        
		lda #RED
		sta VIC.SPRITE_COLOR_0
		sta VIC.SPRITE_COLOR_1
	
        lda #defaultFrame + 0
        sta sprite_pointers + 0
        sta sprite_pointers + 1

		//Multicolor mode sprites (1 for on 0 for hi-res)
		lda #%00000000
		sta $d01c 

		//double width
		lda #%11111111
		sta $D01D   
        //menu blink sprite enable    
		lda #%11111111
		sta VIC.SPRITE_ENABLE
        //block 1 enable sprite msb
        lda #%00000000
        sta VIC.SPRITE_MSB

        // lda #0
        // sta titlesTweenIndex

        jsr initTitleSpritesPos

        // lda #1
        // sta isAnimating
        //***** SELECTOR SPRITES - not multiplexed
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

    setGameModeSprite: {
        //.const defaultFrame = $40
        //double width
        lda #%11111011
        sta $D01D   

        lda #YELLOW
        sta VIC.SPRITE_COLOR_2

        lda #defaultFrame
        clc
        adc GameMode
        sta sprite_pointers + 2 

        lda #104
        sta VIC.SPRITE_2_X
        lda #202
        sta VIC.SPRITE_2_Y

        rts
    }

    initTitleSpritesPos: {

        lda #40
        sta VIC.SPRITE_2_X
        lda #TITLE_TARGET_Y
        sta VIC.SPRITE_2_Y

        lda #88
        sta VIC.SPRITE_3_X
        lda #TITLE_TARGET_Y
        sta VIC.SPRITE_3_Y

        lda #136
        sta VIC.SPRITE_4_X
        lda #TITLE_TARGET_Y
        sta VIC.SPRITE_4_Y

        lda #40
        sta VIC.SPRITE_5_X
        lda #[TITLE_TARGET_Y + 21]
        sta VIC.SPRITE_5_Y

        lda #88
        sta VIC.SPRITE_6_X
        lda #[TITLE_TARGET_Y + 21]
        sta VIC.SPRITE_6_Y

        lda #136
        sta VIC.SPRITE_7_X
        lda #[TITLE_TARGET_Y + 21]
        sta VIC.SPRITE_7_Y

        rts
    }

    //Now called from IRQ 
    setTitleSprites: {
        //.const defaultFrame = $40
        lda #WHITE
        sta VIC.SPRITE_COLOR_2
        sta VIC.SPRITE_COLOR_3
        sta VIC.SPRITE_COLOR_4
        sta VIC.SPRITE_COLOR_5
        sta VIC.SPRITE_COLOR_6
        sta VIC.SPRITE_COLOR_7
    
        lda #defaultFrame + 3
        sta sprite_pointers + 2
        
        lda #defaultFrame + 4
        sta sprite_pointers + 3
        
        lda #defaultFrame + 5
        sta sprite_pointers + 4
        
        lda #defaultFrame + 6
        sta sprite_pointers + 5
        
        lda #defaultFrame + 7
        sta sprite_pointers + 6
        
        lda #defaultFrame + 8
        sta sprite_pointers + 7

        lda #40
        sta VIC.SPRITE_2_X
        
        lda #88
        sta VIC.SPRITE_3_X

        lda #136
        sta VIC.SPRITE_4_X

        lda #40
        sta VIC.SPRITE_5_X
       
        lda #88
        sta VIC.SPRITE_6_X
        
        lda #136
        sta VIC.SPRITE_7_X
        
        //double width
        lda #%11111111
        sta $D01D

        rts
    }

    setTitlePositions: {
        lda #40
        sta VIC.SPRITE_2_X
        lda #TITLE_TARGET_Y
        sta VIC.SPRITE_2_Y

        rts
    }


	DrawSprites: {            
		ldy SelectorTableIndex
        lda SelectorTable, y
        sta VIC.SPRITE_0_Y
        sta VIC.SPRITE_1_Y
		rts

	}

	Update: {
        lda SCREEN_MODE
        cmp #OPTIONS_SELECTED
        bne !skip+
            jsr OptionsScreen.update
        !skip:
        lda SCREEN_MODE
        cmp #CREDITS_SELECTED
        bne !skip+
            jsr Credits.update
        !skip:
        cmp #HISCORE_SELECTED
        bne !skip+
            jsr HiScores.update
        !skip:        
        lda InTitleScreen
        beq !skip+
    		jsr Blink
    		jsr DrawSprites
            // jsr AnimateTitle
            jsr Control
        !skip:
		rts
	}

    AnimateTitle: {
        lda isAnimating
        bne !skip+
            jsr setTitlePositions
            jmp !end+
        !skip:
        ldy titlesTweenIndex
        cpy #TITLE_SCREEN_LEN
        bne !skip+
            lda #0
            sta isAnimating
        !skip:
        lda titlesTween, y
        sta VIC.SPRITE_2_Y
        sta VIC.SPRITE_3_Y
        sta VIC.SPRITE_4_Y
        clc
        adc #21
        sta VIC.SPRITE_5_Y
        sta VIC.SPRITE_6_Y
        sta VIC.SPRITE_7_Y
        inc titlesTweenIndex
        
        !end:
        rts
    }

	Blink: {
        inc FlashCounter
        lda FlashCounter
        cmp #15  //FREQUENCY 
        bne !noFlash+
        lda #0
        sta FlashCounter
        lda VIC.SPRITE_ENABLE
        and #1
        beq !turnOn+
        lda VIC.SPRITE_ENABLE
        and #%11111100
        sta VIC.SPRITE_ENABLE
        rts
    !turnOn:
        lda VIC.SPRITE_ENABLE
        ora #%00000011
        sta VIC.SPRITE_ENABLE  
    !noFlash:
        rts
    }

    teardown: {
        //lda VIC.SPRITE_ENABLE 
        lda #%00000000
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
        //FIRE BUTTON DO CHANGES TO TITLE SCREEN
        lda SelectorTableIndex
        cmp #PLAY_SELECTED
        bne !skip+
            //Start the game
            jsr teardown
            lda #0
            sta Titles.STATE_IN_PROGRESS
        	//jsr Entry
        !skip:
        lda SelectorTableIndex
        cmp #GAME_MODE_SELECTED
        bne !skip+
    	lda GameMode
        cmp #GAME_B
        beq !+ 
            //menu blink sprite enable    
    		lda #GAME_B
    		jmp !setGameMode+
        	!:
    		lda #GAME_A
        	!setGameMode:                
    		sta GameMode
        		//jsr DrawSprites
        !skip:
        //DO OTHER STUFF ON FIRE
        lda SelectorTableIndex
        cmp #OPTIONS_SELECTED
        bne !skip+
            sta SCREEN_MODE
            sta InTitleScreen 
            jsr OptionsScreen.init
        !skip:
        lda SelectorTableIndex
        cmp #CREDITS_SELECTED
        bne !skip+
            sta SCREEN_MODE
            lda #0
            sta InTitleScreen
            jsr Credits.init
        !skip:
        lda SelectorTableIndex
        cmp #HISCORE_SELECTED
        bne !skip+
            sta SCREEN_MODE
            lda #0
            sta InTitleScreen
            jsr HiScores.init
        !skip:
        /*
        // 02 = HI-SCORE
        // 01 = CREDITS
        */
        //cmp 

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
        //inc $d020
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
        //inc $d020
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