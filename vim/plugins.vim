" all plugins and plugin-related configurations sourced here
" this is needed because vim becomes critically broken when loads
" vimrc without plugins installed, so with this file it's possible
" to load only plugins without the rest of configuration

" auto install Plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

""" plugins
call plug#begin('~/.config/nvim/plugged')
" main plugins
Plug 'neoclide/coc.nvim', {'branch': 'release'} " autocompletion
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } " fuzzy search (will be installed system-wide)
Plug 'junegunn/fzf.vim'
Plug 'jremmen/vim-ripgrep' " search by files content
Plug 'scrooloose/nerdtree' " file explorer
Plug 'Xuyuanp/nerdtree-git-plugin' " git extension for NERDTree
Plug 'tpope/vim-fugitive' " git integration
Plug 'scrooloose/nerdcommenter' " simpler comments
Plug 'tpope/vim-repeat' " repeat plugin commands with '.'
Plug 'tpope/vim-surround' " simple quoting and parenthesizing
Plug 'vim-scripts/auto-pairs-gentle' " auto closing brackets
Plug 'tpope/vim-endwise' " auto 'end' keyword
Plug 'drzel/vim-scrolloff-fraction' " auto scroll when getting closer to window border
Plug 'thoughtbot/vim-rspec' " RSpec integration
Plug 'airblade/vim-gitgutter' " git status near line numbers
Plug 'simeji/winresizer' " easier split resizing

" language and tools syntax support
Plug 'pangloss/vim-javascript' " JavaScript
Plug 'mxw/vim-jsx' " react
Plug 'posva/vim-vue' " vue
Plug 'jparise/vim-graphql' " graphQL
Plug 'elixir-editors/vim-elixir' " elixir
Plug 'vim-ruby/vim-ruby' " ruby
Plug 'styled-components/vim-styled-components', { 'branch': 'main' } " CSS in JS files
Plug 'tpope/vim-rails' " rails
Plug 'ap/vim-css-color' " colors preview

" styling
Plug 'jacoborus/tender.vim' " colorscheme
"Plug 'morhetz/gruvbox' " colorscheme without true color support
Plug 'itchyny/lightline.vim' " statusline
Plug 'ryanoasis/vim-devicons' " icons, should be last in this list
call plug#end()
