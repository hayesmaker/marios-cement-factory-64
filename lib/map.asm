//export from Charpad with 2x2 tileset

Map: {
	TileScreenLocations: 
		.byte 0,1,40,41
	RowColourTable:
		.fillword 25, VIC.COLOR_RAM + (i * 40)
	RowScreenTable:
		.fillword 25, SCREEN_RAM + (i * 40)

	numberYPos:
		.byte $00
	numberYIndex:
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

		rts
	}

	ColorByXY: {
		//pass in x and y (as col & row)
		.label zpCharIndex = TEMP2
		tya
		asl
		tay
		lda RowColourTable, y
		sta zpCharIndex
		lda RowColourTable + 1, y
		sta zpCharIndex + 1

		txa
		tay
		lda #15
		sta (zpCharIndex),y
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

		lda #<SCREEN_RAM
		sta Scr + 1
		sta Color + 1

		lda #>SCREEN_RAM
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