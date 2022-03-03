; RALLOC3.PAT, last modified:  2-Sep-86 14:47:10/GMU
;
; Pattern file for pass 3 of the Rigel microcode allocator.
; ALL MICROWORD BIT PATTERNS MUST BE AN EXACT MULTIPLE OF 4 BITS
;	Pattern 3 gives the bit mask of the 11-bit jump field in the 80-bit .MCR and .ULD microword
;	Pattern 4 gives the source of bits to move in the .MCR and .ULD microword
;	Pattern 5 gives the destination of bits to move from the .MCR and .ULD microword
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
  4 xxx xxxx xxxx xxxxx xxxxx xxxx x1111    xxx xxx xxxxx x xxxx xxxxxx x xxxxx xxxxxx x xxx x xxxxxxxxxxx ; Source bits

; BEHAVIORAL MODEL DEFINTION
  5 xxx xxxx xxxx xxxxx xxxxx xxxx xxxxx    xxx xxx xxxxx x xxxx xxxxxx x xxxxx xxxxxx x xxx x 1111xxxxxxx ; Destination bits
; PERFORMANCE MODEL DEFINITION
; 5 xxx xxxx xxxx xxxxx xxxxx xxxx xxxxx    xxx xxx xxxxx x xxxx xxxxxx x xxxxx xxxxxx x xxx x xxxxxxxxxxx ; Destination bits

; ---------------------------------------------------------------------------------------------------------------------------------
; These patterns specify actions to be taken on a microword match of the pattern
;	Pattern 101 specifies the mask for a RETURN microinstruction
;	Pattern 102 specifies the mask for an EXIT TRAP microinstruction
;	Pattern 103 specifies the mask for a DECODER NEXT microinstruction
;	Pattern 105 specifies the mask for a DECODER NEXT IF DL.BWL or DECODER NEXT IF DL.BWL OR AT.W (jump) microinstruction
;	Pattern 106 specifies the mask for a CASE (branch) microinstruction
;	Pattern 107 specifies the mask for a CASE (jump) microinstruction
;	Pattern 108 specifies the mask for a CALL microinstruction
;	Pattern 109 specifies the mask for a JUMP-class microinstruction

101 xxx xxxx xxxx xxxxx xxxxx xxxx xxxxx    xxx xxx xxxxx x xxxx xxxxxx x xxxxx xxxxxx 0 001 x xxxxxxxxxxx ; RETURN
102 xxx xxxx xxxx xxxxx xxxxx xxxx xxxxx    xxx xxx xxxxx x xxxx xxxxxx x xxxxx xxxxxx 0 010 x xxxxxxxxxxx ; EXIT TRAP
103 xxx xxxx xxxx xxxxx xxxxx xxxx xxxxx    xxx xxx xxxxx x xxxx xxxxxx x xxxxx xxxxxx 0 100 x xxxxxxxxxxx ; DECODER NEXT
105 xxx xxxx xxxx xxxxx xxxxx xxxx xxxxx    xxx xxx xxxxx x xxxx xxxxxx x xxxxx xxxxxx 0 101 x xxxxxxxxxxx ; DECODER NEXT NOT QUAD
105 xxx xxxx xxxx xxxxx xxxxx xxxx xxxxx    xxx xxx xxxxx x xxxx xxxxxx x xxxxx xxxxxx 0 110 x xxxxxxxxxxx ; DECODER NEXT NOT QUAD

; BEHAVIORAL MODEL DEFINTION
106 xxx xxxx xxxx xxxxx xxxxx xxxx xxxxx    xxx xxx xxxxx x xxxx xxxxxx x xxxxx xxxxxx 1 xxx x xxxxxxxxxxx ; CASE
; PERFORMANCE MODEL DEFINITION
; 107 xxx xxxx xxxx xxxxx xxxxx xxxx xxxxx    xxx xxx xxxxx x xxxx xxxxxx x xxxxx xxxxxx 1 xxx x xxxxxxxxxxx ; CASE

108 xxx xxxx xxxx xxxxx xxxxx xxxx xxxxx    xxx xxx xxxxx x xxxx xxxxxx x xxxxx xxxxxx 0 000 1 xxxxxxxxxxx ; CALL
109 xxx xxxx xxxx xxxxx xxxxx xxxx xxxxx    xxx xxx xxxxx x xxxx xxxxxx x xxxxx xxxxxx 0 000 0 xxxxxxxxxxx ; JUMP

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
56  xxxxxxx1111111111111111xxxxxxxxx          ; uWord in .acr file
57  xxxxxxxxxxxxxxxxxxxxxxxx1111xxxx          ; uWord text description field in .acr (DECN, CALL, etc.)
58  xxxxxxxxxxxxxxxxxxxxxxxxxxxxx111          ; target uWord hex address field in .acr
60  xxxxxxxxxxxxxxxxxxxxxxxxxxx11111          ; second page number 'p2345' in .acr
61  1111xxxxxxxxxxxxxxxxxxxxxxxxxxxx          ; length = number of digits between commas
62  11111 11111 111xx xxxxxxxxxxxxxx          ; length = number of digits in microword for ACR output

; BEHAVIORAL MODEL DEFINTION
65  11111 11111 111xx xxxxxxxxxxxxxxx         ; length = number of digits in microword for U41 output
; PERFORMANCE MODEL DEFINITION
; 65  11111 11111 11111 11111 xxxxx xxx	      ; length = number of digits in microword for U41 output

; BEHAVIORAL MODEL DEFINTION
63  xxx xxxx xxxx xxxxx xxxxx xxxx xxx11    111 111 11111 1 1111 111111 1 11111 111111 1 111 1 11111111111 ; U41 output string
; PERFORMANCE MODEL DEFINITION
; 63  111 1111 1111 11111 11111 1111 11111    111 111 11111 1 1111 111111 1 11111 111111 1 111 1 11111111111 ; U41 output string

64  xxx xxxx xxxx xxxxx xxxxx xxxx xxx11    111 111 11111 1 1111 111111 1 11111 111111 1 111 1 11111111111 ; ACR output string
66  xxx xxxx xxxx xxxxx xxxxx xxxx xxxxx    xxx xxx xxxxx x xxxx xxxxxx x xxxxx xxxxxx x xxx x 11111111111 ; jump field
67  xxx xxxx xxxx xxxxx xxxxx xxxx xxxxx    xxx xxx xxxxx x xxxx xxxxxx x xxxxx xxxxxx x xxx x xxxx1111111 ; branch field
