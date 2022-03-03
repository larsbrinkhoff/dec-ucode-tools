; 16-jun-83	rms	removed ret if av, bwl codes
; 18-feb-83	rms	swizzled bcs/misc codes
; 17-feb-83 	rms 	added iid no exc
; 13-dec-82 	rms 	added new becsr case
; 4-nov-82 	rms 	added if bwl known
; 19-may-82 	rls 	added new uncond load pc/viba
; 16-apr-82 	rls	new bcs field
; 14-apr-82 	rls	updated for final alloc3
;   4 3210987654321098765432109         8 765432 109876543210987 6 543210987654321
;   9 8765432109876543210987654         3 210987 6543210
  1 x xxxxxxxxxxxxxxxxxxxxxxxxx         x xxxxxx xxxxxxxxxxxxxxx 1 xxxxxxxxxxxxxxx ; reverse bit field
  2 x xxxxxxxxxxxxxxxxxxxxxxxxx         x xxxxxx 111111111111111 x xxxxxxxxxxxxxxx ; true label field
  3 x xxxxxxxxxxxxxxxxxxxxxxxxx         x xxxxxx xxxxxxxxxxxxxxx x 111111111111111 ; false label field
  4 x xxxxxxxxxxxxxxxxxxxxxxxxx         x x11111 1111111xxxxxxxx x xxxxxxxxxxxxxxx ; real jump field
  5 x 1111111111111111111111111         1 1xxxxx xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; real alu and jump control

  6 x xxxxxxxxxxxxxxxxxxxxxxxxx         x xxxxxx 111111111111111 1 111111111111111 ; fake branch fields 
  7 x xxxxxxxxxxxxxxxxxxxxxxxxx         x x11111 111111111111111 1 111111111111111 ; fake jump fields
  8 x xxxxxxxxxxxxxxxxxxxxxxxxx         x 111111 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; fake BCS field
 10 1 xxxxxxxxxxxxxxxxxxxxxxxxx         x xxxxxx xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; fake parity field
 15 x 1111111111111111111111111         1 1xxxxx xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; fake alu and jump control

 14 x xxxxxx xxxxx xxxxx xx111 xxxx     x xxxxxx xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; broad jump page field

 16 x xxxxxxxxxxxxxxxxxxxxxxxxx         x xxxxxx 1111111xxxxxxxx x xxxxxxxxxxxxxxx ; real branch offset field
 17 x xxxxxxxxxxxxxxxxxxxxxxxxx         x xxxxxx xxxxxxx11111111 1 111111111111111 ; extra bits not real fields
 18 x xxxxxxxxxxxxxxxxxxxxxxxxx         x 111111 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; real BCS field
 19 x 1111111111111111111111111         1 111111 1111111xxxxxxxx x xxxxxxxxxxxxxxx ; field over which to check parity
 20 1 xxxxxxxxxxxxxxxxxxxxxxxxx         x xxxxxx xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; real parity field
 
; * NEW FIELD PATTERNS FOR PROCESSING .MCR, .ADR, AND .ACR FILes
50  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx111111111111111111111111111111x ; .ACR date and time
51  xx111111111111111111xxxxxxx               ; location of date and time in .ADR file 
52  1x                                        ; memory in .mcr 
53  1x                                        ; memory in .acr
54  xx1111111111111111111111111111xx          ; uAddress and 64 bit uWord in .mcr file
55  xx1111xxxxxxxxxxxxxxxxxxxxxxxxxx          ; uAddress in .acr file
56  xxxxxxxx111111111111xxxxxxxxxxxx          ; uWord in .acr file
57  xxxxxxxxxxxxxxxxxxxxxx1111xxxxxx          ; first hex address printing field in .acr
58  xxxxxxxxxxxxxxxxxxxxxxxxxxx1111x          ; second hex address printing field in .acr
59  xxxxxxxxxxxxxxxxxxxxx11111xxxxxx          ; first page number  'p1234' in .acr
60  xxxxxxxxxxxxxxxxxxxxxxxxxx11111x          ; second page number 'p2345' in .acr
61  1111xxxxxxxxxxxxxxxxxxxxxxxxxxxx          ; length = number of digits between commas
62  11111 11111xxxxxxxxxxxxxxxxxxxxx          ; length = number of digits in microwords

; ACTIONS
110 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 101011 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; IID NO EXC ignore true label
110 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 101110 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; IID ignore true label
110 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 101100 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; NSD ignore true label
110 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 111111 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; nop ignore true label

111 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 011110 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; br always ignore false label
111 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 101111 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; load pc/viba ignore false label
111 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 111101 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; return ignore false label
111 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 110xxx xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; case br ignore false label
111 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 11100x xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; case br ignore false label
111 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 100101 xxxxxxxxxxxxxxx x 111111111111111 ; NSD if BWL known ignore false label
111 0 xxxxxxxxxxxxxxxxxxxxxxxxx         10 xxxxx xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; jump ignore false field
111 0 xxxxxxxxxxxxxxxxxxxxxxxxx         11 xxxxx xxxxxxxxxxxxxxx x 111111111111111 ; call.no.ret ignore false field
111 1 0 xxxxxxx xxxx xxxxx xxx xxx xxxx    xxxxx xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; float instr ignore false field

112 0 10 xxx xx xxx xx x xxxxxxxx xxxx  x xxxxxx xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; constant no MISC field
112 0 1111011       xxxxxxxxxxxxxxxxxx  x xxxxxx xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; fbox special no MISC field
112 0 111110    xxxxx xxxxx xxxxx xxxx  x xxxxxx xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; special no MISC field
112 1 0 xxxxxxx xxxx xxxxx xxx xxx xxxx    xxxxx xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; float instr ignore MISC field


101 0 xxxxxxxxxxxxxxxxxxxxxxxxx         x xxxxxx xxxxxxxxxxxxxxx 1 xxxxxxxxxxxxxxx ; reverse true/false

113 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 111101 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; return EXIT
113 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 111100 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; return mem ref EXIT
114 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 100010 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; IID group EXIT
114 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 100110 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; IID group EXIT
114 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 101011 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; IID NO EXC EXIT
114 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 101110 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; IID EXIT
115 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 101010 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; bcond,IID group EXIT
116 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 100011 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; NSD group EXIT
116 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 101101 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; NSD group EXIT
116 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 101100 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; NSD EXIT
118 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 111110 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; jsr.fbox EXIT
102 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 xxxxxx xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; other branches [~110] [~111]

103 0 111110    xxxxx xxxxx 11xxx xxxx  1x xxxxx xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; broad jump/call [~111] EXIT
104 0 xxxxxxxxxxxxxxxx      11111 xxxx  1x xxxxx xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; jump page 7 [~112]. EXIT
105 0 xxxxxxxxxxxxxxxxxxxxxxxxx         1x xxxxx xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; call/jump [~111] 

106 1 0 xxxxxxx xxxx xxxxx xxx xxx 1111    xxxxx xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; ERET EXIT
107 1 0 xxxxxxx xxxx xxxxx xxx xxx xxxx    xxxxx xxxxxxxxxxxxxxx 1 xxxxxxxxxxxxxxx ; F-ROM jump page 0 EXIT
103 1 0 0011110 xxxx xxxxx xxx xxx xxxx    xxxxx xxxxxxxxxxxxxxx 0 xxxxxxxxxxxxxxx ; F-fetch broad jump exists. [~111] EXIT
102 1 0 xxxxxxx xxxx xxxxx xxx xxx xxxx    xxxxx xxxxxxxxxxxxxxx 0 xxxxxxxxxxxxxxx ; F-fetch jump
