Game: {
	STATE_IN_PROGRESS:
        .byte $01

	SCREEN_RAM:
			.word $c000
	SPRITE_POINTERS:
			.word SCREEN_RAM + $3f8

	PerformFrameCodeFlag:
	.byte $00  
	
	FadeIndex:
		.byte $00, $07
	FadeToLightGrey:
		.byte $00, $06, $0b, $04, $0c, $0f, $0f, $0f
	FadeTimer:				.byte 0, 200, 200

							// current, currentMax, startValue
	GameTimerTick:			.byte 25, 25, 25
	                        //0: timer on: 1,0, 1: timer current frame: 50, 2: timer initial frame 
	PushButtonTimer:        .byte 0, 10, 10
	FallGuyTimer:           .byte 0, 35, 35
	CementSpillTimer:       .byte 0, 50, 50
	ScoreBlinkingTimer: 	.byte 0, 25, 25
	GameCounter:			.byte $00
	MaxTickStates:          .byte $07
	TickState:              .byte $00

	Random: {
        lda seed
        beq doEor
        asl
        beq noEor
        bcc noEor
    doEor:    
        eor #$1d
        eor $dc04
        eor $dd04
    noEor:  
        sta seed
        rts
    seed:
        .byte $62
    init:
        lda #$ff
        sta $dc05
        sta $dd05
        lda #$7f
        sta $dc04
        lda #$37
        sta $dd04

        lda #$91
        sta $dc0e
        sta $dd0e
        rts
	}

	teardown: {
        // lda VIC.SPRITE_ENABLE 
        // and #%00000011
        // sta VIC.SPRITE_ENABLE
        rts        
	}

	
	entry: {		
	 	lda #1
        sta STATE_IN_PROGRESS	

        sei
        lda #$01
        jsr music_init
        cli
		//Reset Sprites
		//Multicolor mode sprites (1 for on 0 for hi-res)
		lda #%00000000
		sta $d01c 
		//double width
		lda #%00000000
		sta $D01D

		//border & background colour
		lda #$00
		sta $d020 
		sta $d021  
		//inc $d020
		//Turn off bitmap mode
		lda $d011
        and #%11011111
        sta $d011

       
		//bank out BASIC & Kernal ROM
		lda $01    
		and #%11111000
		ora #%00000101
		sta $01
		jsr VIC.SetupRegisters	

		jsr Random.init
		jsr Map.DrawMap
	    jsr Lives.Initialise
	    jsr ELEVATORS.Initialise
		jsr CRATES.Initialise
	    jsr PouredCement.Initialise
	    jsr Mixers.Initialise
	    jsr PLAYER.Initialise
	    jsr Score.Reset

	    NewGame: {
	    	jsr VIC.SetupColours

		    lda #$00
		    sta GameCounter

		    lda GameTimerTick + 2
		    sta GameTimerTick + 0
		    
		    //Init Timers
		    lda #0
		    sta FallGuyTimer + 0
		    lda FallGuyTimer + 2
		    sta FallGuyTimer + 1

		    lda #0
		    sta PushButtonTimer + 0
		    lda PushButtonTimer + 2
		    sta PushButtonTimer + 1

		    lda #0
		    sta CementSpillTimer + 0
		    lda CementSpillTimer + 2
		    sta CementSpillTimer + 1

		    lda #0
		    sta ScoreBlinkingTimer + 0
		    lda ScoreBlinkingTimer + 2
		    sta ScoreBlinkingTimer + 1

		    lda MaxTickStates
		    sta TickState
		    
		    jsr CRATES.DrawSprite
		    jsr PLAYER.DrawSprite

		    jsr Map.Initialise
		}

		//Main Game loop
		!Loop:		
			lda PerformFrameCodeFlag
			beq !Loop-
			dec PerformFrameCodeFlag

			lda STATE_IN_PROGRESS
			bne !skip+				
				jmp !exitGame+
			!skip:

			//do Frame Code
			inc ZP_COUNTER
		    jsr PLAYER.Update
		    jsr GameTick
		    jsr FrameCode
			//end frame Code
		    jmp !Loop-

		GameTick: {
		    //every frame
		    lda PLAYER.IsPlayerDead
		    beq !skip+
		        jmp !end+
		    !skip:
		    //Check GameTimerTick and Do a GameTick onComplete
		    lda GameTimerTick
		    beq !doTick+
		        jmp !end+
		    !doTick:
		    //every 50 frames (1 tick = 1 second)
		    lda GameTimerTick + 1
		    sta GameTimerTick
		    inc GameCounter

		    //Tick Switch Statement
		    lda TickState
		    cmp #$07
		    beq !tick0+

		    lda TickState
		    cmp #$06
		    beq !tick1+

		    lda TickState
		    cmp #$05
		    beq !tick2+

		    lda TickState
		    cmp #$04
		    beq !tick3+

		    lda TickState
		    cmp #$03
		    beq !tick4+

		    lda TickState
		    cmp #$02
		    beq !tick5+

		    lda TickState
		    cmp #$01
		    beq !tick6+

		    lda TickState
		    beq !tick7+

		//MAIN GAME ACTIONS ON TICKS
		!tick0: 
		    //Reset TickState counter
		    jsr CRATES.Update1
		    //jsr Mixers.Update
		    jmp !+
		!tick1:
		    jsr ELEVATORS.Update2
		    jsr Mixers.Update
		    //play SOUND1
	        lda #<SOUND_TICK
	        ldy #>SOUND_TICK
	        ldx #14 //or 7 or 14
	        jsr $1006
		    //
		    jmp !+
		!tick2:
		    //
		    //jsr Mixers.Update
		    jmp !+
		!tick3:
		    jsr ELEVATORS.Update1
		    jsr Mixers.Update
		    //jsr ELEVATORS.Update2
		    //play SOUND1
	        lda #<SOUND_TICK
	        ldy #>SOUND_TICK
	        ldx #14 //or 7 or 14
	        jsr $1006
		    jmp !+
		!tick4:
		    jsr CRATES.Update2
		    //jsr Mixers.Update
		    //jsr CRATES.Update2
		    
		    jmp !+
		!tick5:
		    jsr ELEVATORS.Update2    
		    jsr Mixers.Update

		    //play SOUND1
	        lda #<SOUND_TICK
	        ldy #>SOUND_TICK
	        ldx #14 //or 7 or 14
	        jsr $1006
		    
		    jmp !+
		!tick6: 
		    //jsr Mixers.Update

		    jmp !+
		!tick7:
		    //tickstate = 0
		    lda MaxTickStates
		    sta TickState

		    jsr ELEVATORS.Update1
		    jsr Mixers.Update

		    //play SOUND1
	        lda #<SOUND_TICK
	        ldy #>SOUND_TICK
	        ldx #14 //or 7 or 14
	        jsr $1006
		        
		    jmp !end+
		    //jsr ELEVATORS.Update2
		!:  
		    dec TickState
		!end:    
		    rts
		}

		/**
		** Game Code you want Executed once per frame
		**/
		FrameCode: {		
		    lda CementSpillTimer + 1
		    bne !next+
		        lda CementSpillTimer + 0
		        beq !next+
		            jsr PouredCement.NextSpill
		    !next:        
		    lda FallGuyTimer + 1
		    bne !next+
		        lda FallGuyTimer + 0
		        beq !next+
		            jsr PLAYER.NextFall
		    !next:
		    lda PushButtonTimer + 1
		    bne !next+
		        lda PushButtonTimer + 0
		        beq !next+
		            jsr PLAYER.ResetTimers
		            jsr PLAYER.TimerButton1Reset
		    !next:
		    //jsr Score.DebugLift
		    lda ScoreBlinkingTimer + 1
		    bne !next+
		    	lda ScoreBlinkingTimer + 0
		    	beq !next+
		    		jsr Score.ToggleScore
		    		lda ScoreBlinkingTimer + 2
		    		sta ScoreBlinkingTimer + 1
		    !next:	
		    jsr Score.RenderScore        
		    rts        
		}

		!exitGame:
		jsr teardown
	   	rts
	}

}