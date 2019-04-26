call plug#begin('~/.vim/plugged')

"Themes
Plug 'nightsense/carbonized'
Plug 'junegunn/seoul256.vim'
Plug 'dylanaraps/wal.vim'

"Other
Plug 'itchyny/lightline.vim'
Plug 'terryma/vim-multiple-cursors'
call plug#end()

"Color Theme
color seoul256
highlight Normal ctermbg=NONE
highlight nonText ctermbg=NONE
highlight LineNr ctermbg=NONE

"Lightline
set laststatus=2
set noshowmode
let g:lightline = {
      \ 'colorscheme': 'seoul256',
      \ }

if !has('gui_running')
  set t_Co=256
endif

" FEATURES "

:set mouse=a

" Paste in the same line"
:nmap , $p

"Count lines
set number
set relativenumber

"Repeat a full line
inoremap <C-l> <C-x><C-l>

"Curly braces
inoremap " ""<left>
inoremap ' ''<left>
inoremap ( ()<left>
inoremap [ []<left>
inoremap { {}<left>
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O

" Tabspace "
set tabstop=4
set softtabstop=0 noexpandtab

" F2 Shortcut for Comp. and Exe. (C++) "
autocmd filetype cpp nnoremap <F2> :w <bar> exec '!clear && g++ '.shellescape('%').' -o '.shellescape('%:r').' && ./'.shellescape('%:r')<CR>

" F9 Shortcut for Exe. (Python) "
autocmd FileType python nnoremap <buffer> <F9> :w <bar> :exec '!python3' shellescape(@%, 1)<cr>
