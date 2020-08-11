" vim: ts=8:sw=4:nocindent:smartindent:
if version < 600
    syntax clear
    echo "You need to use 6.0 or later of vim!"
else
if exists("b:current_syntax")
    finish
endif

" Synchronization method
syn sync ccomment maxlines=200


syn case ignore
" Some special, non-FORTH keywords
syn keyword revaTodo contained todo fixme bugbug todo: bugbug: note:
syn match revaTodo contained 'copyright\(\s(c)\)\=\(\s[0-9]\{2,4}\)\='

syn case match
" basic mathematical and logical operators
syn keyword revaoperators + - * / mod /mod negate abs min max umin umax
syn keyword revaoperators and or xor not invert 1+ 1- 
syn keyword revaoperators m+ */ */mod m* um* m*/ um/mod fm/mod sm/rem
syn keyword revaoperators d+ d- dnegate dabs dmin dmax

" stack manipulations
syn keyword revastack drop nip dup over tuck swap rot -rot ?dup pick roll
syn keyword revastack 2drop 2nip 2dup 2over 2swap 2rot
syn keyword revastack >r r> r@ rdrop
" syn keyword revastack sp@ sp! rp@ rp!

" address operations
syn keyword revamemory @ ! +! c@ c! 2@ 2!
syn keyword revaadrarith chars char+ cells cell+ cell align allot allocate here
syn keyword revamemblks move fill 

" conditionals
syn keyword revacond if else then =if >if <if <>if if0  ;; catch throw 

" iterations
syn keyword revaloop while repeat until again
syn keyword revaloop do loop i j leave 

" new words
syn match revaColonDef '\<noname:\|\<:\s+' contains=revaComment
syn keyword revaEndOfColonDef ; 
syn keyword revadefine constant constant, variable create variable,
syn keyword revadefine user value to defer is does> immediate 
syn keyword revadefine compile interp postpone execute literal ' [']

" debugging
syn keyword revadebug .s dump

" basic character operations
syn keyword revaCharOps (.) CHAR EXPECT FIND WORD TYPE -TRAILING EMIT KEY
syn keyword revaCharOps KEY? TIB CR
syn match revaCharOps '\<char\s\S\s'
syn match revaCharOps '\<\[char\]\s\S\s'
syn region revaCharOps start=+."\s+ skip=+\\"+ end=+"+

" char-number conversion
syn keyword revaconversion s>d >digit digit> >single >double >number 

" interptreter, wordbook, compiler
syn keyword revareva bye >body here
syn keyword revareva pad words 

" vocabularies
syn keyword revavocs forth macro loc: loc; 

" numbers
syn keyword revamath decimal hex base
syn match revainteger '\<-\=[0-9.]*[0-9.]\+\>'
" recognize hex and binary numbers, the '$' and '%' notation is for greva
syn match revainteger '\<\$\x*\x\+\>' " *1* --- dont't mess
syn match revainteger '\<\x*\d\x*\>'  " *2* --- this order!
syn match revainteger '\<%[0-1]*[0-1]\+\>'
syn match revainteger "\<'.\>"

" Strings
syn region revaString start=+\.\?\"+ end=+"+ end=+$+
" XXX

" Comments
syn match revaComment '\\\s.*$' contains=revaTodo
syn region revaComment start='\\S\s' end='.*' contains=revaTodo
syn match revaComment '\.(\s[^)]*)' contains=revaTodo
syn region revaComment start='(\s' skip='\\)' end=')' contains=revaTodo
syn region revaComment start='/\*' end='\*/' contains=revaTodo
syn match revaComment '(\s[^\-]*\-\-[^\-]*)' contains=revaTodo
syn match revaComment '|.*' contains=revaTodo
syn match revaColonDef '\<:m\?\s*[^ \t]\+\>' contains=revaComment

" Include files
syn match revaInclude '(include\|needs)\s\+\S\+'

" Define the default highlighting.
if !exists("did_reva_syn_inits")
    " The default methods for highlighting. Can be overriden later.
    hi def link revaTodo Todo
    hi def link revaOperators Operator
    hi def link revaMath Number
    hi def link revaInteger Number
    hi def link revaStack Special
    hi def link revaFStack Special
    hi def link revaSP Special
    hi def link revaMemory Function
    hi def link revaAdrArith Function
    hi def link revaMemBlks Function
    hi def link revaCond Conditional
    hi def link revaLoop Repeat
    hi def link revaColonDef Define
    hi def link revaEndOfColonDef Define
    hi def link revaDefine Define
    hi def link revaDebug Debug
    hi def link revaCharOps Character
    hi def link revaConversion String
    hi def link revaForth Statement
    hi def link revaVocs Statement
    hi def link revaString String
    hi def link revaComment Comment
    hi def link revaClassDef Define
    hi def link revaEndOfClassDef Define
    hi def link revaObjectDef Define
    hi def link revaEndOfObjectDef Define
    hi def link revaInclude Include
endif

let b:current_syntax = "reva"
endif
