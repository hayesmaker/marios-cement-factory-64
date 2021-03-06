GameOverScreen: {
  .label screen_ram = $c000
  .label sprite_pointers = screen_ram + $3f8
  .label WHITE_SPACE_CHAR = 32

  rowScreenTable: .fillword 25, screen_ram + (i * 40)



  //todo: rewrite this lookup table to make clearer/more dynamic
  charShiftTable:
    .byte $12, $1B, $24, $2D, $36
  maxScorePass:
    .byte $00 //overridden in init replace with const

  .encoding "screencode_upper"
  MyLabel1: .text "GAME OVER@"
  MyLabel2: .text "PRESS FIRE@"
  MyLabel3: .text "YOU SCORED@"

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

  DebounceFlag:
    .byte $00
  DebounceFireFlag:
    .byte $00

  isEntryEnabled:
    .byte $00  
  hiscorePos:
    .byte $ff  


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
joyCharIndex:
  .byte firstLetter
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
         cpx #0
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

      //init variables

      lda #0
      sta playerNameIndex

      //Hi Score table LEN
      lda #[HiScores.__scoresTable - HiScores.scoresTableLB - 1] 
      sta maxScorePass

      lda #$ff
      sta hiscorePos

      lda #1
      sta joyCharIndex

      ldx #0
      !loop:
        lda #WHITE_SPACE_CHAR
        sta playerNameEntered, x
        cpx #7
        beq !skip+
        inx
        jmp !loop-
      !skip:  

      jsr checkHighScorePosition
      //y will contain highscorePosition
      cpy #[HiScores.__scoresTable - HiScores.scoresTableLB]
      bne !skip+
        jsr  drawFiredMessage
        jmp !return+
      !skip:
        jsr enableNameInput
        jsr drawCongratsMessage
      !return:
      //jsr drawContinueMessage
      rts
}

checkHighScorePosition: {
  .label scoreLB = TEMP1
  .label scoreHB = TEMP2
  .label tempScoreLB = TEMP3
  .label tempScoreHB = TEMP4
  .label passIndex = TEMP5
  .label passLen = TEMP6
  
  lda Score.currentScore + 0
  sta scoreLB
  lda Score.currentScore + 1
  sta scoreHB

  //check current score is in the table
  // (if y = tableLen) score is not in table
  ldy #0
  !loop:
    lda HiScores.scoresTableHB, y
    cmp scoreHB
    bcc !putScore+
    bne !skip+
    lda HiScores.scoresTableLB, y
    cmp scoreLB
    bcc !putScore+  
    !skip:
    cpy #[HiScores.__scoresTable - HiScores.scoresTableLB]
    beq !return+
    iny
    jmp !loop-

    //shift all scores down the table from current score position
    //bug.. last score isn't overwritten.
    !putScore:
    sty hiscorePos
    lda #[HiScores.__scoresTable - HiScores.scoresTableLB] 
    sec
    sbc hiscorePos
    sbc #1    //?                                 
    sta passIndex
    beq !skip+

    !loop:
    clc 
    lda passIndex
    adc hiscorePos
    sec
    sbc #1
    tay
    lda HiScores.scoresTableLB, y
    sta tempScoreLB
    lda HiScores.scoresTableHB, y
    sta tempScoreHB
    iny
    lda tempScoreLB
    sta HiScores.scoresTableLB, y
    lda tempScoreHB
    sta HiScores.scoresTableHB, y

    dec passIndex
    bne !loop-

    !skip:
    //save current score into score table
    ldy hiscorePos
    lda scoreLB
    sta HiScores.scoresTableLB, y
    lda scoreHB
    sta HiScores.scoresTableHB, y

    lda maxScorePass
    sec
    sbc hiscorePos
    sta maxScorePass

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

  jsr drawScore

  rts
}


drawFiredMessage:  {
  .label row1 = 8
  .label col1 = 12
  .label row2 = 10
  .label col2 = 15
  .label row3 = 12
  .label col3 = 10

  lda #0
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

  jsr drawScore
  jsr drawContinueMessage
  jsr disableNameInput

  rts
}

drawScore: {

  .label row = 16
  .label col = 12

   ldx #0
   !loop_text:  
      lda MyLabel3,x       //; read characters from line1 table of text..
      beq !next+
      sta screen_ram + row*$28 + col, x 
      inx  
      jmp !loop_text-
    !next:

    //thousands
    lda Score.currentScore + 1
    beq !skip+
    lsr
    lsr 
    lsr 
    lsr 
    clc
    adc HiScores.NUMBERWANG  //.byte $30 //First char index for 0 
    inx
    sta screen_ram + row*$28 + col, x

    !skip:
    //hundreds
    lda Score.currentScore + 1
    and #$0f
    clc
    adc HiScores.NUMBERWANG
    inx
    sta screen_ram + row*$28 + col, x

    !skip:
    //tens
    lda Score.currentScore + 0
    lsr
    lsr 
    lsr 
    lsr 
    clc
    adc HiScores.NUMBERWANG  //.byte $30 //First char index for 0 
    inx
    sta screen_ram + row*$28 + col, x

    !skip:
    //units
    lda Score.currentScore + 0
    and #$0f
    clc
    adc HiScores.NUMBERWANG //$30
    inx
    sta screen_ram + row*$28 + col, x

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

enableNameInput: {
  lda #1
  sta keysEnabled
  lda #1
  sta joyEnabled

  rts

}

disableNameInput: {
  lda #0
  sta keysEnabled
  sta $dc02       //Requred after Key input to ENABLE JOYSTICK
  lda #1
  sta joyEnabled

  lda #$ff
  sta $dc00

  rts
}

update: {
  lda joyEnabled
  beq !skip+
    lda #0
    sta $dc02     //Requred after Key input to ENABLE JOYSTICK
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
        lda isEntryEnabled
        bne !skip+
        //doFire
        lda #0
        sta isEntryEnabled
        lda #0
        sta GameOver.STATE_IN_PROGRESS        
      !skip:
        jsr commitLetter
        //commit letter to score
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
      lda isEntryEnabled
      beq !end+
      jsr cycleLetterLeft
    !:
    !Right:

    lda JOY_ZP
    and #JOY_RT
    bne !end+
    inc DebounceFlag              
    //move cursor right
      lda isEntryEnabled
      beq !end+
      jsr cycleLetterRight

    !end:
    rts
    
  }

  renderLetter: {
    .label tempLetter = TEMP4
    .label screenramTemp = TEMP9
    .label row = 10
    .label col = 15

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
    lda tempLetter
    sta (screenramTemp),y
    //add letter to stored payerName
    ldy playerNameIndex
    sta playerNameEntered, y  //h a y e s m a k e r
    rts
}

cycleLetterLeft: {
  .label tempLetter = TEMP4
  sec
  lda joyCharIndex  //h a y e s m a k e r
  sbc #1
  cmp #0
  bne !skip+
    lda #$1a  //cycle back to z
  !skip:
  sta joyCharIndex
  sta tempLetter
  jsr renderLetter

  rts
}  

cycleLetterRight: {
  .label tempLetter = TEMP4
  clc
  lda joyCharIndex  //h a y e s m a k e r
  adc #1
  cmp #$1b //past z?
  bne !skip+
    lda #1
  !skip:
  sta joyCharIndex
  sta tempLetter
  jsr renderLetter
  rts
}

commitLetter: {
  lda joyCharIndex
  lda #0
  sta joyCharIndex
  inc playerNameIndex

  lda playerNameIndex
  cmp #8
  bne !skip+
  
  jsr onEnterPressed

  !skip:
  rts
}

keyControl: {
    .label tempLetter = TEMP4
    .label TempX = TEMP5
    .label TempY = TEMP6

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

      sta tempLetter
      lda playerNameIndex
      cmp #8
      bne !skip+
        jmp NoValidInput
      !skip:
      
      jsr renderLetter
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
  sta (screenramTemp),y

  ldy playerNameIndex
  sta playerNameEntered, y

  inc delDebounce

  !return:
  rts
}

commitName: {
  .label playerNameCharIndex = TEMP1
  .label letterIndex = TEMP2
  .label scorePos = TEMP3
  .label tempLetter = TEMP4
  .label passIndex = TEMP5
  .label passLen = TEMP6
  .label arrayLen = TEMP7 
  
  lda hiscorePos
  cmp #$ff
  beq !end+

  sta scorePos
  asl
  asl
  asl
  clc
  adc scorePos
  sta playerNameCharIndex

  lda #0 
  sta passIndex

  lda #[HiScores.__scoresTableName - HiScores.scoresTableName]
  sta arrayLen

  lda scorePos
  //todo: replace #4 with score names number const    
  cmp #[HiScores.__scoresTable - HiScores.scoresTableLB - 1]
  beq !drawName+

  !outerLoop:
  lda #0
  sta letterIndex
  
  !loop:
  ldy passIndex
  lda arrayLen
  sec
  sbc charShiftTable, y
  clc
  adc letterIndex
  tay

  lda HiScores.scoresTableName, y
  sta tempLetter

  tya
  clc
  adc #9
  tay
  lda tempLetter
  sta HiScores.scoresTableName, y

  inc letterIndex
  lda letterIndex
  cmp #8
  bne !loop-

  inc passIndex
  lda passIndex
  cmp maxScorePass
  bne !outerLoop-

  !drawName:

  lda #0
  sta letterIndex

  !loop:
  ldy letterIndex
  cpy #8
  beq !end+

  lda playerNameCharIndex
  clc
  adc letterIndex
  tax 

  ldy letterIndex
  lda playerNameEntered, y
  sta HiScores.scoresTableName,x
  
  inc letterIndex
  jmp !loop-

  !end:
  rts
}

onEnterPressed: {
  lda #0
  sta isEntryEnabled
  jsr drawContinueMessage
  jsr disableNameInput
  jsr commitName


  rts
}




}