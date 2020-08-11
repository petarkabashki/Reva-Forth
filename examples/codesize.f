| The "cs" word allows you to see how much code space a particular set of words
| will use.  You use it like this:
|    cs dup drop
| after pressing ENTER, "cs" will parse the line, create an anonymous code blob
| at "here", figure out how much space was used, and then deallocate the space.
| So you can use it all day long without consuming the dictionary or the heap.

macro 
: cs ( <code> -- n )
	" { " pad place parseln pad +place "  }" 
	pad +place here pad count eval drop 
	here swap - dup . negate allot ;
forth

