BasicUpstart2(Entry)

#import "./lib/zeropage.asm"
#import "./lib/labels.asm"
#import "./lib/vic.asm"
#import "./lib/map.asm"
#import "./lib/irq.asm"
#import "./actors/cement-crates.asm"
#import "./actors/elevators.asm"

PerformFrameCodeFlag:
	.byte $00

						// current, currentMax, startValue
GameTimerTick:			.byte 50, 50, 50
GameCounter:			.byte $00
TickState:              .byte $03

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
    jsr ELEVATORS.Initialise
	
	
NewGame: {

    //
    lda $00
    sta GameCounter

    lda GameTimerTick + 2
    sta GameTimerTick + 0

    lda #$03
    sta TickState
    
    jsr CRATES.DrawSprite
    jsr ELEVATORS.DrawSprite


}


//Main Game loop
!Loop: 
	lda PerformFrameCodeFlag
	beq !Loop-
	dec PerformFrameCodeFlag

	//do Frame Code
	inc ZP_COUNTER
    jsr GameTick


	//end frame Code
jmp !Loop-

GameTick: {
    //every frame
    lda GameTimerTick
    bne !end+

    //every 50 frames (1 tick = 1 second)
    lda GameTimerTick + 1
    sta GameTimerTick
    inc GameCounter


    lda TickState
    cmp #$03
    beq !tick4+

    lda TickState
    cmp #$02
    beq !tick3+

    lda TickState
    cmp #$01
    beq !tick2+

    lda TickState
    beq !tick1+

    jsr ELEVATORS.Update

//4 tick stepper
!tick1:
    lda #$03
    sta TickState
    jmp !end+
!tick2:
    jmp !+
!tick3:
    jmp !+
!tick4:
    jsr CRATES.Update
    //Short Tick
    //inc $d021
!:
    dec TickState
!end:    
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
