GameOverScreen: {
  .label screen_ram = $c000
  .label sprite_pointers = screen_ram + $3f8
  .label WHITE_SPACE_CHAR = 32

  rowScreenTable: .fillword 25, screen_ram + (i * 40)

  .encoding "screencode_upper"
  MyLabel1: .text "GAME OVER@"
  MyLabel2: .text "PRESS FIRE@"

  LABEL_CONGRATS_1:
    .text "EMPLOYEE OF THE DAY@"
  LABEL_CONGRATS_2:
    .text "ENTER YOUR NAME@"
  
  LABEL_FIRED_1:
    .text "SORRY MARIO YOU@"
  LABEL_FIRED_2:
    .text "ARE FIRED!@"
  LABEL_FIRED_COL:
    .byte 7
  LABEL_CONGRATS_COL:
  .text 6

 shouldUpdate:
    .byte $00
  DebounceFlag:
    .byte $00
  DebounceFireFlag:
    .byte $00

  isEntryEnabled:
    .byte $00  


  playerNameEntered: 
    .fill 8, WHITE_SPACE_CHAR


//highscore vars
playerNameIndex: 
  .byte 0   

//from amk
.const firstLetter = 1              // the char number of A in the char set
.const asciiA = 65                // the ascii value used by kick
.const charOffsetLetter = firstLetter - asciiA  // map asci to the char set
.const firstNumber = 30             // 0 in the char set
.const ascii0 = 48                // the acsii value for 0 used by kick 
.const charOffsetNumber = firstNumber - ascii0  // map ascii to the char set
//.const titleLine = screenRam + 3*40 + 11    // memory address to start printing 

playerScore:
  .text "    "
savePosition:
  .byte 0
keyPressed:
  .byte 0
keyPressedX:
  .byte 0
delDebounce:
  .byte 0

joyEnabled:
  .byte 0
keysEnabled:
  .byte 0 

init: {
      lda #1
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

      ldy #0
      sty delDebounce

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
      .label col1 = 16

      ldx #0
      !loop_text:  
         lda MyLabel1,x       //; read characters from line1 table of text..
         beq !next+
         sta screen_ram + row1*$28 + col1, x 
         inx  
         jmp !loop_text-
      !next:

      lda #0
      sta playerNameIndex


      jsr checkHighScorePosition
      //y will contain highscorePosition?

      cpy #[HiScores.__scoresTableVal - HiScores.scoresTableVal]
      bne !skip+
        jsr  drawFiredMessage
        jmp !return+
      !skip:
        jsr enableKeys
        jsr drawCongratsMessage
      
      !return:
      //jsr drawContinueMessage
      rts
}

checkHighScorePosition: {
  .label scoreLB = TEMP1
  .label scoreHB = TEMP2
  .label hiscorePos = TEMP3

  lda #0
  sta hiscorePos

  lda Score.currentScore
  sta scoreLB
  lda Score.currentScore + 1
  sta scoreHB

  //HiScores.scoresTableVal
  ldy #0
  !loop:
    lda HiScores.scoresTableVal + 1, y
    sec
    sbc scoreHB
    bmi !putScore+
    bne !skip+
      lda HiScores.scoresTableVal + 0,y
      sec
      sbc scoreLB
      bmi !putScore+  
    !skip:
    cpy #[HiScores.__scoresTableVal - HiScores.scoresTableVal]
    beq !return+
    iny
    jmp !loop-

    !putScore:
    sty hiscorePos

    !loop:
    cpy #[HiScores.__scoresTableVal - HiScores.scoresTableVal]
    bne !skip+
      lda scoreLB
      sta HiScores.scoresTableVal + 0,y
      lda scoreHB
      sta HiScores.scoresTableVal + 1,y
    !skip:
    //0-2
    lda HiScores.scoresTableVal + 0, y
    iny
    sta HiScores.scoresTableVal + 0,y
    dey
    lda HiScores.scoresTableVal + 1, y
    iny
    sta HiScores.scoresTableVal + 1,y
    dey
    dey
    cpy hiscorePos
    bne !skip+
      lda scoreLB
      sta HiScores.scoresTableVal + 0,y
      lda scoreHB
      sta HiScores.scoresTableVal + 1,y
    !skip:
    dey
    dey
    bpl !loop-
  !return:
  rts
}

drawCongratsMessage:  {
  .label row1 = 5
  .label col1 = 10
  .label row2 = 7
  .label col2 = 12

  lda #1
  sta isEntryEnabled

  ldx #0
  !loop_text:  
    lda LABEL_CONGRATS_1,x       //; read characters from line1 table of text..
    beq !next+
    sta screen_ram + row1*$28 + col1, x 
    inx  
    jmp !loop_text-
  !next:

  ldx #0
  !loop_text:  
    lda LABEL_CONGRATS_2,x       //; read characters from line1 table of text..
    beq !next+
    sta screen_ram + row2*$28 + col2, x 
    inx  
    jmp !loop_text-
  !next:

  rts
}


drawFiredMessage:  {
  .label row1 = 8
  .label col1 = 12
  .label row2 = 10
  .label col2 = 15

  lda #1
  sta isEntryEnabled

  ldx #0
  !loop_text:  
    lda LABEL_FIRED_1,x       //; read characters from line1 table of text..
    beq !next+
    sta screen_ram + row1*$28 + col1, x 
    inx  
    jmp !loop_text-
  !next:

  ldx #0
  !loop_text:  
    lda LABEL_FIRED_2,x       //; read characters from line1 table of text..
    beq !next+
    sta screen_ram + row2*$28 + col2, x 
    inx  
    jmp !loop_text-
  !next:
  jsr drawContinueMessage
  jsr enableJoy

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

enableKeys: {
  lda #1
  sta keysEnabled
  lda #0
  sta joyEnabled

  rts

}

enableJoy: {
  lda #0
  sta keysEnabled
  sta $dc02 //NO IDEA why THIS IS NECESSARY //ENABLES JOYSTICK
  lda #1
  sta joyEnabled

  lda #$ff
  sta $dc00

  rts
}

update: {
  lda joyEnabled
  beq !skip+
    jsr joyControl
  !skip:
  lda keysEnabled
  beq !skip+
    jsr keyControl
  !skip: 
  rts
}

joyControl: {
    .label JOY_PORT_2 = $dc00
    .label JOY_UP = %00001
    .label JOY_DN = %00010
    .label JOY_LT = %00100
    .label JOY_RT = %01000
    .label JOY_FIRE = %10000

    lda JOY_PORT_2
    sta JOY_ZP
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
        lda keysEnabled
        bne !skip+
        //doFire
        lda #0
        sta isEntryEnabled
        sta shouldUpdate

        lda #0
        sta GameOver.STATE_IN_PROGRESS
        

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
    .label TempA = TEMP4
    .label TempX = TEMP5
    .label TempY = TEMP6
    .label screenramTemp = TEMP9

    .label row = 10
    .label col = 15

    lda isEntryEnabled
    bne !skip+
      jmp !return+
    !skip:

    jsr Keyboard
    bcs NoValidInput
    stx TempX
    sty TempY
    cmp #$ff

    beq NoNewAphanumericKey
      ldy #0
      sty delDebounce


      // Check A for Alphanumeric keys
      //.break
      sta TempA
      lda playerNameIndex
      cmp #8
      beq NoValidInput

      lda #row
      asl
      tay
      lda rowScreenTable, y
      sta screenramTemp
      lda rowScreenTable + 1, y
      sta screenramTemp + 1
      lda #col
      clc 
      adc playerNameIndex
      tay 
      lda TempA
      sta playerNameEntered, y  //h a y e s m a k e r
      sta (screenramTemp),y

      inc playerNameIndex

    NoNewAphanumericKey:
      // Check X & Y for Non-Alphanumeric Keys
      lda TempX
      bne !skip+
      !skip:
      cmp #1
      bne !skip+   //delete
        ldy delDebounce
        bne !skip+
          jsr onDeletePressed
          jmp !return+
      !skip:
      lda TempX
      cmp #2       //return
      bne !skip+
        jsr onEnterPressed
      !skip:
      ldy TempY

    // stx $0401
    // sty $0402
    NoValidInput:  // This may be substituted for an errorhandler if needed
    !return:
  rts
}

onDeleteTimeout: {
  ldy #0
  sty delDebounce

  lda #0
  sta GameOver.deleteDebounceTimer + 0
  lda GameOver.deleteDebounceTimer + 2
  sta GameOver.deleteDebounceTimer + 1
  rts
}

onDeletePressed: {
  .label screenramTemp = TEMP9
  .label row = 10
  .label col = 15

  lda #1
  sta GameOver.deleteDebounceTimer + 0
  lda GameOver.deleteDebounceTimer + 2
  sta GameOver.deleteDebounceTimer + 1

  lda playerNameIndex
  beq !return+
  
  dec playerNameIndex
  lda #row
  asl
  tay
  lda rowScreenTable, y
  sta screenramTemp
  lda rowScreenTable + 1, y
  sta screenramTemp + 1
  lda #col
  clc 
  adc playerNameIndex
  tay 
  lda #WHITE_SPACE_CHAR
  sta playerNameEntered, y  //h a y e s m a k e r
  sta (screenramTemp),y

  inc delDebounce

  !return:
  rts
}

onEnterPressed: {
  lda #0
  sta isEntryEnabled
  jsr drawContinueMessage
  jsr enableJoy


  rts
}




}