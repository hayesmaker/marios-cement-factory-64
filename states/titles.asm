Titles: {
    .label screen_ram = $4c00
    .label sprite_pointers = screen_ram + $3f8

    .label GAME_A = $00
    .label GAME_B = $01
    .label PLAY_SELECTED = $04
    .label GAME_MODE_SELECTED = $03

    STATE_IN_PROGRESS:
        .byte $01

    GameMode:
        .byte GAME_A    

    FlashCounter:
        .byte $00
    DefaultFrame:
        .byte $40
    FrameA:
        .byte $41
    FrameB:
        .byte $42


    DebounceFlag:
        .byte $00
    DebounceFireFlag:
        .byte $00

    SelectorTableIndex:
        .byte $04
    SelectorTable:
        .byte 154, 170, 186, 202, 218
    SelectorTableWidth:
        .byte $03,$03,$03,$03,$01   
    
	entry: {
        lda #1
        sta STATE_IN_PROGRESS

        jsr checkMusic
        jsr IRQ.Setup
        jsr drawScreen
       
        //Main Game loop
        !TitleLoop:
            lda STATE_IN_PROGRESS
            beq !end+

            lda #$ff
            cmp $d012
            bne *-3
            //DO MUSIC

            //Do OTHER STUFF
            jsr TitleScreen.Update
        jmp !TitleLoop-

        !end: 
        rts
	}

    drawScreen: {
        // lda #$00
        // sta VIC.SPRITE_ENABLE
        //bitmap mode?
        lda #%00111000    // $38
        sta $d018
        lda #%11011000    // $d8
        sta $d016
        lda #%00111011    // $3b
        sta $d011
        //vic bank?
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

        rts
    }

    checkMusic: {
        lda Options.isMusicOn
        beq !noMusic+ 
        lda #$00
        jmp !set+
        !noMusic:
        lda #$03
        !set:
        jsr music_init

        lda #5
        jsr music_init + 9
        rts
    }

}