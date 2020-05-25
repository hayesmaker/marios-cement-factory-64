* = * "Keyboard Scan Routine"

// ZERO PAGE Varibles
.const ScanResult       = $e0  // 8 bytes
.const BufferNew        = $e8  // 3 bytes
.const KeyQuantity      = $eb  // 1 byte
.const NonAlphaFlagX    = $ec  // 1 byte
.const NonAlphaFlagY    = $ef  // 1 byte
.const TempZP           = $f0  // 1 byte
.const SimultaneousKeys = $f1  // 1 byte

// Operational Variables
.var MaxKeyRollover = 3

Keyboard:
{
    jmp Main


    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Routine for Scanning a Matrix Row

KeyInRow:
    asl
    bcs *+5
        jsr KeyFound
    .for (var i = 0 ; i < 7 ; i++) {
        inx
        asl
        bcs *+5
            jsr KeyFound
    }
    rts


    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Routine for handling: Key Found

KeyFound:
    stx TempZP
    dec KeyQuantity
    bmi OverFlow
    ldy KeyTable,x
    ldx KeyQuantity
    sty BufferNew,x
    ldx TempZP
    rts

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Routine for handling: Overflow

OverFlow:
    pla  // Dirty hack to handle 2 layers of JSR
    pla
    pla
    pla
    // Don't manipulate last legal buffer as the routine will fix itself once it gets valid input again.
    lda #$03
    sec
    rts


    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Exit Routine for: No Activity

NoActivityDetected:
    // Exit With A = #$01, Carry Set & Reset BufferOld.
    lda #$00
    sta SimultaneousAlphanumericKeysFlag  // Clear the too many keys flag once a "no activity" state is detected.
    stx BufferOld
    stx BufferOld+1
    stx BufferOld+2
    sec
    lda #$01
    rts


    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Exit Routine for Control Port Activity

ControlPort:
    // Exit with A = #$02, Carry Set. Keep BufferOld to verify input after Control Port activity ceases
    sec
    lda #$02
    rts


    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Configure Data Direction Registers
Main:
    ldx #$ff
    stx $dc02       // Port A - Output
    ldy #$00
    sty $dc03       // Port B - Input


    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Check for Port Activity

    sty $dc00       // Connect all Keyboard Rows
    cpx $dc01
    beq NoActivityDetected

    lda SimultaneousAlphanumericKeysFlag
    beq !+
        // Waiting for all keys to be released before accepting new input.
        lda #$05
        sec
        rts
!:

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Check for Control Port #1 Activity

    stx $dc00       // Disconnect all Keyboard Rows
    cpx $dc01       // Only Control Port activity will be detected
    bne ControlPort


    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Scan Keyboard Matrix

    lda #%11111110
    sta $dc00
    ldy $dc01
    sty ScanResult+7
    sec
    .for (var i = 6 ; i > -1 ; i--) {
        rol
        sta $dc00
        ldy $dc01
        sty ScanResult+i
    }


    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Check for Control Port #1 Activity (again)

    stx $dc00       // Disconnect all Keyboard Rows
    cpx $dc01       // Only Control Port activity will be detected
    bne ControlPort


    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Initialize Buffer, Flags and Max Keys

    // Reset current read buffer
    stx BufferNew
    stx BufferNew+1
    stx BufferNew+2

    // Reset Non-AlphaNumeric Flag
    inx
    stx NonAlphaFlagY

    // Set max keys allowed before ignoring result
    lda #MaxKeyRollover
    sta KeyQuantity

    // Counter to check for simultaneous alphanumeric key-presses
    lda #$fe
    sta SimultaneousKeys


    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Check and flag Non Alphanumeric Keys

    lda ScanResult+6
    eor #$ff
    and #%10000000     // Left Shift
    lsr
    sta NonAlphaFlagY
    lda ScanResult+0
    eor #$ff
    and #%10100100     // RUN STOP - C= - CTRL
    ora NonAlphaFlagY
    sta NonAlphaFlagY
    lda ScanResult+1
    eor #$ff
    and #%00011000     // Right SHIFT - CLR HOME
    ora NonAlphaFlagY
    sta NonAlphaFlagY

    lda ScanResult+7  // The rest
    eor #$ff
    sta NonAlphaFlagX


    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Check for pressed key(s)

    lda ScanResult+7
    cmp #$ff
    beq *+5
        jsr KeyInRow
    .for (var i = 6 ; i > -1 ; i--) {
        ldx #[7-i]*8
        lda ScanResult+i
        beq *+5
            jsr KeyInRow
    }


    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Key Scan Completed

    // Put any new key (not in old scan) into buffer
    ldx #MaxKeyRollover-1
    !:  lda BufferNew,x
        cmp #$ff
        beq Exist        // Handle 'null' values
        cmp BufferOld
        beq Exist
        cmp BufferOld+1
        beq Exist
        cmp BufferOld+2
        beq Exist
            // New Key Detected
            inc BufferQuantity
            ldy BufferQuantity
            sta Buffer,y
            // Keep track of how many new Alphanumeric keys are detected
            inc SimultaneousKeys
            beq TooManyNewKeys
    Exist:
        dex
        bpl !-

    // Anything in Buffer?
    ldy BufferQuantity
    bmi BufferEmpty
        // Yes: Then return it and tidy up the buffer
        dec BufferQuantity
        lda Buffer
        ldx Buffer+1
        stx Buffer
        ldx Buffer+2
        stx Buffer+1
        jmp Return

BufferEmpty:  // No new Alphanumeric keys to handle.
    lda #$ff

Return:  // A is preset
    clc
    // Copy BufferNew to BufferOld
    ldx BufferNew
    stx BufferOld
    ldx BufferNew+1
    stx BufferOld+1
    ldx BufferNew+2
    stx BufferOld+2
    // Handle Non Alphanumeric Keys
    ldx NonAlphaFlagX
    ldy NonAlphaFlagY
    rts

TooManyNewKeys:
    sec
    lda #$ff
    sta BufferQuantity
    sta SimultaneousAlphanumericKeysFlag
    lda #$04
    rts

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
KeyTable:
    .byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  // CRSR DOWN, F5, F3, F1, F7, CRSR RIGHT, RETURN, INST DEL
    .byte $ff, $05, $13, $1a, $34, $01, $17, $33  // LEFT SHIFT, "E", "S", "Z", "4", "A", "W", "3"
    .byte $18, $14, $06, $03, $36, $04, $12, $35  // "X", "T", "F", "C", "6", "D", "R", "5"
    .byte $16, $15, $08, $02, $38, $07, $19, $37  // "V", "U", "H", "B", "8", "G", "Y", "7"
    .byte $0e, $0f, $0b, $0d, $30, $0a, $09, $39  // "N", "O" (Oscar), "K", "M", "0" (Zero), "J", "I", "9"
    .byte $2c, $00, $3a, $2e, $2d, $0c, $10, $2b  // ",", "@", ":", ".", "-", "L", "P", "+"
    .byte $2f, $1e, $3d, $ff, $ff, $3b, $2a, $1c  // "/", "^", "=", RIGHT SHIFT, HOME, ";", "*", "£"
    .byte $ff, $11, $ff, $20, $32, $ff, $1f, $31  // RUN STOP, "Q", "C=" (CMD), " " (SPC), "2", "CTRL", "<-", "1"

BufferOld:
    .byte $ff, $ff, $ff

Buffer:
    .byte $ff, $ff, $ff, $ff

BufferQuantity:
    .byte $ff

SimultaneousAlphanumericKeysFlag:
    .byte $00
}