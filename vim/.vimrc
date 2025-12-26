" notdummy
set shell=/bin/bash
set noautochdir
set termguicolors
syntax on
set background=dark
set laststatus=1
let mapleader=" "

filetype plugin indent on
set nocompatible
set number
set relativenumber
set tabstop=4
set shiftwidth=4
set expandtab
set cursorline
set wrap
set laststatus=2
set encoding=utf-8
set whichwrap+=h,l
set virtualedit=onemore
set selection=inclusive
set foldmethod=indent
set foldlevel=99
set clipboard=unnamedplus
set makeprg=python3\ %

"===============================================================================
" Transparent background setup
"===============================================================================
function! SetTransparentBackground()
  if &termguicolors || has("gui_running")
    " GUI or truecolor terminals
    highlight Normal       guibg=NONE
    highlight NormalNC     guibg=NONE
    highlight EndOfBuffer  guibg=NONE
    highlight SignColumn   guibg=NONE
    highlight VertSplit    guibg=NONE
    highlight LineNr       guibg=NONE
    highlight FoldColumn   guibg=NONE
    highlight NonText      guibg=NONE
    highlight StatusLine   guibg=NONE
  else
    " Fallback for cterm (without truecolor)
    highlight Normal       ctermbg=NONE
    highlight NormalNC     ctermbg=NONE
    highlight EndOfBuffer  ctermbg=NONE
    highlight SignColumn   ctermbg=NONE
    highlight VertSplit    ctermbg=NONE
    highlight LineNr       ctermbg=NONE
    highlight FoldColumn   ctermbg=NONE
    highlight NonText      ctermbg=NONE
    highlight StatusLine   ctermbg=NONE
  endif
endfunction
call SetTransparentBackground()
"===============================================================================
" Plugin bootstrap & sourcing
"===============================================================================
if filereadable(expand("~/.config/vim/vimrc.plug"))
  source ~/.config/vim/vimrc.plug
endif

"===============================================================================
" Lightline Configuration
"===============================================================================
let g:lightline = {
      \ 'colorscheme': 'carbonfox',
      \ 'active': {
      \   'left': [ ['mode','paste'], ['readonly','filename','modified','helloworld'] ]
      \ },
      \ 'component': {
      \   'helloworld': 'Darling...'
      \ },
      \ }

"===============================================================================
" Theme persistence file
"===============================================================================
let s:theme_file = expand("~/.config/vim/selected_theme")

"===============================================================================
" Apply + Persist helper
"===============================================================================
function! ApplyColorscheme(theme)
  if a:theme ==# 'default'
    highlight clear | syntax reset
  else
    execute 'colorscheme ' . a:theme
  endif

  if exists('*lightline#init')
    call lightline#init()
    call lightline#colorscheme()
    call lightline#update()
  endif

  call SetTransparentBackground()

  " Persist
  call writefile([a:theme], s:theme_file)
endfunction

"===============================================================================
" Simple FZF Theme Picker (with Favorites & Last Used)
"===============================================================================
function! FuzzyPickColorscheme()
  let favorite_themes = ['wombat', 'gruvbox', 'desert', 'morning']
  let all_themes = getcompletion('', 'color')
  let themes = favorite_themes + filter(all_themes, 'index(favorite_themes, v:val) == -1')

  if filereadable(s:theme_file)
    let last_theme = readfile(s:theme_file)[0]
    call insert(themes, 'Last used → ' . last_theme, 0)
  endif

  call fzf#run(fzf#wrap({
        \ 'source': themes,
        \ 'sink': function('s:SelectTheme'),
        \ 'options': [
        \   '--prompt=Theme> ',
        \   '--layout=reverse',
        \   '--info=inline',
        \   '--height=50%',
        \ ]
        \ }))
endfunction

function! s:SelectTheme(choice)
  if a:choice =~# '^Last used → '
    let theme = substitute(a:choice, '^Last used → ', '', '')
  else
    let theme = a:choice
  endif
  call ApplyColorscheme(theme)
endfunction

"===============================================================================
" Load last theme on startup
"===============================================================================
if filereadable(s:theme_file)
  let g:default_theme = readfile(s:theme_file)[0]
else
  let g:default_theme = 'default'
endif

call ApplyColorscheme(g:default_theme)

"===============================================================================
" status line height toggle
"===============================================================================
function! ToggleStatusLine()
  if &laststatus == 0
    set laststatus=2
  else
    set laststatus=0
  endif
endfunction

nnoremap <leader>ch :call ToggleStatusLine()<CR>
"===============================================================================
" Keybindings
"===============================================================================
nnoremap <leader>ft :call FuzzyPickColorscheme()<CR>
nnoremap <leader>n :NERDTreeToggle<CR>
vnoremap <leader>y :w !wl-copy<CR><CR>
nnoremap <leader>p :r !wl-paste<CR>

nnoremap <leader>ff :Files<CR>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>fr :GFiles<CR>
nnoremap <leader>fg :Rg<CR>
nnoremap <leader>fe :edit <C-D>
