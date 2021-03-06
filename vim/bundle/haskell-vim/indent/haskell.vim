" indentation for haskell
"
" author: raichoo (raichoo@googlemail.com)
"
" Modify g:haskell_indent_if and g:haskell_indent_case to
" change indentation for `if'(default 3) and `case'(default 5).
" Example (in .vimrc):
" > let g:haskell_indent_if = 2

if exists('b:did_indent')
  finish
endif

let b:did_indent = 1

if !exists('g:haskell_indent_if')
  " if x
  " >>>then ...
  " >>>else ...
  let g:haskell_indent_if = 3
endif

if !exists('g:haskell_indent_case')
  " case xs of
  " >>[]     -> ...
  " >>(y:ys) -> ...
  let g:haskell_indent_case = 2
endif

if !exists('g:haskell_indent_let')
  " let x = 0 in
  " >>>>x
  let g:haskell_indent_let = 4
endif

if !exists('g:haskell_indent_where')
  " where f :: Int -> Int
  " >>>>>>f x = x
  let g:haskell_indent_where = 6
endif

if !exists('g:haskell_indent_do')
  " do x <- a
  " >>>y <- b
  let g:haskell_indent_do = 3
endif

if !exists('g:haskell_indent_in')
  " let x = 1
  " >in x
  let g:haskell_indent_in = 1
endif

if !exists('g:haskell_indent_guard')
  " f x y
  " >>|
  let g:haskell_indent_guard = 2
endif

setlocal indentexpr=GetHaskellIndent()
setlocal indentkeys=0{,0},!^F,o,O,0\|,0\=,0=where,0=let,0=deriving,0=->,0=\=>,<Space>

function! s:isInBlock(hlstack)
  return index(a:hlstack, 'haskellParens') > -1 || index(a:hlstack, 'haskellBrackets') > -1 || index(a:hlstack, 'haskellBlock') > -1
endfunction

function! s:getNesting(hlstack)
  return filter(a:hlstack, 'v:val == "haskellBlock" || v:val == "haskellBrackets" || v:val == "haskellParens"')
endfunction

function! s:getHLStack()
  return map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunction

" indent matching character
function! s:indentMatching(char)
  norm 0
  call search(a:char, 'c')
  norm %
  return col('.') - 1
endfunction

" backtrack to find guard clause
function! s:indentGuard(pos, prevline)
  let l:l = a:prevline
  let l:c = 1

  while v:lnum != l:c
    " empty line, stop looking
    if l:l =~ '^$'
      return a:pos
    " guard found
    elseif l:l =~ '^\s*|\s\+'
      return match(l:l, '|')
    " found less deeper indentation (not starting with `,` or `=`)
    " stop looking
    else
      let l:m = match(l:l, '\S')
      if l:l !~ '^\s*[=,]' && l:m <= a:pos
        return l:m + g:haskell_indent_guard
      endif
    endif
    let l:c += 1
    let l:l = getline(v:lnum - l:c)
  endwhile

  return -1
endfunction

function! GetHaskellIndent()
  let l:hlstack = s:getHLStack()

  " blockcomment handling
  if index(l:hlstack, 'haskellBlockComment') > -1
    for l:c in range(v:lnum - 1, 0, -1)
      let l:line = getline(l:c)
      if l:line =~ '{-'
        return 1 + match(l:line, '{-')
      endif
    endfor
    return 1
  endif

  let l:prevline = getline(v:lnum - 1)
  let l:line     = getline(v:lnum)

  " reset
  if l:prevline =~ '^\s*$' && l:line !~ '^\s*\S'
    return 0
  endif

  " comment indentation
  if l:prevline =~ '^\s*--'
    return match(l:prevline, '\S')
  endif

  " operator at end of previous line
  if l:prevline =~ '\s\+[!#$%&*+./<>?@\\^|~-]\+\s*$'
    let l:s = match(l:prevline, '\S')
    if l:s > 0
      return l:s + &shiftwidth
    endif
  endif

  " let foo =
  " >>>>>>bar
  if l:prevline =~ '\C\<let\>\s\+[^=]\+=\s*$'
    return match(l:prevline, '\C\<let\>') + g:haskell_indent_let + &shiftwidth
  endif

  " let x = 1 in
  " >>>>x
  if l:prevline =~ '\C\<let\>\s\+.\+\<in\>\?\s*$'
    return match(l:prevline, '\C\<let\>') + g:haskell_indent_let
  endif

  " let x = 1
  " let y = 2
  "
  " let x = 1
  " >in x
  "
  " let x = 1
  " >>>>y = 2
  if l:prevline =~ '\C\<let\>\s\+.\+$'
    if l:line =~ '\C^\s*\<let\>'
      return match(l:prevline, '\C\<let\>')
    elseif l:line =~ '\C^\s*\<in\> '
      return match(l:prevline, '\C\<let\>') + g:haskell_indent_in
    else
      return match(l:prevline, '\C\<let\>') + g:haskell_indent_let
    endif
  endif

  " if handling
  if l:prevline !~ '\C\<else\>'
    let l:s = match(l:prevline, '\C\<if\>.*\&.*\zs\<then\>')
    if l:s > 0
      return l:s
    endif

    let l:s = match(l:prevline, '\C\<if\>')
    if l:s > 0
      return l:s + g:haskell_indent_if
    endif
  endif

  " where
  " >>foo
  "
  " do
  " >>foo
  "
  " foo =
  " >>bar
  if l:prevline =~ '\C\(\<where\>\|\<do\>\|=\)\s*$'
    return match(l:prevline, '\S') + &shiftwidth
  endif

  "" where foo
  "" >>>>>>bar
  if l:prevline =~ '\C\<where\>\s\+\S\+.*$'
    if  l:line =~ '^\s*[=-]>\s' && l:prevline =~ ' :: '
      return match(l:prevline, ':: ')
    else
      return match(l:prevline, '\C\<where\>') + g:haskell_indent_where
  endif
  endif

  " do foo
  " >>>bar
  if l:prevline =~ '\C\<do\>\s\+\S\+.*$'
    return match(l:prevline, '\C\<do\>') + g:haskell_indent_do
  endif

  " case foo of
  " >>bar -> quux
  if l:prevline =~ '\C\<case\>\s\+.\+\<of\>\s*$'
    return match(l:prevline, '\C\<case\>') + g:haskell_indent_case
  endif

  " newtype Foo = Foo
  " >>{ bar :: Int }
  "
  " newtype Foo = Foo
  " >>deriving
  if l:prevline =~ '\C\s*\<\(newtype\|data\)\>[^{]\+' && (l:line =~ '^\s*{' || l:line =~ '\C^\s*\<deriving\>')
    return match(l:prevline, '\S') + &shiftwidth
  endif

  " foo :: Int
  " >>>>-> Int
  "
  " foo
  "   :: Int
  " foo
  if l:prevline =~ '\s::\s'
    if l:line =~ '^\s*[-=]>'
      return match(l:prevline, '::\s')
    elseif match(l:prevline, '^\s\+::') > -1
      return match(l:prevline, '::\s') - &shiftwidth
    endif
  endif

  " foo :: Int
  "     -> Int
  " foo x
  "
  " foo
  "   :: Int
  "   -> Int
  " foo x
  if l:prevline =~ '^\s*[-=]>' && l:line !~ '^\s*[-=]>'
    if s:isInBlock(l:hlstack)
      return match(l:prevline, '[^\s-=>]')
    else
      let l:m = matchstr(l:line, '^\s*\zs\S\+\ze\s\+')
      let l:l = l:prevline
      let l:c = 1

      while v:lnum != l:c
        " fun decl
        let l:s = match(l:l, l:m)
        if l:s >= 0
          return l:s
        " empty line, stop looking
        elseif l:l =~ '^$'
           return 0
        endif
        let l:c += 1
        let l:l = getline(v:lnum - l:c)
      endwhile

      return 0
    endif
  endif

  "   | otherwise = ...
  " foo
  "
  "   | foo
  "   , bar
  "
  "   | foo
  "   = bar
  if l:prevline =~ '^\s\+|' && !s:isInBlock(l:hlstack)
    if l:line =~ '\s*[,=]'
      return match(l:prevline, '|')
    elseif l:line !~ '^\s*|'
      return match(l:prevline, '|') - g:haskell_indent_guard
    endif
  endif

  " foo :: ( Monad m
  "        , Functor f
  "        )
  ">>>>>=> Int
  if l:prevline =~ '^\s*)' && l:line =~ '^\s*=>'
    let l:s = match(l:prevline, ')')
    return l:s - (&shiftwidth + 1)
  endif

  " module Foo
  " >>( bar
  if l:prevline =~ '^module \S\+$'
    return &shiftwidth
  endif

  "  in foo
  " where bar
  if l:line =~ '\C^\s*\<where\>'
    if match(l:prevline, '^\s\+in\s\+') == 0
      return match(l:prevline, 'in') - g:haskell_indent_in
    endif

    return match(l:prevline, '\S') + &shiftwidth
  endif

  " let x = 1
  "     y = 2
  " >in x + 1
  if l:line =~ '\C^\s*\<in\>\s'
    return match(l:prevline, '\S') - (4 - g:haskell_indent_in)
  endif

  " data Foo
  " >>= Bar
  "
  "   |
  "   ...
  " >>=
  "
  " foo
  " >>=
  if l:line =~ '^\s*='
    if l:prevline =~ '\C^\<data\>\s\+[^=]\+\s*$'
      return match(l:prevline, '\C\<data\>') + &shiftwidth
    else
      let l:s = s:indentGuard(match(l:line, '='), l:prevline)
      if l:s > 0
        return l:s
      else
        return &shiftwidth
      endif
    endif
  endif

  "   { foo :: Int
  " >>,
  "
  "   |
  "   ...
  " >>,
  if l:line =~ '^\s*,'
    if s:isInBlock(l:hlstack)
      norm 0
      call search(',', 'c')
      let l:n = s:getNesting(l:hlstack)
      call search('[(\[{]', 'b')

      while l:n != s:getNesting(s:getHLStack())
        call search('[(\[{]', 'b')
      endwhile

      return col('.') - 1
    else
      let l:s = s:indentGuard(match(l:line, ','), l:prevline)
      if l:s > -1
        return l:s
      end
    endif
  endif

  "   |
  "   ...
  " >>|
  if l:line =~ '^\s*|\s'
    let l:s = s:indentGuard(match(l:line, '|'), l:prevline)
    if l:s > -1
      return l:s
    end
  endif

  " foo
  " >>:: Int
  if l:line =~ '^\s*::\s'
    return match(l:prevline, '\S') + &shiftwidth
  endif

  "   bar
  " _ -> quux
  if l:line =~ '^\s*\S\+\s\+->\s\+' && l:prevline !~ '^\s*\S\+\s\+->\s\+'
    return match(l:prevline, '\S') - g:haskell_indent_case
  endif

  " indent closing brace, paren or bracket
  if l:line =~ '^\s*}'
    return s:indentMatching('}')
  endif

  if l:line =~ '^\s*)'
    return s:indentMatching(')')
  endif

  if l:line =~ '^\s*]'
    return s:indentMatching(']')
  endif

  return match(l:prevline, '\S')
endfunction
