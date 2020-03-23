IRQ: {
	Setup: {
		sei
		lda #$7f
		sta $dc0d
		sta $dd0d

		lda VIC.INTERRUPT_CONTROL
		ora #%00000001
		sta VIC.INTERRUPT_CONTROL

		//routine called when interrupt triggers
		lda #<MainIRQ
		ldx #>MainIRQ
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

	MainIRQ: {
		
		:StoreState()
			inc GameCounter
			dec GameTimerTick
			dec PushButtonTimer + 1
			dec FallGuyTimer + 1
			//inc $d020
			//dec $d020
			
			lda #$01
			sta PerformFrameCodeFlag
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