PROGRAM calloc4(INPUT,OUTPUT,u41_file,stat_file,dump_file);

{
			COPYRIGHT (c) 1985, 1986 BY
	      DIGITAL EQUIPMENT CORPORATION, MAYNARD, MASS.

 THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY BE USED AND  COPIED
 ONLY  IN  ACCORDANCE  WITH  THE  TERMS  OF  SUCH  LICENSE AND WITH THE
 INCLUSION OF THE ABOVE COPYRIGHT NOTICE.  THIS SOFTWARE OR  ANY  OTHER
 COPIES  THEREOF MAY NOT BE PROVIDED OR OTHERWISE MADE AVAILABLE TO ANY
 OTHER PERSON.  NO TITLE TO AND OWNERSHIP OF  THE  SOFTWARE  IS  HEREBY
 TRANSFERRED.

 THE INFORMATION IN THIS SOFTWARE IS SUBJECT TO CHANGE  WITHOUT  NOTICE
 AND  SHOULD  NOT  BE  CONSTRUED  AS  A COMMITMENT BY DIGITAL EQUIPMENT
 CORPORATION.

 DIGITAL ASSUMES NO RESPONSIBILITY FOR THE USE OR  RELIABILITY  OF  ITS
 SOFTWARE ON EQUIPMENT WHICH IS NOT SUPPLIED BY DIGITAL.

 AUTHOR:
   Paul Rubinfeld

 CREATION DATE: 
   20-Jun-85 1.00

 MODIFIED BY:
   	     V1.01 PIR updated microcode format
             V1.02 PIR updated microcode format; added word line loading
   10-Oct-85 V1.03 PIR updated microcode format
   11-Feb-86 V1.04 PIR Control store reorganization reflected
    1-Apr-86 V1.05 PIR .BDR file name parsing fixed
   28-May-86 V1.06 PIR Final ucode field assignments reflected; CS addressing gap implemented
   12-Jun-86 V1.07 PIR .MIN and .CALMA programming files generated

 LINKING INSTRUCTIONS:
  Use this command to link this program:
	$ LINK CALLOC4


 This program generates
	1. statistics about a U41 microcode file
	2. bit line loading
	3. word line loading
	4. a Control Store programming map
	5. a shareable microcode list
}

	
CONST
	max_adr = 2047;
	max_word_line = 200;
VAR
	day_stamp, time_stamp : PACKED ARRAY[1..11] OF CHAR;
	cs_map : array[0..327,0..max_word_line-1] OF CHAR;
	grp_order : ARRAY[0..7,0..max_word_line-1] OF UNSIGNED;
	bit_order : ARRAY[1..41] OF UNSIGNED := (0, 1, 18, 16, 15, 14, 13, 17, 2, 3, 
						 4, 5,   6,  7,  8,  9, 10, 11, 12, 19, 
					 	20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 
						30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 
						40);

	ucode_data, ucode_seq : ARRAY[0..max_adr] OF UNSIGNED;
	mcr_pt, adr_pt : ARRAY[0..max_adr] OF INTEGER;
	have_delta : ARRAY[0..max_adr] OF BOOLEAN;
	con_file_name, bdr_file_name, u41_file_name, stat_file_name : VARYING[132] OF CHAR;
	search_for_share, debug, command_line_fail : BOOLEAN;
	dump_file,con_file, bdr_file, u41_file, stat_file : TEXT;
	line_number, page_number : ARRAY[0..max_adr] OF INTEGER;
	last_adr : INTEGER;


FUNCTION xtor( bit, adr : UNSIGNED) : BOOLEAN;
VAR
	msk : UNSIGNED;
BEGIN {xtor}
	IF (bit < 0) OR (bit > 40) THEN 
	   writeln('DRY ROT (XTOR) - bad bit value ',bit);
	IF (adr < 0) OR (adr > max_adr) THEN
	   writeln('DRY ROT (xtor) - ADR out of range ',adr,'(',HEX(adr,6),')');
	IF bit < 13 THEN
	   BEGIN {useq bit}
		msk := 2**bit;
		IF UAND(msk, ucode_seq[adr::INTEGER]) = 0 THEN
		   xtor := FALSE
		 ELSE 
		   xtor := TRUE;
	   END {useq bit}
	ELSE
	   BEGIN {data bit}
		msk := 2**(bit-13);
		IF UAND(msk, ucode_data[adr::INTEGER]) = 0 THEN
		   xtor := FALSE
		 ELSE 
		   xtor := TRUE;
	   END; {data bit}
END; {xtor}

PROCEDURE dump_min_file (ms_word_line, ls_bit_line, bit_count : INTEGER);
VAR
	dump_file_name : VARYING[132] OF CHAR;
	bit_line, word_line, word_width, bit_width : INTEGER;
BEGIN
	IF ms_word_line < 10 THEN word_width := 1
	 ELSE IF ms_word_line < 100 THEN word_width := 2
	  ELSE word_width := 3;

	IF ls_bit_line < 10 THEN bit_width := 1
	 ELSE IF ls_bit_line < 100 THEN bit_width := 2
	  ELSE bit_width := 3;

	WRITEV(dump_file_name,'CS_',ms_word_line:word_width,'_',ls_bit_line:bit_width,'.MIN');
{writeln('dumping MIN file ',dump_file_name);}

	OPEN( 	FILE_VARIABLE := dump_file,
		FILE_NAME := dump_file_name,
		HISTORY := NEW);
	REWRITE(dump_file);
	WRITELN(dump_file,'  CVAX CONTROL STORE FILE: ',dump_file_name,'   ',day_stamp,'   ',time_stamp,'   CALLOC4 1.07');
	WRITELN(dump_file,'.i 50');
	WRITELN(dump_file,'.o 1');
	WRITELN(dump_file,'.p ',bit_count:2);

	FOR bit_line := ls_bit_line TO ls_bit_line + bit_count - 1 DO
	   BEGIN
		WRITE(dump_file,'.d ');
		FOR word_line := ms_word_line DOWNTO ms_word_line - 49 DO
		   IF cs_map[bit_line,word_line] = '0' THEN WRITE(dump_file,' 0')
		    ELSE WRITE(dump_file,' 1');
		WRITELN(dump_file,'    0');
	   END;
	WRITELN(dump_file,'.e');
	CLOSE(dump_file);
END;

PROCEDURE dump_calma_file (ms_word_line, ls_bit_line, bit_count : INTEGER);
VAR
	dump_file_name : VARYING[132] OF CHAR;
	bit_line, word_line, word_width, bit_width : INTEGER;
BEGIN
	IF ms_word_line < 10 THEN word_width := 1
	 ELSE IF ms_word_line < 100 THEN word_width := 2
	  ELSE word_width := 3;

	IF ls_bit_line < 10 THEN bit_width := 1
	 ELSE IF ls_bit_line < 100 THEN bit_width := 2
	  ELSE bit_width := 3;

	WRITEV(dump_file_name,'CS_',ms_word_line:word_width,'_',ls_bit_line:bit_width,'.CALMA');
{writeln('dumping MIN file ',dump_file_name);}

	OPEN( 	FILE_VARIABLE := dump_file,
		FILE_NAME := dump_file_name,
		HISTORY := NEW);
	REWRITE(dump_file);
	FOR bit_line := ls_bit_line TO ls_bit_line + bit_count - 1 DO
	   BEGIN
		FOR word_line := ms_word_line DOWNTO ms_word_line - 49 DO
		   IF cs_map[bit_line,word_line] = '0' THEN WRITE(dump_file,'2')
		    ELSE WRITE(dump_file,'1');
		WRITELN(dump_file);
	   END;
	CLOSE(dump_file);
END;

PROCEDURE gen_cs_map;
VAR
	sum, row, dum, col_sel, word_sel : INTEGER;
	bit_num, adr : UNSIGNED;
	word_line_loading : ARRAY[0..max_word_line-1] OF INTEGER;
	word_line_loading_sum, word_line_loading_ave : REAL;
	word_line_loading_min, word_line_loading_max : INTEGER;
	bit_line_loading : ARRAY[0..327] OF INTEGER;
	bit_line_loading_sum, bit_line_loading_ave : REAL;
	bit_line_loading_min, bit_line_loading_max : INTEGER;

BEGIN {gen_cs_map}

	writeln;
	writeln('   ***Generating Control Store Map ');

{ initialize grp_order }

	adr := 0;
	word_sel := 0;
	FOR dum := 0 TO 99 DO
	   BEGIN
		FOR col_sel := 0 TO 7 DO
		   BEGIN
			grp_order[col_sel, word_sel] := adr;
			grp_order[col_sel, word_sel+1] := adr+1;
			adr := adr + 2;
		   END;


		{ skip address 620 thru 7DF }
		IF adr = %x'620' THEN adr := %x'7E0';
		word_sel := word_sel + 2;

	   END;
	IF adr <> %x'800' THEN writeln('DRY ROT (GEN_CS_MAP) - grp_order generation error: end address is ',HEX(adr,8));

{ fill in cs map}

	row := 0;
	FOR dum := 1 TO 41 DO
	   BEGIN {each bit}
		bit_num := bit_order[dum];
		FOR col_sel := 0 TO 7 DO
		   BEGIN {each row within bit}
			FOR word_sel := 0 TO max_word_line-1  DO 
			   IF xtor(bit_num,grp_order[col_sel, word_sel]) THEN cs_map[row,word_sel] := '1'
			   ELSE cs_map[row,word_sel] := '0';
			row := row + 1;
		   END {each row within bit};
	   END {each bit};

{ word line loading }

	word_line_loading_min := 328;
	word_line_loading_max := 0;
	word_line_loading_ave := 0.0;

	FOR word_sel := 0 TO max_word_line-1 DO
	   BEGIN
		word_line_loading[word_sel] := 0;
		word_line_loading_sum := 0.0;
		FOR row := 0 TO 327 DO IF cs_map[row,word_sel]='1' THEN 
		   BEGIN
			word_line_loading[word_sel] := word_line_loading[word_sel] + 1;
			word_line_loading_sum := word_line_loading_sum + 1.0;
		   END;

		word_line_loading_ave := word_line_loading_ave + word_line_loading_sum;

		IF word_line_loading[word_sel] > word_line_loading_max THEN
		   word_line_loading_max := word_line_loading[word_sel]
		ELSE IF word_line_loading[word_sel] < word_line_loading_min THEN
		   word_line_loading_min := word_line_loading[word_sel];

	   END; 

	word_line_loading_ave := word_line_loading_ave / 200.0;

{ bit line loading }

	bit_line_loading_min := 200;
	bit_line_loading_max := 0;
	bit_line_loading_ave := 0.0;

	FOR row := 0 TO 327 DO
	   BEGIN
		bit_line_loading[row] := 0;
		bit_line_loading_sum := 0.0;
		FOR word_sel := 0 TO max_word_line-1 DO IF cs_map[row,word_sel]='1' THEN 
		   BEGIN
			bit_line_loading[row] := bit_line_loading[row] + 1;
			bit_line_loading_sum := bit_line_loading_sum + 1.0;
		   END;

		bit_line_loading_ave := bit_line_loading_ave + bit_line_loading_sum;

		IF bit_line_loading[row] > bit_line_loading_max THEN
		   bit_line_loading_max := bit_line_loading[row]
		ELSE IF bit_line_loading[row] < bit_line_loading_min THEN
		   bit_line_loading_min := bit_line_loading[row];

	   END; 

	bit_line_loading_ave := bit_line_loading_ave / 328.0;

	PAGE(stat_file);
	writeln(stat_file,'CS Programming Map');
	writeln(stat_file);
writeln(stat_file,'                                   UPPER WORD LINES');
writeln(stat_file,'1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111');
writeln(stat_file,'9999999998888888888777777777766666666665555555555444444444433333333332222222222111111111100000000000');
writeln(stat_file,'9876453210987654321098765432109876543210987654321098765432109876543210987654321098765432109876543210');
	FOR row := 0 TO 327 DO
	   BEGIN
		WRITELN(stat_file);
		FOR word_sel := max_word_line-1 DOWNTO 100 DO 
		   BEGIN
			WRITE(stat_file,cs_map[row, word_sel]);
		   END;
	   END;
	PAGE(stat_file);
	writeln(stat_file,'CS Programming Map');
	writeln(stat_file);
writeln(stat_file,'                                   LOWER WORD LINES');
writeln(stat_file,'0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000');
writeln(stat_file,'9999999998888888888777777777766666666665555555555444444444433333333332222222222111111111100000000000');
writeln(stat_file,'9876453210987654321098765432109876543210987654321098765432109876543210987654321098765432109876543210');

	FOR row := 0 TO 327 DO
	   BEGIN
		WRITELN(stat_file);
		FOR word_sel := 99 DOWNTO 0 DO 
		   BEGIN
			WRITE(stat_file,cs_map[row, word_sel]);
		   END;
	   END;

	PAGE(stat_file);
	writeln(stat_file,'Loading Table');
	writeln(stat_file);
	writeln(stat_file,'Bit or    Bit       Word');	
	writeln(stat_file,'Word     Line       Line');	
	writeln(stat_file,'Line    Loading    loading');	
	writeln(stat_file,'----    -------    -------');	
	For dum := 0 to 327 DO

	IF dum > max_word_line-1 THEN
	 WRITELN(stat_file,dum:3,'       ',bit_line_loading[dum]:3,'        --')
	ELSE
	 WRITELN(stat_file,dum:3,'       ',bit_line_loading[dum]:3,'        ',word_line_loading[dum]:3);

	writeln(stat_file,'        -------    -------');	
	writeln(stat_file,'Min     ',bit_line_loading_min:3,'       ',word_line_loading_min:3);
	writeln(stat_file,'Max     ',bit_line_loading_max:3,'       ',word_line_loading_max:3);	
	writeln(stat_file,'Ave     ',bit_line_loading_ave:5:2,'     ',word_line_loading_ave:5:2);	


	dump_min_file(199,0,24);
	dump_min_file(149,0,24);
	dump_min_file(99,0,24);
	dump_min_file(49,0,24);
		
	dump_min_file(199,24,48);
	dump_min_file(149,24,48);
	dump_min_file(99,24,48);
	dump_min_file(49,24,48);

	dump_min_file(199,72,48);
	dump_min_file(149,72,48);
	dump_min_file(99,72,48);
	dump_min_file(49,72,48);

	dump_min_file(199,120,48);
	dump_min_file(149,120,48);
	dump_min_file(99,120,48);
	dump_min_file(49,120,48);

	dump_min_file(199,168,48);
	dump_min_file(149,168,48);
	dump_min_file(99,168,48);
	dump_min_file(49,168,48);

	dump_min_file(199,216,48);
	dump_min_file(149,216,48);
	dump_min_file(99,216,48);
	dump_min_file(49,216,48);

	dump_min_file(199,264,48);
	dump_min_file(149,264,48);
	dump_min_file(99,264,48);
	dump_min_file(49,264,48);

	dump_min_file(199,312,16);
	dump_min_file(149,312,16);
	dump_min_file(99,312,16);
	dump_min_file(49,312,16);

	dump_calma_file(199,0,24);
	dump_calma_file(149,0,24);
	dump_calma_file(99,0,24);
	dump_calma_file(49,0,24);
		
	dump_calma_file(199,24,48);
	dump_calma_file(149,24,48);
	dump_calma_file(99,24,48);
	dump_calma_file(49,24,48);

	dump_calma_file(199,72,48);
	dump_calma_file(149,72,48);
	dump_calma_file(99,72,48);
	dump_calma_file(49,72,48);

	dump_calma_file(199,120,48);
	dump_calma_file(149,120,48);
	dump_calma_file(99,120,48);
	dump_calma_file(49,120,48);

	dump_calma_file(199,168,48);
	dump_calma_file(149,168,48);
	dump_calma_file(99,168,48);
	dump_calma_file(49,168,48);

	dump_calma_file(199,216,48);
	dump_calma_file(149,216,48);
	dump_calma_file(99,216,48);
	dump_calma_file(49,216,48);

	dump_calma_file(199,264,48);
	dump_calma_file(149,264,48);
	dump_calma_file(99,264,48);
	dump_calma_file(49,264,48);

	dump_calma_file(199,312,16);
	dump_calma_file(149,312,16);
	dump_calma_file(99,312,16);
	dump_calma_file(49,312,16);
		
END; {gen_cs_map}

PROCEDURE gen_xref;
 VAR
	xref : ARRAY[0..max_adr,0..max_adr] OF BOOLEAN;
	found_share, first : BOOLEAN;
	count, base, target : INTEGER;
	target_block, base_block, bcs : UNSIGNED;

BEGIN {gen_xref}

	writeln;
	writeln('   ***Searching for shareable code');


	found_share := FALSE;
	FOR base := 0 TO 2047 DO
	  FOR target := 0 TO 2047 DO  xref[base,target] := FALSE;

	FOR base := 0 TO last_adr-1 DO
		FOR target := base+1 TO last_adr DO
			IF (NOT have_delta[base]) AND (NOT have_delta[target]) AND
			   (ucode_data[base] = ucode_data[target]) AND
			   (mcr_pt[base] >= 0) AND (mcr_pt[target] >= 0) AND
			   (ucode_seq[base] = ucode_seq[target]) THEN
			   BEGIN {possible hit}

{ case 1: sequencing fields are unconditional jump }

				IF UAND(ucode_seq[base],%x'1800') = %x'0000' THEN xref[base,target] := TRUE
				 ELSE 
				   BEGIN {case 2 and 3}
					bcs := UAND(ucode_seq[base] DIV %x'080',%x'1F');

{ case 2: sequencing fields are unconditional I Box dispatch }

					IF bcs=8 THEN xref[base,target] := TRUE

{ case 3: sequencing fields are cases or conditional I box dispatch; offset is equal; and both 
	instructions are in the same block }

					 ELSE 
					   BEGIN {case 3}
						base_block := base DIV %x'080';
						target_block := target DIV %x'080';
						IF base_block = target_block THEN
							IF (bcs > 9) THEN xref[base,target] := TRUE
					   END {case 3}
				   END {case 2 and 3}
			   END; {possible hit}

	page(stat_file);
	writeln(stat_file);
	WRITELN(stat_file,
	'    Microinstruction    |                  Shareable code');
	WRITELN(stat_file,
	'  Adr        Line/Page  |   Adr        Line/Page       Adr        Line/Page       Adr        Line/Page');
	WRITELN(stat_file,
	'  ---       ---- -----  |   ---        ---------       ---       ----------       ---       ----------');

	FOR base:=0 TO 2047 DO
	   BEGIN {each base}
		first := true;
		count := 0;

		FOR target := 0 TO 2047 DO
		 IF xref[base,target] THEN
		   BEGIN {each target}
			IF first THEN
			  BEGIN
				found_share := TRUE;
				first := false;
				count := 1;
				WRITEln(stat_file,'                        |');
				WRITE(stat_file,base:4,'(',hex(base,3),')   ',line_number[base]:6,'/',page_number[base]:4,
				' |  ',target:4,'(',hex(target,3),')   ',line_number[target]:6,'/',page_number[target]:4,
				'    ');
			   END
			ELSE
			   BEGIN
				found_share := TRUE;
				IF count = 0 THEN 
				   BEGIN
					WRITELN(stat_file);
					WRITE(stat_file,'                        |  ');
				   END;
				WRITE(stat_file,target:4,'(',hex(target,3),')   ',line_number[target]:6,'/',
				page_number[target]:4,'    ');
				count:=count + 1;
				IF count > 2 THEN count := 0;
			   END
		   END; {each target}
		IF NOT first THEN WRITELN(stat_file);
	   END; {each base}
	IF NOT found_share THEN 
	   BEGIN
		WRITELN(stat_file);
		writeln(stat_file,'		NO SHAREABLE CODE FOUND');
		writeln(stat_file,'		NO SHAREABLE CODE FOUND');
		writeln(stat_file,'		NO SHAREABLE CODE FOUND');
	   END;
END; {gen_xref}


PROCEDURE prologue(VAR fail:BOOLEAN);
 VAR
	com_line_pt, dum, ziltch, switch_length, ext_length, dot_loc, slash_loc, file_end, com_status, com_line_length : INTEGER;
	left_loc, right_loc : INTEGER;
	directory, switch, root, com_line, switches : VARYING[132] OF CHAR;
	have_dot, have_slash : BOOLEAN;

{	[EXTERNAL] FUNCTION LIB$GET_FOREIGN
			(VAR INPUT_TEXT : VARYING[U] OF CHAR ;
				PROMPT : VARYING[V] OF CHAR := %IMMED 0;
			OUT_LEN : INTEGER := %IMMED 0 ) : INTEGER ;
		   EXTERN;
}
BEGIN  {prologue}
	WRITE('Filename[/switches]>');
	READLN(com_line);
	com_line_length := length(com_line);
	FOR dum:=1 to com_line_length DO 
	 IF (com_line[dum] >= 'a') AND (com_line[dum] <= 'z') THEN com_line[dum] := CHR( ORD(com_line[dum]) - 32 );
	fail := FALSE;
	left_loc := index(com_line,'[');
	right_loc := index(com_line,']');
	IF (left_loc <> 0) OR (right_loc <> 0) THEN
	   BEGIN {directory found}
		IF (right_loc = com_line_length) OR (right_loc = 0) OR (left_loc = 0) OR (right_loc < left_loc) THEN
		   BEGIN
			WRITELN(com_line);
			FOR dum := 1 TO right_loc-1 DO write(' ');
			WRITELN('^');
			WRITELN(' Directory syntax error ');
			fail := TRUE;
		   END
		 ELSE
		   BEGIN
			directory := substr(com_line,1,right_loc);
			com_line := substr(com_line,right_loc+1,com_line_length-right_loc);
			com_line_length := length(com_line);
		   END
	   END {directory found}
	 ELSE directory := '';
		
	slash_loc := index(com_line,'/');
	IF slash_loc = 0 THEN 
	   BEGIN
		slash_loc := com_line_length + 1;
		file_end := com_line_length;
		have_slash := FALSE;
	   END
	 ELSE 
	   BEGIN
		file_end := slash_loc-1;
		have_slash := TRUE
	   END;
		dot_loc := index(com_line,'.');
	IF dot_loc = 0 THEN 
	   BEGIN
		dot_loc := file_end + 1;
		have_dot := FALSE
	   END
	 ELSE have_dot := TRUE;
		IF dot_loc > slash_loc THEN
	   BEGIN
		fail := TRUE;
		WRITELN(com_line);
		FOR dum := 1 TO slash_loc-1 DO write(' ');
		WRITELN('^');
		WRITELN(' Option syntax error ')
	   END
	 ELSE
	   BEGIN {good ./}
		root := substr(com_line,1,dot_loc-1);
		IF NOT have_dot THEN u41_file_name := directory + root + '.U41' 
		 ELSE 
		   BEGIN
			ext_length := slash_loc - dot_loc;
			u41_file_name := directory + root + substr(com_line,dot_loc,ext_length);
		   END;
		stat_file_name := root + '.DAT';
		bdr_file_name := directory + root + '.BDR';
		con_file_name := directory + root + '.CON';
	   END; {good ./}

	IF have_slash THEN
	   BEGIN {have switch}
		com_line_pt := slash_loc;
		switch_length := com_line_length - slash_loc;
		IF switch_length = 0 THEN
		   BEGIN
			WRITELN(com_line);
			FOR dum := 1 TO com_line_pt DO write(' ');
			WRITELN('^');
			WRITELN(' Option ignored')
		   END
		 ELSE 
		   BEGIN {switch parse setup}
			switches := substr(com_line,slash_loc+1,switch_length);
			REPEAT
			   BEGIN {parse switches}
				switch_length := length(switches);
				slash_loc := index(switches,'/');
				IF (slash_loc = 0) OR (slash_loc = switch_length) THEN
				   BEGIN
					slash_loc := switch_length + 1;
					have_slash := FALSE
				   END;
				   
				switch := substr(switches,1,slash_loc-1);

				IF index('DEBUG',switch) = 1 THEN debug := TRUE
				 ELSE IF index('NODEBUG',switch) = 1 THEN debug := FALSE
				 ELSE IF index('SHARE',switch) = 1 THEN search_for_share := TRUE
				 ELSE IF index('NOSHARE',switch) = 1 THEN search_for_share := FALSE
				 ELSE IF index('HELP',switch) = 1 THEN 
				   BEGIN
					WRITELN;
					WRITELN('Valid switch        HELP DEBUG NODEBUG NOSHARE SHARE');
					WRITELN('Defaults switches              NODEBUG NOSHARE');
					WRITELN('   DEBUG will cause lots of internal state to be displayed');
					WRITELN('   SHARE will cause CALLOC4 to search for shareable microcode');
					WRITELN('Default input file   <filename>.U41');
					WRITELN('   Files generated');
					WRITELN('Statistics file      <filename>.DAT');
					WRITELN;
					have_slash := FALSE;
					fail := TRUE
				   END
				 ELSE
				   BEGIN
					WRITELN(com_line);
					FOR dum := 1 TO com_line_pt DO write(' ');
					WRITELN('^');
					WRITELN(' Invalid option');
					fail := true;
					have_slash := false
				   END;

				com_line_pt := com_line_pt + slash_loc;
				IF have_slash THEN
				   BEGIN
					switch_length := switch_length - slash_loc;
					switches := substr(switches,slash_loc+1,switch_length);
				   END;
			   END {parse switches}
			UNTIL NOT have_slash;
		   END {switch parse setup}
		   END; {have switch}
		IF NOT fail THEN 
	   BEGIN {open files}
		OPEN( 	FILE_VARIABLE := u41_file,
			FILE_NAME := u41_file_name,
			RECORD_LENGTH := max_word_line,
			HISTORY := READONLY,
			SHARING := READONLY,
			ERROR := continue);
		IF STATUS(u41_file) <> 0 THEN
		   BEGIN
			fail := TRUE;
			WRITELN(' Can not open file ',u41_file_name);
		   END
		 ELSE
		   BEGIN {u41 file okay}
			RESET(u41_file);
			OPEN( 	FILE_VARIABLE := bdr_file,
				FILE_NAME := bdr_file_name,
				HISTORY := READONLY,
				SHARING := READONLY,
				ERROR := continue);
			IF STATUS(bdr_file) <> 0 THEN
			   BEGIN
				fail := TRUE;
				WRITELN(' Can not open file ',bdr_file_name);
			   END
			 ELSE
			   BEGIN {bdr open okay}
				RESET(bdr_file);
				OPEN( 	FILE_VARIABLE := con_file,
					FILE_NAME := con_file_name,
					HISTORY := READONLY,
					SHARING := READONLY,
					ERROR := continue);
				IF STATUS(con_file) <> 0 THEN
				   BEGIN
					fail := TRUE;
					WRITELN(' Can not open file ',con_file_name);
				   END
				 ELSE
				   BEGIN {all input files open okay}
					RESET(con_file);
					OPEN( 	FILE_VARIABLE := stat_file,
						FILE_NAME := stat_file_name,
						HISTORY := NEW);
					REWRITE(stat_file);
				   END {all input files open okay}
			   END {bdr open okay}
		   END {u41 file okay}
	   END {open files}
END;  {prologue}

PROCEDURE get_bdr;
 VAR
	dum, mcr, ln, pn, adr : InTEGER;
	stamp : VARYING[80] OF CHAR;

BEGIN  {get_bdr}
	FOR dum :=  0 TO max_adr DO mcr_pt[dum] := -1;

	IF NOT EOF(bdr_file) THEN READLN(bdr_file,stamp)
	 ELSE WRITELN(bdr_file_name,' is empty');
	
	WHILE NOT EOF(bdr_file) DO
	   BEGIN
		READLN(bdr_file,mcr,ln,pn,adr);
		IF (adr < 0) OR (adr > max_adr) THEN writeln('DRY ROT (get_bdr) - ADR out of range ',adr,'(',HEX(adr,6),')');
		IF (mcr < 0) OR (mcr > max_adr) THEN writeln('DRY ROT (get_bdr) - mcr out of range ',mcr,'(',HEX(mcr,6),')');
		page_number[adr] := pn;
		line_number[adr] := ln;
		mcr_pt[adr] := mcr;
		adr_pt[mcr] := adr;
	   END;
	CLOSE(bdr_file);
END; {get_bdr}

PROCEDURE get_con;
 TYPE
	con_type = (a,b,d);

 VAR
	con_field : con_type;
	delta, dum, mcr, ln, companion, adr : INTEGER;
	stamp : VARYING[80] OF CHAR;

BEGIN  {get_con}
	FOR dum:= 0 TO max_adr DO have_delta[dum] := FALSE;

	IF NOT EOF(con_file) THEN READLN(con_file,stamp)
	 ELSE WRITELN(con_file_name,' is empty');

	WHILE NOT EOF(con_file) DO
	   BEGIN
		READLN(con_file,con_field,ln,mcr,companion,delta);
		IF (companion < 0) OR (companion > max_adr) THEN 
			writeln('DRY ROT (get_con) - ADR out of range ',companion,'(',HEX(companion,6),')');
		IF (mcr < -1) OR (mcr > max_adr) THEN 
			writeln('DRY ROT (get_con) - mcr out of range ',mcr,'(',HEX(mcr,6),')');
		IF (mcr <> -1) AND (con_field = d) THEN
		   BEGIN
			adr := adr_pt[companion];
			IF (adr < 0) OR (adr > max_adr) THEN 
				writeln('DRY ROT (get_con) - ADR out of range ',adr,'(',HEX(adr,6),')');
			have_delta[adr] := TRUE;
			adr := adr_pt[mcr];
			IF (adr < 0) OR (adr > max_adr) THEN 
				writeln('DRY ROT (get_con) - ADR out of range ',adr,'(',HEX(adr,6),')');
			have_delta[adr] := TRUE;
		   END
	   END;
	CLOSE(con_file);
END; {get_con}

FUNCTION count_1s(value, mask:UNSIGNED) : INTEGER;
VAR
	one_bit : UNSIGNED;
	dum : INTEGER;

BEGIN
	dum := 0;
	REPEAT
		IF UAND(mask,1) = 1 THEN IF ODD(value) THEN dum := dum +1;
		value := value DIV 2;
		mask := mask DIV 2;
	UNTIL mask = 0;
	count_1s := dum;
END;

FUNCTION count_0s(value, mask:UNSIGNED) : INTEGER;
VAR
	one_bit : UNSIGNED;
	dum : INTEGER;

BEGIN
	dum := 0;
	REPEAT
		IF UAND(mask,1) = 1 THEN IF NOT ODD(value) THEN dum := dum +1;
		value := value DIV 2;
		mask := mask DIV 2;
	UNTIL mask = 0;
	count_0s := dum;
END;

PROCEDURE gen_stat;
VAR
	map, line : VARYING[256] OF CHAR;
	mab, dummy, high_1s, col, row, ones, zeros, base, icount, power, adr, dum, line_length : INTEGER;
	DATA_msk, seq_msk : UNSIGNED;
	new_base : BOOLEAN;

{ data path statistics }
	basic_cnt, constant_cnt, shift_cnt, mem_cnt, special_cnt : INTEGER;
	constant_type : ARRAY[0..7] OF INTEGER;
	constant_pos : ARRAY[0..3] OF INTEGER;
	basic_type : ARRAY[0..31] OF INTEGER;
	shift_type : ARRAY[0..1] OF INTEGER;
	mem_type : ARRAY[0..31] OF INTEGER;
	special_misc1 : ARRAY[0..31] OF INTEGER;
	special_misc2 : ARRAY[0..1] OF INTEGER;
	special_misc3 : ARRAY[0..15] OF INTEGER;
	misc : ARRAY[0..31] OF INTEGER;

{ sequencing statistics }
	jmp_nosub_type, jmp_sub_type : INTEGER;
	br_type : ARRAY[0..31] OF INTEGER;
	ones_sum, ones_ave : REAL;

{   Sample .U41 input format 

! <<< ALLOCATED 01-May-85 14:11:12
!     CVAX.ULD		     MICRO2  1M(01)	1-MAY-85  14:02:47
!RADIX 16
!RTOL
[000]:1280433F11B
[11B]:07CF003F12D
[12D]:07CE003F133
[133]:07E8003F13B
[13B]:1282404113E
[13E]:07E90041143
[143]:07C9003F14E
[14E]:1E82402F165
[165]:1681C32B16B

}

BEGIN {gen_Stat}
	map := '0123456789ABCDEF';
	date(day_stamp);
	time(time_stamp);

	icount := 0;
	last_adr := 0;
	jmp_nosub_type := 0;
	jmp_sub_type := 0;

	FOR dum := 0 to 15 DO special_misc3[dum] := 0;
	FOR dum := 0 to 7 DO constant_type[dum] := 0;
	FOR dum := 0 to 3 DO constant_pos[dum] := 0;

	FOR dum := 0 TO 31 DO
	   BEGIN
		br_type[dum] := 0;
		basic_type[dum] := 0;
		mem_type[dum] := 0;
		special_misc1[dum] := 0;
		misc[dum] := 0
	   END;
	shift_type[0] := 0;
	shift_type[1] := 0;
	special_misc2[0] := 0;
	special_misc2[1] := 0;
	basic_cnt := 0;
	mem_cnt := 0;
	special_cnt := 0;
	constant_cnt := 0;
	shift_cnt := 0;
		
	WRITELN(stat_file,'CVAX microcode statistics file: ',stat_file_name,' ',day_stamp,' ',time_stamp);
	WRITELN(stat_file,'  Microcode source file: ',u41_file_name);
	WRITELN(stat_file);

	READLN(u41_file,line);  {first line contains ALLOCTION time stamp}
	WRITELN(stat_file,'      ',line);

	writeln;
	writeln('   ***Reading Microcode');

	READLN(u41_file,line);
	WHILE NOT EOF(u41_file) DO
	   BEGIN {read source file}
		IF line[1] <> '!' THEN
		   BEGIN {parse microcode line}
			icount := icount + 1;
			line_length := length(line);
			IF line_length <> 17 THEN 
			   BEGIN
				WRITELN('Warning - input length error,  Length: ',line_length);
				WRITELN(line)
			   END;
			IF (line[1] <> '[') OR (line[5] <> ']') OR (line[6] <> ':') THEN
			   BEGIN
				WRITELN('WARNING - input format error');
				WRITELN(line)
			   END;
			
			adr := 0;
			power := 1;
			FOR DUM:= 4 DOWNTO 2 DO
			   BEGIN
				adr := adr + (INDEX(map, line[dum]) -1) * power;
				power := power * 16;
			   END;
			IF adr > last_adr THEN last_adr := adr;

			IF debug THEN 
			   BEGIN
				WRITELN(line);	
				WRITELN('adr ',adr,'(',hex(adr,3),')')
			   END;
			ucode_data[adr] := 0;
			ucode_seq[adr] := 0;

			power := 1;
			FOR DUM:= 17 DOWNTO 15 DO
			   BEGIN
				ucode_seq[adr] := ucode_seq[adr] + (INDEX(map, line[dum]) -1) * power;
				power := power * 16;
			   END;
			IF NOT ODD(INDEX(map,line[14])) THEN ucode_seq[adr] := ucode_seq[adr] + %x'1000';

			power := 1;
			FOR DUM:= 14 DOWNTO 7 DO
			   BEGIN
				ucode_data[adr] := ucode_data[adr] + (INDEX(map, line[dum]) -1) * power;
				power := power * 16;
			   END;
			ucode_data[adr] := UAND(ucode_data[adr], %x'FFFFFFFE') DIV 2;

			IF debug THEN 
			   BEGIN
				WRITELN(line);	
				WRITELN('microword sequencing field ',hex(ucode_seq[adr],4));
				WRITELN('microword data field ',hex(ucode_data[adr],7))
			   END
		   END; {parse microde line}
		READLN(u41_file,line);
	   END; {read source file}

	dum := 0;
	REPEAT
	 IF mcr_pt[dum] >= 0 THEN
	   BEGIN

{ sequencing statistics }

		IF UAND(ucode_seq[dum],%x'1000') = %x'0000' THEN
		   BEGIN {some kind of jump}
			IF UAND(ucode_seq[dum],%x'0800') = %x'0800' THEN jmp_sub_type := jmp_sub_type + 1
			 ELSE jmp_nosub_type := jmp_nosub_type + 1;
		   END {some kind of jump}
		 ELSE
		   BEGIN {some kind of branch}
			adr := (UAND(ucode_seq[dum],%x'0F80') DIV 128)::INTEGER;
			br_type[adr] := br_type[adr] + 1;
		   END; {some kind of branch}

{ data path statistics }


		IF UAND(ucode_data[dum],%x'8000000') = %x'8000000' THEN
		   BEGIN {constant type}
			constant_cnt := constant_cnt + 1;
			adr := (UAND(ucode_data[dum] DIV %x'2000000',3))::INTEGER;
			constant_pos[adr] := constant_pos[adr] +1;
			adr := (UAND(ucode_data[dum] DIV %x'400000',7))::INTEGER;
			constant_type[adr] := constant_type[adr] +1;
		   END {constant type}
		ELSE IF (UAND(ucode_data[dum],%x'E000000') = %x'6000000') THEN
		   BEGIN {basic type}
			basic_cnt := basic_cnt + 1;
			adr := (UAND(ucode_data[dum] DIV %x'100000',%x'1F'))::INTEGER;
			basic_type[adr] := basic_type[adr] +1;
		   END {basic type}
		ELSE IF (UAND(ucode_data[dum],%x'E000000') = %x'4000000') THEN
		   BEGIN {shift type}
			shift_cnt := shift_cnt + 1;
			adr := ( UAND((ucode_data[dum] DIV %x'80000'),%x'1'))::INTEGER;
			shift_type[adr] := shift_type[adr] +1;
		   END {shift type}
		ELSE IF (UAND(ucode_data[dum],%x'E000000') = %x'2000000') THEN
		   BEGIN {mem ref type}
			mem_cnt := mem_cnt + 1;
			adr := (UAND(ucode_data[dum] DIV %x'100000',%x'1F'))::INTEGER;
			mem_type[adr] := mem_type[adr] +1;
		   END {mem ref type}
		ELSE IF (UAND(ucode_data[dum],%x'E000000') = %x'0000000') THEN
		   BEGIN {special type}
			special_cnt := special_cnt + 1;
			adr := (UAND(ucode_data[dum] DIV %x'100000',%x'1F'))::INTEGER;
			special_misc1[adr] := special_misc1[adr] +1;
			adr := (UAND(ucode_data[dum] DIV %x'80000',1))::INTEGER;
			IF (adr<> 1) AND (adr <> 0) THEN writeln('misc2 index out of range: ',adr);
			special_misc2[adr] := special_misc2[adr] +1;
			adr := (UAND(ucode_data[dum] DIV %x'8000',%x'F'))::INTEGER;
			special_misc3[adr] := special_misc3[adr] +1;
		   END {special type}
		ELSE WRITELN('Unclassified microinstruction at address ',dum:4,'(',hex(dum,3),')');

		adr := (UAND(ucode_data[dum] DIV %x'40',%x'1F'))::INTEGER;
		misc[adr] := misc[adr] +1;
	   END;

	 dum := dum + 1;
	 { skip address 620 thru 7DF }
	 IF dum = %x'620' THEN dum:= %x'7E0';

	UNTIL dum > max_adr;

	WRITELN(stat_file);
	WRITELN(stat_file,'Highest microaddress assigned: ',last_adr:4,'(',HEX(last_adr,3),')');
	WRITELN(stat_file,'Number of microinstruction   : ',icount:4);
	WRITELN(stat_file);
	WRITELN(stat_file,'Microcode seqencer statistics');
	WRITELN(stat_file);
	WRITELN(stat_file,'   CLASS                        OCCURENCES');
	WRITELN(stat_file,'   -----                        ----------');
	WRITELN(stat_file,'   JUMP without subroutine call    ',jmp_nosub_type:4);
	WRITELN(stat_file,'   JUMP with subroutine call       ',jmp_sub_type:4);
	dum := jmp_sub_type + jmp_nosub_type;

	WRITELN(stat_file,'   RET                             ',br_type[4]:4);
	dum := dum + br_type[4];
	WRITELN(stat_file,'   DEC.NEXT                        ',br_type[8]:4);
	dum := dum + br_type[8];
	WRITELN(stat_file,'   DL.BWL.AT.RVM_DEC.NEXT          ',br_type[10]:4);
	dum := dum + br_type[10];
	WRITELN(stat_file,'   AT.RVM_DEC.NEXT                 ',br_type[11]:4);
	dum := dum + br_type[11];
	WRITELN(stat_file,'   DL.BWL.AT.R_DEC.NEXT            ',br_type[12]:4);
	dum := dum + br_type[12];
	WRITELN(stat_file,'   AT.R_DEC.NEXT                   ',br_type[13]:4);
	dum := dum + br_type[13];
	WRITELN(stat_file,'   AT.AV_DEC_NEXT                  ',br_type[14]:4);
	dum := dum + br_type[14];
	WRITELN(stat_file,'   DL.BWL_DEC.NEXT                 ',br_type[15]:4);
	dum := dum + br_type[15];
	WRITELN(stat_file,'   CASE ALU.NZV                    ',br_type[16]:4);
	dum := dum + br_type[16];
	WRITELN(stat_file,'   CASE ALU.NZC                    ',br_type[17]:4);
	dum := dum + br_type[17];
	WRITELN(stat_file,'   CASE SC2-0                      ',br_type[18]:4);
	dum := dum + br_type[18];
	WRITELN(stat_file,'   CASE SC5-3                      ',br_type[19]:4);
	dum := dum + br_type[19];
	WRITELN(stat_file,'   CASE PSL26-24                   ',br_type[21]:4);
	dum := dum + br_type[21];
	WRITELN(stat_file,'   CASE STATE2-0                   ',br_type[22]:4);
	dum := dum + br_type[22];
	WRITELN(stat_file,'   CASE STATE5-3                   ',br_type[23]:4);
	dum := dum + br_type[23];
	WRITELN(stat_file,'   CASE MBOX.STATUS                ',br_type[24]:4);
	dum := dum + br_type[24];
	WRITELN(stat_file,'   CASE MMGT.STATUS                ',br_type[25]:4);
	dum := dum + br_type[25];
	WRITELN(stat_file,'   CASE MREF.STATUS                ',br_type[26]:4);
	dum := dum + br_type[26];
	WRITELN(stat_file,'   CASE FPA.DL                     ',br_type[27]:4);
	dum := dum + br_type[27];
	WRITELN(stat_file,'   CASE INT.RM                     ',br_type[28]:4);
	dum := dum + br_type[28];
	WRITELN(stat_file,'   CASE OPCODE2-0                  ',br_type[29]:4);
	dum := dum + br_type[29];
	WRITELN(stat_file,'   CASE ID.LOAD                    ',br_type[30]:4);
	dum := dum + br_type[30];
	WRITELN(stat_file,'                                   ----');
	WRITELN(stat_file,'                      TOTAL        ',dum:4);
	PAGE(stat_file);
	WRITELN(stat_file);
	WRITELN(stat_file,'Microcode frequency statistics');
	WRITELN(stat_file);
	WRITELN(stat_file,'             CLASS: BASIC');
	WRITELN(stat_file,'   FUNCTION                     OCCURENCES');
	WRITELN(stat_file,'   --------                     ----------');
	WRITELN(stat_file,'   A.PLUS.B                        ',basic_type[0]:4);
	dum := basic_type[0];
	WRITELN(stat_file,'   A.OR.B                          ',basic_type[1]:4);
	dum := dum + basic_type[1];
	WRITELN(stat_file,'   A.PLUS.B.PLUS.PSL.C             ',basic_type[2]:4);
	dum := dum + basic_type[2];
	WRITELN(stat_file,'   A.MINUS.1                       ',basic_type[3]:4);
	dum := dum + basic_type[3];
	WRITELN(stat_file,'   PASS.B                          ',basic_type[4]:4);
	dum := dum + basic_type[4];
	WRITELN(stat_file,'   A.MINUS.B.MINUS.PSL.C           ',basic_type[5]:4);
	dum := dum + basic_type[5];
	WRITELN(stat_file,'   A.AND.NOT.B                     ',basic_type[6]:4);
	dum := dum + basic_type[6];
	WRITELN(stat_file,'   NOT.B                           ',basic_type[8]:4);
	dum := dum + basic_type[8];
	WRITELN(stat_file,'   A.XOR.B                         ',basic_type[9]:4);
	dum := dum + basic_type[9];
	WRITELN(stat_file,'   PASS.A                          ',basic_type[10]:4);
	dum := dum + basic_type[10];
	WRITELN(stat_file,'   A.AND.B                         ',basic_type[12]:4);
	dum := dum + basic_type[12];
	WRITELN(stat_file,'   SMUL.STEP                       ',basic_type[13]:4);
	dum := dum + basic_type[13];
	WRITELN(stat_file,'   A.PLUS.B.PLUS.1                 ',basic_type[17]:4);
	dum := dum + basic_type[17];
	WRITELN(stat_file,'   A.MINUS.B                       ',basic_type[20]:4);
	dum := dum + basic_type[20];
	WRITELN(stat_file,'   UDIV.STEP                       ',basic_type[22]:4);
	dum := dum + basic_type[22];
	WRITELN(stat_file,'   B.MINUS.A                       ',basic_type[24]:4);
	dum := dum + basic_type[24];
	WRITELN(stat_file,'   A.PLUS.1                        ',basic_type[25]:4);
	dum := dum + basic_type[25];
	WRITELN(stat_file,'   NEG.B                           ',basic_type[26]:4);
	dum := dum + basic_type[26];
	WRITELN(stat_file,'                                   ----');
	WRITELN(stat_file,'                      TOTAL        ',dum:4);
	IF dum <> basic_cnt THEN WRITELN(' Accounting error: should have ',basic_cnt:4,' BASIC microinstructions');
	WRITELN(stat_file);
	WRITELN(stat_file);
	WRITELN(stat_file,'             CLASS: MEM REQ');
	WRITELN(stat_file,'   FUNCTION                     OCCURENCES');
	WRITELN(stat_file,'   --------                     ----------');
	WRITELN(stat_file,'   MEM.VIRT.VA                     ',mem_type[0]:4);
	dum := mem_type[0];
	WRITELN(stat_file,'   MEM.VIRT.VA.LOCK                ',mem_type[2]:4);
	dum := dum + mem_type[2];
	WRITELN(stat_file,'   MEM.VIRT.VAP                    ',mem_type[4]:4);
	dum := dum + mem_type[4];
	WRITELN(stat_file,'   MEM.VIRT.VAP.PTE                ',mem_type[5]:4);
	dum := dum + mem_type[5];
	WRITELN(stat_file,'   MEM.VIRT.VAP.LOCK               ',mem_type[6]:4);
	dum := dum + mem_type[6];
	WRITELN(stat_file,'   MEM.PHYS.VA                     ',mem_type[8]:4);
	dum := dum + mem_type[8];
	WRITELN(stat_file,'   MEM.PHYS.VA.LOCK                ',mem_type[10]:4);
	dum := dum + mem_type[10];
	WRITELN(stat_file,'   MEM.PHYS.VA.IPR                 ',mem_type[11]:4);
	dum := dum + mem_type[11];
	WRITELN(stat_file,'   MEM.PHYS.VAP                    ',mem_type[12]:4);
	dum := dum + mem_type[12];
	WRITELN(stat_file,'   MEM.PHYS.VAP.PTE                ',mem_type[13]:4);
	dum := dum + mem_type[13];
	WRITELN(stat_file,'   MEM.PHYS.VAP.LOCK               ',mem_type[14]:4);
	dum := dum + mem_type[14];
	WRITELN(stat_file,'   MEM.PHYS.VAP.INTVEC             ',mem_type[15]:4);
	dum := dum + mem_type[15];
	WRITELN(stat_file,'   PROBE.VIRT.VA                   ',mem_type[16]:4);
	dum := dum + mem_type[16];
	WRITELN(stat_file,'   PROBE.VIRT.VAP                  ',mem_type[20]:4);
	dum := dum + mem_type[20];
	WRITELN(stat_file,'   FPA.DATA                        ',mem_type[24]:4);
	dum := dum + mem_type[24];
	WRITELN(stat_file,'   MXPR                            ',mem_type[29]:4);
	dum := dum + mem_type[29];
	WRITELN(stat_file,'   MXPS0                           ',mem_type[30]:4);
	dum := dum + mem_type[30];
	WRITELN(stat_file,'   MXPS1                           ',mem_type[31]:4);
	dum := dum + mem_type[31];
	WRITELN(stat_file,'                                   ----');
	WRITELN(stat_file,'                      TOTAL        ',dum:4);
	IF dum <> mem_cnt THEN WRITELN(' Accounting error: should have ',mem_cnt:4,' MEM REQ microinstructions');
	WRITELN(stat_file);
	WRITELN(stat_file);
	WRITELN(stat_file,'             CLASS: CONSTANT');
	WRITELN(stat_file,'   FUNCTION                     OCCURENCES');
	WRITELN(stat_file,'   --------                     ----------');
	WRITELN(stat_file,'   A.PLUS.CONST                    ',constant_type[0]:4);
	dum := constant_type[0];
	WRITELN(stat_file,'   A.MINUS.CONST                   ',constant_type[1]:4);
	dum := dum + constant_type[1];
	WRITELN(stat_file,'   CONST.MINUS.A                   ',constant_type[2]:4);
	dum := dum + constant_type[2];
	WRITELN(stat_file,'   A.AND.CONST                     ',constant_type[3]:4);
	dum := dum + constant_type[3];
	WRITELN(stat_file,'   A.OR.CONST                      ',constant_type[4]:4);
	dum := dum + constant_type[4];
	WRITELN(stat_file,'   CONST                           ',constant_type[5]:4);
	dum := dum + constant_type[5];
	WRITELN(stat_file,'   A.AND.NOT.CONST                 ',constant_type[6]:4);
	dum := dum + constant_type[6];
	WRITELN(stat_file,'   A.XOR.CONST                     ',constant_type[7]:4);
	dum := dum + constant_type[7];
	WRITELN(stat_file,'                                   ----');
	WRITELN(stat_file,'                      TOTAL        ',dum:4);
	IF dum <> constant_cnt THEN WRITELN(' Accounting error: should have ',constant_cnt:4,' constant microinstructions');
	WRITELN(stat_file);
	WRITELN(stat_file);
	WRITELN(stat_file,'   POSITION                     OCCURENCES');
	WRITELN(stat_file,'   --------                     ----------');
	WRITELN(stat_file,'   BYTE 0                          ',constant_pos[0]:4);
	dum := constant_pos[0];
	WRITELN(stat_file,'   BYTE 1                          ',constant_pos[1]:4);
	dum := dum + constant_pos[1];
	WRITELN(stat_file,'   BYTE 2                          ',constant_pos[2]:4);
	dum := dum + constant_pos[2];
	WRITELN(stat_file,'   BYTE 3                          ',constant_pos[3]:4);
	dum := dum + constant_pos[3];
	WRITELN(stat_file,'                                   ----');
	WRITELN(stat_file,'                      TOTAL        ',dum:4);
	IF dum <> constant_cnt THEN WRITELN(' Accounting error: should have ',constant_cnt:4,' constant microinstructions');
	WRITELN(stat_file);
	WRITELN(stat_file);
	WRITELN(stat_file,'             CLASS: SHIFT');
	WRITELN(stat_file,'   FUNCTION                     OCCURENCES');
	WRITELN(stat_file,'   --------                     ----------');
	WRITELN(stat_file,'  RIGHT SHIFT                      ',shift_type[0]:4);
	dum := shift_type[0];
	WRITELN(stat_file,'  LEFT SHIFT                       ',shift_type[1]:4);
	dum := dum + shift_type[1];
	WRITELN(stat_file,'                                   ----');
	WRITELN(stat_file,'                      TOTAL        ',dum:4);
	IF dum <> shift_cnt THEN WRITELN(' Accounting error: should have ',shift_cnt:4,' SHIFT microinstructions');
	WRITELN(stat_file);
	WRITELN(stat_file);
	WRITELN(stat_file,'             CLASS: SPECIAL');
	WRITELN(stat_file,'   MISC1 FUNCTION               OCCURENCES');
	WRITELN(stat_file,'   --------------               ----------');
	WRITELN(stat_file,'  NOP                              ',special_misc1[0]:4);
	dum := special_misc1[0];
	WRITELN(stat_file,'  CLEAR.VAX.TRAP.REQUEST           ',special_misc1[18]:4);
	dum := dum + special_misc1[18];
	WRITELN(stat_file,'  SET.VAX.TRAP.REQUEST             ',special_misc1[2]:4);
	dum := dum + special_misc1[2];
	WRITELN(stat_file,'  ZAP.TB                           ',special_misc1[1]:4);
	dum := dum + special_misc1[1];
	WRITELN(stat_file,'  ZAP.TP(HIT).IF.HIT               ',special_misc1[17]:4);
	dum := dum + special_misc1[17];
	WRITELN(stat_file,'  SET.REPORBE                      ',special_misc1[4]:4);
	dum := dum + special_misc1[4];
	WRITELN(stat_file,'  SET.MMGT.TD                      ',special_misc1[8]:4);
	dum := dum + special_misc1[8];
	WRITELN(stat_file,'  HALT                             ',special_misc1[16]:4);
	dum := dum + special_misc1[16];
	WRITELN(stat_file,'                                   ----');
	WRITELN(stat_file,'                      TOTAL        ',dum:4);
	IF dum <> special_cnt THEN WRITELN(' Accounting error: should have ',special_cnt:4,' SPECIAL microinstructions');
	WRITELN(stat_file);
	WRITELN(stat_file,'   MISC2 FUNCTION               OCCURENCES');
	WRITELN(stat_file,'   --------------               ----------');
	WRITELN(stat_file,'  NOP                              ',special_misc2[0]:4);
	dum := special_misc2[0];
	WRITELN(stat_file,'  LOAD.PC.FROM.BPC                 ',special_misc2[1]:4);
	dum := dum + special_misc2[1];
	WRITELN(stat_file,'                                   ----');
	WRITELN(stat_file,'                      TOTAL        ',dum:4);
	IF dum <> special_cnt THEN WRITELN(' Accounting error: should have ',special_cnt:4,' SPECIAL microinstructions');
	WRITELN(stat_file);
	WRITELN(stat_file,'   MISC3 FUNCTION               OCCURENCES');
	WRITELN(stat_file,'   --------------               ----------');
	WRITELN(stat_file,'  NOP                              ',special_misc3[0]:4);
	dum := special_misc3[0];
	WRITELN(stat_file,'  CLEAR.STATE.5-4                  ',special_misc3[1]:4);
	dum := dum + special_misc3[1];
	WRITELN(stat_file,'  SET.STATE.3                      ',special_misc3[2]:4);
	dum := dum + special_misc3[2];
	WRITELN(stat_file,'  SET.STATE.4                      ',special_misc3[4]:4);
	dum := dum + special_misc3[4];
	WRITELN(stat_file,'  SET.STATE.5                      ',special_misc3[8]:4);
	dum := dum + special_misc3[8];
	WRITELN(stat_file,'                                   ----');
	WRITELN(stat_file,'                      TOTAL        ',dum:4);
	IF dum <> special_cnt THEN WRITELN(' Accounting error: should have ',special_cnt:4,' SPECIAL microinstructions');
	WRITELN(stat_file);
	WRITELN(stat_file);
	WRITELN(stat_file,'Microcode Frequency Summary');
	WRITELN(stat_file,'   CLASS                           OCCURENCES');
	WRITELN(stat_file,'   -----                           ----------');
	WRITELN(stat_file,'   BASIC                           ',basic_cnt:4);
	WRITELN(stat_file,'   MEM REQ                         ',mem_cnt:4);
	WRITELN(stat_file,'   SHIFT                           ',shift_cnt:4);
	WRITELN(stat_file,'   CONSTANT                        ',constant_cnt:4);
	WRITELN(stat_file,'   SPECIAL                         ',special_cnt:4);
	WRITELN(stat_file,'                                   ----');
	dum := basic_cnt + mem_cnt + shift_cnt + constant_cnt + special_cnt;
	WRITELN(stat_file,'                      TOTAL        ',dum:4);

	PAGE(stat_file);
	WRITELN(stat_file);
	WRITELN(stat_file,'MISC Field Statistics');
	WRITELN(stat_file);
	WRITELN(stat_file,'   FUNCTION                        OCCURENCES');
	WRITELN(stat_file,'   --------                        ----------');
	WRITELN(stat_file,'  NOP                              ',misc[0]:4);
	dum := misc[0];
	WRITELN(stat_file,'  WRITE.VA                         ',misc[1]:4);
	dum := dum + misc[1];
	WRITELN(stat_file,'  WRITE.VAP                        ',misc[2]:4);
	dum := dum + misc[2];
	WRITELN(stat_file,'  WRITE.SC                         ',misc[3]:4);
	dum := dum + misc[3];
	WRITELN(stat_file,'  FLUSH.WRITE.BUFFER               ',misc[4]:4);
	dum := dum + misc[4];
	WRITELN(stat_file,'  RESTART.PREFETCH                 ',misc[5]:4);
	dum := dum + misc[5];
	WRITELN(stat_file,'  DISABLE.IB.PREFETCH              ',misc[6]:4);
	dum := dum + misc[6];
	WRITELN(stat_file,'  ENABLE.IB.PREFETCH               ',misc[7]:4);
	dum := dum + misc[7];
	WRITELN(stat_file,'  CLEAR.RN                         ',misc[8]:4);
	dum := dum + misc[8];
	WRITELN(stat_file,'  RN.MINUS.1                       ',misc[9]:4);
	dum := dum + misc[9];
	WRITELN(stat_file,'  RN.PLUS.1                        ',misc[10]:4);
	dum := dum + misc[10];
	WRITELN(stat_file,'  RN.PLUS.DL.Q                     ',misc[11]:4);
	dum := dum + misc[11];
	WRITELN(stat_file,'  DL.BYTE                          ',misc[12]:4);
	dum := dum + misc[12];
	WRITELN(stat_file,'  DL.WORD                          ',misc[13]:4);
	dum := dum + misc[13];
	WRITELN(stat_file,'  DL.LONG                          ',misc[14]:4);
	dum := dum + misc[14];
	WRITELN(stat_file,'  DL.QUAD                          ',misc[15]:4);
	dum := dum + misc[15];
	WRITELN(stat_file,'  CLEAR.STATE.3-0                  ',misc[16]:4);
	dum := dum + misc[16];
	WRITELN(stat_file,'  SET.STATE.0                      ',misc[17]:4);
	dum := dum + misc[17];
	WRITELN(stat_file,'  SET.STATE.1                      ',misc[18]:4);
	dum := dum + misc[18];
	WRITELN(stat_file,'  SET.STATE.2                      ',misc[19]:4);
	dum := dum + misc[19];
	WRITELN(stat_file,'  SET.REEXECUTE                    ',misc[20]:4);
	dum := dum + misc[20];
	WRITELN(stat_file,'  CLEAR.MMGT.TD                    ',misc[21]:4);
	dum := dum + misc[21];
	WRITELN(stat_file,'  LOAD.V&PC                        ',misc[22]:4);
	dum := dum + misc[22];
	WRITELN(stat_file,'  SWAP.RN                          ',misc[23]:4);
	dum := dum + misc[23];
	WRITELN(stat_file,'  IF.BCOND.LOAD.V&PC.TRAP          ',misc[24]:4);
	dum := dum + misc[24];
	WRITELN(stat_file,'  IF.BCOND.LOAD.V&PC               ',misc[25]:4);
	dum := dum + misc[25];
	WRITELN(stat_file,'  OLD.Z                            ',misc[26]:4);
	dum := dum + misc[26];
	WRITELN(stat_file,'  SHIFT.DL                         ',misc[27]:4);
	dum := dum + misc[27];
	WRITELN(stat_file,'  RLOG                             ',misc[28]:4);
	dum := dum + misc[28];
 	WRITELN(stat_file,'  MAP.JIZJ                         ',misc[29]:4);
	dum := dum + misc[29];
	WRITELN(stat_file,'  MAP.IIII                         ',misc[30]:4);
	dum := dum + misc[30];
	WRITELN(stat_file,'  MAP.IIIJ                         ',misc[31]:4);
	dum := dum + misc[31];
	WRITELN(stat_file,'                                   ----');
	WRITELN(stat_file,'                      TOTAL        ',dum:4);

END;  {gen_stat}

{************************************************body of CALLOC4 begins here**************************************}
BEGIN  { plaout }
	debug := FALSE;
	search_for_share := FALSE;

	writeln('CVAX Pass 4 Allocator  V1.07  12-Jun-86');

	command_line_fail := TRUE;
	REPEAT
	   prologue(command_line_fail)
	UNTIL NOT command_line_fail;

	get_bdr;
	get_con;
	gen_stat;
	gen_cs_map;
	IF search_for_share THEN gen_xref; 

	close(u41_file);
	close(stat_file);

end.  {plaout}


