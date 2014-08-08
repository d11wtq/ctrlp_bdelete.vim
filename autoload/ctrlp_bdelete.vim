" ctrlp_bdelete.vim: An extension to ctrlp.vim for closing buffers.
"
" To use this plugin, install it with Vundle or Pathogen, then add
"   call ctrlp_bdelete#init()
" to your ~/.vimrc to initialize the ctrlp settings.
"
" When installed, you can use <C-@> in the ctrlp finder to delete open
" buffers. This also works for buffers marked with <C-z>.
"
" =============================================================================
" File: plugin/ctrlp_bdelete.vim
" Description: ctrlp, buffer
" Author: Chris Corbyn <chris@w3style.co.uk>
" =============================================================================

" Initialize the bdelete extension to ctrlp (applies settings to ctrlp).
function! ctrlp_bdelete#init()
  if !exists('g:ctrlp_buffer_func')
    let g:ctrlp_buffer_func = {}
  endif

  " don't clobbber any existing user setting
  if has_key(g:ctrlp_buffer_func, 'enter')
    if g:ctrlp_buffer_func['enter'] != 'ctrlp_bdelete#mappings'
      let s:ctrlp_bdelete_user_func = g:ctrlp_buffer_func['enter']
    endif
  endif

  let g:ctrlp_buffer_func['enter'] = 'ctrlp_bdelete#mappings'
endfunction

" Buffer function used in the ctrlp settings (applies mappings).
function! ctrlp_bdelete#mappings(...)
  " call the original user setting, if set
  if exists('s:ctrlp_bdelete_user_func')
    call call(s:ctrlp_bdelete_user_func, a:000)
  endif

  nnoremap <buffer> <silent> <c-@> :call <sid>DeleteMarkedBuffers()<cr>
endfunction

function! s:DeleteMarkedBuffers()
  " get the line number to preserve position
  let currln = line('.')
  let lastln = line('$')

  " list all marked buffers
  let marked = ctrlp#getmarkedlist()

  " the file under the cursor is implicitly marked
  if empty(marked)
    call add(marked, fnamemodify(ctrlp#getcline(), ':p'))
  endif

  " call bdelete on all marked buffers
  for fname in marked
    let bufid = fname =~ '\[\d\+\*No Name\]$' ? str2nr(matchstr(fname, '\d\+'))
          \ : fnamemodify(fname[2:], ':p')
    exec "silent! bdelete" bufid
  endfor

  " refresh ctrlp
  exec "normal \<f5>"

  " unmark buffers that have been deleted
  silent! call ctrlp#clearmarkedlist()

  " preserve line selection
  if line('.') == currln && line('$') < lastln
    exec "normal \<up>"
  endif
endfunction
