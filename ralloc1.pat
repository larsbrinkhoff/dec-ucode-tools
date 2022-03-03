; RALLOC1.PAT, last modified:  2-Sep-86 14:51:38/GMU
;
; Pattern file for pass 1 of the Rigel microcode allocator.
; ALL MICROWORD BIT PATTERNS MUST BE AN EXACT MULTIPLE OF 4 BITS
;	Pattern 3 gives the bit mask of the 11-bit jump field in the microword.
;
;    +- LV+AV+BV
;    |   +- SIM.WBUS.CC
;    |   |    +- SIM.CONST
;    |   |    |     +- SIM.CTRL
;    |   |    |     |     +- SIM.ADDR.SEL
;    |   |    |     |     |    +- SIM.ADDR
;    |   |    |     |     |    |     +- SEQ.COND copy
;    |   |    |     |     |    |     |
;    |   |    |     |     |    |     |       +- BASIC + BASIC.ALU
;    |   |    |     |     |    |     |       |   +- BASIC.ALU
;    |   |    |     |     |    |     |       |   |    +- BASIC.MRQ
;    |   |    |     |     |    |     |       |   |    |   +- L
;    |   |    |     |     |    |     |       |   |    |   |  +- B
;    |   |    |     |     |    |     |       |   |    |   |  |     +- W
;    |   |    |     |     |    |     |       |   |    |   |  |     |    +- CC
;    |   |    |     |     |    |     |       |   |    |   |  |     |    |   +- MISC
;    |   |    |     |     |    |     |       |   |    |   |  |     |    |   |     +- A
;    |   |    |     |     |    |     |       |   |    |   |  |     |    |   |     |    +- SEQ.FMT
;    |   |    |     |     |    |     |       |   |    |   |  |     |    |   |     |    |  +- SEQ.MUX
;    |   |    |     |     |    |     |       |   |    |   |  |     |    |   |     |    |  |  +- SEQ.SUB
;    |   |    |     |     |    |     |       |   |    |   |  |     |    |   |     |    |  |  |      +- J
;    |   |    |     |     |    |     |       |   |    |   |  |     |    |   |     |    |  |  |      |
;   [-] [--] [--] [---] [---] [--] [---]    [-] [-] [---] v [--] [----] v [---] [----] v [-] v [---------]
  3 xxx xxxx xxxx xxxxx xxxxx xxxx xxxxx    xxx xxx xxxxx x xxxx xxxxxx x xxxxx xxxxxx x xxx x 11111111111 ; Jump field

;----------------------------------------------------------------------------------------------------------------------------------
; The following patterns identify microword bit patterns for each of the cases which need to generate constraints.
;	Pattern 101 is used everywhere an intra-page branch is used to constrain the destination of the branch to
;			have the same page number as the branch itself.
;	Pattern 102 is used for CALL to constrain the microinstruction which is the return point of the called routine
;			to the CALL itself.

101 xxx xxxx xxxx xxxxx xxxxx xxxx xxxxx    xxx xxx xxxxx x xxxx xxxxxx x xxxxx xxxxxx 1 xxx x xxxxxxxxxxx ; Branch
102 xxx xxxx xxxx xxxxx xxxxx xxxx xxxxx    xxx xxx xxxxx x xxxx xxxxxx x xxxxx xxxxxx 0 000 1 xxxxxxxxxxx ; CALL
