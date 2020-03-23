ELEVATORS: {
	//getLength: [ _Positions_L_end - Positions_L ]    6
	Data_L: //0 - - -[1 2 3]- 8 9 - -12 - - -16 - - -20 - - - - - 
		.byte 0,0,0,0,1,0,1,0,0,1,0,1,0,0,0,1,0,1,0,0,0,1,0,1,0,0
	_Data_L_End:

	LeftDataIndex:
		.byte 0

	PosIndex_L:
		.byte 0
	//todo: make this local var?
	DrawLoopIndex:
		.byte 0
	StoreYPos:
		.byte 0		
	
	Data_R:// - - - - -                                           - - - - -
		.byte 1,0,0,0,1,0,1,0,0,1,0,1,0,0,0,1,0,1,0,0,0,1,0,1,0,0,1,0,0,0,1
	_Data_R_End:

	RightDataIndex:
		.byte 0
	PosIndex_R:
		.byte 0
	//todo: make this local var?
	DrawLoopIndex_R:
	.byte 0
	StoreYPos_R:
		.byte 0			

	ClearLoopIndex:
		.byte 0
	
	

	Initialise: {

		lda #0
		sta PosIndex_L
		sta PosIndex_R
		lda #0
		sta DrawLoopIndex
		sta DrawLoopIndex_R
		jsr ClearAllLifts

		lda #0
		sta LeftDataIndex
		sta RightDataIndex

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

	AddTopLiftXY: {
		.label leftXIndex = TEMP1
		.label leftYIndex = TEMP2
		stx leftXIndex
		sty leftYIndex
		lda Tiles.LIFTS_CHAR_TOP + 0
		ldx leftXIndex
		ldy leftYIndex
		jsr Map.SwitchCharAtXY
		lda Tiles.LIFTS_CHAR_TOP + 1	
		ldx leftXIndex
		inx
		ldy leftYIndex
		jsr Map.SwitchCharAtXY
		
		lda Tiles.LIFTS_CHAR_TOP + 1	
		ldx leftXIndex
		inx
		inx
		ldy leftYIndex
		jsr Map.SwitchCharAtXY

		lda Tiles.LIFTS_CHAR_TOP + 2	
		ldx leftXIndex
		inx
		inx
		inx
		ldy leftYIndex
		jsr Map.SwitchCharAtXY
		rts

	}

	AddLiftXY: {
		.label leftXIndex = TEMP1
		.label leftYIndex = TEMP2
		stx leftXIndex
		sty leftYIndex

		lda Tiles.LIFTS_CHAR + 0
		ldx leftXIndex
		ldy leftYIndex
		jsr Map.SwitchCharAtXY

		lda Tiles.LIFTS_CHAR + 1	
		ldx leftXIndex
		inx
		ldy leftYIndex
		jsr Map.SwitchCharAtXY
		
		lda Tiles.LIFTS_CHAR + 1	
		ldx leftXIndex
		inx
		inx
		ldy leftYIndex
		jsr Map.SwitchCharAtXY

		lda Tiles.LIFTS_CHAR + 2	
		ldx leftXIndex
		inx
		inx
		inx
		ldy leftYIndex
		jsr Map.SwitchCharAtXY
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
		jsr Map.SwitchCharAtXY

		lda EmptyTile
		ldx leftXIndex
		inx
		ldy leftYIndex
		jsr Map.SwitchCharAtXY
		
		lda EmptyTile
		ldx leftXIndex
		inx
		inx
		ldy leftYIndex
		jsr Map.SwitchCharAtXY

		lda EmptyTile
		ldx leftXIndex
		inx
		inx
		inx
		ldy leftYIndex
		jsr Map.SwitchCharAtXY
		rts
	}

    Update1: {
    	ldy #0

    	!Loop:
	    	sty DrawLoopIndex
			lda Tiles.LIFTS_Y, y
			sta StoreYPos
			ldx Tiles.LIFTS_L_X
	    	
	    	lda #4
	    	sec
	    	sbc DrawLoopIndex
	    	clc
	    	adc LeftDataIndex
	    	tay 
	    	lda Data_L, y
	    	bne !add+

	    	!remove:
	    		ldy StoreYPos
	    		jsr RemoveLiftXY
	    		jmp !end+
	    	!add:
	    		lda DrawLoopIndex
	    		jsr PLAYER.MoveWithLiftY1

	    		ldy StoreYPos
	    		lda StoreYPos
	    		cmp #4
	    		beq !drawTopCharLift+
	    		cmp #19
	    		beq	!drawTopCharLift+

	    		jsr AddLiftXY
	    		jmp !end+
	    	!drawTopCharLift:
	    		jsr AddTopLiftXY
	    	
	    	!end:
	    	ldy DrawLoopIndex
			iny
			cpy #5
			bmi !Loop-
			ldx LeftDataIndex
			inx
			cpx #21
			bne !return+
			ldx #4
		!return:
			stx LeftDataIndex
			rts

	}



	Update2: {
    	//.label LeftIndex = TEMP1

    	ldy #0

    	!Loop:
	    	sty DrawLoopIndex_R
			lda Tiles.LIFTS_Y, y
			sta StoreYPos_R
			ldx Tiles.LIFTS_R_X

			lda DrawLoopIndex_R
			clc
			adc RightDataIndex
			tay
	    	lda Data_R, y
	    	bne !add+

	    	!remove:
	    		ldy StoreYPos_R
	    		jsr RemoveLiftXY
	    		jmp !end+
	    	!add:

	    		lda DrawLoopIndex_R
	    		jsr PLAYER.MoveWithLiftY2

	    		ldy StoreYPos_R
	    		lda StoreYPos_R
	    		
	    		cmp #4
	    		beq !drawTopCharLift+
	    		cmp #19
	    		beq !drawTopCharLift+

	    		jsr AddLiftXY
	    		jmp !end+
	    	!drawTopCharLift:
	    		jsr AddTopLiftXY
	    	
	    	!end:
	    	ldy DrawLoopIndex_R
			iny
			cpy #5
			bmi !Loop-
		
			ldx RightDataIndex
			inx

			cpx #26 //todo: change this val
			bne !return+

			ldx #0 //todo: reset val

		!return:
			stx RightDataIndex

			//jsr PLAYER.CheckMovement	
			
			rts

	}

}