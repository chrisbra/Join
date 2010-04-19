" Join: Improved Algorithm for joining large files
"   Author:  Christian Brabandt <cb@256bit.org>
"   Version: 2.4
"   Script:  http://www.vim.org/scripts/script.php?script_id=2766
"   License: VIM License
"   Last Change: Mon, 19 Apr 2010 22:20:33 +0200


"   Documentation: see :help Join.txt
"   GetLatestVimScripts: 2766 5 :AutoInstall: Join.vim

" ---------------------------------------------------------------------
" Load Once: {{{1
if exists("g:loaded_Join") || &cp
 finish
endif
let g:loaded_Join      = 1
let s:keepcpo          = &cpo
set cpo&vim


" ---------------------------------------------------------------------
" Public Interface {{{1
com! -bang -range -nargs=? Join :<line1>,<line2>call Join#Position(empty('<bang>') ? 0 : 1, <q-args>)

" =====================================================================
" Restoration And Modelines: {{{1
" vim: fdm=marker sw=2 sts=2 ts=8 fdl=0
let &cpo= s:keepcpo
unlet s:keepcpo
