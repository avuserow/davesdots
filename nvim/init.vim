" ---- General Setup ----
set tabstop=4              " 4 spaces for tabs
set shiftwidth=4           " 4 spaces for indents
set smarttab               " Tab next line based on current line
set expandtab              " Spaces for indentation
set autoindent             " Automatically indent next line
if has('smartindent')
   set smartindent            " Indent next line based on current line
endif
"set linebreak             " Display long lines wrapped at word boundaries
set incsearch              " Enable incremental searching
set hlsearch               " Highlight search matches
set ignorecase             " Ignore case when searching...
set smartcase              " ...except when we don't want it
set infercase              " Attempt to figure out the correct case
set showfulltag            " Show full tags when doing completion
set virtualedit=block      " Only allow virtual editing in block mode
set lazyredraw             " Lazy Redraw (faster macro execution)
set wildmenu               " Menu on completion please
set wildmode=longest,full  " Match the longest substring, complete with first
set wildignore=*.o,*~      " Ignore temp files in wildmenu
set scrolloff=3            " Show 3 lines of context during scrolls
set sidescrolloff=2        " Show 2 columns of context during scrolls
set backspace=2            " Normal backspace behavior
set hidden                 " Allow flipping of buffers without saving
set noerrorbells           " Disable error bells
set visualbell             " Turn visual bell on
set t_vb=                  " Make the visual bell emit nothing
set showcmd                " Show the current command
set undofile               " Use persistent undo
set clipboard=unnamed      " Use system clipboard

set diffopt+=iwhite
set backupcopy=yes

" Display a pretty statusline if we can
if has('title')
   set title
endif
set laststatus=2
set shortmess=atI
if has('statusline')
   set statusline=%<%F\ %r[%{&ff}]%y%m\ %=\ Line\ %l\/%L\ Col:\ %v\ (%P)
endif

set list listchars=tab:»·,trail:·,extends:…,nbsp:‗

if has('mouse')
   " Dont copy the listchars when copying
   set mouse=nvi
endif

colorscheme jellybeans

" tab indents selection
vmap <silent> <Tab> >gv

" shift-tab unindents
vmap <silent> <S-Tab> <gv

" shifted arrows are stupid
inoremap <S-Up> <C-O>gk
noremap  <S-Up> gk
inoremap <S-Down> <C-O>gj
noremap  <S-Down> gj

" Y should yank to EOL
map Y y$

" vK is stupid
" vmap K k

" :W and :Q are annoying
if has('user_commands')
   command! -nargs=0 -bang Q q<bang>
   command! -nargs=0 -bang W w<bang>
   command! -nargs=0 -bang WQ wq<bang>
   command! -nargs=0 -bang Wq wq<bang>
endif

" stolen from auctex.vim
if has('eval')
   fun! EmacsKill()
      if col(".") == strlen(getline(line(".")))+1
         let @" = "\<CR>"
         return "\<Del>"
      else
         return "\<C-O>D"
      endif
   endfun
endif

" some emacs-isms are OK
map! <C-a> <Home>
map  <C-a> <Home>
map! <C-e> <End>
map  <C-e> <End>
imap <C-f> <Right>
imap <C-b> <Left>
map! <M-BS> <C-w>
map  <C-k> d$
if has('eval')
   inoremap <buffer> <C-K> <C-R>=EmacsKill()<CR>
endif

" Alternate bindings for some keys stolen by emacs-isms.
" C-c for increment (think "count") but also easily reached
" C-b for digraphs (important for Raku and foreign languages)
noremap <C-c> <C-a>
nnoremap <C-b> <C-k>
inoremap <C-b> <C-k>

" use <CR> to clear highlight
nnoremap <silent> <CR> :noh<CR><CR>

" Disable q and Q
map q <Nop>
map Q <Nop>

" Space to insert a single letter
nnoremap <silent> <Space> :exec "normal i".getcharstr()."\el"<CR>

" preserve register when pasting, so we can paste the same text multiple times
xnoremap p P

" Python specific stuff
if has('eval')
   let python_highlight_all = 1
   let python_slow_sync = 1
endif

" no module scanning for perl completion
autocmd FileType perl set complete-=i

" javascript default formatting style
autocmd FileType javascript set tabstop=2|set shiftwidth=2|set expandtab

" clang-format
" function! Formatonsave()
"   let l:formatdiff = 1
"   py3f /usr/share/clang/clang-format.py
" endfunction
" autocmd BufWritePre *.c,*.h,*.cc,*.cpp call Formatonsave()

" Speed options
let g:matchparen_insert_timeout=100
set ttimeout
set ttimeoutlen=100
set timeoutlen=3000

" When we open a file, go to the last edit position
autocmd BufWinEnter * silent! normal! g`"zv
