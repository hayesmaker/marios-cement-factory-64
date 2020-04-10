BasicUpstart2(main)

#import "./states/game.asm"
#import "./states/titles.asm"
//#import "./states/gameover.asm"

#import "./lib/title-screen.asm"

#import "./lib/zeropage.asm"
#import "./lib/labels.asm"
#import "./lib/vic.asm"
// #import "./lib/map.asm"
#import "./lib/irq.asm"
// #import "./actors/mixers.asm"
// #import "./actors/cement-crates.asm"
// #import "./actors/elevators.asm"
// #import "./actors/player.asm"
// #import "./actors/poured-cement.asm"
#import "./game/constants.asm"
// #import "./game/score.asm"
// #import "./game/lives.asm"

main: 
	!stateLoop:
		jsr Titles.entry
	jmp !stateLoop-