Game: {
	STATE_IN_PROGRESS:
        .byte $01

	.label SCREEN_RAM = $c000
	.label SPRITE_POINTERS = SCREEN_RAM + $3f8

	PerformFrameCodeFlag:
	.byte $00  
	//30 frames per tick
	.label FRAMES_PER_TICK = 20
							// current, currentMax, startValue
	GameTimerTick:			.byte FRAMES_PER_TICK, FRAMES_PER_TICK, FRAMES_PER_TICK
	                        //0: timer on: 1,0, 1: timer current frame: 50, 2: timer initial frame 
	PushButtonTimer:        .byte 0, 10, 10
	FallGuyTimer:           .byte 0, 35, 35
	CratePourTimer1:		.byte 0, 15, 15
	CratePourTimer2: 		.byte 0, 15, 15
	CementSpillTimer:       .byte 0, 50, 50
	ScoreBlinkingTimer: 	.byte 0, 25, 25
	AlarmTimer: 			.byte 0, 10, 10
	GameCounter:			.byte $00
	MaxTickStates:          .byte $07
	TickState:              .byte $00

	SpeedIncreaseTable:	
		.byte $00, $01, $02, $03, $04, $05, $06, $07, $08
			//.byte 16, 16, 16, 16, 16, 16, 16, 16, 16, 16

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
        //lda VIC.SPRITE_ENABLE 
        lda #%00000000
        sta VIC.SPRITE_ENABLE
        rts        
	}

	
	entry: {	
	 	lda #1
        sta STATE_IN_PROGRESS	

        //Turn Off Bitmap Mode
		lda $d011
        and #%11011111
        sta $d011

       	jsr checkMusic
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
       
		//bank out BASIC & Kernal ROM
		lda $01    
		and #%11111000
		ora #%00000101
		sta $01
		jsr VIC.SetupRegisters	

		jsr Random.init
		jsr Map.DrawMap

	    jsr Lives.Initialise
	    jsr Elevators.Initialise
		jsr Crates.Initialise
	    jsr PouredCement.Initialise
	    jsr Mixers.Initialise
	    jsr PLAYER.Initialise
	    jsr Score.Reset

	    NewGame: {
	    	jsr VIC.SetupColours

		    lda #$00
		    sta GameCounter

		    lda GameTimerTick + 2
		    sta GameTimerTick + 1
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

		    lda #0
		    sta CratePourTimer1 + 0
		    lda CratePourTimer1 + 2
		    sta CratePourTimer1 + 1

		    lda #0
		    sta CratePourTimer2 + 0
		    lda CratePourTimer2 + 2
		    sta CratePourTimer2 + 1

		    lda MaxTickStates
		    sta TickState
		    
		    jsr Crates.DrawSprite1
		    jsr Crates.DrawSprite2
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
		    //inc $d020
		    //every 50 frames (1 tick = 1 second)
		    // set level number and subtract from GameTimerTick
		    lda Score.currentScore + 1
		    and #$0f
		    asl 
		    // cmp #8
		    // beq !skip+
			   //  clc 
			   //  adc TitleScreen.GameMode //Adds 0 | 1 : GameA |  GameB
		    // !skip:
		    tay

		    lda GameTimerTick + 1
		    sec 
		    sbc SpeedIncreaseTable, y 
		    sta GameTimerTick + 0
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
		    jsr Crates.Update1
		    jmp !+
		!tick1:
		    jsr Elevators.Update1
		    jsr Mixers.Update
	        jsr Sounds.LIFT_TICK
		    //
		    jmp !+
		!tick2:
		    //
		    //jsr Mixers.Update
		    jmp !+
		!tick3:
		    jsr Elevators.Update2
		    jsr Mixers.Update
	        jsr Sounds.LIFT_TICK

		    jmp !+
		!tick4:
		    jsr Crates.Update2
		    jmp !+
		!tick5:
		    jsr Elevators.Update1
		    jsr Mixers.Update
	        jsr Sounds.LIFT_TICK
		
		    jmp !+
		!tick6: 
		    jmp !+
		!tick7:
		    lda MaxTickStates
		    sta TickState

		    jsr Elevators.Update2
		    jsr Mixers.Update
	       	jsr Sounds.LIFT_TICK		        
		    jmp !end+
		!:  
		    dec TickState
		!end:    
		    rts
		}

		/**
		** Game Code you want Executed once per frame
		**/
		FrameCode: {
			lda CratePourTimer1 + 0
			beq !next+
				lda CratePourTimer1 + 1
				bne !next+
					jsr Crates.pourInterval1
			!next:
			lda CratePourTimer2 + 0
			beq !next+
				lda CratePourTimer2 + 1
				bne !next+
					jsr Crates.pourInterval2
			!next:
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
		    lda PLAYER.IsPlayerDead
	    	beq !skip+
	    		lda #0
	    		sta AlarmTimer + 0
	    		jmp !end+
	    	!skip:
		    jsr Mixers.checkFullMixers
		    lda AlarmTimer + 0
			beq !end+
				lda AlarmTimer + 1
				bne !end+
					jsr Sounds.SFX_SCORE
					lda AlarmTimer + 2
					sta AlarmTimer + 1
			!end:
		    rts        
		}

		!exitGame:
		jsr teardown
	   	rts
	}

	checkBonusMusic: {
		lda Options.isMusicOn
        beq !noMusic+ 
            lda #$02
        jmp !set+
        !noMusic:
        lda #$03
        !set:
        jsr music_init

		rts
	}

	checkMusic: {
		lda Options.isMusicOn
       	beq !noMusic+ 
        	lda #$01
        	jmp !set+
        !noMusic:
        lda #$03
        !set:
        jsr music_init
        rts
	}

}