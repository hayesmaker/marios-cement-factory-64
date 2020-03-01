CEMENTS: {

	Initialise: {
		jsr ClearHoppers
		rts
	}
		//Create a Clear Hopper by index (0,1,2,3) subroutine
	ClearHoppers: {
		//1-2
		ldx Tiles.Cements.Hopper1.PosX + 0
		ldy Tiles.Cements.Hopper1.PosY + 0
		jsr ClearCementAtXY

		ldx Tiles.Cements.Hopper1.PosX + 0
		ldy Tiles.Cements.Hopper1.PosY + 1
		jsr ClearCementAtXY

		ldx Tiles.Cements.Hopper1.PosX + 0
		ldy Tiles.Cements.Hopper1.PosY + 2
		jsr ClearCementAtXY

		ldx Tiles.Cements.Hopper2.PosX + 0
		ldy Tiles.Cements.Hopper2.PosY + 0
		jsr ClearCementAtXY

		ldx Tiles.Cements.Hopper2.PosX + 0
		ldy Tiles.Cements.Hopper2.PosY + 1
		jsr ClearCementAtXY

		ldx Tiles.Cements.Hopper2.PosX + 0
		ldy Tiles.Cements.Hopper2.PosY + 2
		jsr ClearCementAtXY

		//3-4
		ldx Tiles.Cements.Hopper3.PosX + 0
		ldy Tiles.Cements.Hopper3.PosY + 0
		jsr ClearCementAtXY

		ldx Tiles.Cements.Hopper3.PosX + 0
		ldy Tiles.Cements.Hopper3.PosY + 1
		jsr ClearCementAtXY

		ldx Tiles.Cements.Hopper3.PosX + 0
		ldy Tiles.Cements.Hopper3.PosY + 2
		jsr ClearCementAtXY

		ldx Tiles.Cements.Hopper4.PosX + 0
		ldy Tiles.Cements.Hopper4.PosY + 0
		jsr ClearCementAtXY

		ldx Tiles.Cements.Hopper4.PosX + 0
		ldy Tiles.Cements.Hopper4.PosY + 1
		jsr ClearCementAtXY

		ldx Tiles.Cements.Hopper4.PosX + 0
		ldy Tiles.Cements.Hopper4.PosY + 2
		jsr ClearCementAtXY

		rts
	}

	ClearCementAtXY: {
		.label leftXIndex = TEMP1
		.label leftYIndex = TEMP2
		stx leftXIndex
		sty leftYIndex

		lda Tiles.HOPPER_LEFT_EMPTY
		ldx leftXIndex
		ldy leftYIndex
		jsr MAPLOADER.SwitchCharAtXY

		lda Tiles.EMPTY
		ldx leftXIndex
		inx
		ldy leftYIndex
		jsr MAPLOADER.SwitchCharAtXY

		lda Tiles.HOPPER_RIGHT_EMPTY
		ldx leftXIndex
		inx
		inx
		ldy leftYIndex
		jsr MAPLOADER.SwitchCharAtXY

		rts
	}	
}