Credits: {
	.encoding "screencode_upper"
	MyLabel1: .text "                CREDITS                 "
  .encoding "screencode_upper"
  MyLabel2: .text "      CODE     HAYESMAKER64             "
  .encoding "screencode_upper"
  MyLabel3: .text "      GFX      HAYESMAKER64             "
  .encoding "screencode_upper"
  MyLabel4: .text "      SOUND    PHASE101                 "


	init: {

		//Turn off bitmap mode
        lda $d011
        and #%11011111
        sta $d011

        //VIC n stuff
        lda #%00000011
        sta $dd00
        lda #%00011000
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
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
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

        ldx #0   
        !loop_text:  
           lda MyLabel1,x       //; read characters from line1 table of text..
           sta $0428,x         //; ...and store in screen ram near the center 
           
           lda MyLabel2, x
           sta $04A0,x

           lda MyLabel3, x
           sta $04F0,x

           lda MyLabel4, x
           sta $0540, x
           // lda line2,x      ; read characters from line1 table of text...
           // sta $0478,x      ; ...and put 2 rows below line1
           // lda line3,x      ; read characters from line1 table of text...
           // sta $0770,x      ; ...and put 2 rows below line1
           inx 
           cpx #$28          //; finished when all 40 cols of a line are processed
           bne !loop_text-
           
          // lda #$10
          // bit $dc00
          // bne *-3

          // inc $d020

          rts

    
	}

}