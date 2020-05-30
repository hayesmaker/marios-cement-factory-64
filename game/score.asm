DebugLift:
	.byte $00

Score:{

	currentScore: .byte $40, $00
	bonusOn: .byte 0
	scoreToAdd: .byte 0
	isBonus: .byte $00
	upperScore: .byte 1
	lowerScore: .byte 2
	scoreToggledOn: .byte 1

	Reset:{
		lda #$00
		sta currentScore + 0
		lda #$00
		sta currentScore + 1
		rts
	}

	onUpperMixer: {
		lda upperScore
		sta scoreToAdd
		jsr AddPoints
		rts
	}

	onLowerMixer: {
		lda lowerScore
		sta scoreToAdd
		jsr AddPoints
		rts
	}

	EnableBonus: {
		lda Lives.LivesLost
		beq !skip+
			jsr Lives.AddLife
			jmp !return+
		!skip:

		lda #1
		sta Game.ScoreBlinkingTimer + 0
		lda Game.ScoreBlinkingTimer + 2
		sta Game.ScoreBlinkingTimer + 1

		lda #1
		sta bonusOn
		lda #2
		sta upperScore
		lda #4
		sta lowerScore
		!return:
		rts
	}

	DisableBonus: {
		lda #0
		sta Game.ScoreBlinkingTimer + 0
		lda #0
		sta bonusOn
		lda #1
		sta upperScore
		lda #2
		sta lowerScore
		rts
	}

	/**
	* Ensure scoreToAdd is set before calling
	*/
	AddPoints: {
		jsr Sounds.SFX_SCORE
		sed
		lda currentScore
		clc
		adc scoreToAdd
		sta currentScore + 0
		lda currentScore+1
		adc #0
		sta currentScore+1

		//if score added is 299 AND score goes to 301
		lda scoreToAdd
		cmp #2
		bne !skipTo300Check+

		lda currentScore + 0
		cmp #$01
		bne !skipTo300Check+
		lda currentScore + 1
		cmp #3
		bne !skipTo300Check+
			//check if player has a lost a life
			jsr EnableBonus	
		!skipTo300Check:
		//check if score is 300
		lda currentScore + 0
		bne !skip+
		//do stuff
		lda currentScore + 1
		cmp #3
		bne !skip+
			//check if player has a lost a life
			jsr EnableBonus
		!skip:



		cld
		rts
	}

	ToggleScore: {
		lda scoreToggledOn
		bne !setToZero+
			lda #1
			sta scoreToggledOn
			jmp !return+
		!setToZero:
		lda #0
		sta scoreToggledOn		
		!return:
		rts
	}

	RenderScore: {
		//Check if Score is Toggled or Not
		lda currentScore	
		and #$0f
		asl 
		clc
		adc Ui.NUMBER_WANG //#$60
		//score Blinking
		ldx scoreToggledOn
		bne !draw+
			lda Tiles.EMPTY
		!draw:		
		sta Game.SCREEN_RAM + 133
		clc
		adc #$01
		//score Blinking
		ldx scoreToggledOn
		bne !draw+
			lda Tiles.EMPTY
		!draw:	
		sta Game.SCREEN_RAM + 133 + 40

		lda currentScore
		lsr
		lsr 
		lsr 
		lsr 
		asl
		clc
		adc Ui.NUMBER_WANG  //.byte $60 //First char index for 0
		//score Blinking
		ldx scoreToggledOn
		bne !draw+
			lda Tiles.EMPTY
		!draw:		
		sta Game.SCREEN_RAM + 132
		clc
		adc #$01
		ldx scoreToggledOn
		bne !draw+
			lda Tiles.EMPTY
		!draw:		
		sta Game.SCREEN_RAM + 132 + 40
		ldx scoreToggledOn
		bne !draw+
			lda Tiles.EMPTY
		!draw:	
		lda currentScore + 1
		and #$0f
		asl 
		clc
		adc Ui.NUMBER_WANG
		ldx scoreToggledOn
		bne !draw+
			lda Tiles.EMPTY
		!draw:	
		sta Game.SCREEN_RAM + 131
		clc
		adc #$01
		ldx scoreToggledOn
		bne !draw+
			lda Tiles.EMPTY
		!draw:	
		sta Game.SCREEN_RAM + 131 + 40
		rts
	}
}