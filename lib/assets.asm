.label SCREEN_RAM = $c000

.label SPRITE_POINTERS = SCREEN_RAM + $3f8

* = $d000 "Sprites"
	.import binary "../assets/sprites/sprites.bin"

* = $8000 "Map data"
MAP_TILES: 
	.import binary "../assets/maps/mcf-bg - Tiles.bin"

CHAR_COLORS: 
	.import binary "../assets/maps/mcf-bg - CharAttribs.bin"

MAP: 
	.import binary "../assets/maps/mcf-bg - Map (20x13).bin"

* = $f000 "Charset"
	.import binary "../assets/maps/mcf-bg - Chars.bin"



