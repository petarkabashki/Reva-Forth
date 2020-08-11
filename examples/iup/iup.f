needs ui/gui

context: ~test-app
~test-app

with~ ~ui
with~ ~iup

:: ." Ok, bye!" cr gui-close ; 16 cb: callback-quit
 

: define-dialog ( -- dialoghandle )
  dialog[
    hbox[
      " Label 1" label[ " 255 0 255" fgcolor ]w
      " Label 2" label[ " 255 100 100" bgcolor ]w
    ]c
    spacer
    hbox[
      " Label 3" label[ " 0 255 255" fgcolor  " 10 10 10" bgcolor ]w
    ]c
    spacer
    hbox[
      " Quit!" button[  action: callback-quit  ]w
      spacer
      " Quit!" button[  ['] callback-quit action  ]w
    ]c
  ]d  " My Dialog!"  title
;


: go  define-dialog  show  gui-main-loop  hide  destroy  ;
to~ ~ go

without~ | ~ui

exit~ | ~test-app

go bye
