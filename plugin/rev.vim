" Vim syntax file for review comments
"
" Maintainer:	Karthick Gururaj <karthickgururaj at yahoo dot com>
" Last change:	Jul 20 2004
" Version:     0.1.0

" All characters except space and tab
syn match rev_Description "[^ |	]*" contains=NONE
exe 'syn match rev_Defect "'. g:CodeReviewer_defects . '" contained'
exe "syn keyword rev_Initial " . g:CodeReviewer_reviewer . " contained"
exe 'syn match rev_Source "^[a-zA-Z0-9_\\\/\.]*:[0-9]\+:\s*[a-zA-Z]\+\s*-\s*' . g:CodeReviewer_defects . '" contains=rev_Defect,rev_Initial'

hi link rev_Description Special
hi link rev_Defect Type
hi link rev_Initial Keyword
hi link rev_Source Include
