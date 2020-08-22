" Entrypoint script for basics-vim plugin.

" get full absolute path of the plugin root directory. This will be ../../
" from the this script file. We can use this path get access to helper scripts.
let s:plugin_dir = resolve(expand('<sfile>:p:h:h'))

" Source a vimscript file by name.
function! SourceConfig(filepath) abort
  execute 'source ' . '/' . a:filepath
endfunction

" fzf a list of files. Opens file on selection.
function! g:_basics_fzf_files(files)
    call fzf#run(fzf#wrap({'source': a:files}))
    call feedkeys('i')
endfunction

" General purpose fzf selector. Feed a list of items into fzf. When
" makes a selection, function with name cb is called with selection.
function! g:_basics_fzf_select(items, cb)
    call fzf#run(fzf#wrap({'source': a:items, 'sink': function(a:cb)}))
    call feedkeys('i')
endfunction

function! s:not_available()
  echo 'basics-vim: action not available'
endfunction

function! s:_command_to_buffer(cmd) abort
  redir @a
  silent execute a:cmd
  redir end
  enew
  put a
  normal! gg
endfunction

" Config for terminal buffer.
function! s:on_term_open() abort
  setlocal nonumber
  setlocal norelativenumber
  set filetype=Terminal
  startinsert
endfunction

" Lists output of a command in fzf. Output is split into a list of
" sorted lines. Each line is an item in FZF selector.
" (cmd:String, [callback:FuncRef]) => Nothing
function! s:cmd_output_in_fzf(cmd, ...) abort
  let Cb = a:0 > 0 ? a:1 : {... -> 0}
  redir => cmd_output
  silent execute a:cmd
  redir END
  let list = sort(split(cmd_output, "\n"))
  return fzf#run(fzf#wrap({'source': list, 'sink': Cb}))
  call feedkeys('i')
endfunction

" Enable folding for vimscript.
augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END

" Write output of a given command into new buffer.
command! -nargs=1 C2b call s:_command_to_buffer(<q-args>)

" Lists all functions in fzf
command! Funcs call s:cmd_output_in_fzf('func')

" Lists all variables in fzf
command! Vars call s:cmd_output_in_fzf('let')

" Set filetype correctly for markdown
augroup on_buf_md
  autocmd!
  autocmd BufNewFile,BufRead *.md set filetype=markdown
augroup END

autocmd TermOpen * call s:on_term_open()

" Indicates existance of this plugin.
let g:basics_plugin_loaded = 1
