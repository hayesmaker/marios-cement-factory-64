SCORE:{


	CementScore: .byte 1, 2
	BonusScore: .byte 3

	Value: .byte 0, 0, 0	// H M L
	.label Amount = TEMP1
	
	.label CharacterSetStart = 232

	ScoreToAdd: .byte 0


	Reset:{

		lda #ZERO
		sta Value
		sta Value + 1
		sta Value + 2

		jsr Draw
		rts

	}

	AddToScore:{

		lda ScoreToAdd
		clc
		adc Amount
		sta ScoreToAdd
		rts


	}


	CheckScoreToAdd:{

		lda ScoreToAdd
		beq Finish

		dec ScoreToAdd
		lda #ONE
		jsr Add

		Finish:

		rts


	}

	Add: {

		sta Amount
		sed
		clc
		lda Value
		adc Amount
		sta Value
		lda Value+1
		adc #ZERO
		sta Value+1
		lda Value+2
		adc #ZERO
		sta Value+2
		cld
		jsr Draw
		//jsr SID.ScoreSound
		rts
	}

	Draw:{
		rts
	}
}