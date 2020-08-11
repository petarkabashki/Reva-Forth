| throw and catch

variable ex
: a ." in a" cr ex @ 1+ dup ex ! throw ;
: b ." in b" cr a ." after a " cr ;
: c ." in c" cr 1 2 3 ['] b catch 
    cr dup 0if ." ok" drop 
    else ." caught exception: " . then cr ;

c bye
