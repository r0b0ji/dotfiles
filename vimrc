" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible 

"--------------
"" Load pathogen
"--------------
runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()
call pathogen#helptags()

"------------------
" Syntax and indent
"------------------
syntax on " turn on syntax highlighting
set showmatch " show matching braces when text indicator is over them

" highlight current line, but only in active window
augroup CursorLineOnlyInActiveWindow
    autocmd!
    autocmd VimEnter,WinEnter,BufWinEnter * setlocal cursorline
    autocmd WinLeave * setlocal nocursorline
augroup END

filetype plugin indent on " enable file type detection
set autoindent

"---------------------
" Basic editing config
"---------------------
set number              " number lines
set incsearch           " incremental search (as string is being typed)
set hlsearch            " highlight search
set linebreak           " line break
set showcmd             " Show (partial) command in status line.
set ruler               " show current position in file
set showmode            " show mode
set hidden              " allow auto-hiding of edited buffers
set autochdir           " automatically set current directory to directory of last opened file
set history=8192        " more history
set scrolloff=5         " show lines above and below cursor (when possible)
set laststatus=2        " show status line 'always' in last window
set backspace=2         " allow backspacing over everything
set nojoinspaces        " suppress inserting two spaces between sentences

" disable folds
set nofen               " disable folds
set foldcolumn=2        " set a column incase we need it
set foldlevel=0         " show contents of all folds
set foldmethod=indent   " use indent unless overridden

" use 4 spaces instead of tabs during formatting
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4

set textwidth=0         " Don't wrap words by default
set textwidth=80        " This wraps a line with a break when you reach 80 chars

" smart case-sensitive search
set ignorecase
set smartcase

" longer set options
set diffopt=filler,iwhite                       " keep files synced and ignore whitespace
set timeout timeoutlen=1000 ttimeoutlen=100     " fix slow O inserts
set listchars=tab:>-,nbsp:~,eol:$,trail:-       " set visible characters for tabs, etc
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc,.class

" tab completion for files/bufferss
set wildmode=longest,list
set wildmenu

" LargeFile.vim settings
" don't run syntax and other expensive things on files larger than NUM megs
let g:LargeFile = 100

" mouse setting
set mouse+=a            " enable mouse mode (scrolling, selection, etc)
if &term =~ '^screen'
    " tmux knows the extended mouse mode
    set ttymouse=xterm2
endif

"--------------------
" Misc configurations
"--------------------

set helpfile=$VIMRUNTIME/doc/help.txt

" open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" quicker window movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" save read-only files
command -nargs=0 Sudow w !sudo tee % >/dev/null

"---------------------
" Plugin configuration
"---------------------

" vim-nerdtree-tabs
" Open/close NERDTree Tabs with \t
nmap <silent> <leader>t :NERDTreeTabsToggle<CR>
" To have NERDTree always open on startup
let g:nerdtree_tabs_open_on_console_startup = 0

" vim-color-solarized
" vim can autodetect this based on $TERM (e.g. 'xterm-256color')
" but it can be set to force 256 colors
" set t_Co=256
if &t_Co < 256
    colorscheme default
    set nocursorline " looks bad in this mode
else
    set background=dark
    let g:solarized_termcolors=256 " instead of 16 color with mapping in terminal
    colorscheme solarized
    " customized colors
    highlight SignColumn ctermbg=234
    highlight StatusLine cterm=bold ctermfg=245 ctermbg=235
    highlight StatusLineNC cterm=bold ctermfg=245 ctermbg=235
    let g:NeatStatusLine_color_normal='ctermfg=64 ctermbg=235 cterm=bold'
    let g:NeatStatusLine_color_insert='ctermfg=136 ctermbg=235 cterm=bold'
    let g:NeatStatusLine_color_replace='ctermfg=160 ctermbg=235 cterm=bold'
    let g:NeatStatusLine_color_visual='ctermfg=33 ctermbg=235 cterm=bold'
    let g:NeatStatusLine_color_position='ctermfg=245 ctermbg=235 cterm=bold'
    let g:NeatStatusLine_color_modified='ctermfg=166 ctermbg=235 cterm=bold'
    let g:NeatStatusLine_color_line='ctermfg=61 ctermbg=235 cterm=bold'
    let g:NeatStatusLine_color_filetype='ctermfg=37 ctermbg=235 cterm=bold'
endif

"---------------------
" Local customizations
"---------------------

" local customizations in ~/.vimrc_local
let $LOCALFILE=expand("~/.vimrc_local")
if filereadable($LOCALFILE)
    source $LOCALFILE
endif
