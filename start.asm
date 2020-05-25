BasicUpstart2(main)

*=$1000 "music"
.label music_init =*
.label music_play =*+3	
.import binary "./assets/sound/music.bin"

SOUND_FALL:
.import binary "./assets/sound/sfx/SOUND_FALL"
SOUND_MOVE:
.import binary "./assets/sound/sfx/SOUND_MOVE"
SOUND_TICK: 
.import binary "./assets/sound/sfx/SOUND_TICK"
SOUND_CRUNCH:
.import binary "./assets/sound/sfx/SOUND_FALL"
SOUND_SCORE:
.import binary "./assets/sound/sfx/SOUND_SCORE"


* = * "KoalaImage" 
.const KOALA_TEMPLATE = "C64FILE, Bitmap=$0000, ScreenRam=$1f40, ColorRam=$2328, BackgroundColor=$2710"
.var picture = LoadBinary("./assets/maps/titles.kla", KOALA_TEMPLATE)
* = * "End of KoalaImage"

* = * "CODE"
#import "./game/sounds.asm" 
#import "./lib/title-screen.asm"
#import "./lib/options-screen.asm"
#import "./lib/credits-screen.asm"
#import "./lib/scores-screen.asm"
#import "./states/titles.asm"
#import "./states/game.asm"
#import "./lib/zeropage.asm"
#import "./lib/labels.asm"
#import "./lib/vic.asm"
#import "./lib/map.asm"
#import "./lib/irq.asm"
#import "./actors/mixers.asm"
#import "./actors/cement-crates.asm"
#import "./actors/elevators.asm"
#import "./actors/player.asm"
#import "./actors/poured-cement.asm"

* = * "Main" 
main: 
//bank out BASIC and Kernal

  lda $01
  and #%11111000
  ora #%000101
  sta $01

	!stateLoop:

		jsr Titles.entry
		jsr GameOver.entry
		jsr Game.entry
		
		
	jmp !stateLoop-

*=* "End main"

*=$4c00;             .fill picture.getScreenRamSize(), picture.getScreenRam(i)
*=$5000 "Menu Sprites"
     .import binary "./assets/sprites/titles.bin"
*=$5c00; colorRam:   .fill picture.getColorRamSize(), picture.getColorRam(i)
*=$6000;             .fill picture.getBitmapSize(), picture.getBitmap(i)

*=$8000 "modules"

#import "./game/constants.asm"
#import "./game/score.asm"
#import "./game/lives.asm"
#import "./game/options.asm"
#import "./states/gameover.asm"
#import "./lib/game-over-screen.asm"
#import "./lib/keyboard.asm"

*=* "end of modules"

* = $d000 "Sprites"
	.import binary "./assets/sprites/sprites.bin"
* = $b000 "Map data"
MAP_TILES: 
	.import binary "./assets/maps/mcf-bg - Tiles.bin"
CHAR_COLORS: 
	.import binary "./assets/maps/mcf-bg - CharAttribs.bin"
MAP: 
	.import binary "./assets/maps/mcf-bg - Map (20x12).bin"
* = $f000 "Game-Charset"
	.import binary "./assets/maps/mcf-bg - Chars.bin"
* = $f800 "Titles-Charset"
    .import binary "./assets/maps/thereyabloodygo.bin"

