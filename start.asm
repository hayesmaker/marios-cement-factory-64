BasicUpstart2(Entry)

#import "./lib/zeropage.asm"
#import "./lib/labels.asm"
#import "./lib/vic.asm"
#import "./lib/map.asm"
#import "./lib/irq.asm"
#import "./actors/mixers.asm"
#import "./actors/cement-crates.asm"
#import "./actors/elevators.asm"
#import "./actors/player.asm"
#import "./actors/mixer-cements.asm"
#import "./game/constants.asm"

PerformFrameCodeFlag:
	.byte $00  

						// current, currentMax, startValue
GameTimerTick:			.byte 27, 27, 27
PushButtonTimer:        .byte 0, 10, 10

GameCounter:			.byte $00
MaxTickStates:          .byte $07
TickState:              .byte $00

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
    jsr ELEVATORS.Initialise
	jsr CRATES.Initialise
    jsr MixerCements.Initialise
    jsr Mixers.Initialise
    jsr PLAYER.Initialise
    //jsr VIC.ColourLastRow
	
	
NewGame: {
    
    //
    lda #$00
    sta GameCounter

    lda GameTimerTick + 2
    sta GameTimerTick + 0

    jsr PLAYER.ResetTimers

    lda MaxTickStates
    sta TickState
    
    jsr CRATES.DrawSprite
    jsr PLAYER.DrawSprite

    // ldx #$09
    // ldy #$0A
    // jsr MAPLOADER.ColorByXY
    jsr MAPLOADER.Initialise
    //jsr MixerCements.DrawSprite

    //jsr ELEVATORS.DrawSprite
    //jsr ELEVATORS.DrawSprite2


}


//Main Game loop
!Loop:
	lda PerformFrameCodeFlag
	beq !Loop-
	dec PerformFrameCodeFlag

	//do Frame Code
	inc ZP_COUNTER
    jsr PLAYER.Update
    jsr GameTick

    


	//end frame Code
jmp !Loop-

GameTick: {

    //every frame
    lda PushButtonTimer + 0
    beq !+
    jsr FrameCode

!:
    lda GameTimerTick
    beq !doTick+
        jmp !end+
    !doTick:

    //every 50 frames (1 tick = 1 second)
    lda GameTimerTick + 1
    sta GameTimerTick
    inc GameCounter

    lda TickState
    cmp #$07
    beq !tick0+

    lda TickState
    cmp #$06
    beq !tick1+

    lda TickState
    cmp #$05
    beq !tick2+

    lda TickState
    cmp #$04
    beq !tick3+

    lda TickState
    cmp #$03
    beq !tick4+

    lda TickState
    cmp #$02
    beq !tick5+

    lda TickState
    cmp #$01
    beq !tick6+

    lda TickState
    beq !tick7+


//MAIN GAME ACTIONS ON TICKS
!tick0: 
    //Reset TickState counter
    jsr CRATES.Update1
    //jsr Mixers.Update
    jmp !+
!tick1:
    jsr ELEVATORS.Update2
    jsr Mixers.Update
    //
    jmp !+
!tick2:
    //
    //jsr Mixers.Update
    jmp !+
!tick3:
    jsr ELEVATORS.Update1
    jsr Mixers.Update
    //jsr ELEVATORS.Update2
    jmp !+
!tick4:
    jsr CRATES.Update2
    //jsr Mixers.Update
    //jsr CRATES.Update2
    
    jmp !+
!tick5:
    jsr ELEVATORS.Update2    
    jsr Mixers.Update
    
    jmp !+

!tick6: 
    //jsr Mixers.Update

    jmp !+
!tick7:
    //tickstate = 0
    lda MaxTickStates
    sta TickState

    jsr ELEVATORS.Update1
    jsr Mixers.Update
        
    jmp !end+
    //jsr ELEVATORS.Update2
!:
    dec TickState
!end:    
    rts
}

/**
** Game Code you want Executed once per frame
**/
FrameCode: {

    lda PushButtonTimer + 1
    bne !end+

        jsr PLAYER.ResetTimers
        jsr PLAYER.TimerButton1Reset

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
