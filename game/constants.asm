
//todo: Convert to HEX

Numberwang: 
	.byte $60, $61

Tiles: {
	EMPTY:
		.byte 22
	LIFTS_L_X:
		.byte 16
	LIFTS_R_X:
		.byte 20
	LIFTS_Y: 
		.byte 4, 7, 11, 15, 19
	LIFTS_CHAR:
		.byte 53, 54, 55
	LIFTS_CHAR_TOP:
		.byte 56, 57, 58
	SWITCH_1_UP:
		.byte 61, 9, 10
	SWITCH_1_DOWN:
		.byte 63, 9, 11
	SWITCH_2_UP:
		.byte 61, 9, 14
	SWITCH_2_DOWN:
		.byte 63, 9, 15
	SWITCH_3_UP:
		.byte 74, 30, 10
	SWITCH_3_DOWN:
		.byte 78, 30, 11

	SWITCH_4_UP:
		.byte 74, 30, 14
	SWITCH_4_DOWN:
		.byte 78, 30, 15	
		
	
	HAND_1_UP:
		.byte 59, 10, 10
	HAND_1_DOWN:
		.byte 62, 10, 11

	HAND_2_UP:
		.byte 59, 10, 14
	HAND_2_DOWN:
		.byte 62, 10, 15

	HAND_3_UP:
		.byte 76, 29, 10
	HAND_3_DOWN:
		.byte 77, 29, 11
		
	HAND_4_UP:
		.byte 76, 29, 14
	HAND_4_DOWN:
		.byte 77, 29, 15		
	

	TRAP_1_CLOSED:
		.byte 68, 7, 12
	TRAP_1_OPEN:
		.byte 6, 6, 12
	TRAP_1_CLOSED_2:
		.byte 75, 6, 12	

	TRAP_2_CLOSED:
		.byte 68, 7, 16
	TRAP_2_OPEN:
		.byte 6, 6, 16
	TRAP_2_CLOSED_2:
		.byte 75, 6, 16

	TRAP_3_CLOSED:
		.byte 68, 32, 12
	TRAP_3_OPEN:
		.byte 6, 31, 12
	TRAP_3_CLOSED_2:
		.byte 75, 31, 12	

	TRAP_4_CLOSED:
		.byte 68, 32, 16
	TRAP_4_OPEN:
		.byte 6, 31, 16
	TRAP_4_CLOSED_2:
		.byte 75, 31, 16

	//new chars
	//#4 feature
	CEMENT_NEW_LEFT_1:
		.byte 12, 6, 8
	CEMENT_NEW_LEFT_2:
		.byte 66, 7, 8
	CRATE_DOOR_1:
		.byte 79, 8, 8

	//new chars
	//#4 feature
	CEMENT_NEW_RIGHT_1:
		.byte 81, 32, 8
	CEMENT_NEW_RIGHT_2:
		.byte 80, 33, 8
	CRATE_DOOR_2:
		.byte 82, 31, 8	

	CEMENT_SPILL_1_LEFT_1:
		.byte 83, 9, 9
	CEMENT_SPILL_1_LEFT_2:
		.byte 84, 10, 9

	CEMENT_SPILL_2_LEFT_1:
		.byte 85,9,12		
	CEMENT_SPILL_2_LEFT_2:
		.byte 86,10,12	
	CEMENT_SPILL_2_LEFT_3:
		.byte 87,9,13

	CEMENT_SPILL_3_LEFT_1:
		.byte 88,9,16
	CEMENT_SPILL_3_LEFT_2:
		.byte 89,10,16
	CEMENT_SPILL_3_LEFT_3:
		.byte 90, 11, 16

	HOPPER_LEFT_EMPTY:
		.byte 73
	HOPPER_RIGHT_EMPTY:
		.byte 72

	Cements: {
		FRAMES: 
			.byte 69,70,71
		Hopper1: {
			PosX: 
				.byte 6
			PosY:
				.byte 9,10,11			
		}		

		Hopper2: {
			PosX: 
				.byte 6
			PosY:
				.byte 13,14,15			
		}

		Hopper3: {
			PosX: 
				.byte 31
			PosY:
				.byte 9,10,11			
		}

		Hopper4: {
			PosX: 
				.byte 31
			PosY:
				.byte 13,14,15			
		}						

	}	


						


			



}