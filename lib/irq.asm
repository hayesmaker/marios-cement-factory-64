IRQ: {
	Setup: {
		sei	
		//disable CIA Interrupts 
		lda #$7f
		sta $dc0d
		sta $dd0d

		lda $dc0d     // read interupts to clear them
        lda $dd0d

		lda #1
		sta $d01a

		//routine called when interrupt triggers
		lda #<TitlesIRQHandler
		ldx #>TitlesIRQHandler
		sta $fffe //0314
		stx $ffff //0315

		lda #$00
		sta VIC.RASTER_Y		
		asl VIC.INTERRUPT_STATUS
		cli

		rts
	}

	SwitchToGame: {
		sei
		//routine called when interrupt triggers
		lda #<MainIRQ
		ldx #>MainIRQ
		sta $fffe //0314
		stx $ffff //0315

		cli
		rts
	}

	TitlesIRQHandler: {
		
		:StoreState()			
			jsr TitleScreen.setTitleSprites	
			jsr TitleScreen.AnimateTitle
			
			jsr music_play
			
			lda #100
         	sta $d012
			lda #<TitlesIRQHandler2
			ldx #>TitlesIRQHandler2
			sta $fffe //0314
			stx $ffff //0315
			lsr VIC.INTERRUPT_STATUS     // Acknowledge
		:RestoreState()	
		
		rti
	}


	TitlesIRQHandler2: {

		:StoreState()

		jsr TitleScreen.setGameModeSprite

		lda #$00
     	sta $d012
		lda #<TitlesIRQHandler
		ldx #>TitlesIRQHandler
		sta $fffe //0314
		stx $ffff //0315
		lsr VIC.INTERRUPT_STATUS
		:RestoreState()	
		
		rti
	}

	MainIRQ: {
		
		:StoreState()
			inc Game.GameCounter
			dec Game.GameTimerTick
			dec Game.PushButtonTimer + 1
			dec Game.FallGuyTimer + 1
			dec Game.CementSpillTimer + 1
			dec Game.ScoreBlinkingTimer + 1
			dec Game.CratePourTimer1 + 1
			dec Game.CratePourTimer2 + 1
			//inc $d020
			//dec $d021
			lda #$01
			sta Game.PerformFrameCodeFlag

			jsr music_play
			lsr VIC.INTERRUPT_STATUS      // **********************8
		:RestoreState()	
		
		rti
	}
}

.macro StoreState() {
	pha //A
	txa
	pha //X
	tya
	pha //Y
}

.macro RestoreState() {
	pla
	tay
	pla
	tax
	pla
}