| convert help.txt to help.db

~sys
needs string/trim
needs db/sqlite
needs os/dir
~db
0 value db
create wordbuf 256 allot		| name of word
create stackbuf 256 allot		| stack diagram
create origbuf 256 allot		| origin of word
create ctxbuf 256 allot			| context of word
create osbuf 256 allot			| os this appears in (blank =both, or linux or windows)
create descbuf 10000 allot		| description of word
create verbuf 256 allot			| version of Reva this word first appears
create buf 10000 allot			| the SQL to write out
create enq	10000 allot
create area 256 allot			| area - memory, strings, util etc.

: null? dup c@ 0if drop " NULL" else count then ;
: notnull! dup c@ 0if wordbuf count type ."  is incomplete" cr -1 throw ;then count ;
: -cr ( a n -- )
	00; 2dup 0do
		count 
		13 =if 32 over 1- c! then
	loop drop
	;

: enquote ( a n -- a' n' )
	-cr
	" '" enq lplace
	quote' enq +lplace
	39 enq c+lplace
	enq lcount
	;
: ,, ', buf c+lplace ;

: nocr 2dup + c@ 13 =if 1- then ;
| trim is bad ?!?
: getline parseln trim enquote ;
: stack: ( <stack> )
	getline stackbuf place 
	;
: orig: ( <stack> ) getline origbuf place ;
: ctx: ( <context> ) getline ctxbuf place ;
: os: ( <os> ) getline osbuf place ;
: ver: ( <os> ) getline verbuf place ;

variable area#
: updarea
	area c@ 0;	| if empty, do nothing
	" insert or ignore into areas values (NULL,'" pad place
	area count pad +place
	" ')" pad +place
	db pad count sql_exec
	" select ix from areas where name='" pad place
	area count pad +place
	" '" pad +place
	db pad count sql_fetch# area# !
	;
: area: ( <area> ) parseln trim area place updarea ;

: getix ( a n -- ix )
	trim
	dup 0if 2drop 0 ;then
	" select ix from help where word=" pad place
	enquote pad +place
	db pad count sql_fetch# ;


create first 20 allot
create second 20 allot
: dopermute ( -- )
	db " insert into also values (" pad place
		first count pad +place
		" ," pad +place
		second count pad +place
		" )" pad +place  
		pad count sql_exec
	db " insert into also values (" pad place
		second count pad +place
		" ," pad +place
		first count pad +place
		" )" pad +place  
		pad count sql_exec
	;
: permute ( ... n -- )
	1- 0drop; 0do
		| take the top item and each of the following items and permute:
		(.) first place
		remains 1+ 0do
			i pick (.) second place dopermute
		loop
	loop
	drop
	;

: related ( a n -- )
	trim
	| split the string into component words.  Keep track of how many words have
	| been seen.  Each word must be looked up and its index pushed on the stack
	0 -rot			| count a n
	repeat 
		ltrim
		32 split
		>r getix r>  | count a n ix true | count ix false
		over 0if
			nip
		else
			if
				-rot 2swap swap 1+ 2swap
				true
			else
				| count ix
				swap 1+
				false
			then
		then
	while
	| ... count 
	permute
	;
: also: ( <also> ) -1 throw ;
| This word must only occur *after* the 'related' words!  It's a good idea to
| place it at the bottom of the help file.
: related: 10 parse related ;
: desc: ( <desc>^L ) 
    parsews drop c@ parse 
	enquote descbuf lplace 
	| write out the word
	" insert into help values (NULL," buf lplace
	wordbuf count buf +lplace ,,
	stackbuf null? buf +lplace ,,
	ctxbuf notnull! buf +lplace ,,
	origbuf null? buf +lplace ,,
	osbuf null? buf +lplace ,,
	verbuf null? buf +lplace ,,
	area# @ (.) buf +lplace ,,
	descbuf lcount
	buf +lplace
	" )" buf +lplace
	db buf lcount sql_exec
	;

variable #defs
: def: ( <name> <stack> <desc> )
	#defs ++
	getline wordbuf place
	stackbuf off
	ctxbuf off
	osbuf off
	descbuf off
	verbuf off
	area off
	area# off
	; 

: init
	appdir pad place " help.db" pad +place pad count
	2dup delete sql_open dup to db 
	" create table help (ix integer primary key,word,stack,ctx,orig,os,ver,area,desc)" sql_exec 
	db " create table also (ix integer, other integer)" sql_exec 
	db " create table libs (ix integer primary key, name)" sql_exec
	db " create table areas (ix integer primary key, name)" sql_exec
	db " create unique index a1 on areas (name)" sql_exec
	db " insert into areas values (0,'UNK')" sql_exec
	;
: readin  db sql_begin
	appdir 4 - pad place " src/help.txt" pad +place pad count 
	(include)
	db sql_commit
	;
: deinit  
	db sql_begin
	db " create index w1 on help(word)" sql_exec 
	db sql_commit
	db sql_close 
	0 to db ;

: dolib ( a n -- )
	slurp 2dup | a n a n
	" |||" search if
		| a n a1 a2
		4 /string eval
	then
	drop free
	;
: (dolibs) ( a n -- )
	origbuf off
	in~ ~os fullname 
	2dup " CVS/" search if 2drop 2drop ;then
	| a n
	2dup
	libdir nip cell- /string enquote origbuf place
	#defs @ >r

	db sql_begin
	dolib
	" insert into libs values (NULL, " pad place
	origbuf count pad +place
	') pad c+place 
	db pad count sql_exec
	db sql_commit
	#defs @ r> - 0if
		origbuf count type space ." NOHELP!" cr 
	then
	;
: listareas
	." Areas: "
	db 
	" select name from areas order by name"
	{ 0 sql_getcol$ type_ false } 
	sql_fetch drop
	cr
	;
: dolibs
	| iterate over libraries and process each one ...
	['] (dolibs) ['] 2drop libdir in~ ~os rdir
	;
init readin dolibs listareas deinit 
cr #defs ? ." word definitions in database" cr bye

