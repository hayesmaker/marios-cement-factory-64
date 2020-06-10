IRQ: {
	Setup: {
		sei	
		
		jsr DisableNMI

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

	DisableNMI: {
	    lda #<nmi
	    sta $fffa
	    lda #>nmi
	    sta $fffb
	    rts
	  nmi:
	    rti
	}

	SwitchToGame: {

		:StoreState()
		sei
		//routine called when interrupt triggers

		lda #0
     	sta $d012
		lda #<MainIRQ
		ldx #>MainIRQ
		sta $fffe //0314
		stx $ffff //0315

		asl VIC.INTERRUPT_STATUS

		cli
		:RestoreState()	
		rts
	}

	TitlesIRQHandler: {
		
		:StoreState()	
			sei

			lda TitleScreen.SCREEN_MODE
			cmp #TitleScreen.OPTIONS_SELECTED
			beq !skip+
				jsr TitleScreen.setTitleSprites	
				jsr TitleScreen.AnimateTitle
			!skip:

			jsr music_play
			
			lda #100
         	sta $d012
			lda #<TitlesIRQHandler2
			ldx #>TitlesIRQHandler2
			sta $fffe //0314
			stx $ffff //0315
			asl VIC.INTERRUPT_STATUS     // Acknowledge

			cli
		:RestoreState()	
		
		rti
	}


	TitlesIRQHandler2: {

		:StoreState()

		lda TitleScreen.SCREEN_MODE
		cmp #TitleScreen.OPTIONS_SELECTED
		beq !skip+
		jsr TitleScreen.setGameModeSprite
		!skip:

		sei

		lda #$00
     	sta $d012
		lda #<TitlesIRQHandler
		ldx #>TitlesIRQHandler
		sta $fffe //0314
		stx $ffff //0315
		asl VIC.INTERRUPT_STATUS

		cli
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
			dec Game.AlarmTimer + 1
			//inc $d020
			//dec $d021
			lda #$01
			sta Game.PerformFrameCodeFlag

			lda Game.isDukeMode
		    	bne !skip+
			jsr music_play
			!skip:
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