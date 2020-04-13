Sounds: {

	SFX_SCORE: {
        lda #<SOUND_SCORE
        ldy #>SOUND_SCORE
        ldx #14 //0, 7 or 14
        jsr $1006
            
        rts
    }

    SFX_SPLAT: {
        lda #<SOUND_CRUNCH
        ldy #>SOUND_CRUNCH
        ldx #14 //or 7 or 14
        jsr $1006
            
        rts
    }


    SFX_FALL: {
        lda #<SOUND_FALL
        ldy #>SOUND_FALL
        ldx #14 //or 7 or 14
        jsr $1006
            
        rts
    }

    SFX_MOVE: {
         //play SOUND1
            lda #<SOUND_MOVE
            ldy #>SOUND_MOVE
            ldx #14 //or 7 or 14
            jsr $1006

        rts
    }
}