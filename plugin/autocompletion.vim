" autocompletion.vim:	automatically offers word completion
" Last Modified: Fri 25. Sep 2015 18:00:19 +0200 CEST
" Author:		Jan Christoph Ebersbach <jceb@e-jc.de>
" Version:		0.4
"
" inspired by http://vim.sourceforge.net/scripts/script.php?script_id=73

" DESCRIPTION:
"  Each time you type an alphabetic character, the script attempts to complete
"  the current word. The suggested completion is draw below the word you are
"  typing. Type <C-N> to select the completion and continue with the next word.

" LIMITATIONS:
"  The script works by :imap'ping each alphabetic character, and uses
"  Insert-mode completion (:help ins-completion). It is far from perfect.

" INSTALLATION:
"  :source it from your vimrc file or drop it in your plugin directory.
"  To activate, choose "Start Autocompletion" from the Tools menu, or type
"  :call AutocompletionStart()
"  To make it stop, choose "Plugin/Stop Autocompletion", or type
"  :call AutocompletionStop()
"  If you want to activate the script for certain filetypes, add the line
"  	let g:autocompletion_filetypes = 'filetype,...'
"  to your vimrc file.

if (exists("g:loaded_autocompletion") && g:loaded_autocompletion) || &cp
    finish
endif
let g:loaded_autocompletion = 1

if !exists('g:autocompletion_nomenuone')
  set completeopt=menuone
endif

" avoid completion options from being written into the buffer - let the user
" select the preferred one manually
set completeopt+=noinsert

if !exists("g:autocompletion_min_length")
  let g:autocompletion_min_length = 1
endif

let b:completion_active = 0

" Make an :imap for each alphabetic character, and define a few :smap's.
fun! s:AutocompletionStart()
  " Thanks to Bohdan Vlasyuk for suggesting a loop here:
  for c in [["A", "Z"], ["a", "z"]]
    let l:letter = char2nr(c[0])
    let l:letter_to = char2nr(c[1])
    while l:letter <= l:letter_to
      let char = nr2char(l:letter)
      execute "imap <buffer> <expr> ".char." <SID>Autocomplete('".char."')"
      let l:letter += 1
    endwhile
  endfor
  " start completion when . is pressed
  " inoremap <buffer> <expr> . <SID>Autocomplete(".")
  let b:completion_active = 1
endfun


" Remove all the mappings created by AutocompletionStart().
" Lazy: I do not save and restore existing mappings.
fun! s:AutocompletionStop()
  if (!b:completion_active)
    return
  endif
  " Thanks to Bohdan Vlasyuk for suggesting a loop here:
  for c in [["A", "Z"], ["a", "z"]]
    let l:letter = char2nr(c[0])
    let l:letter_to = char2nr(c[1])
    while l:letter <= l:letter_to
      execute "iunmap <buffer> ".nr2char(l:letter)
      let l:letter = l:letter + 1
    endwhile
  endfor
  let b:completion_active = 0
endfun

if (exists('g:autocompletion_filetypes') && len(g:autocompletion_filetypes) > 0)
    exec 'au FileType '.g:autocompletion_filetypes.' :AutocompletionStart'
endif

" Completes current word if autocompletion_min_length chars are written
" char is given because v:char seems not to work
fun! s:Autocomplete(char)
  " Trigger comletion only when paste mode is not active and the completion menu
  " is not displayed
  if !&paste && !pumvisible()
    let l:line = getline('.')
    let l:col = col('.')
    let l:word = strpart(l:line, -1, l:col)  " from start to cursor
    let l:word = matchstr(l:word, '\S*$')  " word before cursor
    " note we get the word's length without the current char
    if strlen(l:word)+1 >= g:autocompletion_min_length
      " integrate with the vim completes me plugin
      if exists('g:vcm_default_maps')
        return a:char."\<Tab>"
      else
        return a:char."\<C-n>"
      endif
    endif
  endif
  return a:char
endfun

if has("menu")
  amenu &Plugin.&Autocompletion.&Start\ Autocompletion :AutocompletionStart<CR>
  amenu &Plugin.&Autocompletion.Sto&p\ Autocompletion :AutocompletionStop<CR>
endif

command! -nargs=0 AutocompletionStart call <SID>AutocompletionStart()
command! -nargs=0 AutocompletionStop call <SID>AutocompletionStop()

" vi: ft=vim:tw=80:sw=2:ts=2:sts=2:et
