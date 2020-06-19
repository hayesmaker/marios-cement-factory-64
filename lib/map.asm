//export from Charpad with 2x2 tileset

Map: {
	TileScreenLocations: 
		.byte 0,1,40,41
	RowColourTable:
		.fillword 25, VIC.COLOR_RAM + (i * 40)
	RowScreenTable:
		.fillword 25, Game.SCREEN_RAM + (i * 40)

	numberYPos:
		.byte $00
	numberYIndex:
		.byte $00

	RowLoopIndex:
		.byte $00		

	/**
	Set A to Required number
	Set Y to Required Y Pos Index
	Set X to Required X Pos Index
	*/
	DrawNumber: {
		sty numberYPos
		asl 
		tay 
		lda Ui.NUMBER_WANG
		iny
		sty numberYIndex
		ldy numberYPos
		jsr SwitchCharAtXY

		ldy numberYIndex
		lda Ui.NUMBER_WANG + 1
		ldy numberYPos
		iny
		jsr SwitchCharAtXY
		rts
	}


	DrawScore: {

		ldx #11
		ldy #3
		lda #0
		jsr DrawNumber

		ldx #12
		ldy #3
		lda #0
		jsr DrawNumber

		ldx #13
		ldy #3
		lda #0
		jsr DrawNumber

		rts

	}
		

	Initialise: {

		.label rowTableIndex = TEMP6

		lda Tiles.EMPTY
		ldx Tiles.SWITCH_1_DOWN + 1
		ldy Tiles.SWITCH_1_DOWN + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.SWITCH_2_DOWN + 1
		ldy Tiles.SWITCH_2_DOWN + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.SWITCH_3_DOWN + 1
		ldy Tiles.SWITCH_3_DOWN + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.SWITCH_4_DOWN + 1
		ldy Tiles.SWITCH_4_DOWN + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.HAND_1_DOWN + 1
		ldy Tiles.HAND_1_DOWN + 2
		jsr SwitchCharAtXY

		lda Tiles.TRAP_1_CLOSED_2 + 0
		ldx Tiles.TRAP_1_CLOSED_2 + 1
		ldy Tiles.TRAP_1_CLOSED_2 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.HAND_2_UP + 1
		ldy Tiles.HAND_2_UP + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.HAND_2_DOWN + 1
		ldy Tiles.HAND_2_DOWN + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.HAND_3_UP + 1
		ldy Tiles.HAND_3_UP + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.HAND_3_DOWN + 1
		ldy Tiles.HAND_3_DOWN + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.HAND_4_UP + 1
		ldy Tiles.HAND_4_UP + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.HAND_4_DOWN + 1
		ldy Tiles.HAND_4_DOWN + 2
		jsr SwitchCharAtXY

		//new chars
		//#4
		lda Tiles.EMPTY
		ldx Tiles.CEMENT_NEW_LEFT_1 + 1
		ldy Tiles.CEMENT_NEW_LEFT_1 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.CEMENT_NEW_LEFT_2 + 1
		ldy Tiles.CEMENT_NEW_LEFT_2 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.CRATE_DOOR_1 + 1
		ldy Tiles.CRATE_DOOR_1 + 2
		jsr SwitchCharAtXY

		//right new cements
		lda Tiles.EMPTY
		ldx Tiles.CEMENT_NEW_RIGHT_1 + 1
		ldy Tiles.CEMENT_NEW_RIGHT_1 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.CEMENT_NEW_RIGHT_2 + 1
		ldy Tiles.CEMENT_NEW_RIGHT_2 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.CRATE_DOOR_2 + 1
		ldy Tiles.CRATE_DOOR_2 + 2
		jsr SwitchCharAtXY


		lda Tiles.EMPTY
		ldx Tiles.CEMENT_SPILL_1_LEFT_1 + 1
		ldy Tiles.CEMENT_SPILL_1_LEFT_1 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.CEMENT_SPILL_1_LEFT_2 + 1
		ldy Tiles.CEMENT_SPILL_1_LEFT_2 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.CEMENT_SPILL_2_LEFT_1 + 1
		ldy Tiles.CEMENT_SPILL_2_LEFT_1 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.CEMENT_SPILL_2_LEFT_2 + 1
		ldy Tiles.CEMENT_SPILL_2_LEFT_2 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.CEMENT_SPILL_2_LEFT_3 + 1
		ldy Tiles.CEMENT_SPILL_2_LEFT_3 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.CEMENT_SPILL_3_LEFT_1 + 1
		ldy Tiles.CEMENT_SPILL_3_LEFT_1 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.CEMENT_SPILL_3_LEFT_2 + 1
		ldy Tiles.CEMENT_SPILL_3_LEFT_2 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.CEMENT_SPILL_3_LEFT_3 + 1
		ldy Tiles.CEMENT_SPILL_3_LEFT_3 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.CEMENT_SPILL_3_LEFT_3 + 1
		ldy Tiles.CEMENT_SPILL_3_LEFT_3 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.CEMENT_SPILL_1_RIGHT_1 + 1
		ldy Tiles.CEMENT_SPILL_1_RIGHT_1 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.CEMENT_SPILL_1_RIGHT_2 + 1
		ldy Tiles.CEMENT_SPILL_1_RIGHT_2 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.CEMENT_SPILL_2_RIGHT_1 + 1
		ldy Tiles.CEMENT_SPILL_2_RIGHT_1 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.CEMENT_SPILL_2_RIGHT_2 + 1
		ldy Tiles.CEMENT_SPILL_2_RIGHT_2 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.CEMENT_SPILL_2_RIGHT_3 + 1
		ldy Tiles.CEMENT_SPILL_2_RIGHT_3 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.CEMENT_SPILL_3_RIGHT_1 + 1
		ldy Tiles.CEMENT_SPILL_3_RIGHT_1 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.CEMENT_SPILL_3_RIGHT_2 + 1
		ldy Tiles.CEMENT_SPILL_3_RIGHT_2 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.CEMENT_SPILL_3_RIGHT_3 + 1
		ldy Tiles.CEMENT_SPILL_3_RIGHT_3 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.CEMENT_SPILL_3_RIGHT_3 + 1
		ldy Tiles.CEMENT_SPILL_3_RIGHT_3 + 2
		jsr SwitchCharAtXY

		//driver left (dead)
		lda Tiles.EMPTY
		ldx Tiles.DRIVER_DEAD_LEFT_1 + 1
		ldy Tiles.DRIVER_DEAD_LEFT_1 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.DRIVER_DEAD_LEFT_2 + 1
		ldy Tiles.DRIVER_DEAD_LEFT_2 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.DRIVER_DEAD_LEFT_3 + 1
		ldy Tiles.DRIVER_DEAD_LEFT_3 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.DRIVER_DEAD_LEFT_4 + 1
		ldy Tiles.DRIVER_DEAD_LEFT_4 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.DRIVER_DEAD_LEFT_5 + 1
		ldy Tiles.DRIVER_DEAD_LEFT_5 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.DRIVER_DEAD_LEFT_6 + 1
		ldy Tiles.DRIVER_DEAD_LEFT_6 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.DRIVER_DEAD_LEFT_7 + 1
		ldy Tiles.DRIVER_DEAD_LEFT_7 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.DRIVER_DEAD_LEFT_8 + 1
		ldy Tiles.DRIVER_DEAD_LEFT_8 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.DRIVER_DEAD_LEFT_9 + 1
		ldy Tiles.DRIVER_DEAD_LEFT_9 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.DRIVER_DEAD_LEFT_10 + 1
		ldy Tiles.DRIVER_DEAD_LEFT_10 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.DRIVER_DEAD_LEFT_11 + 1
		ldy Tiles.DRIVER_DEAD_LEFT_11 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.DRIVER_DEAD_LEFT_12 + 1
		ldy Tiles.DRIVER_DEAD_LEFT_12 + 2
		jsr SwitchCharAtXY

		//driver right(dead)
		lda Tiles.EMPTY
		ldx Tiles.DRIVER_DEAD_RIGHT_1 + 1
		ldy Tiles.DRIVER_DEAD_RIGHT_1 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.DRIVER_DEAD_RIGHT_2 + 1
		ldy Tiles.DRIVER_DEAD_RIGHT_2 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.DRIVER_DEAD_RIGHT_3 + 1
		ldy Tiles.DRIVER_DEAD_RIGHT_3 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.DRIVER_DEAD_RIGHT_4 + 1
		ldy Tiles.DRIVER_DEAD_RIGHT_4 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.DRIVER_DEAD_RIGHT_5 + 1
		ldy Tiles.DRIVER_DEAD_RIGHT_5 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.DRIVER_DEAD_RIGHT_6 + 1
		ldy Tiles.DRIVER_DEAD_RIGHT_6 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.DRIVER_DEAD_RIGHT_7 + 1
		ldy Tiles.DRIVER_DEAD_RIGHT_7 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.DRIVER_DEAD_RIGHT_8 + 1
		ldy Tiles.DRIVER_DEAD_RIGHT_8 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.DRIVER_DEAD_RIGHT_9 + 1
		ldy Tiles.DRIVER_DEAD_RIGHT_9 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.DRIVER_DEAD_RIGHT_10 + 1
		ldy Tiles.DRIVER_DEAD_RIGHT_10 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.DRIVER_DEAD_RIGHT_11 + 1
		ldy Tiles.DRIVER_DEAD_RIGHT_11 + 2
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx Tiles.DRIVER_DEAD_RIGHT_12 + 1
		ldy Tiles.DRIVER_DEAD_RIGHT_12 + 2
		jsr SwitchCharAtXY

		//Left Cement Crate
		lda Tiles.EMPTY
		ldx #5
		ldy #5
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx #5
		ldy #6
		jsr SwitchCharAtXY

		//Right Cement Crate
		lda Tiles.EMPTY
		ldx #34
		ldy #5
		jsr SwitchCharAtXY

		lda Tiles.EMPTY
		ldx #34
		ldy #6
		jsr SwitchCharAtXY

		//check game mode
		lda TitleScreen.GameMode
		cmp #TitleScreen.GAME_A
		bne !skip+
			//GAME MODE A
			lda Tiles.EMPTY
			ldx #25
			ldy #3
			jsr SwitchCharAtXY

			lda Tiles.EMPTY
			ldx #26
			ldy #3
			jsr SwitchCharAtXY

			lda Tiles.EMPTY
			ldx #27
			ldy #3
			jsr SwitchCharAtXY

			lda Tiles.EMPTY
			ldx #28
			ldy #3
			jsr SwitchCharAtXY
			jmp !end+
		!skip:
			//GAME MODE B
			lda Tiles.EMPTY
			ldx #25
			ldy #2
			jsr SwitchCharAtXY

			lda Tiles.EMPTY
			ldx #26
			ldy #2
			jsr SwitchCharAtXY

			lda Tiles.EMPTY
			ldx #27
			ldy #2
			jsr SwitchCharAtXY

			lda Tiles.EMPTY
			ldx #28
			ldy #2
			jsr SwitchCharAtXY
		!end:

		.label row = 24
		//clear bottom row color
       	lda #RED
		ldx #39
        !loop_colour:        	 
           sta VIC.COLOR_RAM + row*$28, x     //Change colour? COLOR_RAM
           dex
           bpl !loop_colour-
		
		//clear bottom row	
		lda #0
		ldx #39
		!loop_row:
			sta Game.SCREEN_RAM + row*$28,x
			dex
			bpl !loop_row-

		rts
	}

	dukeModeOff: {

		/*
		ldx #0
          !loop_text:
          lda MyLabel4,x       //; read characters from line1 table of text..
          beq !next+
          sta screen_ram + row4*$28 + col4, x 
          inx 
          jmp !loop_text-
          !next:
		*/
		lda #0
		ldx #38
		ldy #18
		jsr SwitchCharAtXY
		lda #0
		ldx #39
		ldy #18
		jsr SwitchCharAtXY

		lda #0
		ldx #39
		ldy #19
		jsr SwitchCharAtXY

		lda #0
		ldx #38
		ldy #20
		jsr SwitchCharAtXY
		lda #0
		ldx #39
		ldy #20
		jsr SwitchCharAtXY

		lda #0
		ldx #38
		ldy #21
		jsr SwitchCharAtXY
		lda #0
		ldx #38
		ldy #22
		jsr SwitchCharAtXY
		lda #0
		ldx #39
		ldy #22
		jsr SwitchCharAtXY
		rts
	}

	dukeModeOn: {

		/*
		ldx #0
          !loop_text:
          lda MyLabel4,x       //; read characters from line1 table of text..
          beq !next+
          sta screen_ram + row4*$28 + col4, x 
          inx 
          jmp !loop_text-
          !next:
		*/
		lda #188
		ldx #38
		ldy #18
		jsr SwitchCharAtXY
		lda #189
		ldx #39
		ldy #18
		jsr SwitchCharAtXY

		lda #195
		ldx #39
		ldy #19
		jsr SwitchCharAtXY

		lda #190
		ldx #38
		ldy #20
		jsr SwitchCharAtXY
		lda #196
		ldx #39
		ldy #20
		jsr SwitchCharAtXY

		lda #191
		ldx #38
		ldy #21
		jsr SwitchCharAtXY

		lda #193
		ldx #38
		ldy #22
		jsr SwitchCharAtXY
		lda #192
		ldx #39
		ldy #22
		jsr SwitchCharAtXY
		rts
	}

	SwitchCharAtXY: {
		//pass in a, x, y
		//(char tile index, screenX, screenY)
		.label charIndex = TEMP5
		.label rowTableIndex = TEMP6
		sta charIndex
		tya
		asl
		tay
		lda RowScreenTable, y
		sta rowTableIndex
		lda RowScreenTable + 1, y
		sta rowTableIndex + 1
		txa
		tay
		lda charIndex
		sta (rowTableIndex),y
		rts
	}

	SwitchOnCharAtXY: {
		.label zpOriginalCharIndex = TEMP1
		.label zpCharIndex = TEMP2

		tya
		asl
		tay
		lda RowScreenTable, y
		sta zpCharIndex
		lda RowScreenTable + 1, y
		sta zpCharIndex + 1

		txa
		tay
		//lda #EMPTY_CHAR
		

		sta (zpCharIndex),y
		rts
	}


	DrawMap: {
		.label Row = TEMP1
		.label Col = TEMP2

		lda #<Game.SCREEN_RAM
		sta Scr + 1
		sta Color + 1

		lda #>Game.SCREEN_RAM
		sta Scr + 2

		lda #>VIC.COLOR_RAM
		sta Color + 2



		lda #<MAP
		sta Tile + 1
		lda #>MAP
		sta Tile + 2

		lda #$00
		sta Row

	!RowLoop:
		lda #$00
		sta Col

	!ColumnLoop:	
		ldy #$00

		lda #$00
		sta TileLookup + 1
		sta TileLookup + 2

	Tile: 
		lda $BEEF
		sta TileLookup + 1
		asl TileLookup + 1
		rol TileLookup + 2
		asl TileLookup + 1
		rol TileLookup + 2

		clc
		lda #<MAP_TILES
		adc TileLookup + 1
		sta TileLookup + 1
		lda #>MAP_TILES
		adc TileLookup + 2
		sta TileLookup + 2

	!:
	TileLookup:
		lda $BEEF, y
		ldx TileScreenLocations, y

	Scr: 
		sta $BEEF, x
		tax
		lda CHAR_COLORS, x
		ldx TileScreenLocations, y
	Color: 
		sta $BEEF, x

		iny 
		cpy #$04
		bne !-

		clc
		lda Tile + 1
		adc #$01
		sta Tile + 1
		lda Tile + 2
		adc #$00
		sta Tile + 2

		clc
		lda Scr + 1
		adc #$02
		sta Scr + 1
		sta Color + 1
		bcc !+
		inc Scr + 2
		inc Color + 2
	!:
		
		inc Col
		ldx Col
		cpx #20
		beq !+
		jmp !ColumnLoop-
	!:
		clc
		lda Scr + 1
		adc #$28
		sta Scr + 1
		sta Color + 1
		bcc !+
		inc Scr + 2
		inc Color + 2
	!:	
		inc Row
		ldx Row
		cpx #12

		beq !+
		jmp !RowLoop-
	!:	
		rts			
	}
}