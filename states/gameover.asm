GameOver: {
	

	shouldUpdate:
		.byte $00
	DebounceFlag:
		.byte $00
	DebounceFireFlag:
		.byte $00
    STATE_IN_PROGRESS:
        .byte $01

    deleteDebounceTimer:
        .byte 0, 250, 250
    


	entry: {

        lda #1
        sta STATE_IN_PROGRESS


        lda #0
        sta deleteDebounceTimer + 0
        lda deleteDebounceTimer + 2
        sta deleteDebounceTimer + 1
        //init joystick
        lda #$01
        sta DebounceFireFlag
        lda #$00
        sta DebounceFlag


	    //Turn off bitmap mode
        lda $d011
        and #%11011111
        sta $d011

        //VIC n stuff
        //set last VIC bank (to allow charset)
        lda #$00
        sta $dd00
        /*
        the fist 4 bits there : 0000 tell the vic the screen is at $c000
        the last 4 : 1110 tell it the chars are found at $f800
        */
        jsr GameOverScreen.init

         !TitleLoop:
            lda STATE_IN_PROGRESS
            beq !end+

            dec deleteDebounceTimer + 1    
            //Do OTHER STUFF
            jsr frameCode
            jsr GameOverScreen.update
        jmp !TitleLoop-

        !end:
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
        rts
    }

    frameCode: {

        lda deleteDebounceTimer + 0
        beq !next+
        lda deleteDebounceTimer + 1
        bne !next+
            jsr GameOverScreen.onDeleteTimeout
        !next:

        rts
    }

}