" for plug
set nocompatible
filetype off

" auto install Plug https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" plugins
call plug#begin('~/.vim/plugged')
" main plugins
Plug 'neoclide/coc.nvim', {'branch': 'release'} " autocompletion
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } " fuzzy search (will be install system-wide)
Plug 'junegunn/fzf.vim'
Plug 'jremmen/vim-ripgrep' " search by files content
Plug 'scrooloose/nerdtree' " file explorer
Plug 'tpope/vim-fugitive' " git integration
Plug 'scrooloose/nerdcommenter' " simpler comments
Plug 'tpope/vim-repeat' " repeat plugin commands with '.'
Plug 'tpope/vim-surround' " simple quoting and parenthesizing
Plug 'jiangmiao/auto-pairs' " auto closing brackets
Plug 'tpope/vim-endwise' " auto end keyword
Plug 'drzel/vim-scrolloff-fraction' " auto scroll when getting closer to window border

" language syntax support
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'jparise/vim-graphql'
Plug 'elixir-editors/vim-elixir'
Plug 'vim-ruby/vim-ruby'
Plug 'styled-components/vim-styled-components', { 'branch': 'main' } " CSS in JS files

" styling

call plug#end()

" keys mappings
nnoremap ; :
vnoremap ; :
nnoremap <C-g> :Ag<Cr>
nnoremap <C-p> :FZF<Cr>
map <C-n> :NERDTreeToggle<CR>

" settings
syntax on
colorscheme monokai
highlight default link SignColumn LineNr
set exrc " allows project specific .vimr
set encoding=utf-8
set timeoutlen=250                                              " used for mapping delays
set cursorline                                                  " shows cursorline
set relativenumber                                              " shows relative numbers
set number                                                      " shows current line with relative numbers
set path+=**                                                    " allows find to look deep into folders during search
set wildmenu                                                    " lets you see what your other options for <TAB>
set hidden                                                      " allows to manage multiple buffers effectively
set hlsearch                                                    " highlights search items
set incsearch                                                   " highligths search items dynamically as they are typed
set ignorecase                                                  " the case of normal letters is ignored
set smartcase                                                   " overrides ignorecase if search contains uppercase chars
set nowrap                                                      " don't wrap lines
set tabstop=2                                                   " tab to two spaces
set shiftwidth=2                                                " identation in normal mode pressing < or >
set softtabstop=2                                               " set 'tab' as 2 spaces and removes 2 spaces on backspace
set expandtab                                                   " replaces tabs with spaces
set smarttab                                                    " needed for tabbing
set nofoldenable                                                " don't fold by default
set ruler                                                       " shows the cursor position
set laststatus=2                                                " shows status line
set synmaxcol=200                                               " maximum column in which to search for syntax items.  In long lines the
set autoindent                                                  " copy indent from current line when starting a new line
set smartindent                                                 " does smart autoindenting
set nowritebackup                                               " to not write backup before save
set autoread                                                    " to autoread if file was changed outside from vim
set noswapfile                                                  " to not use swap files
set nobackup                                                    " to not write backup during overwriting file
set showcmd                                                     " shows command
set list                                                        " enables showing of hidden chars
set listchars=tab:▸\ ,eol:¬,trail:∙                             " shows hidden end of line. tabs and trailing spaces
set foldmethod=syntax                                           " fold based on syntax
set foldnestmax=3                                               " deepest fold is 3 levels
set clipboard=unnamed                                           " copying from/to clipboard

"run NERDTree on vim start
autocmd vimenter * NERDTree
"run NERDTree when vim started with no specified files
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif
"close vim if the only window left open is a NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

autocmd BufWritePre * %s/\s\+$//e "removes trailing whitespaces
autocmd BufNewFile * set noeol "removes eol

" auto scroll on 20% of window width
let g:scrolloff_fraction = 0.2

""" styling

set colorcolumn=121 " vertical line on 121'st column

" status line colors
highlight StatusLine ctermbg=208 ctermfg=232 cterm=NONE
highlight StatusLineNC ctermbg=8 cterm=NONE

" Dim inactive windows https://groups.google.com/d/msg/vim_use/IJU-Vk-QLJE/xz4hjPjCRBUJ
" this will only work with lines containing text
if exists('+colorcolumn')
  function! s:DimInactiveWindows()
    for i in range(1, tabpagewinnr(tabpagenr(), '$'))
      let l:range = ""
      if i != winnr()
        if &wrap
         let l:width=256
        else
         let l:width=winwidth(i)
        endif
        let l:range = join(range(1, l:width), ',')
      endif
      call setwinvar(i, '&colorcolumn', l:range)
    endfor
  endfunction
  augroup DimInactiveWindows
    au!
    au WinEnter * call s:DimInactiveWindows()
    au WinEnter * set cursorline
    au WinLeave * set nocursorline
  augroup END
endif
