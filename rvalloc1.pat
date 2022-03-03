; RVALLOC1.PAT, last modified:  Feb, 90, RMS.
;
; Pattern file for pass 1 of the Rigel microcode allocator.
; ALL MICROWORD BIT PATTERNS MUST BE AN EXACT MULTIPLE OF 4 BITS
;	Pattern 3 gives the bit mask of the 11-bit jump field in the microword.
;
;    +- BCS.1
;    |    +- ADR
;    |    |    +- ALU.SHF
;    |    |    |     +- CRQ
;    |    |    |     |   +- LIT
;    |    |    |     |   |   +- B
;    |    |    |     |   |   |     +- VAL
;    |    |    |     |   |   |     |   +- RS
;    |    |    |     |   |   |     |   | +- LEN
;    |    |    |     |   |   |     |   | |    +- DST
;    |    |    |     |   |   |     |   | |    |      +- A
;    |    |    |     |   |   |     |   | |    |      |      +- MISC
;    |    |    |     |   |   |     |   | |    |      |      |   +- FMT
;    |    |    |     |   |   |     |   | |    |      |      |   | +- OR
;    |    |    |     |   |   |     |   | |    |      |      |   | |  +- MUX
;    |    |    |     |   |   |     |   | |    |      |      |   | |  |       +- NA
;    |    |    |     |   |   |     |   | |    |      |      |   | |  |       |
;   [--] [-] [---] [---] v [---] [---] v [] [----] [----] [---] v v [-] [---------]
  3 xxxx xxx xxxxx xxxxx x xxxxx xxxxx x xx xxxxxx xxxxxx xxxxx x x xxx 11111111111 ; Jump field

;----------------------------------------------------------------------------------------------------------------------------------
; The following patterns identify microword bit patterns for each of the cases which need to generate constraints.
;	Pattern 101 is used everywhere an intra-page branch is used to constrain the destination of the branch to
;			have the same page number as the branch itself.
;	Pattern 102 is used for CALL to constrain the microinstruction which is the return point of the called routine
;			to the CALL itself.

101 xxxx xxx xxxxx xxxxx x xxxxx xxxxx x xx xxxxxx xxxxxx xxxxx 1 x x0x xxxxxxxxxxx ; Branch (with real address)
102 xxxx xxx xxxxx xxxxx x xxxxx xxxxx x xx xxxxxx xxxxxx xxxxx x x 001 xxxxxxxxxxx ; Call
