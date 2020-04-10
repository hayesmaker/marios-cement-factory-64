//VPTV
BasicUpstart2(main)

.const KOALA_TEMPLATE = "C64FILE, Bitmap=$0000, ScreenRam=$1f40, ColorRam=$2328, BackgroundColor=$2710"
.var picture = LoadBinary("./assets/maps/titles.kla", KOALA_TEMPLATE)

#import "./lib/title-screen.asm"

/**
    IN TITLE
**/
main:
* = * ""
        lda #%00111000    // $38
        sta $d018
        lda #%11011000    // $d8
        sta $d016
        lda #%00111011    // $3b
        sta $d011
        lda #%00000010
        sta $dd00

        lda #0
        sta $d020   // border
        lda #picture.getBackgroundColor()
        sta $d021   // background
        ldx #0
!loop:
        .for (var i=0; i<4; i++) {
           lda colorRam+i*$100,x
           sta $d800+i*$100,x
        }
        inx
        bne !loop-

        //init title screen sprite
        jsr TitleScreen.Initialise

        //Main Game loop
       !TitleLoop:
        lda #$ff
        cmp $d012
        bne *-3


        //DO MUSIC

        //Do OTHER STUFF
        jsr TitleScreen.Update
        jmp !TitleLoop-
        //inc $d020
        /*
        lda #$10
        bit $dc00
        bne *-3
                lda $d011
                and #%11011111
                sta $d011
        jmp Entry
        */

        

*=$4c00;            .fill picture.getScreenRamSize(), picture.getScreenRam(i)
*=$5000;            .import binary "./assets/sprites/titles.bin"
*=$5c00; colorRam:  .fill picture.getColorRamSize(), picture.getColorRam(i)
*=$6000;            .fill picture.getBitmapSize(), picture.getBitmap(i)


/**
    IN GAME

    /*
        Sprites MAP
        ************
        0: Player - Squashed0  00000001   11111110
        1: Cement-Crates0      00000010   11111101
        2: Cement-Crates1      00000100   11111011
        3: Poured-Cement0      00001000   11110111
        4: *                   00010000   11101111
        5: Squashed1           00100000   11011111
        6: *
        7: *
*/
#import "./lib/zeropage.asm"
#import "./lib/labels.asm"
#import "./lib/vic.asm"
#import "./lib/map.asm"
#import "./lib/irq.asm"
#import "./actors/mixers.asm"
#import "./actors/cement-crates.asm"
#import "./actors/elevators.asm"
#import "./actors/player.asm"
#import "./actors/poured-cement.asm"
#import "./game/constants.asm"
#import "./game/score.asm"
#import "./game/lives.asm"


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

	jsr Map.DrawMap
    jsr Lives.Initialise
    jsr ELEVATORS.Initialise
	jsr CRATES.Initialise
    jsr PouredCement.Initialise
    jsr Mixers.Initialise
    jsr PLAYER.Initialise
    //jsr VIC.ColourLastRow
    jsr Score.Reset
	
	
NewGame: {
    lda #$00
    sta GameCounter

    lda GameTimerTick + 2
    sta GameTimerTick + 0
    
    //Init Timers
    lda #0
    sta FallGuyTimer + 0
    lda FallGuyTimer + 2
    sta FallGuyTimer + 1

    lda #0
    sta PushButtonTimer + 0
    lda PushButtonTimer + 2
    sta PushButtonTimer + 1

    lda #0
    sta CementSpillTimer + 0
    lda CementSpillTimer + 2
    sta CementSpillTimer + 1

    lda MaxTickStates
    sta TickState
    
    jsr CRATES.DrawSprite
    jsr PLAYER.DrawSprite

    jsr Map.Initialise
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
    jsr FrameCode
	//end frame Code
    jmp !Loop-

GameTick: {
    //every frame
    lda PLAYER.IsPlayerDead
    beq !skip+
        jmp !end+
    !skip:
    //Check GameTimerTick and Do a GameTick onComplete
    lda GameTimerTick
    beq !doTick+
        jmp !end+
    !doTick:
    //every 50 frames (1 tick = 1 second)
    lda GameTimerTick + 1
    sta GameTimerTick
    inc GameCounter

    //Tick Switch Statement
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
    lda CementSpillTimer + 1
    bne !next+
        lda CementSpillTimer + 0
        beq !next+
            jsr PouredCement.NextSpill
    !next:        
    lda FallGuyTimer + 1
    bne !next+
        lda FallGuyTimer + 0
        beq !next+
            jsr PLAYER.NextFall
    !next:
    lda PushButtonTimer + 1
    bne !next+
        lda PushButtonTimer + 0
        beq !next+
            jsr PLAYER.ResetTimers
            jsr PLAYER.TimerButton1Reset
    !next:
    //jsr Score.DebugLift
    jsr Score.RenderScore        
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
