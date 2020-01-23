.label SCREEN_RAM = $c000

.label SPRITE_POINTERS = SCREEN_RAM + $3f8

* = $d000 "Sprites"
	.import binary "../assets/sprites/sprites.bin"

* = $8000 "Map data"
MAP_TILES: 
	.import binary "../assets/maps/tiles.bin"

CHAR_COLORS: 
	.import binary "../assets/maps/colours.bin"

MAP: 
	.import binary "../assets/maps/map.bin"

* = $f000 "Charset"
	.import binary "../assets/maps/char.bin"



