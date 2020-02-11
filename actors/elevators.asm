ELEVATORS: {
	//getLength: [ _Positions_L_end - Positions_L ]
	Data_L:
		.byte 1,0,1,0,0,1,0,1,0,0,0,1,0,1,0,0,0
	_Data_L_End:

	Data_R:
		.byte 1,0,1,0,0,1,0,1,0,0,0,1,0,1,0,0,0
	_Data_R_End:

	PosIndex_L:
		.byte 0

	PosIndex_R:
		.byte 0

	ClearLoopIndex:
		.byte 0
	DrawLoopIndex:
		.byte 0
	StoreYPos:
		.byte 0		

	Initialise: {

		lda #0
		sta PosIndex_L
		sta PosIndex_R
		
		jsr ClearAllLifts

		rts
	}

	ClearAllLifts: {
		//Todo: Look at refactoring to stack - decide later
		ldy #0

	!Loop:	
		sty ClearLoopIndex	
		lda Tiles.LIFTS_Y, y
		tay
		ldx Tiles.LIFTS_L_X + 0
		jsr RemoveLiftXY

		ldy ClearLoopIndex

		sty ClearLoopIndex	
		lda Tiles.LIFTS_Y, y
		tay
		ldx Tiles.LIFTS_R_X + 0
		jsr RemoveLiftXY

		ldy ClearLoopIndex
		iny
		cpy #5
		bmi !Loop-

		rts
	}

	AddLiftXY: {
		.label leftXIndex = TEMP1
		.label leftYIndex = TEMP2
		//.label EmptyTile = TEMP3
		//53 //54 //55
		stx leftXIndex
		sty leftYIndex

		lda Tiles.LIFTS_CHAR + 0
		ldx leftXIndex
		ldy leftYIndex
		jsr MAPLOADER.SwitchCharAtXY

		lda Tiles.LIFTS_CHAR + 1	
		ldx leftXIndex
		inx
		ldy leftYIndex
		jsr MAPLOADER.SwitchCharAtXY
		
		lda Tiles.LIFTS_CHAR + 1	
		ldx leftXIndex
		inx
		inx
		ldy leftYIndex
		jsr MAPLOADER.SwitchCharAtXY

		lda Tiles.LIFTS_CHAR + 2	
		ldx leftXIndex
		inx
		inx
		inx
		ldy leftYIndex
		jsr MAPLOADER.SwitchCharAtXY
		rts

	}

	RemoveLiftXY: {
		.label leftXIndex = TEMP1
		.label leftYIndex = TEMP2
		.label EmptyTile = TEMP3
		
		lda Tiles.EMPTY
		sta EmptyTile		
		stx leftXIndex
		sty leftYIndex

		lda EmptyTile
		ldx leftXIndex
		ldy leftYIndex
		jsr MAPLOADER.SwitchCharAtXY

		lda EmptyTile
		ldx leftXIndex
		inx
		ldy leftYIndex
		jsr MAPLOADER.SwitchCharAtXY
		
		lda EmptyTile
		ldx leftXIndex
		inx
		inx
		ldy leftYIndex
		jsr MAPLOADER.SwitchCharAtXY

		lda EmptyTile
		ldx leftXIndex
		inx
		inx
		inx
		ldy leftYIndex
		jsr MAPLOADER.SwitchCharAtXY
		rts
	}

    Update: {
    	//.label LeftIndex = TEMP1

    	ldy #0

    	!Loop:
	    	sty DrawLoopIndex
			lda Tiles.LIFTS_Y, y
			sta StoreYPos
			ldx Tiles.LIFTS_L_X
	    	
	    	ldy DrawLoopIndex
	    	lda Data_L, y
	    	
	    	beq !remove+
	    	bne !add+

	    	!remove:
	    		ldy StoreYPos
	    		jsr RemoveLiftXY
	    		jmp !end+
	    	!add:
	    		ldy StoreYPos
	    		jsr AddLiftXY	
	    	
	    	!end:
	    	ldy DrawLoopIndex
			iny
			cpy #5
			bmi !Loop-

		rts
	}

	Update2: {
		// ldx Elevator1_Pos_Index
		// cpx #5
		// bne !Loop+
		// ldx #0
	!Loop:	
		// clc
		// lda Elevator_PosY, x
		// sta Pos1_Y
		// //jsr DrawSprite
		// inx
		// stx Elevator1_Pos_Index
		rts
	}

	
}