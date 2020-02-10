ELEVATORS: {
	Positions:
		.fill 6, 0

	Initialise: {

			
		
		rts
	}

    Update: {
		ldx Elevator1_Pos_Index
		cpx #5
		bne !Loop+
		ldx #0
	!Loop:	
		clc
		lda Elevator_PosY, x
		sta Pos1_Y
		//jsr DrawSprite
		inx
		stx Elevator1_Pos_Index
		rts
	}

	
}