.macro LIBSCORING_DISPLAYSCORESET_AA (scoreAddress,scoreScreenPosition)
{
    // Score Address Location
    // Screen Position Address

    lda scoreAddress
    and #$f0                        // hundred-thousands
    lsr                             // divide by 2
    lsr                             // divide by 4
    lsr                             // divide by 8
    lsr                             // divide by 16
    ora #$30                        // -->ascii
    sta scoreScreenPosition         // print on screen
    lda scoreAddress
    and #$0f                        // ten-thousands
    ora #$30                        // -->ascii
    sta scoreScreenPosition + 1     // print on next screen position
}

//====================================================================================
.macro LIBSCORING_DISPLAYSCORE_AA(scoreAddress, scoreScreenPosition)
{
    // Score Address Location
    // Screen Position Address

    LIBSCORING_DISPLAYSCORESET_AA(scoreAddress + 2, scoreScreenPosition)
    LIBSCORING_DISPLAYSCORESET_AA(scoreAddress + 1, scoreScreenPosition + 2)
    LIBSCORING_DISPLAYSCORESET_AA(scoreAddress, scoreScreenPosition + 4)
} 
