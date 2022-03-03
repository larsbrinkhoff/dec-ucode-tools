; 2-Aug-85   PIR  MIB<12> is flipped
; 24-Apr-85  PIR  Update to match new I-box
; 28-Nov-84  RLS  First try for CVAX
  3 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx x xxxxx 11111111111 ; label field

101 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 01010 xxxxxxxxxxx ; dl.bwl.at.rvm_decnext		unused		same page
101 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 01011 xxxxxxxxxxx ; at.rvm_decnext			unused		same page
101 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 01100 xxxxxxxxxxx ; dl.bwl.at.r_decnext		unused		same page
101 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 01101 xxxxxxxxxxx ; at.r_decnext			unused		same page
101 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 01110 xxxxxxxxxxx ; at.av.decnext			unused		same page
101 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 01111 xxxxxxxxxxx ; dl.bwl_decnext			unused		same page

101 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 10000 xxxxxxxxxxx ; alu.nzv case			unused		same page
101 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 10001 xxxxxxxxxxx ; alu.nzc case			unused		same page
101 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 10010 xxxxxxxxxxx ; sc<2:0> case			unused		same page
101 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 10011 xxxxxxxxxxx ; sc<5:3> case			unused		same page
101 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 10101 xxxxxxxxxxx ; psl<26:24> case			unused		same page
101 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 10110 xxxxxxxxxxx ; state<2:0> case			unused		same page
101 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 10111 xxxxxxxxxxx ; state<5:3> case			unused		same page

101 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 11000 xxxxxxxxxxx ; mem mgt1 status case		unused		same page
101 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 11001 xxxxxxxxxxx ; mem mgt2 status case		unused		same page
101 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 11010 xxxxxxxxxxx ; mem mgt3 status case		unused		same page
101 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 11011 xxxxxxxxxxx ; fpa'dl case			unused		same page
101 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 11100 xxxxxxxxxxx ; I box status case			unused		same page
101 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 11101 xxxxxxxxxxx ; Opcode<2:0> case			unused		same page
101 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 1 11110 xxxxxxxxxxx ; ID load<2:0> case			unused		same page

102 xxx xxx xxxxxxxxxxxxxx xxxxx xxxxxx 0 1 xxxx xxxxxxxxxxx ; call				anywhere	ret=uPC+1
