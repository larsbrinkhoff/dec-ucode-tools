; 2-Aug-85   PIR  MIB<12> flipped
; 24-Apr-85  PIR  Updated to match new style I-box
; 26-Mar-85  RLS  First try for CVAX
  2 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx x xxxxx 11111111111 ; label field

; * NEW FIELD PATTERNS FOR PROCESSING .MCR, .ADR, AND .ACR FILes

50  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx111111111111111111111111111111x ; .ACR date and time
51  xx111111111111111111xxxxxxx               ; location of date and time in .ADR file 
52  1x                                        ; memory in .mcr 
53  1x                                        ; memory in .acr
54  xx1111111111111111111111111111xx          ; uAddress and 64 bit uWord in .mcr file
55  xx111xxxxxxxxxxxxxxxxxxxxxxxxxxx          ; uAddress in .acr file
56  xxxxxxx1111111111111xxxxxxxxxxxx          ; uWord in .acr file
57  xxxxxxxxxxxxxxxxxxxxxx1111xxxxxx          ; first hex address printing field in .acr
58  xxxxxxxxxxxxxxxxxxxxxxxxxxx1111x          ; second hex address printing field in .acr
59  xxxxxxxxxxxxxxxxxxxxx11111xxxxxx          ; first page number  'p1234' in .acr
60  xxxxxxxxxxxxxxxxxxxxxxxxxx11111x          ; second page number 'p2345' in .acr
61  1111xxxxxxxxxxxxxxxxxxxxxxxxxxxx          ; length = number of digits between commas
62  11111 111111xxxxxxxxxxxxxxxxxxxx          ; length = number of digits in microwords

101 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 00100 xxxxxxxxxxx ; ret
102 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 01000 xxxxxxxxxxx ; decnext
103 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 01010 xxxxxxxxxxx ; dl.bwl.at.rvm_decnext
104 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 01011 xxxxxxxxxxx ; at.rvm_decnext
105 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 01100 xxxxxxxxxxx ; dl.bwl.at.r_decnext
106 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 01101 xxxxxxxxxxx ; at.r_decnext
107 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 01110 xxxxxxxxxxx ; at.av_decnext
108 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 01111 xxxxxxxxxxx ; dl.bwl_decnext

109 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 10000 xxxxxxxxxxx ; alu.nzv case
109 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 10001 xxxxxxxxxxx ; alu.nzc case
109 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 10010 xxxxxxxxxxx ; sc<2:0> case
109 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 10011 xxxxxxxxxxx ; sc<5:3> case
109 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 10101 xxxxxxxxxxx ; psl<26:24> case
109 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 10110 xxxxxxxxxxx ; state<2:0> case
109 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 10111 xxxxxxxxxxx ; state<5:3> case

109 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 11000 xxxxxxxxxxx ; mem mgt1 status case
109 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 11001 xxxxxxxxxxx ; mem mgt2 status case
109 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 11010 xxxxxxxxxxx ; mem mgt3 status case
109 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 11011 xxxxxxxxxxx ; fpa'dl case
109 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 11100 xxxxxxxxxxx ; I box status case
109 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 11101 xxxxxxxxxxx ; Opcode<2:0> case
109 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 11110 xxxxxxxxxxx ; Load ID<2:0> case

110 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 0 0 xxxx xxxxxxxxxxx ; jump
111 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 0 1 xxxx xxxxxxxxxxx ; call
