DebugLift:
	.byte $00

Score:{

	currentScore: .byte $00, $00
	bonusOn: .byte 0
	scoreToAdd: .byte 0
	isBonus: .byte $00
	upperScore: .byte 1
	lowerScore: .byte 2


	Reset:{
		lda #$00
		sta currentScore + 0
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
		lda #1
		sta bonusOn
		lda #2
		sta upperScore
		lda #4
		sta lowerScore
		rts
	}

	DisableBonus: {
		lda #0
		sta bonusOn
		lda #1
		sta upperScore
		lda #2
		sta lowerScore
		rts
	}

	//DebugLift
	DebugLift: {
		lda DebugLift
		sta currentScore


		rts
	}

	/**
	* Ensure scoreToAdd is set before calling
	*/
	AddPoints: {
		sed
		lda currentScore
		clc
		adc scoreToAdd
		sta currentScore + 0
		lda currentScore+1
		adc #0
		sta currentScore+1
		cld
		rts
	}

	RenderScore: {
		

		lda currentScore
		and #$0f
		asl 
		clc
		adc Ui.NUMBER_WANG //#$60
		sta SCREEN_RAM + 133
		clc
		adc #$01
		sta SCREEN_RAM + 133 + 40

		lda currentScore
		lsr
		lsr 
		lsr 
		lsr 
		asl
		clc
		adc Ui.NUMBER_WANG
		sta SCREEN_RAM + 132
		clc
		adc #$01
		sta SCREEN_RAM + 132 + 40

		lda currentScore + 1
		and #$0f
		asl 
		clc
		adc Ui.NUMBER_WANG
		sta SCREEN_RAM + 131
		clc
		adc #$01
		sta SCREEN_RAM + 131 + 40

		rts
	}
}