Sounds: {
    enableMusic: {
        lda #$00
        jsr music_init
        rts
    }

    disableMusic: {
        lda #$03
        jsr music_init
        rts
    }

	SFX_SCORE: {
        lda Options.isSoundOn
        beq !return+
        lda #<SOUND_SCORE
        ldy #>SOUND_SCORE
        ldx #14 //0, 7 or 14
        jsr $1006
        !return:    
        rts
    }

    SFX_CRUNCH: {
        lda Options.isSoundOn
        beq !return+
        lda #<SOUND_CRUNCH
        ldy #>SOUND_CRUNCH
        ldx #14 //or 7 or 14
        jsr $1006
        !return:    
        rts
    }

    SFX_FALL: {
        lda Options.isSoundOn
        beq !return+
        lda #<SOUND_FALL
        ldy #>SOUND_FALL
        ldx #14 //or 7 or 14
        jsr $1006
        !return:
        rts
    }

    SFX_MOVE: {
        lda Options.isSoundOn
        beq !return+
         //play SOUND1
        lda #<SOUND_MOVE
        ldy #>SOUND_MOVE
        ldx #14 //or 7 or 14
        jsr $1006
        !return:
        rts
    }

    LIFT_TICK: {
        lda Options.isSoundOn
        beq !return+

        lda #<SOUND_TICK
        ldy #>SOUND_TICK
        ldx #14 //or 7 or 14
        jsr $1006
        !return:
        rts
    }
}