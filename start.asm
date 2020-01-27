BasicUpstart2(Entry)

#import "./lib/zeropage.asm"
#import "./lib/labels.asm"
#import "./lib/vic.asm"
#import "./lib/map.asm"
#import "./lib/irq.asm"
#import "./actors/cement-crates.asm"

PerformFrameCodeFlag:
	.byte $00

						// current, currentMax, startValue
GameTimerTick:			.byte 50, 50, 50
GameCounter:			.byte $00

SpeedIncreaseCounter: 	.byte 48, 48

.label MaxSpeed = 13

Entry:

	jsr IRQ.Setup

	//bank out BASIC & Kernal ROM
	lda $01    
	and #%11111000
	ora #%00000101
	sta $01

	jsr Random.init

	jsr VIC.SetupRegisters
	jsr VIC.SetupColours

	jsr MAPLOADER.DrawMap
	jsr CRATES.Initialise
	
	
NewGame: {

    //
    lda $00
    sta GameCounter

    lda GameTimerTick + 2
    sta GameTimerTick + 0
    
    //jsr CRATES.DrawSprite


}


//Main Game loop
!Loop: 
	lda PerformFrameCodeFlag
	beq !Loop-
	dec PerformFrameCodeFlag

	//do Frame Code
	inc ZP_COUNTER
    jsr GameTick


	//end frame code
jmp !Loop-

GameTick: {

    lda GameTimerTick
    bne !+

    lda GameTimerTick + 1
    sta GameTimerTick

    inc GameCounter

    //Short Tick

    jsr CRATES.Update

    //inc $d021

    !:  
    rts
}

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

#import "./lib/assets.asm"
