set nocompatible
set backspace=2
set laststatus=2
set tabstop=3
set shiftwidth=3
set nowrap
set backup
set writebackup
set backupdir=~/MISC/backups,/tmp,.
set directory=/hostname/malfetto/swap_files,~/MISC/swap_files/.,~/tmp,/var/tmp,/tmp
set number
set report=0
set autoread
set incsearch
set hlsearch
set mouse=a
set ttymouse=xterm2
set expandtab " I like to insert tabs, but SIG asked for spaces ( I'm crying on the inside )
set hidden
set wildmenu
set wildmode=longest,list,full "same as bash
set ww=h,l,b,<,>,[,]
set listchars=tab:\|\ ,extends:>,precedes:< "These only show when 'list' is set
set list
set showcmd
set cinoptions=l1,i-s "Changes the switch statement indenting,initializer lists and template class braces align better
set matchpairs+=<:>
set shellcmdflag=-lc "Make my shell be a login shell
set cursorline
set spelllang=en_us
set clipboard=unnamed,autoselect "Used to also have ,exclude:cons\|linux
set splitright
set shm=at
set ignorecase
set encoding=utf-8

"Paste mode toggling 
"I stopped using insert since my chromeos doesn't have an insert mode mapping
"Also, chromeos C-t and C-n are bound in the browser window
set pastetoggle=<C-e>
map <C-e> :set paste!<CR>
imap <C-e> <C-o>:set paste!<CR>

"Useful later rather than dealing with logname/username
"-------------------------------------------------------
let user = $USERNAME
if exists("$USER")
   let user = $USER
endif
if exists("$LOGNAME")
   let user = $LOGNAME
endif
 
"----------------
"Vundle settings
"----------------
filetype off "required
let g:vundle_default_git_proto = 'http'
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
"let Vundle manage Vundle required!
Bundle 'gmarik/vundle'
 
"My bundles ( powerline is currently the old deprecated one that works )
"L9 is a dependency of FuzzyFinder
"-----------
"Colorschemes
"------------
Bundle 'desert-warm-256'
Bundle 'two2tango'
Bundle 'wombat256.vim'
Bundle 'Diablo3'

"Bundles from vim.org
"--------------------
Bundle 'a.vim'
Bundle 'pylint.vim'
Bundle 'tslime.vim'
Bundle 'taglist.vim'
Bundle 'TaskList.vim'

"Bundles from designed for Vundle or pathogen
"--------------------------------------------
Bundle 'Tagbar'
Bundle 'FuzzyFinder'
Bundle 'L9'
Bundle 'UltiSnips'

"Bundles from GitHub
"-------------------
"Bundle 'Lokaltog/powerline'
Bundle 'Lokaltog/vim-powerline'
Bundle 'ervandew/supertab'
Bundle 'fholgado/minibufexpl.vim'
Bundle 'scrooloose/nerdtree'
 
"My Bundle of settings
"---------------------
Bundle 'krismalfettone/vim-extras'

filetype plugin indent on "required
 
"--------------------
"End Vundle settings
"--------------------
 
"Syntax Highlighting, terminal colors, colorschemes, etc...
"Purposely done after Vundle
"-----------------------------------------------------------
syntax on
set t_Co=256
silent! colorscheme wombat256mod
if !exists("g:colors_name") || g:colors_name != "wombat256mod"
   colorscheme torte
endif
 
 
"Random key mappings
"--------------------
map <Leader>q :qa<CR>
nmap ,v :e ~/.vimrc<CR>
nmap ,s :source ~/.vimrc<CR>
 
"Make buffer / window switching easier
"--------------------------------------
if user == "malfetto"
   nmap <C-n> :MBEbn<cr>
   nmap <C-p> :MBEbp<cr>
else
   nmap <C-n> :bn<cr>
   nmap <C-p> :bp<cr>
endif
 
"Window switching and line movements when wrap is on
"----------------------------------------------------
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-h> <C-w>h
 
"Make line movements when wrap is on more intuitive
"----------------------------------------------------
nnoremap k gk
nnoremap j gj
nnoremap gk k
nnoremap gj j
 
"Search related
"---------------
nmap <Leader>f :%s/\<<c-r>=expand("<cword>")<cr>\>/
nmap <Leader>F :%s//
map <silent> <Leader><Leader> :nohlsearch<cr>
 
"Quick fix window settings window ( couldn't get alt to work normally )
"-----------------------------------------------------------------------
nmap :cw :botright cw
map n :cn<cr>
map p :cp<cr>
 
"Spell Checking
"---------------
map <Leader>s :setlocal spell!<CR>
 
"Underline the current line with dashes
"---------------------------------------
map <Leader>U Yp:s/./-/g<CR>:let @/=""<CR>
 
"Switch to the current directory of the file
"--------------------------------------------
map <Leader>c :exec("cd " . expand("%:p:h"))<CR>
 
"Exit if quickfix is the last window
"------------------------------------
function! MyLastWindow()
   if &buftype=="quickfix"
      " if this window is last on screen quit without warning
      if winbufnr(2) == -1
         quit!
      endif
   endif
endfunction
 
function! CreateNormalGateName()
   "Get the full path from Source with '/', '.', '-' replaced by _
   let fullpath = expand("%:p")
   "let tmp = substitute(fullpath,".*Source/","","")
   let tmp = substitute(fullpath,".*/MD/","MD/","")
   let tmp = substitute(tmp,"\\.","_","g")
   let tmp = substitute(tmp,"/","_","g")
   let tmp = substitute(tmp,"-","_","g")
   return toupper(tmp)
endfunction
"
"Adds the #define to protect h files when h files are created.
"This is overridden in in local vimrc for work
function! GetIncludeGuardName()
   let includeguard = CreateNormalGateName()
   return includeguard
endfunction
 
"Adds the #define to protect h files when h files are created.
function! InsertIncludeGuard()
   let includeguard = GetIncludeGuardName()
   execute "normal i#ifndef " . includeguard
   execute "normal o#define " . includeguard
   execute "normal Go#endif /* " . includeguard . " */"
   normal kk
endfunction

function! UpdateGatesFunction()
   "Save the current cursor posistion
   let save_cursor = getpos(".")
   let search_flags = "cnw"
   "We have to start at the top and hope they made the include gates the first
   "#ifndef in the file
   normal gg
   let opening_gate_search_str = "^\\(\\s*\\)#ifndef\\(\\s\\+\\)\\(\\S\\+\\)\\(.*\\)$"
   let opening_gate_ln = search(opening_gate_search_str,search_flags)
   if opening_gate_ln == 0
      echo "Could not find opening gate"
      return
   endif
   
   "Get the gate name
   let opening_gate = getline(opening_gate_ln)
   let match_list = matchlist(opening_gate,opening_gate_search_str)
   let gate_name = match_list[3]

   "Find the define for the gate
   let define_search_str = "^\\(\\s*\\)#define\\(\\s\\+\\)\\(" . gate_name . "\\)\\(.*\\)$"
   let gate_define_ln = search(define_search_str,search_flags)
   if gate_define_ln == 0
      echo "Could not find define for gate"
      return
   endif

   "Find the closing endif of the gate, should be the last endif
   normal G
   let endif_search_str = "^\\(\\s*\\)#endif\\(.*\\)$"
   let endif_ln = search(endif_search_str,"b" . search_flags) "Note backwards search here
   if endif_ln == 0
      echo "Could not find the final endif"
      return
   endif

   "For all three lines do a search/replace on the gate_name with the new one
   let gate_search = "\\<" . gate_name . "\\>"
   let new_opening_str = substitute(getline(opening_gate_ln),gate_search,GetIncludeGuardName(),"g")
   let new_defining_str = substitute(getline(gate_define_ln),gate_search,GetIncludeGuardName(),"g")
   let new_endif_str = substitute(getline(endif_ln),gate_search,GetIncludeGuardName(),"g")
   call setline(opening_gate_ln,new_opening_str)
   call setline(gate_define_ln,new_defining_str)
   call setline(endif_ln,new_endif_str)

   "Restore the current cursor posistion
   call setpos('.',save_cursor)
endfunction
command! -nargs=0 UpdateGates :call UpdateGatesFunction()
 
"Utitlity function to fix highlighting when a bufdo command turned it off
"-------------------------------------------------------------------------
function! FixHighlighting()
   let curr = bufname("%")
   let start = 1
   let end = bufnr("$")
   while start <= end
      if bufexists(start)
         execute "buffer " . start
         execute "filetype detect"
      endif
      let start = start + 1
   endwhile
   execute "buffer " . curr
endfunction
command! -nargs=0 FixHighlighting :call FixHighlighting()
 
"Pulses the cursor location for easy locating
"---------------------------------------------
function! PulseCursorLine()
   let current_window = winnr()
 
   setlocal cursorline
   setlocal cursorcolumn
 
   redraw
   sleep 400m
 
   setlocal nocursorline
   setlocal nocursorcolumn
   execute current_window . 'wincmd w'
endfunction
nmap <Space> :call PulseCursorLine()<CR>
 
"Sets the current file writable on linux
"----------------------------------------
command! -nargs=0 SetWritable :!chmod +w %
nmap <Leader>w :SetWritable<CR>
 
if has("autocmd")
   autocmd BufEnter * call MyLastWindow()
   autocmd BufEnter * let &titlestring = "vim<" . user . "@" . hostname() . "> " . expand("%:p")
   autocmd BufNewFile *.{h,hpp} call <SID>InsertIncludeGuard()
   set title titlestring=%<%F%=%l/%L-%P titlelen=70
endif " has("autocmd")
 
"miniBufExplorer Settings
"-------------------------
let g:miniBufExplorerMoreThanOne=1
 
"Tagbar Settings
"-----------------
"let g:tagbar_ctags_bin = "$MY_DIST_BIN/ctags"
"let g:tagbar_left = 1
"let g:tagbar_width = 50
map <Leader>tt :TagbarToggle<CR>
map <Leader>tb :TagbarOpen j<CR>
 
"Taglist Settings
"let g:Tlist_Ctags_Cmd = "$MY_DIST_BIN/ctags"
let g:Tlist_Use_Right_Window = 1
map <Leader>tl :TlistToggle<CR>
 
"FuzzyFinder Settings (I'll delete some of the maps later)
"---------------------
let g:fuf_modesDisable = []
let g:fuf_mrufile_maxItem = 400
let g:fuf_mrucmd_maxItem = 400
let g:fuf_file_exclude = '\v\~$|\.(o|exe|dll|bak|orig|swp|pyc)$|(^|[/\\])\.(hg|git|bzr)($|[/\\])'
"let g:fuf_buffertag_ctagsPath = "$MY_DIST_BIN/ctags"
nnoremap <silent> sj     :FufBuffer<CR>
nnoremap <silent> sk     :FufFileWithCurrentBufferDir<CR>
nnoremap <silent> sK     :FufFileWithFullCwd<CR>
nnoremap <silent> s<C-k> :FufFile<CR>
nnoremap <silent> sl     :FufCoverageFileChange<CR>
nnoremap <silent> sL     :FufCoverageFileChange<CR>
nnoremap <silent> s<C-l> :FufCoverageFileRegister<CR>
nnoremap <silent> sd     :FufDirWithCurrentBufferDir<CR>
nnoremap <silent> sD     :FufDirWithFullCwd<CR>
nnoremap <silent> s<C-d> :FufDir<CR>
nnoremap <silent> sn     :FufMruFile<CR>
nnoremap <silent> sN     :FufMruFileInCwd<CR>
nnoremap <silent> sm     :FufMruCmd<CR>
nnoremap <silent> su     :FufBookmarkFile<CR>
nnoremap <silent> s<C-u> :FufBookmarkFileAdd<CR>
vnoremap <silent> s<C-u> :FufBookmarkFileAddAsSelectedText<CR>
nnoremap <silent> si     :FufBookmarkDir<CR>
nnoremap <silent> s<C-i> :FufBookmarkDirAdd<CR>
nnoremap <silent> st     :FufTag<CR>
nnoremap <silent> sT     :FufTag!<CR>
nnoremap <silent> s<C-]> :FufTagWithCursorWord!<CR>
nnoremap <silent> s,     :FufBufferTag<CR>
nnoremap <silent> s<     :FufBufferTag!<CR>
vnoremap <silent> s,     :FufBufferTagWithSelectedText!<CR>
vnoremap <silent> s<     :FufBufferTagWithSelectedText<CR>
nnoremap <silent> s}     :FufBufferTagWithCursorWord!<CR>
nnoremap <silent> s.     :FufBufferTagAll<CR>
nnoremap <silent> s>     :FufBufferTagAll!<CR>
vnoremap <silent> s.     :FufBufferTagAllWithSelectedText!<CR>
vnoremap <silent> s>     :FufBufferTagAllWithSelectedText<CR>
nnoremap <silent> s]     :FufBufferTagAllWithCursorWord!<CR>
nnoremap <silent> sg     :FufTaggedFile<CR>
nnoremap <silent> sG     :FufTaggedFile!<CR>
nnoremap <silent> so     :FufJumpList<CR>
nnoremap <silent> sp     :FufChangeList<CR>
nnoremap <silent> sq     :FufQuickfix<CR>
nnoremap <silent> sy     :FufLine<CR>
nnoremap <silent> sh     :FufHelp<CR>
nnoremap <silent> se     :FufEditDataFile<CR>
nnoremap <silent> sr     :FufRenewCache<CR>
 
"Tasklist Settings ( TODOs )
"-----------------
map <leader>td <Plug>TaskList
 
"Powerline settings ( really workarounds for newest powerline, i am not using it )
"-------------------
"let g:powerline_loaded=1
"set encoding=utf-8
"python import sys
"python sys.path.append("/home/malfetto/.vim/bundle/powerline")
"set rtp+=/home/malfetto/.vim/bundle/powerline/powerline/bindings/vim
 
"NERDTree Settings
"-----------------
let g:NERDTreeQuitOnOpen=0
let g:NERDTreeShowBookmarks=1
let g:NERDTreeIgnore=['\~$','\.pyc$']
map <leader>nt :NERDTreeFind<CR>
map <leader>NT :NERDTreeToggle<CR>

"MiniBufExpl Settings
"---------------------
let g:miniBufExplModSelTarget = 1
map <Leader>mb :TMiniBufExplorer<cr>

"UltiSnips Settings
"------------------
let g:UltiSnipsDontReverseSearchPath="1" "Make sure their snips are processed before mine
let g:UltiSnipsExpandTrigger="<c-j>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"


"Allow local vimrc settings ( this is to handle work vs. home settings )
"-----------------------------------------------------------------------
let local_vimrc=glob("~/.vimrc.local")
if filereadable(local_vimrc)
   execute "source " . local_vimrc
endif
