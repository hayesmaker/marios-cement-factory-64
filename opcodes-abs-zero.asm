/*
Absolute mode(3) + Zero Page(2)
*/

lda $d020 //16 bit number = Abs mode
lda $d0   //8  bit number = Zp mode

//absolute
lda $2300    		   //hex
lda %0110110101101101 //binary
lda 53280             //decimal

//zeropage
lda $01
lda %01101111
lda 240