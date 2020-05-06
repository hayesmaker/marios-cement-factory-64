Credits: {
	.encoding "screencode_upper"
	MyLabel1: .text "CREDITS@"
  .encoding "screencode_upper"
  MyLabel2: .text "CODE     HAYESMAKER64@"
  .encoding "screencode_upper"
  MyLabel3: .text "GFX      HAYESMAKER64@"
  .encoding "screencode_upper"
  MyLabel4: .text "SOUND    PHASE101@"

  .label screen_ram = $c000
  .label sprite_pointers = screen_ram + $3f8

  shouldUpdate:
    .byte $00
  DebounceFlag:
    .byte $00
  DebounceFireFlag:
    .byte $00


	init: {
        lda #1
        sta shouldUpdate
        //init joystick
        lda #$00
        sta DebounceFireFlag
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
        lda #RED
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
           cpx #$400
           bne !loop_colour-

        
        .label row1 = 1
        .label row2 = 5
        .label row3 = 8
        .label row4 = 11

        .label col1 = 15
        .label col2 = 7
        .label col3 = 7
        .label col4 = 7

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

          ldx #0
          !loop_text:
           lda MyLabel4,x       //; read characters from line1 table of text..
           beq !next+
           sta screen_ram + row4*$28 + col4, x 
           inx 
           jmp !loop_text-
           
           !next:  


          rts

    
	}

  update: {
    // jsr control
    // jsr drawSprites
    rts
  }

  control: {
    inc $d020
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
        //jsr TitleScreen.gotoMain
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

  drawSprites: {
    
    !return:
    rts
  }

}