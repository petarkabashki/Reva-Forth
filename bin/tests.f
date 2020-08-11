#! reva

needs string/misc
needs os/shell

: shell prior shell drop ;
appdir " test.f" strcatf shell 
appdir " testlib.f" strcatf shell 
bye
