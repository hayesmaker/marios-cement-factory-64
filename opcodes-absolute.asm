`/*
- Absolute mode (3) 
- Zero Page mode the same (but number is always 8bit)
- Absolute mode addressing means using a radix base + number 
- Look up number at the specified address
*/

//Loads
=======
lda $d020 //16 bit number = Abs mode
lda $d0   //8  bit number = Zp mode
lda 53280 //8 bit Decimal

//Store
=======
sta $d020
stx $d021
sty $d022

//Jumps
=======
jmp $1000 //Does not have a ZP mode
jmp $34
//$4c $34 $00
jsr $1000
jsr $42
jsr $0042

//Increments
============
inc $2000  //increment
dec $2000  //decrement

//absolute
==========
lda $2300    		  //hex
lda %0110110101101101 //binary
lda 53280             //decimal

//Shifts & rolls
================
asl $2000
lsr $2030
rol $4096
ror $8000

//Logical ops 
=============
//between acc & memory - store result in acc
ora $1000
and $1000
eor $1000
bit $1000  //like AND but doesnt store result

/* using AND */
-----------------
a     = %00110001
$1000 = %00000001
-----------------
and $1000
=================
a     = %00000001

*bit is like this but does not change the accumulator (only resulting flags are set)
// common use example below:

/* wait for fire button press */
-----------------
lda #$10
bit $dc000
bne *-3
=================

// Add & Sub
============
// add or subtract value in accumulator with value at the passed address
adc $1000  
sbc $1000 

// Compares 
===========
// compare a/x/y with value at the passed address
cmp $2000  // with a
cpx $1000  // with x reg
cpy $5678  // with y reg

// Zeropage
==========
lda $01
lda %01101111	
lda 240
