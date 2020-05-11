ScoreEntryScreen: {
  .label screen_ram = $c000
  .label sprite_pointers = screen_ram + $3f8

  .encoding "screencode_upper"
  MyLabel1: .text "GAME OVER@"
 
  scoresTableName:
    .text "HAYESMKR HAYESMKR HAYESMKR HAYESMKR"
  scoresTableVal:
    .word $03e8, $0384, $02bc, $01f4
  __scoresTableVal:
  scoresTableIndex:
    .byte $00
  scoreRows:
    .byte screen_ram + 5*40 + 7, screen_ram + 7*40 + 7, screen_ram + 9*40 + 7, screen_ram + 11*40 + 7
  
 shouldUpdate:
    .byte $00
  DebounceFlag:
    .byte $00
  DebounceFireFlag:
    .byte $00



	init: {

    //clear screen
        ldx #0
        lda #$20 //space character? (it said so on internet)
        !loop:   
        sta screen_ram,x
        sta screen_ram + 255,x
        sta screen_ram + 510,x
        sta screen_ram + 765,x
        dex
        bne !loop-
        //clear screen chars
        
        lda #$00
        sta VIC.SPRITE_ENABLE

        ldx #0
        !loop_colour:          
           lda #WHITE
           sta $D800, x        //Change colour? COLOR_RAM
           sta $D900, x
           sta $Da00, x
           sta $Db00, x

           inx
           cpx #$400
           bne !loop_colour-

        .label row1 = 1

        .label col1 = 15

        ldx #0
        !loop_text:  
           lda MyLabel1,x       //; read characters from line1 table of text..
           beq !next+
           sta screen_ram + row1*$28 + col1, x 
           inx
           jmp !loop_text-
        !next:


        rts
	}

  update: {
    jsr control
    
    rts
  }

  control: {
    .label JOY_PORT_2 = $dc00
    .label JOY_UP = %00001
    .label JOY_DN = %00010
    .label JOY_LT = %00100
    .label JOY_RT = %01000
    .label JOY_FIRE = %10000

    lda JOY_PORT_2
    sta JOY_ZP
    lda JOY_ZP
    and #JOY_FIRE
    beq !fireButtonPressed+

    lda #$00
    sta DebounceFireFlag
    jmp !movement+

    !fireButtonPressed:
    lda DebounceFireFlag
    bne !movement+
    !:
    !Fire:
    //doFire

    inc DebounceFireFlag
    !movement:   
    //Check if we need debounce
    lda DebounceFlag
    beq !+
    //Otherwise check if we can turn it off
    lda JOY_ZP
    and #[JOY_LT + JOY_RT + JOY_UP + JOY_DN]
    cmp #[JOY_LT + JOY_RT + JOY_UP + JOY_DN]
    bne !end+

    lda #$00
    sta DebounceFlag
    !:
    !Up: 
    lda JOY_ZP
    and #JOY_UP
    bne !+
    inc DebounceFlag
    //do up
   
    !:
    !Down:
    lda JOY_ZP
    and #JOY_DN
    bne !+
    inc DebounceFlag
    //do down
   
    !:
    !Left:
    lda JOY_ZP
    and #JOY_LT
    bne !+

    inc DebounceFlag
    //move player left

    !:
    !Right:

    lda JOY_ZP
    and #JOY_RT
    bne !end+

    inc DebounceFlag              
    //move cursor right
  
    !end:
    rts 
  }






}