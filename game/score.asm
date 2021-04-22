DebugLift:
	.byte $00

Score:{

	.const UPPER_SCORE_DEFAULT = $01; 
	.const LOWER_SCORE_DEFAULT = $02;
	.const UPPER_SCORE_BONUS = $02;
	.const LOWER_SCORE_BONUS = $04;

	currentScore: .byte $00, $00
	bonusOn: .byte 0
	scoreToAdd: .byte 0
	isBonus: .byte $00
	hasBonusTriggered: .byte $00
	upperScore: .byte UPPER_SCORE_DEFAULT
	lowerScore: .byte LOWER_SCORE_DEFAULT
	scoreToggledOn: .byte 1

	Reset: {
		lda #0
		sta hasBonusTriggered

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

        jsr Game.checkBonusMusic
		lda #1
		sta Game.ScoreBlinkingTimer + 0
		lda Game.ScoreBlinkingTimer + 2
		sta Game.ScoreBlinkingTimer + 1

		lda #1
		sta bonusOn
		lda #UPPER_SCORE_BONUS
		sta upperScore
		lda #LOWER_SCORE_BONUS
		sta lowerScore
		!return:
		rts
	}

	DisableBonus: {

		lda bonusOn
		beq !return+

		lda #0
		sta Game.ScoreBlinkingTimer + 0
		lda #0
		sta bonusOn
		lda #UPPER_SCORE_DEFAULT
		sta upperScore
		lda #LOWER_SCORE_DEFAULT
		sta lowerScore

		lda #1
		sta scoreToggledOn
		jsr Game.checkMusic

		!return:
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
		lda currentScore + 1
		adc #0
		sta currentScore + 1

		//Check for a BONUS ROUND
		lda hasBonusTriggered
		bne !skipBonusChecking+
			lda currentScore + 1
			cmp #$03
			bcc !skipBonusChecking+
				lda #1
				sta hasBonusTriggered
				jsr EnableBonus
		!skipBonusChecking:
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