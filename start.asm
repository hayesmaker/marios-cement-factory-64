BasicUpstart2(main)

*=$1000 "music"
.label music_init =*
.label music_play =*+3
.import binary "./assets/sound/MariosFactory_00ch3_01ch2_02ch0_v8_1000.bin"
* = * "KoalaImage" 
.const KOALA_TEMPLATE = "C64FILE, Bitmap=$0000, ScreenRam=$1f40, ColorRam=$2328, BackgroundColor=$2710"
.var picture = LoadBinary("./assets/maps/titles.kla", KOALA_TEMPLATE)
* = * "End of KoalaImage" 
#import "./lib/title-screen.asm"
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
#import "./game/constants.asm"
#import "./game/score.asm"
#import "./game/lives.asm"

* = * "Main" 
main: 

	//bank out BASIC and Kernal
  lda $01
  and #%11111000
  ora #%000101
  sta $01


	!stateLoop:
		jsr Titles.entry
		jsr Game.entry
		
	jmp !stateLoop-

*=$4c00;            .fill picture.getScreenRamSize(), picture.getScreenRam(i)
*=$5000;            .import binary "./assets/sprites/titles.bin"
*=$5c00; colorRam:  .fill picture.getColorRamSize(), picture.getColorRam(i)
*=$6000;            .fill picture.getBitmapSize(), picture.getBitmap(i)

.label SCREEN_RAM = $c000
.label SPRITE_POINTERS = SCREEN_RAM + $3f8

* = $d000 "Sprites"
	.import binary "./assets/sprites/sprites.bin"

* = $b000 "Map data"
MAP_TILES: 
	.import binary "./assets/maps/mcf-bg - Tiles.bin"
CHAR_COLORS: 
	.import binary "./assets/maps/mcf-bg - CharAttribs.bin"
MAP: 
	.import binary "./assets/maps/mcf-bg - Map (20x13).bin"
* = $f000 "Charset"
	.import binary "./assets/maps/mcf-bg - Chars.bin"
