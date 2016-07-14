

""""""""""""""""""""""""""""""""""""""""""""""""
" macros used when convering my texts to markdown
" http://stackoverflow.com/questions/2024443/saving-vim-macros
" http://vim.wikia.com/wiki/Macros#Saving_a_macro
" http://stackoverflow.com/questions/1585449/insert-the-carriage-return-character-in-vim
""""""""""""""""""""""""""""""""""""""""""""""""
" strip any leading '- ' bullet indicators
let @s = '0:s/^\(\s*\)- /\1 /0'
" replace 4 spaces with a # (heading level)
let @h = '0:s/^\(#*\)    /\1#/0'
" convert zim heading (uppercased sentence with colon at the end) to markdown heading
let @i = '0:s/^\(.*\):$/\1/0v$u0~0i## jj0'
" tabulate???? (^I replaced to real tab... not sure if it works)
let @t = '0lllllllli	jj0j'

" open fenced code block
let @f = '0i```bashjj'
" close fenced code block
let @g = '0i```jj'
" fence code block a single line
let @u = '0@f0j@g0'

" encapsulate/protect URL
let @e = '0i<jjA>jj0j'
" single line code fence
let @c = '0dwi`jjA`jj0'
" bold text
let @b = '0i**jjA**jj0j'
" quote line by using double quotes and italicizing the text
let @q = ':s/^\(\s*\)\(- \)*\(.*\)$/\1\2*"\3"*/g0:nohlsearch0'


""""""""""""""""""""""""""""""""""""""""""""""""
" Indenting
""""""""""""""""""""""""""""""""""""""""""""""""
"Default to autoindenting of C like languages
"This is overridden per filetype below
set noautoindent smartindent

"The rest deal with whitespace handling and
"mainly make sure hardtabs are never entered
"as their interpretation is too non standard in my experience
set softtabstop=4
" Note if you don't set expandtab, vi will automatically merge
" runs of more than tabstop spaces into hardtabs. Clever but
" not what I usually want.
set expandtab
set shiftwidth=4
set shiftround
set nojoinspaces

" if python indenting gets borked:
" http://stackoverflow.com/questions/234564/tab-key-4-spaces-and-auto-indent-after-curly-braces-in-vim
"set expandtab tabstop=4 shiftwidth=4 ai
autocmd! FileType python set expandtab tabstop=4 shiftwidth=4 nosmartindent autoindent

" set 2 space indenting for some filetypes
autocmd Filetype ruby,yaml setlocal ts=2 sts=2 sw=2


""""""""""""""""""""""""""""""""""""""""""""""""
" other options
""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible
set ruler
set laststatus=2
set showcmd
set showmode
set number
set incsearch
set ignorecase
set smartcase
set hlsearch

" leader keys
let mapleader = ','
let maplocalleader = ' '

" spell check toggle
map <F5> :setlocal spell! spelllang=en_us<CR>

" shift+J is for joining a line, so we map ctrl+j for breaking (cracking) a line
nnoremap <C-J> i<CR><Esc>k$hl

" esc mapping using jj. paste needs to be disabled, so we had a toggle for F2
set nopaste
inoremap jj <esc>l
inoremap jk <esc>
set pastetoggle=<F2>

" search for text visually selected
vnoremap <Bslash> y/<C-r>=substitute(@",'/','\\/','g')<CR><CR>

" clear the search buffer by typing ,/ (, is used instead of : because vim shannaningas will cause an annoying delay)
nmap <silent> ,/ :nohlsearch<CR>

" vim allows advancing \t characters with ctrl+t (tab) and to recede/detab with ctrl+d (detabulate), but this doesn't always works.
" So we'll map shift+tab to deleting the previous 4 characters.
" This is not perfect since we really only want to delete those chars if they are whitespace.
" But provides something different from ctrl+d which doesn't always works as intended.
" TODO: bind a function this mapping that only deletes N whitespace characters as to be tab aligned
imap <S-tab> <Esc>xxxxa

" increase max num of tabs (useful for vim -p ...)
set tabpagemax=100
" cycle through buffers and tabs
let g:mycycle = 0
function! MyCycleMode()
    if g:mycycle == 0
        let g:mycycle = 1
        " efficient way to cycle through tabs:
        nnoremap <silent> <C-p> :tabprevious<CR>
        nnoremap <silent> <C-n> :tabnext<CR>
        nnoremap <silent> <C-c> :tabclose<CR>
        echom 'will cycle over tabs'
    else
        let g:mycycle = 0
        " efficient way to cycle through buffers:
        nnoremap <silent> <C-p> :bprevious<CR>
        nnoremap <silent> <C-n> :bnext<CR>
        nnoremap <silent> <C-c> :bp<bar>sp<bar>bn<bar>bd<CR>
        echom 'will cycle over buffers'
    endif
endfunction
nnoremap <F4> :call MyCycleMode()<CR>
silent call MyCycleMode()

"I disabled this pseudo ctrl+tab since it isn't that useful, and was
"overriding a pre-defined shortcut
"let g:lasttab = 1
"nnoremap <silent> <C-i> :exe "tabn ".g:lasttab<CR>
"auto TabLeave * let g:lasttab = tabpagenr()

" shortcuts for moving a tab to the left or right:
map <silent> <C-h> :execute 'silent! tabmove ' . (tabpagenr()-2) <CR>
map <silent> <C-l> :execute 'silent! tabmove ' . tabpagenr() <CR>







""""""""""""""""""""""""""""""""""""""""""""""""
" plugins
""""""""""""""""""""""""""""""""""""""""""""""""

" pathogen for plugin management
execute pathogen#infect()
syntax on
filetype plugin indent on
set sessionoptions-=options

" nerdcommenter
filetype plugin on
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1

" nerdtree
let NERDTreeShowHidden = 1
"let g:NERDTreeDirArrows = 0 " only required if not in an UTF locale system
"autocmd vimenter * NERDTree " automatically open the tree pane
map <C-T> :NERDTreeToggle<CR>

" source code completion
set omnifunc=syntaxcomplete#Complete
autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1
autocmd FileType ruby,eruby let g:rubycomplete_rails = 1

" commenting this block because it breaks vim-markdown
" markdown
"augroup markdown
"    au!
"    au BufNewFile,BufRead *.md,*.markdown setlocal filetype=ghmarkdown
"augroup END

" vim-markdown
let g:vim_markdown_frontmatter = 1
let g:vim_markdown_folding_disabled = 1
"let g:vim_markdown_folding_level = 6
let g:vim_markdown_toc_autofit = 1
let g:vim_markdown_emphasis_multiline = 0
augroup bash
    au!
    au BufNewFile,BufRead *.sh,*.bash setlocal filetype=sh
augroup END


" ack
let g:ackhighlight = 1
let g:ackpreview = 1
function! MyAk(...)
    let restab = '[search results]'
    let switchbufbak=&switchbuf
    set switchbuf=useopen,usetab,newtab
    let restabidx = 0

   " loop through each tab page
    for t in range(tabpagenr('$'))
        let bc = len(tabpagebuflist(t + 1))  "counter to avoid last ' '
        let n = ''  "temp string for buffer names while we loop and check buftype
        " loop through each buffer in a tab
        for b in tabpagebuflist(t + 1)
            let n .= pathshorten(bufname(b))
            " echom n  " note: this causes problems, as it will ask for pressing enter on tab creation, and other things
            if n == restab
                let restabidx = t + 1
           endif
        endfor
    endfor
    if restabidx > 0
        execute 'tabclose' restabidx
    endif
    execute 'tabedit' fnameescape(restab)
    " better to use fnameescape(restab) than escape(restab, ' ')
"    tabm 0
"    tabfirst

    let shellpipe_bak=&shellpipe
    let &shellpipe="&>"
    silent execute 'Ack! ' . join(a:000)
    let &shellpipe=shellpipe_bak

    let &switchbuf=switchbufbak
    unlet switchbufbak
endfunction

command! -nargs=* Ak call MyAk(<f-args>)




""""""""""""""""""""""""""""""""""""""""""""""""
" Syntax highlighting
""""""""""""""""""""""""""""""""""""""""""""""""

if v:version >= 700
    "The following are a bit slow
    "for me to enable by default
    "set cursorline   "highlight current line
    "set cursorcolumn "highlight current column
endif

"Syntax highlighting if appropriate
if &t_Co > 2 || has("gui_running")
    syntax on
    set hlsearch
    set incsearch "For fast terminals can highlight search string as you type
endif

if &diff
    "I'm only interested in diff colours
    syntax off
endif

"syntax highlight shell scripts as per POSIX,
"not the original Bourne shell which very few use
let g:is_posix = 1

"flag problematic whitespace (trailing and spaces before tabs)
"Note you get the same by doing let c_space_errors=1 but
"this rule really applys to everything.
highlight RedundantSpaces term=standout ctermbg=red guibg=red
match RedundantSpaces /\s\+$\| \+\ze\t/ "\ze sets end of match so only spaces highlighted
"use :set list! to toggle visible whitespace on/off
set listchars=tab:>-,trail:.,extends:>


highlight Comment ctermfg=gray





"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" tabs (show tabline under open tab)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set showtabline=2

" ATTEMPT 4, JonSkanes comment at http://vim.wikia.com/wiki/Show_tab_number_in_your_tab_line
set showtabline=2  " 0, 1 or 2; when to use a tab pages line
set tabline=%!MyTabLine()  " custom tab pages line
function MyTabLine()
  let s = '' " complete tabline goes here
  " loop through each tab page
  for t in range(tabpagenr('$'))
    " set highlight for tab number and &modified
    let s .= '%#TabLineSel#'
    " set the tab page number (for mouse clicks)
    let s .= '%' . (t + 1) . 'T'
    " set page number string
    let s .= t + 1 . ':'
    " get buffer names and statuses
    let n = ''  "temp string for buffer names while we loop and check buftype
    let m = 0  " &modified counter
    let bc = len(tabpagebuflist(t + 1))  "counter to avoid last ' '
    " loop through each buffer in a tab
    for b in tabpagebuflist(t + 1)
      " buffer types: quickfix gets a [Q], help gets [H]{base fname}
      " others get 1dir/2dir/3dir/fname shortened to 1/2/3/fname
      if getbufvar( b, "&buftype" ) == 'help'
        let n .= '[H]' . fnamemodify( bufname(b), ':t:s/.txt$//' )
      elseif getbufvar( b, "&buftype" ) == 'quickfix'
        let n .= '[Q]'
      else
        let n .= pathshorten(bufname(b))
      endif
      " check and ++ tab's &modified count
      if getbufvar( b, "&modified" )
        let m += 1
      endif
      " no final ' ' added...formatting looks better done later
      if bc > 1
        let n .= ' '
      endif
      let bc -= 1
    endfor
    " add modified label [n+] where n pages in tab are modified
    if m > 0
      let s .= '[' . m . '+]'
    endif
    " select the highlighting for the buffer names
    " my default highlighting only underlines the active tab
    " buffer names.
    if t + 1 == tabpagenr()
      let s .= '%#TabLine#'
    else
      let s .= '%#TabLineSel#'
    endif
    " add buffer names
    let s .= n
    " switch to no underlining and add final space to buffer list
    let s .= '%#TabLineSel#' . ' '
  endfor
  " after the last tab fill with TabLineFill and reset tab page nr
  let s .= '%#TabLineFill#%T'
  " right-align the label to close the current tab page
  if tabpagenr('$') > 1
    let s .= '%=%#TabLineFill#%999Xclose'
  endif
  return s
endfunction


