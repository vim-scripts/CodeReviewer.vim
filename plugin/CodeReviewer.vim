" Vim plugin file for inserting review comments
"
" Maintainer:	Karthick Gururaj <karthickgururaj at yahoo dot com>
" Last change:	Jul 20 2004
" Version:     0.1.0

if exists( "g:loaded_CodeReviewer" ) 
  finish 
endif 
let g:loaded_CodeReviewer=1 

" Set file-type to review
au BufNewFile,BufRead *.rev  setf rev

" Hard-settings:
let g:CodeReviewer_defects = '\[\(Defect\|Remark\|Question\)\]'
let g:CodeReviewer_defaultDefect = "[Defect]"
let g:CodeReviewer_lineContinuation = '\\'

if ( !hasmapto( '<Plug>AddComment', 'n' ) ) 
  nmap <unique> <leader>ic <Plug>AddComment 
endif 

nmap <Plug>AddComment :call <SID>SavePosition()<cr>:call <SID>OpenReviewFile()<cr>:call <SID>InsertComment()<cr>A 

com! CheckReview execute "cfile " . g:CodeReviewer_reviewFile 
com! SortReviewFile :call <SID>SortReviewFile()

function! s:SortReviewFile()
  " For handling multi-line comments, club them with ctrl-A...
  "   first, search for lines to be joined with the next
  vglobal/\n^[a-zA-Z0-9\.\\\/_]\+:[0-9]\+:/ substitute /\(.*$\)/\1/
  "   if the last char is the line continuation character, insert ctrl-A
  if exists("g:CodeReviewer_lineContinuation")
     exe 'silent! %s/\(' . g:CodeReviewer_lineContinuation . '\)$/\1'
  endif
  "   next, join them
  silent! %s/\n//
  "   ..corner case - remove trailing ctrl-As
  silent! %s/$//
  " Sort all lines
  "  - Assumes presence of sort which can take a field seperator (-t <char)
  "    and multiple fields (-k <keyname>)
  " POSIX.2 compilant sort should work
  silent 0,$!sort -t: -k1,1 -k2n,2
  " silent 0,$!sort

  if exists("g:CodeReviewer_sortDefects") && g:CodeReviewer_sortDefects == 1
     " This script uses registers D, Q, and R, so save register values
     let d=@d 
     let q=@q
     let r=@r
     let @d=""  " Clear contents of register d
     silent! g/\[Defect\]/ delete D  " Transfer all defects to register D
     let @q="" 
     silent! g/\[Question\]/ delete Q
     let @r="" 
     silent! g/\[Remark\]/ delete R
     " Remove rest of the lines too - should be none really
     silent! g/^/ delete _
     " Start putting stuff back
     " Put major comments first, then questions, then minor comments, then nits
     silent! normal G"dPG"qPG"rP
     " Remove blank lines if any
     silent! g/^$/ d

     " Restore register values
     let d=@d 
     let q=@q
     let r=@r
  endif

  "   ..replace ctrl-As with newline characters
  silent! %s///g
endfunction

function! s:SavePosition() 
  let g:CodeReviewer_fileName = expand( "%" )
  let g:CodeReviewer_lineNumber = line( "." ) 
endfunction

function! s:InsertComment() 
  let commentLine = g:CodeReviewer_fileName . ":" 
  let commentLine = commentLine . g:CodeReviewer_lineNumber . ": " 
  let commentLine = commentLine . g:CodeReviewer_reviewer . " - " 
  let commentLine = commentLine . g:CodeReviewer_defaultDefect . " "

  $put=commentLine 
endfunction 

function! s:OpenReviewFile() 
  call OpenOrSwitch( g:CodeReviewer_reviewFile ) 
endfunction 
 
" If a window for the filename specified exists, switches to it (uses :sb); otherwise, opens a new 
" window with that file name (uses :sp). 
function! OpenOrSwitch( theFile ) 
  let openingCommand = "sb" 

  if ( bufwinnr( a:theFile ) < 0 ) 
    let openingCommand = "sp" 
  endif 

  execute openingCommand . " " . a:theFile 
endfunction 
" Need this option for the above function to work properly
set switchbuf=useopen
