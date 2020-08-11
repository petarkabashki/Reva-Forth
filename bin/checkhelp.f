| utility to check the help file to make sure:
|   1) all words have help
|   2) each word is listed in the correct context
|   3) the help file doesn't have words listed which don't exist
with~ ~priv
variable starthere | don't list the words we create here!

needs util/classes
needs db/sqlite

with~ ~db

0 value db		| the help database
: init
	appdir pad place " help.db" pad +place pad count
	sql_open dup to db
	0if ." Could not open the help database " pad count type cr bye then
	db " create temp table inreva(word,context)" sql_exec
	;
: dumpall
	0 sql_getcol$ type_ 
	1 sql_getcol$ type cr
	false
	;
: deinit db 0; sql_close ;

create enq	1000 allot

: enquote ( a n -- a' n' )
	" '" enq lplace
	quote' enq +lplace
	39 enq c+lplace
	enq lcount
	;

variable curctx

: addword ( dict -- )
	>name count			| a n
	dup 0if 2drop ;then
	" insert into inreva values (" pad lplace
	enquote pad +lplace
	', pad c+lplace
	curctx @ ctx>name enquote pad +lplace
	') pad c+lplace
	db pad lcount sql_exec
	;
| similar to the version in 'map.f', but this one inserts the words in a new
| temporary table in the help file.  let's leverage SQLite!
: wordlist
	." Generating word list..." cr
	db " begin" sql_exec	| if you don't use transactions, you will wait a
							| very long time ...
	{
		@ dup curctx !
		| @ | 'last' for this context
		{
			cell- 
				dup [''] starthere  <if
					addword
				else
					drop
				then
			true
		} swap iterate
		true
	} all-contexts iterate
	db " commit" sql_exec
	;

: words-without-help
	cr ." Words which have no help: " cr
	db quote @
		select word,context from inreva 
		where word not in (select word from help)
		and context <> "~priv"
		order by context,word
	@ ['] dumpall sql_fetch
	;
: help-without-words
	cr ." Help without words: " cr
	db quote @
		select word,ctx 
		from help
		where 
			substr(orig,1,4) = 'src/'
		and	help.word not in (select word from inreva)
		and ctx <> 'meta'
		order by word,ctx
	@ ['] dumpall sql_fetch
	;
: words-in-wrong-context
	cr ." Words in wrong context: " cr
	db quote @
		select inreva.word,inreva.context 
		from inreva join help
		where inreva.word = help.word
		and inreva.context != help.ctx
		and substr(help.orig,1,4) = 'src/'
		order by inreva.word,inreva.context
	@ ['] dumpall sql_fetch
	;

: dump-words
	cr ." All inreva words:" cr
	db
	" select word,context from inreva order by word,context" 
	['] dumpall sql_fetch
	;
: words-with-no-area
	cr ." Core words with no 'area':" cr
	db quote @
		select word,ctx
		from help
		where area = 0
		and substr(help.orig,1,4) = 'src/'
		order by word,ctx
	@ ['] dumpall sql_fetch
	;
init
wordlist
words-without-help
help-without-words
words-in-wrong-context
words-with-no-area
| dump-words
deinit
bye
