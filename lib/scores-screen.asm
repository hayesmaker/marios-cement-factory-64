HiScores: {
  .label screen_ram = $c000
  .label sprite_pointers = screen_ram + $3f8
  .label WHITE_SPACE_CHAR = 32
  
  rowScreenTable: .fillword 25, screen_ram + (i * 40)

  .encoding "screencode_upper"
    MyLabel1: .text "HIGH SCORES@"
    MyLabel2: .text "PRESS FIRE@"
  scoresTableName:
   .text "HAYESMKR@AMKNIGHT@SHALLAN @STEPZ   @"
  __scoresTableName:
  
  NUMBERWANG:
    .byte $30 //First char index for 0
  scoresTableIndex:
     .byte $00
  rowIndex:
     .byte $00

  scoresTableHB:
    .byte $09, $07, $04, $03
  scoresTableLB:
    .byte $99, $00, $50, $00
  __scoresTable:  

  scoreTemp:
      .byte $00, $00
    
  shouldUpdate:
    .byte $00
  DebounceFireFlag:
    .byte $01
  DebounceFlag:
    .byte $00    

	init: {
        lda #1
        sta shouldUpdate
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
        lda #%00001110
        sta $d018

        //border & background colour
        lda #BLACK
        sta $d020   // border
        lda #RED
        sta $d021   // background
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
           cpx #0
           bne !loop_colour-

        .label row1 = 1
        .label row2 = 5
        .label row3 = 8
        .label row4 = 11
        .label row5 = 20

        .label col1 = 14
        .label col2 = 2
        .label col3 = 7
        .label col4 = 7
        .label col5 = 14

        ldx #0
        !loop_text:  
           lda MyLabel1,x       //; read characters from line1 table of text..
           beq !next+
           sta screen_ram + row1*$28 + col1, x
           inx
           jmp !loop_text-
        !next:
        jsr drawNames
        jsr drawScore
        jsr drawContinueMessage
		rts
	}

drawContinueMessage: {
  .label row = 20
  .label col = 14

   ldx #0
   !loop_text:  
      lda MyLabel2,x       //; read characters from line1 table of text..
      beq !next+
      sta screen_ram + row*$28 + col, x 
      inx  
      jmp !loop_text-
    !next:

        rts
    }

  drawScore: {
    //.label scoreTemp = TEMP8
    .label screenramTemp = TEMP9
    .label digitIndexCount = TEMP11
    .label START_ROW = 5
    .label START_COL = 28

    lda #0
    sta scoresTableIndex
    sta digitIndexCount
    lda #START_ROW
    sta rowIndex

    !loop_score:
    lda rowIndex
    asl
    tay
    lda rowScreenTable, y 
    sta screenramTemp
    lda rowScreenTable + 1, y
    sta screenramTemp + 1

    ldy scoresTableIndex
    cpy #[__scoresTable - scoresTableLB]
    beq !end+

    //get score
    lda scoresTableLB, y
    sta scoreTemp + 0
    lda scoresTableHB, y
    sta scoreTemp + 1

    //start col
    lda digitIndexCount
    clc
    adc #START_COL
    tay

    //y has start col
    //lda digitIndexCount

    //units
    lda scoreTemp
    and #$0f
    clc
    adc NUMBERWANG //$30
    sta (screenramTemp), y

    dey
    //tens
    lda scoreTemp
    lsr
    lsr 
    lsr 
    lsr 
    clc
    adc NUMBERWANG  //.byte $30 //First char index for 0 
    sta (screenramTemp), y

    dey
    
    //hundreds
    lda scoreTemp + 1
    and #$0f
    clc
    adc NUMBERWANG
    sta (screenramTemp), y

    dey
    
    //thousands
    lda scoreTemp + 1
    lsr
    lsr 
    lsr 
    lsr
    clc
    adc NUMBERWANG  // $30: start index of numbers (char: 0)
    sta (screenramTemp), y

    inc scoresTableIndex
    inc rowIndex
    inc rowIndex
    jmp !loop_score-

    !end:
    rts
  }

  drawNames: {
    //.label scoreCharTemp = TEMP7
    .label screenramTemp = TEMP10
    .label wordIndexCount = TEMP5
    .label START_ROW = 5
    .label START_COL = 10

    lda #0
    sta scoresTableIndex
    sta wordIndexCount
    lda #START_ROW
    sta rowIndex

    !loop_char:
    ldx scoresTableIndex
    lda rowIndex
    asl
    tay
    lda rowScreenTable, y
    sta screenramTemp
    lda rowScreenTable + 1, y
    sta screenramTemp + 1
    
    ldy scoresTableIndex
    cpy #[__scoresTableName - scoresTableName]
    beq !end+
    
    lda scoresTableName, y  //Get letter

    beq !loop_row+

    //letter x position adc START_COL to indent
    lda wordIndexCount
    clc
    adc #START_COL
    tay

    ldx scoresTableIndex
    lda scoresTableName, x  //Get letter (again!)
    sta (screenramTemp), y  //print letter

    inc scoresTableIndex
    inc wordIndexCount
    jmp !loop_char-

    !loop_row:
    inc scoresTableIndex
    lda #0
    sta wordIndexCount
    inc rowIndex
    inc rowIndex
    jmp !loop_char-
    !end:
    rts
  }

  update: {
    //inc $d020
    jsr control
    //jsr drawSprites
    jsr keyControl
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
    lda JOY_ZP
    and #JOY_FIRE
    bne !movement+
    //doFire
        lda #0
        sta shouldUpdate
        //inc $d020
        jsr Titles.drawScreen
      !skip:

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

  keyControl: {

    rts
  }

}