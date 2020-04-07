
BasicUpstart2(main)

.const KOALA_TEMPLATE = "C64FILE, Bitmap=$0000, ScreenRam=$1f40, ColorRam=$2328, BackgroundColor=$2710"
.var picture = LoadBinary("tree.kla", KOALA_TEMPLATE)

main:
* = * ""
        lda #%00111000    // $38
        sta $d018
        lda #%11011000    // $d8
        sta $d016
        lda #%00111011    // $3b
        sta $d011
        lda #0
        sta $d020   // border
        lda #picture.getBackgroundColor()
        sta $d021   // background
        ldx #0
!loop:
        .for (var i=0; i<4; i++) {
           lda colorRam+i*$100,x
           sta $d800+i*$100,x
        }
        inx
        bne !loop-
        jmp *

*=$0c00;            .fill picture.getScreenRamSize(), picture.getScreenRam(i)
*=$1c00; colorRam:  .fill picture.getColorRamSize(), picture.getColorRam(i)
*=$2000;            .fill picture.getBitmapSize(), picture.getBitmap(i)
