" Join: Improved Algorithm for joining large files
"   Author:  Christian Brabandt <cb@256bit.org>
"   Version: 2.4
"   Script:  http://www.vim.org/scripts/script.php?script_id=2766
"   License: VIM License
"   Last Change: Mon, 19 Apr 2010 22:20:33 +0200


"   Documentation: see :help Join.txt
"   GetLatestVimScripts: 2766 5 :AutoInstall: Join.vim

fu! Join#Join_Wrap(flag, count) range
    " this is a guess, but I think, 1000 lines can be joined by vim
    " without problems. If you lower the limit, the plugin has to run more
    " often, if the limit is too large, it will suffer from the same
    " performance issue.
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
	exe start . ',' . end . "call Join#My_Join(a:flag)"
    endif
endfu


fu! Join#My_Join(bang_flag) range
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
	exe ":" . first . "," . (first+runs-1) . "call Join#Join_Wrap(" . a:bang_flag . ", '' )"
    endif
endfu

fu! Join#Position(flag, count) range
    let oldpos=getpos('.')
    exe a:firstline . ',' . a:lastline . "call Join#Test_Joinspaces(a:flag, a:count)"
    exe a:firstline . ',' . a:lastline . "call Join#Join_Wrap(a:flag, a:count)"
    call setpos('.', oldpos)
endfu

fu! Join#Test_Joinspaces(flag, count) range
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


" vim: sw=2 sts=2 ts=8 fdm=marker fdl=0
