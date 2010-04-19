" Join: Improved Algorithm for joining large files
"   Author:		Christian Brabandt <cb@256bit.org>
"   Date:		Oct 1, 2009
"   Version:		2.2
" GetLatestVimScripts: 2766 3 :AutoInstall: Join.vim

" Load Once: {{{1
if exists("g:loaded_Join") || &cp
 finish
endif
let g:loaded_Join      = "1"


fu! <SID>Join_Wrap(flag, count) range
    let limit = 1000
    let start =  a:firstline
    let end  =  a:lastline
    if !empty(a:count)
	let ccount = (a:count == 1 ? 1 : a:count - 1)
    else 
	let ccount = 1
    endif

    if (a:lastline == a:firstline)
	let end = start + ccount
    elseif (!empty(a:count) && (a:lastline != a:firstline))
	let start = a:lastline
	let end  = start + ccount
    elseif (empty(a:count) && (a:lastline == a:firstline))
	let end = start + 1
    endif

    if (end > line('$'))
      let end=line('$')
    endif

    if  ( (a:lastline - a:firstline) <= limit )
	"echo "builtin join"
	exe start . ',' . end . 'join' . ( a:flag ? '!' : ' ' ) 
    else
	"echo "custom join"
	exe start . ',' . end . "call <SID>My_Join(a:flag)"
    endif
endfu


fu! <SID>My_Join(bang_flag) range
    let limit=10000

    let first  = a:firstline
    let last   = a:lastline 

    let runs   = (last - first)/limit + 1
    let remain = last - first + 1

    for i in range(runs)
        let start = first + i*limit
	if (remain > limit)
	    let end = start + limit - 1
	elseif (remain <= limit && ((i > 0) || first > 1))
	    let end = start + remain - 1
	else
	    let end = remain
	endif
        call setline(i+first, join(filter(getline(start,end), 'v:val !~ "^$"') , a:bang_flag ? '' : ' '))
	let remain -=  limit
    endfor

    if (last > first)
	exe ":silent " . (runs+first) . "," . last . "d_" 
    endif
    if (runs > 1)
	exe ":" . first . "," . (first+runs-1) . "call <SID>Join_Wrap(" . a:bang_flag . ", '' )"
    endif
endfu

fu! <SID>Position(flag, count) range
    let oldpos=getpos('.')
    exe a:firstline . ',' . a:lastline . "call <SID>Test_Joinspaces(a:flag, a:count)"
    exe a:firstline . ',' . a:lastline . "call <SID>Join_Wrap(a:flag, a:count)"
    call setpos('.', oldpos)
endfu

fu! <SID>Test_Joinspaces(flag, count) range
  if !a:flag
      " Check joinspaces setting and correct range
      let start = a:firstline
      let end   = a:lastline

      if !empty(a:count) && (a:count == 1)
	  let ccount = 1
      elseif !empty(a:count) && (a:count > 1)
	  let ccount = a:count - 1
      else 
	  let ccount = 1
      endif

      if (a:lastline == a:firstline)
	  let end = start + ccount
      elseif (!empty(a:count) && (a:lastline != a:firstline))
	  let start = a:lastline
	  let end  = start + ccount
      elseif (empty(a:count) && (a:lastline == a:firstline))
	  let end = start + 1
      endif

      if (end > line('$'))
	let end=line('$')
      endif

	let old = @/
	exe "silent " . start . "," . end . 's/ $//e'
	exe 'silent ' . start . ',' . end . 's/\n\().*\)$/\1\r/e'
	
	if (&js)
	  if (&cpo !~# 'j')
	      let sep = '\%(\.\|?\|!\)'
	  else
	      let sep = '\%(\.\)'
	  endif
	  exe "silent " . start . "," . end . 's/' . sep . '/& /e'
	endif
	let @/  = old
      endif
endfu


" Commands:
com! -bang -range -nargs=? Join :<line1>,<line2>call <SID>Position(empty('<bang>') ? 0 : 1, <q-args>)

" vim: sw=2 sts=2 ts=8 tw=79
