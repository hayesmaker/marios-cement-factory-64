Options: {
	.encoding "screencode_upper"
	MyLabel1: .text "                OPTIONS                 "
  .encoding "screencode_upper"
  MyLabel2: .text "      MUSIC:          ON                "
  .encoding "screencode_upper"
  MyLabel3: .text "      SFX:            ON                "
  .encoding "screencode_upper"
  MyLabel4: .text "      RESET SCORES                      "

  .label screen_ram = $c000
  .label sprite_pointers = screen_ram + $3f8


  Player_X:
    .byte 106
  Player_X_MB:
    .byte 0
  Player_Y: //*              
    .byte 70, 88, 119
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

        ldx #0   
        !loop_text:  
           lda MyLabel1,x       //; read characters from line1 table of text..
           sta $c028,x         //; ...and store in screen ram near the center 
           
           lda MyLabel2, x
           sta $c0A0,x

           lda MyLabel3, x
           sta $c0F0,x

           lda MyLabel4, x
           sta $c140, x
           // lda line2,x      ; read characters from line1 table of text...
           // sta $0478,x      ; ...and put 2 rows below line1
           // lda line3,x      ; read characters from line1 table of text...
           // sta $0770,x      ; ...and put 2 rows below line1
           inx 
           cpx #$28          //; finished when all 40 cols of a line are processed
           bne !loop_text-
           rts

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