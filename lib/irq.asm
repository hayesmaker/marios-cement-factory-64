IRQ: {
	Setup: {
		sei
		lda VIC.INTERRUPT_CONTROL
		ora #%00000001
		sta VIC.INTERRUPT_CONTROL

		//routine called when interrupt triggers
		lda #<Titles
		ldx #>Titles
		sta $fffe //0314
		stx $ffff //0315

		lda #$ff
		sta VIC.RASTER_Y
		lda VIC.SCREEN_CONTROL_1
		and #%01111111
		sta VIC.SCREEN_CONTROL_1
		
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

	Titles: {
		
		:StoreState()
			jsr music_play
			asl VIC.INTERRUPT_STATUS
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
			//inc $d020
			//dec $d021
			lda #$01
			sta Game.PerformFrameCodeFlag

			jsr music_play
			asl VIC.INTERRUPT_STATUS
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