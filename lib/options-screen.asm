OptionsScreen: {
	.encoding "screencode_upper"
	MyLabel1: .text "OPTIONS@"
  MyLabel2: .text "MUSIC:@"
  MyLabel3: .text "SFX:@"
  MyLabel4: .text "RESET SCORES@"
  MyLabel5: .text "MAIN MENU@"
  MyLabelOn: .text "ON @"
  MyLabelOff: .text "OFF@"

  .const MAX_OPTIONS = 3

  .label screen_ram = $c000
  .label sprite_pointers = screen_ram + $3f8

  shouldUpdate:
    .byte $00

  // screenRowLSB: .fill 25, <[screen_ram + i * $28]
  // screenRowMSB: .fill 25, >[screen_ram + i * $28]
  DebounceFlag:
    .byte $00
  DebounceFireFlag:
    .byte $01
  Player_X:
    .byte 80
  Player_X_MB:
    .byte 0
  Player_Y: //*              
    .byte 80, 105, 130, 155
  Player_PosY_Index:
    .byte 0
  FramesTable:
    .byte $48, $49, $4A, $4B

  .label row1 = 1
  .label row2 = 5
  .label row3 = 8
  .label row4 = 11
  .label row5 = 14

  .label col1 = 15
  .label col2 = 11
  .label col3 = 11
  .label col4 = 11
  .label col5 = 11  


	init: {
        // inc $d020
        // inc $d021
        lda #1
        sta shouldUpdate
        //init joystick
        lda #$01
        sta DebounceFireFlag
        lda #$00
        sta DebounceFlag
        
        lda #$00
        sta VIC.SPRITE_ENABLE

        //Sprites init
        lda #$00
        sta VIC.SPRITE_COLOR_0
      
        lda FramesTable + 0
        sta sprite_pointers + 0

         //  set sprites to single height an width
        lda #$00
        sta $d01d
        sta $d017

        //player sprite enable
        //only enables sprite 0, disable  1-7     
        lda #%00000001
        sta VIC.SPRITE_ENABLE

        //block 1 enable sprite player msb
        lda VIC.SPRITE_MSB
        and #%11111110  
        sta VIC.SPRITE_MSB

        lda #$00
        sta VIC.SPRITE_MULTICOLOR

        ldy #0
        sty Player_PosY_Index

        //double width
        lda #%11111110
        sta $D01D

        //end sprite init
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
        
        // inc $d021

        // lda #'X'
        // sta screen_ram

        // inc $d800

        ldx #0
        !loop_text:  
           lda MyLabel1,x       //; read characters from line1 table of text..
           beq !next+
           sta screen_ram + row1*$28 + col1, x 
           inx
           jmp !loop_text-
        !next:

        ldx #0
        !loop_text:
          lda MyLabel2,x       //; read characters from line1 table of text..
          beq !next+
          sta screen_ram + row2*$28 + col2, x 
          inx
          jmp !loop_text-           
         !next:

         ldx #0
         !loop_text:
           lda MyLabel3,x       //; read characters from line1 table of text..
           beq !next+
           sta screen_ram + row3*$28 + col3, x 
           inx
           jmp !loop_text-
          !next:

          // ldx #0
          // !loop_text:
          //  lda MyLabel4,x       //; read characters from line1 table of text..
          //  beq !next+
          //  sta screen_ram + row4*$28 + col4, x 
          //  inx 
          //  jmp !loop_text-
          //  !next:

           ldx #0
           !loop_text:
           lda MyLabel5,x       //; read characters from line1 table of text..
           beq !next+
           sta screen_ram + row4*$28 + col5, x 
           inx 
           jmp !loop_text-
           
           !next:  

        jsr printMusic
        jsr printSound

        rts
	}

  update: {
    jsr control
    jsr drawSprites
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
      lda Player_PosY_Index
      bne !skip+
        jsr toggleMusic
      !skip:
      lda Player_PosY_Index
      cmp #1
      bne !skip+
        jsr toggleSound
      !skip:
      lda Player_PosY_Index
      cmp #2
      bne !skip+
        //go to main menu
        lda #0
        sta shouldUpdate
        jsr Titles.drawScreen
      !skip:
      lda Player_PosY_Index
      cmp #3
      bne !skip+
        
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
    lda Player_PosY_Index
    beq !+
      dec Player_PosY_Index
    !:
    !Down:
    lda JOY_ZP
    and #JOY_DN
    bne !+
    inc DebounceFlag
    //do down
    lda Player_PosY_Index
    cmp #MAX_OPTIONS
    beq !+
      inc Player_PosY_Index
    !:
    !Left:
    lda JOY_ZP
    and #JOY_LT
    bne !+

    inc DebounceFlag
    //move player left
    //inc $d020
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

  drawSprites: {
    lda shouldUpdate
    beq !return+

    //inc $d020
    lda Player_X
    sta VIC.SPRITE_0_X

    ldy Player_PosY_Index
    lda Player_Y, y
    sta VIC.SPRITE_0_Y
    //y * 8 + x = table index

    //double width
    lda #0
    sta $D01D

    lda FramesTable, y
    sta sprite_pointers + 0
    
    !return:
    rts
  }

  toggleSound: {
    jsr Options.toggleSound
    jsr printSound
    rts
  }

  toggleMusic: {
    jsr Options.toggleMusic
    jsr printMusic
    rts
  }

  printSound: {
    .label col = 27
    lda Options.isSoundOn
    bne !switchOn+
    ldx #0
    
    !loop_text:
    lda MyLabelOff,x       
    beq !return+
    sta screen_ram + row3*$28 + col, x 
    inx
    jmp !loop_text-

    !switchOn:
    ldx #0
    !loop_text:
    lda MyLabelOn,x       
    beq !return+
    sta screen_ram + row3*$28 + col, x 
    inx
    jmp !loop_text-
    !return:
    rts
  }

  printMusic: {
  .label col = 27
      lda Options.isMusicOn
      bne !switchOn+
      ldx #0
      !loop_text:
      lda MyLabelOff,x       
      beq !return+
      sta screen_ram + row2*$28 + col, x 
      inx
      jmp !loop_text-

      !switchOn:
      ldx #0
      !loop_text:
      lda MyLabelOn,x       
      beq !return+
      sta screen_ram + row2*$28 + col, x 
      inx
      jmp !loop_text-
      !return:
      rts
    }


}