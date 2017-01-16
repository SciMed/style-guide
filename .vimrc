" Use Vim settings, rather then Vi settings. This setting must be as early as
" possible, as it has side effects.
set nocompatible

" Leader
let mapleader = " "

" Switch between the last two files
nnoremap <leader><leader> <c-^>

" Set undo file to allow undoing even after closing and reopening vim
silent !mkdir -p ~/.vim/undo > /dev/null 2>&1
set undofile
set undodir=~/.vim/undo

" Softtabs, 2 spaces
set softtabstop=2
set tabstop=2
set shiftwidth=2
set shiftround
set expandtab
set backspace=indent,eol,start " Backspace deletes like most programs in insert mode

" Numbers
set number
set numberwidth=5

" General preferences
set nobackup
set nowritebackup
set noswapfile        " http://robots.thoughtbot.com/post/18739402579/global-gitignore#comment-458413287
set history=50
set ruler             " show the cursor position all the time
set showcmd           " display incomplete commands
set incsearch         " do incremental searching
set hlsearch          " highlight search results
set laststatus=2      " Always display the status line
set autowrite         " Automatically :write before running commands
set lazyredraw        " Only redraw screen when necessary
set diffopt+=vertical " Always use vertical diffs
set colorcolumn=80    " highlights the 80th column
set cursorline        " highlights the line the cursor is on
set cursorcolumn      " highlights the column the cursor is in

" Open new split panes to right and bottom
set splitbelow
set splitright

" Quicker window movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

set background=dark
colorscheme delek

" Show all matching options for file completion
set wildmode=list:longest,list:full

" Display extra whitespace and visually differentiate between spaces/tabs
set list listchars=tab:»·,trail:·

if has('autocmd')
  filetype plugin indent on
endif

" Switch syntax highlighting on, when the terminal has colors
if has('syntax') && !exists('g:syntax_on')
  syntax enable
endif

augroup vimrcEx
  autocmd!

  " When editing a file, always jump to the last known cursor position.
  " Don't do it for commit messages, when the position is invalid, or when
  " inside an event handler (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  " Set syntax highlighting for specific file types
  autocmd BufRead,BufNewFile Appraisals set filetype=ruby
  autocmd BufRead,BufNewFile *.md set filetype=markdown

  " Enable spellchecking for Markdown
  autocmd FileType markdown setlocal spell

  " Automatically wrap at 80 characters for Markdown
  autocmd BufRead,BufNewFile *.md setlocal textwidth=80

  " Allow stylesheets to autocomplete hyphenated words
  autocmd FileType css,scss,sass setlocal iskeyword+=-

  autocmd BufWritePre * :%s/\s\+$//e
augroup END

" Tab completion
" Will insert tab at beginning of line,
" Will use completion if not at beginning
function! InsertTabWrapper()
  let col = col('.') - 1
  if !col || getline('.')[col - 1] !~ '\k'
    return "\<tab>"
  else
    return "\<c-p>"
  endif
endfunction
inoremap <Tab> <c-r>=InsertTabWrapper()<cr>
inoremap <S-Tab> <c-n>

" Run commands that require an interactive shell
nnoremap <Leader>r :RunInInteractiveShell<space>

" Local config
if filereadable($HOME . "/.vimrc.local")
  source ~/.vimrc.local
endif
