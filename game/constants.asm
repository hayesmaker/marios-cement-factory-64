
//todo: Convert to HEX

Ui: {
	NUMBER_WANG: 
		.byte $60 //First char index for 0
} 
	

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


	//right hand tiles
	CEMENT_SPILL_1_RIGHT_1:
		.byte 91, 29, 9
	CEMENT_SPILL_1_RIGHT_2:
		.byte 92, 30, 9

	CEMENT_SPILL_2_RIGHT_1:
		.byte 93,29,12		
	CEMENT_SPILL_2_RIGHT_2:
		.byte 94,30,12	
	CEMENT_SPILL_2_RIGHT_3:
		.byte 95,30,13

	CEMENT_SPILL_3_RIGHT_1:
		.byte 88,28,16
	CEMENT_SPILL_3_RIGHT_2:
		.byte 89,29,16
	CEMENT_SPILL_3_RIGHT_3:
		.byte 90, 30, 16
	//

	//@todo implement driver disappearing from this
	DRIVER_LEFT_1:
		.byte 137, 9, 17

	DRIVER_LEFT_2:
		.byte 138, 10, 17
	
	DRIVER_LEFT_3:
		.byte 139, 11, 17

	DRIVER_LEFT_4:
		.byte 141, 9, 18

	DRIVER_LEFT_5:
		.byte 140, 10, 18
	
	DRIVER_DEAD_LEFT_1:
		.byte 135, 10, 19

	DRIVER_DEAD_LEFT_2:
		.byte 136, 11, 19

	DRIVER_DEAD_LEFT_3:
		.byte 125, 9, 20

	DRIVER_DEAD_LEFT_4:
		.byte 126, 10, 20

	DRIVER_DEAD_LEFT_5:
		.byte 127, 11, 20

	DRIVER_DEAD_LEFT_6:
		.byte 128, 12, 20

	DRIVER_DEAD_LEFT_7:
		.byte 129, 13, 20

	DRIVER_DEAD_LEFT_8:
		.byte 130, 9, 21

	DRIVER_DEAD_LEFT_9:
			.byte 131, 10, 21

	DRIVER_DEAD_LEFT_10:
			.byte 132, 11, 21

	DRIVER_DEAD_LEFT_11:
			.byte 133, 12, 21

	DRIVER_DEAD_LEFT_12:
		.byte 134, 13, 21
	/*//*/ //END DRIVER LEFT

	//@todo implement driver right frames:
	//@todo change these values (they are currently the left vals)
	DRIVER_RIGHT_1:
		.byte 157, 28, 17

	DRIVER_RIGHT_2:
		.byte 156, 29, 17
	
	DRIVER_RIGHT_3:
		.byte 155, 30, 17

	DRIVER_RIGHT_4:
		.byte 158, 29, 18

	DRIVER_RIGHT_5:
		.byte 159, 30, 18
	
	DRIVER_DEAD_RIGHT_1:
		.byte 154, 28, 19

	DRIVER_DEAD_RIGHT_2:
		.byte 153, 29, 19

	DRIVER_DEAD_RIGHT_3:
		.byte 147, 26, 20

	DRIVER_DEAD_RIGHT_4:
		.byte 146, 27, 20

	DRIVER_DEAD_RIGHT_5:
		.byte 145, 28, 20

	DRIVER_DEAD_RIGHT_6:
		.byte 144, 29, 20

	DRIVER_DEAD_RIGHT_7:
		.byte 143, 30, 20

	DRIVER_DEAD_RIGHT_8:
		.byte 152, 26, 21

	DRIVER_DEAD_RIGHT_9:
			.byte 151, 27, 21

	DRIVER_DEAD_RIGHT_10:
			.byte 150, 28, 21

	DRIVER_DEAD_RIGHT_11:
			.byte 149, 29, 21

	DRIVER_DEAD_RIGHT_12:
		.byte 148, 30, 21


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