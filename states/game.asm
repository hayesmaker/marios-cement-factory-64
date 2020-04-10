Game: {
	* = $d000 "Sprites"
		.import binary "../assets/sprites/sprites.bin"

	* = $b000 "Map data"
	MAP_TILES: 
		.import binary "../assets/maps/mcf-bg - Tiles.bin"

	CHAR_COLORS: 
		.import binary "../assets/maps/mcf-bg - CharAttribs.bin"

	MAP: 
		.import binary "../assets/maps/mcf-bg - Map (20x13).bin"

	* = $f000 "Charset"
		.import binary "../assets/maps/mcf-bg - Chars.bin"

	SCREEN_RAM:
			.word $c000
	SPRITE_POINTERS:
			.word SCREEN_RAM + $3f8

	PerformFrameCodeFlag:
	.byte $00  
							// current, currentMax, startValue
	GameTimerTick:			.byte 25, 25, 25
	                        //0: timer on: 1,0, 1: timer current frame: 50, 2: timer initial frame 
	PushButtonTimer:        .byte 0, 10, 10
	FallGuyTimer:           .byte 0, 35, 35
	CementSpillTimer:       .byte 0, 50, 50


	GameCounter:			.byte $00
	MaxTickStates:          .byte $07
	TickState:              .byte $00

	Random: {
        lda seed
        beq doEor
        asl
        beq noEor
        bcc noEor
    doEor:    
        eor #$1d
        eor $dc04
        eor $dd04
    noEor:  
        sta seed
        rts
    seed:
        .byte $62


    init:
        lda #$ff
        sta $dc05
        sta $dd05
        lda #$7f
        sta $dc04
        lda #$37
        sta $dd04

        lda #$91
        sta $dc0e
        sta $dd0e
        rts
}

	
	entry: {

		// jsr IRQ.Setup
		// //bank out BASIC & Kernal ROM
		// lda $01    
		// and #%11111000
		// ora #%00000101
		// sta $01

		// jsr Random.init

		// jsr VIC.SetupRegisters
		// jsr VIC.SetupColours

		// jsr Map.DrawMap
	 //    jsr Lives.Initialise
	 //    jsr ELEVATORS.Initialise
		// jsr CRATES.Initialise
	 //    jsr PouredCement.Initialise
	 //    jsr Mixers.Initialise
	 //    jsr PLAYER.Initialise
	 //    //jsr VIC.ColourLastRow
	 //    jsr Score.Reset

	   
	}

}