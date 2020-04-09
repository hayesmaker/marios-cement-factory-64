Titles: {

	.label screen_ram = $4c00
	.label sprite_pointers = screen_ram + $3f8

	FlashCounter:
		.byte $00
	DefaultFrame:
		.byte $40

	Initialise: {

		lda #RED
		sta VIC.SPRITE_COLOR_0
		sta VIC.SPRITE_COLOR_1

		lda #%11111100
		sta $d01c //Turn on bit 0 of MC for sprite 0 & 1

		lda DefaultFrame + 0
		sta sprite_pointers + 0
		sta sprite_pointers + 1

		//double width
		lda #%00000011
		sta $D01D   
        //menu blink sprite enable    
		lda VIC.SPRITE_ENABLE 
		ora #%00000011
		sta VIC.SPRITE_ENABLE
        //block 1 enable sprite msb
        lda VIC.SPRITE_MSB
        and #%11111100
        sta VIC.SPRITE_MSB
        lda #40
        sta VIC.SPRITE_0_X     
        lda #123
        sta VIC.SPRITE_0_Y

        lda #88
        sta VIC.SPRITE_1_X     
        lda #123
        sta VIC.SPRITE_1_Y

		inc $d020
		rts
	}

	Update: {
		ldx #%00
		inc FlashCounter
		lda FlashCounter
		and #%00010000
		beq !NoFlash+
		ldx #%11
		!NoFlash:
		txa
		ora #%11111100
		sta VIC.SPRITE_ENABLE
		rts
	}

}