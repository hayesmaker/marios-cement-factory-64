//export from Charpad with 2x2 tileset

MAPLOADER: {
	.label EMPTY_CHAR = 22
	TileScreenLocations: 
		.byte 0,1,40,41
	RowColourTable:
		.fillword 25, VIC.COLOR_RAM + (i * 40)
	RowScreenTable:
		.fillword 25, SCREEN_RAM + (i * 40)

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

	SwitchOffCharAtXY: {
		//pass in x and y (as col & row)

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
		lda #EMPTY_CHAR
		sta (zpCharIndex),y
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