; RVALLOC3.PAT, last modified:  Feb, 90, RMS.
;
; Pattern file for pass 3 of the Raven microcode allocator.
; ALL MICROWORD BIT PATTERNS MUST BE AN EXACT MULTIPLE OF 4 BITS
;	Pattern 3 gives the bit mask of the 11-bit jump field in the 80-bit .MCR and .ULD microword
;	Pattern 4 gives the source of bits to move in the .MCR and .ULD microword
;	Pattern 5 gives the destination of bits to move from the .MCR and .ULD microword
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
  4 1111 xxx xxxxx xxxxx x xxxxx xxxxx x xx xxxxxx xxxxxx xxxxx x x xxx xxxxxxxxxxx ; Source bits
  5 xxxx xxx xxxxx xxxxx x xxxxx xxxxx x xx xxxxxx xxxxxx xxxxx x x xxx 1111xxxxxxx ; Destination bits

; ---------------------------------------------------------------------------------------------------------------------------------
; These patterns specify actions to be taken on a microword match of the pattern
;	Pattern 101 specifies the mask for a RETURN microinstruction
;	Pattern 102 specifies the mask for an EXIT TRAP microinstruction
;	Pattern 103 specifies the mask for a DECODE NEXT microinstruction
;	Patterns 104-107 specifies the masks for variants of GOTO
;	Patterns 108-111 specifies the masks for variants of CALL
;	Patterns 112-115 specifies the masks for variants of DECODE NEXT conditional

101 xxxx xxx xxxxx xxxxx x xxxxx xxxxx x xx xxxxxx xxxxxx xxxxx x x 011 xxxxxxxxxxx ; RETURN
102 xxxx xxx xxxxx xxxxx x xxxxx xxxxx x xx xxxxxx xxxxxx xxxxx x x 010 xxxxxxxxxxx ; EXIT TRAP
103 xxxx xxx xxxxx xxxxx x xxxxx xxxxx x xx xxxxxx xxxxxx xxxxx x x 11x xxxxxxxxxxx ; DECODE NEXT
104 xxxx xxx xxxxx xxxxx x xxxxx xxxxx x xx xxxxxx xxxxxx xxxxx 0 0 000 xxxxxxxxxxx ; GOTO jump
105 xxxx xxx xxxxx xxxxx x xxxxx xxxxx x xx xxxxxx xxxxxx xxxxx 0 1 000 xxxxxxxxxxx ; GOTO CASE jump
106 xxxx xxx xxxxx xxxxx x xxxxx xxxxx x xx xxxxxx xxxxxx xxxxx 1 0 000 xxxxxxxxxxx ; GOTO branch
107 xxxx xxx xxxxx xxxxx x xxxxx xxxxx x xx xxxxxx xxxxxx xxxxx 1 1 000 xxxxxxxxxxx ; GOTO CASE branch
108 xxxx xxx xxxxx xxxxx x xxxxx xxxxx x xx xxxxxx xxxxxx xxxxx 0 0 001 xxxxxxxxxxx ; CALL jump
109 xxxx xxx xxxxx xxxxx x xxxxx xxxxx x xx xxxxxx xxxxxx xxxxx 0 1 001 xxxxxxxxxxx ; CALL CASE jump
110 xxxx xxx xxxxx xxxxx x xxxxx xxxxx x xx xxxxxx xxxxxx xxxxx 1 0 001 xxxxxxxxxxx ; CALL branch
111 xxxx xxx xxxxx xxxxx x xxxxx xxxxx x xx xxxxxx xxxxxx xxxxx 1 1 001 xxxxxxxxxxx ; CALL CASE branch
112 xxxx xxx xxxxx xxxxx x xxxxx xxxxx x xx xxxxxx xxxxxx xxxxx 0 0 10x xxxxxxxxxxx ; DECODE NEXT COND jump
113 xxxx xxx xxxxx xxxxx x xxxxx xxxxx x xx xxxxxx xxxxxx xxxxx 0 1 10x xxxxxxxxxxx ; DECODE NEXT COND CASE jump
114 xxxx xxx xxxxx xxxxx x xxxxx xxxxx x xx xxxxxx xxxxxx xxxxx 1 0 10x xxxxxxxxxxx ; DECODE NEXT COND branch
115 xxxx xxx xxxxx xxxxx x xxxxx xxxxx x xx xxxxxx xxxxxx xxxxx 1 1 10x xxxxxxxxxxx ; DECODE NEXT COND CASE branch

; ---------------------------------------------------------------------------------------------------------------------------------
; These patterns define what the output files look like
;	Pattern 50 determines where the ALLOC information is placed in the .ACR header line
;	Pattern 54 delimits the region on the .ACR file line where the mapped address and microword are written
;	Pattern 55 delimits the region on the .ACR file line where the mapped address is written
;	Pattern 56 delimits the region on the .ACR file line where the mapped microword is written
;	Pattern 57 delimits the region on the .ACR file line where the textual description of the microword is written
;	Pattern 58 delimits the region on the .ACR file line where the target microword address is written
;	Pattern 60 delimits the region on the .ACR file line where the target microword page address is written
;	Pattern 61 specifies the number of digits between commas in the .ACR file microword
;	Pattern 62 specifies the total number of hex digits to be output in the .ACR file microword
;	Pattern 63 indicates which bits of the microword are to be output to the .U41 file
;	Pattern 64 indicates which bits of the microword are to be output to the .ACR file
;	Pattern 65 specifies the total number of hex digits to be output in the .U41 file microword
;	Pattern 66 indicates which bits comprise the 11-bit jump field in the output microword.
;	Pattern 67 indicates which bits comprise the 7-bit branch field in the output microword.

50  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx111111111111111111111111111111x ; .ACR date and time
54  xx111111111111111111111111111111          ; uAddress and 80-bit uWord in .mcr file
55  xx111xxxxxxxxxxxxxxxxxxxxxxxxxxx          ; uAddress in .acr file
56  xxxxxx111111111111111111xxxxxxxx          ; uWord in .acr file
57  xxxxxxxxxxxxxxxxxxxxxxxxx11xxxxx          ; uWord text description field in .acr (DECN, CALL, etc.)
58  xxxxxxxxxxxxxxxxxxxxxxxxxxxx111x          ; target uWord hex address field in .acr
60  xxxxxxxxxxxxxxxxxxxxxxxxxx11111x          ; second page number 'p2345' in .acr
61  1111xxxxxxxxxxxxxxxxxxxxxxxxxxxx          ; length = number of digits between commas
62  11111 11111 11111 xxxxxxxxxxxxxx          ; length = number of digits in microword for ACR output
63  xxxx 111 11111 11111 1 11111 11111 1 11 111111 111111 11111 1 1 111 11111111111 ; U41 output string field
64  xxxx 111 11111 11111 1 11111 11111 1 11 111111 111111 11111 1 1 111 11111111111 ; ACR output string field
65  11111 11111 11111 xxxxxxxxxxxxxx	      ; length = number of digits in microword for U41 output
66  xxxx xxx xxxxx xxxxx x xxxxx xxxxx x xx xxxxxx xxxxxx xxxxx x x xxx 11111111111 ; Jump field
67  xxxx xxx xxxxx xxxxx x xxxxx xxxxx x xx xxxxxx xxxxxx xxxxx x x xxx xxxx1111111 ; Branch field
