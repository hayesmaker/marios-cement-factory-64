Options: {

	isMusicOn:
		.byte $01
	isSoundOn:
		.byte $01

	customBorder:
		.byte $0F	

	toggleMusic: {
		lda isMusicOn
		bne !turnOff+
			jsr Sounds.enableMusic
			lda #$01
			jmp !set+
		!turnOff:
			jsr Sounds.disableMusic
			lda #$00
		!set:	
		sta isMusicOn		
		rts
	}

	toggleSound: {
		lda isSoundOn
		bne !turnOff+
			lda #$01
			jmp !set+
		!turnOff:
			lda #$00
		!set:	
		sta isSoundOn		
		rts
	}

}