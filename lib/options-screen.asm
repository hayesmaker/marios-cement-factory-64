Options: {
	.encoding "screencode_upper"
	MyLabel1: .text "OPTIONS0"
  MyLabel2: .text "MUSIC:          ON0"
  MyLabel3: .text "SFX:            ON0"
  MyLabel4: .text "RESET SCORES0"
  MyLabel5: .text "MAIN MENU0"

  .label screen_ram = $c000
  .label sprite_pointers = screen_ram + $3f8

  shouldUpdate:
    .byte $00

  // screenRowLSB: .fill 25, <[screen_ram + i * $28]
  // screenRowMSB: .fill 25, >[screen_ram + i * $28]
  DebounceFlag:
    .byte $00
  DebounceFireFlag:
    .byte $00
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


	init: {

        // inc $d020
        // inc $d021


        lda #1
        sta shouldUpdate
        //init joystick
        lda #$00
        sta DebounceFireFlag
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
        //only enables sprite 0, doesnt affect 1-7    
        lda VIC.SPRITE_ENABLE 
        ora #%00000001
        sta VIC.SPRITE_ENABLE

        //block 1 enable sprite player msb
        lda VIC.SPRITE_MSB
        and #%11111110
        sta VIC.SPRITE_MSB

        lda #$00
        sta VIC.SPRITE_MULTICOLOR

        ldy #0
        sty Player_PosY_Index

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
        // lda #RED
        // sta $d020   // border
        // lda #RED
        // sta $d021   // background
        //clear screen
        ldx #0
        lda #$20 //space character? (it said so on internet)
        !loop:   
        sta $c000,x
        sta $c100,x
        sta $c200,x
        sta $c300,x
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
           cpx #$400
           bne !loop_colour-

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

        
        // inc $d021

        // lda #'X'
        // sta screen_ram

        // inc $d800

        ldx #0
        !loop_text:  
           lda MyLabel1,x       //; read characters from line1 table of text..
           cmp #$30
           beq !next+
           sta screen_ram + row1*$28 + col1, x 
           inx
           jmp !loop_text-
        !next:

        ldx #0
        !loop_text:
          lda MyLabel2,x       //; read characters from line1 table of text..
          cmp #$30
          beq !next+
          sta screen_ram + row2*$28 + col2, x 
          inx
          jmp !loop_text-           
         !next:

         ldx #0
         !loop_text:
           lda MyLabel3,x       //; read characters from line1 table of text..
           cmp #$30
           beq !next+
           sta screen_ram + row3*$28 + col3, x 
           inx
           jmp !loop_text-
          !next:

          ldx #0
          !loop_text:
           lda MyLabel4,x       //; read characters from line1 table of text..
           cmp #$30
           beq !next+
           sta screen_ram + row4*$28 + col4, x 
           inx 
           jmp !loop_text-
           
           !next:

           ldx #0
           !loop_text:
           lda MyLabel5,x       //; read characters from line1 table of text..
           cmp #$30
           beq !next+
           sta screen_ram + row5*$28 + col5, x 
           inx 
           jmp !loop_text-
           
           !next:  

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
    lda JOY_ZP
    and #JOY_FIRE
    bne !movement+
    //doFire
      lda Player_PosY_Index
      cmp #3
      bne !skip+
        //go to main menu
        lda #0
        sta shouldUpdate
        jsr TitleScreen.gotoMain
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
    cmp #3
    beq !+
      inc Player_PosY_Index
    !:
    !Left:
    lda JOY_ZP
    and #JOY_LT
    bne !+

    inc DebounceFlag
    //move player left
    inc $d020
    !:
    !Right:

    lda JOY_ZP
    and #JOY_RT
    bne !end+

    inc DebounceFlag              
    //move cursor right
    inc $d020
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
    lda FramesTable, y
    sta sprite_pointers + 0
    
    !return:
    rts
  }


}