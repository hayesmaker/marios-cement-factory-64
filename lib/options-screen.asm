Options: {
	.encoding "screencode_upper"
	MyLabel1: .text "OPTIONS0"
  .encoding "screencode_upper"
  MyLabel2: .text "MUSIC:          ON0"
  .encoding "screencode_upper"
  MyLabel3: .text "SFX:            ON0"
  .encoding "screencode_upper"
  MyLabel4: .text "RESET SCORES0"

  .label screen_ram = $c000
  .label sprite_pointers = screen_ram + $3f8

  // screenRowLSB: .fill 25, <[screen_ram + i * $28]
  // screenRowMSB: .fill 25, >[screen_ram + i * $28]

  Player_X:
    .byte 80
  Player_X_MB:
    .byte 0
  Player_Y: //*              
    .byte 80, 88, 119
  Player_PosY_Index:
    .byte 0
  DefaultFrame:
    .byte $44, $44

	init: {
        lda #$00
        sta VIC.SPRITE_ENABLE

        //Sprites init
        lda #$00
        sta VIC.SPRITE_COLOR_0
      
        lda DefaultFrame + 1
        sta DefaultFrame + 0
        sta sprite_pointers + 0

         //  set sprites to single height an width
        lda #$00
        sta $d01d
        sta $d017

        //player sprite enable    
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
        lda #RED
        sta $d020   // border
        lda #RED
        sta $d021   // background
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

        .label col1 = 15
        .label col2 = 11
        .label col3 = 11
        .label col4 = 11

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
        rts
	}

  update: {
    jsr control
    jsr drawSprites
    rts
  }

  control: {

    rts
  }

  drawSprites: {
    lda Player_X
    sta VIC.SPRITE_0_X

    ldy Player_PosY_Index
    lda Player_Y, y
    sta VIC.SPRITE_0_Y
    //y * 8 + x = table index
    lda DefaultFrame
    sta sprite_pointers + 0
    
    rts
  }


}