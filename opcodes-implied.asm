/*
Implied Mode 1 Byte
*/

clc //carry
sec

cld //decimal
sed

cli //interrupt flag
sei 

clv // clear overflow

nop // no op
brk // break instruction

rts // return subroutine
rti // return interrupt

tax // transfrer
txa 
tay 
tay

tsx //stack pointer
tsx

inx //increment 1
iny 

dex //decrement 1
dey

pha // push acc to stack
pla 

php // push processor status to stack
plp 

//bit ops
asl //Arithmetic shift left (accumulator) - puts cut off bit in carry flag
lsr //logical shift right

rol // roll left accumulator
ror // roll right accumulator