; 16-jun-83	rms	removed ret if av, bwl codes
; 18-feb-83	rms	swizzled branch/misc codes
; 17-feb-83	rms	added iid no exc
; 13-dec-82	rms	added becsr case
; 4-nov-82	rms	added if bwl known
; 19-may-82 	rls	added uncond pc,viba load
  1 x xxxxxxxxxxxxxxxxxxxxxxxxx         x xxxxxx xxxxxxxxxxxxxxx 1 xxxxxxxxxxxxxxx ; reverse bit field
  2 x xxxxxxxxxxxxxxxxxxxxxxxxx         x xxxxxx 111111111111111 x xxxxxxxxxxxxxxx ; true label field
  3 x xxxxxxxxxxxxxxxxxxxxxxxxx         x xxxxxx xxxxxxxxxxxxxxx x 111111111111111 ; false label field


110 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 111110 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; jsr fbox ignore true label
110 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 111101 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; return ignore true label
110 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 111100 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; return mrok ignore true label
110 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 101011 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; IID NO EXC ignore true label
110 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 101110 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; IID ignore true label
110 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 101100 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; NSD ignore true label

111 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 011110 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; br always ignore false label
111 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 101111 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; load pc/viba ignore false label
111 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 111101 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; return ignore false label
111 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 110xxx xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; case br ignore false label
111 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 11100x xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; case br ignore false label

111 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 101011 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; IID NO EXC ignore FALSE label
111 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 101110 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; IID ignore FALSE label
111 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 101010 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; IID group ignore false label
111 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 100010 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; IID group ignore false label
111 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 100110 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; IID group ignore false label
111 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 101100 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; NSD ignore false label
111 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 101101 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; NSD if AV ignore false label
111 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 100011 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; NSD if BWLQ ignore false label
111 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 100101 xxxxxxxxxxxxxxx x 111111111111111 ; NSD if BWL known ignore false label
111 0 xxxxxxxxxxxxxxxxxxxxxxxxx         11 xxxxx xxxxxxxxxxxxxxx x 111111111111111 ; call.no.ret 

112 0 10 xxx xx xxx xx x xxxxxxxx xxxx  x xxxxxx xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; constant no MISC field
112 0 1111011       xxxxxxxxxxxxxxxxxx  x xxxxxx xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; fbox special no MISC field
112 0 111110    xxxxx xxxxx xxxxx xxxx  x xxxxxx xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; special no MISC field


101 0 xxxxxxxxxxxxxxxxxxxxxxxxx         x xxxxxx xxxxxxxxxxxxxxx 1 xxxxxxxxxxxxxxx ; reverse true/false

105 0 111111 11111xxxxxxxxxxxxxx         x xxxxxx xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; HALT exists. EXIT

102 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 xxxxxx xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; br R . T -63..+64 [~110]
103 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 xxxxxx xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; br R . F +1..+1   [~111]
117 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 110xxx xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; case br A . F
117 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 11100x xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; case br A . F
105 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 111101 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; return exists. EXIT
105 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 101011 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; IID exists. EXIT
105 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 101110 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; IID exists. EXIT
105 0 xxxxxxxxxxxxxxxxxxxxxxxxx         0 101100 xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; NSD exists. EXIT

103 0 xxxxxxxxxxxxxxxxxxxxxxxxx         11 xxxxx xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; call R . F +1..+1 [~111]
106 0 xxxxxxxxxxxxxxxx      11111 xxxx  1x xxxxx xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; jump page 7 R 0 T 28K..32K [~112]. EXIT
105 0 111110    xxxxx xxxxx 11xxx xxxx  1x xxxxx xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; broad jump/call exists. EXIT
104 0 xxxxxxxxxxxxxxxxxxxxxxxxx         1x xxxxx xxxxxxxxxxxxxxx x xxxxxxxxxxxxxxx ; jump/call B . T 4K 

105 1 0 xxxxxxx xxxx xxxxx xxx xxx xxxx    xxxxx xxxxxxxxxxxxxxx 1 xxxxxxxxxxxxxxx ; F-ROM exists. EXIT
105 1 0 xxxxxxx xxxx xxxxx xxx xxx 1111    xxxxx xxxxxxxxxxxxxxx 0 xxxxxxxxxxxxxxx ; ERET exists. EXIT
105 1 0 0011110 xxxx xxxxx xxx xxx xxxx    xxxxx xxxxxxxxxxxxxxx 0 xxxxxxxxxxxxxxx ; F-fetch broad jump exists. EXIT
104 1 0 xxxxxxx xxxx xxxxx xxx xxx xxxx    xxxxx xxxxxxxxxxxxxxx 0 xxxxxxxxxxxxxxx ; F-fetch. Block 4K
