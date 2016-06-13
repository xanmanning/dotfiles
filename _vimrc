" ---------------------
"  Xan's ~/.vimrc File
" ---------------------
"
" == Global Settings ==
"

" No Compatible and Tmux Fix
set nocompatible
set t_ut=

" Try using the jellybeans colourscheme
if has('gui_running')
	silent! colorscheme jellybeans
endif

" Dark background
set background=dark

" Make sure we always see an ^M when it is there
set fileformats=unix

" Syntax highlighting on
syntax on

" Filetype plugin
filetype plugin on

" Set terminal title to filename
set title

" Line numbers
set number

" Show matching braces
set showmatch

" Enable WildMenu
set wildmenu

" Enable mouse support
set mouse=a

" Disable folding by default
set nofoldenable

" Fold on indents
set foldmethod=indent

" Maximum folds
set foldnestmax=10

" Level of folds
set foldlevel=1

" Encrypted file cipher
set cm=blowfish

" Set invisible characters
set listchars=tab:>-,trail:.,nbsp:.,extends:>,precedes:<,eol:$

" Variable to get the current file name.
let b:currentfile = expand('%:p')

" Draw a line at 80 columns width
if &t_Co >= 256 && &bg == "dark"
	highlight ColorColumn ctermbg=233 guibg=#202020
elseif &t_Co >= 256 && &bg != "dark"
	highlight ColorColumn ctermbg=230 guibg=#e8e9eb
else
	highlight ColorColumn ctermbg=8
endif
set colorcolumn=80

" Annoy me when I go over 80 columns
highlight OverspillColumn ctermbg=magenta guibg=magenta
call matchadd('OverspillColumn', '\%81v', 100)

" Indenting and shift width
set tabstop=4
set shiftwidth=4

" Expandtabs into spaces
set expandtab

" Set spelling to English. Disable for now.
set nospell
set spelllang=en
set spellsuggest=10

" Always use forward slashes in file paths 
set shellslash

" Don't bug me with error bells and visual bells
set noerrorbells
set novisualbell

" Ignore case when searching by default
set ignorecase

" Make backspace behave nicely
set backspace=indent,eol,start

" Keep plenty of history when editing
set history=200

" Don't listen to modelines in files, they can be bad.
set nomodeline

" Do backups of files.
set backup

" Swapfile handling
" Stop duplicated editing of files
" 	- When swap is newer than file then open read only by default
" 	- When swap file is older than file then delete swap file, continue.
augroup NoSimultaneousEdits
	autocmd!
	autocmd SwapExists * let b:filename = expand('%:p')
	autocmd SwapExists * if getftime(v:swapname) < getftime(b:filename)
		autocmd SwapExists * call delete(v:swapname)
		autocmd SwapExists * let v:swapchoice = 'e'
		autocmd SwapExists * echo "Old swapfile deleted."
	autocmd SwapExists * else
		autocmd SwapExists * let v:swapchoice = 'o'
		autocmd SwapExists * echo "Duplicate edit session (readonly)"
	autocmd SwapExists * endif
	autocmd SwapExists * sleep 2
augroup END

" Function for handling copy
function! ToggleCopy()
	if &mouse == 'a'
		set mouse=
		set nonumber
	else
		set mouse=a
		set number
	endif
endfunction



"
" == OS Specific Config ==
"

" Windows Config
if has('win32')
	" If we have a currentfile set, change directory to
	" $USERPROFILE (Windows Specific)
	if strlen(b:currentfile) < 1 
		chdir $USERPROFILE
	endif
	
	" Backup file path on Windows
	set backupdir=~/vimfiles/backup

	" Temp file path on Windows
	set directory=~/vimfiles/tmp

	" Auto change directory on file opening.
	set autochdir

	" Check for AirLine
	if filereadable(expand("~/vimfiles/autoload/airline.vim"))
		if has('gui_running')
		    set laststatus=2
			let g:airline_theme="jellybeans"
		endif
	endif
else
	" *NIX Config
	if has('unix')
		" If we have a currentfile set, change directory to
		" $HOME (*NIX Specific)
		if strlen(b:currentfile) < 1
			chdir $HOME
		endif

		" Find the system name, ie. Darwin or Linux?
		let s:uname = system("echo -n \"$(uname)\"")

		" Non Mac OS X Config
		if s:uname != "Darwin"
			set autochdir
		endif

		" Backup file path on *NIX
		set backupdir=~/.vim/backup

		" Temp file path on *NIX
		set directory=~/.vim/tmp

		" Check for AirLine
		if filereadable(expand("~/.vim/autoload/airline.vim"))
			if has('gui_running')
			    set laststatus=2
				let g:airline_theme="jellybeans"
			endif
		endif
	endif
endif



"
" == Shortcut Keys ==
"

" Set toggle paste on <F10>
set pastetoggle=<F10>

" Open up explorer with <F8>
" Only in normal mode
nmap <F8> :Explore<CR>

" RXVT compatibility for direction keys
" Insert mode.
imap OA <up>
imap OB <down>
imap OC <right>
imap OD <left>

" Mapping of Copy, Paste and Select All
" ^c ^v ^a
map <C-c> "+y
map <C-v> "+p
map <C-a> ggVG
imap <C-a> <ESC>ggVG
imap <C-v> <ESC>"+pa

" Save shortcut (^s)
inoremap <C-s> <ESC>:w<CR>a
nnoremap <C-s> :w<CR>

" Toggle copy on <F9>
" Disables Line Numbering and Mouse
if !has('gui_running')
	map <F9> :call ToggleCopy()<CR>
endif



"
" == GUI Settings ==
"
if has('gui_running')
	" Highlight cursor column
	set cursorcolumn

	" Highlight cursor line
	set cursorline

	" Set the default size of the editor
	set lines=24 columns=88

	" Remove menus
	set guioptions-=m

	" Remove toolbar
	set guioptions-=T

	" Remove scrollbar
	set guioptions-=r

	" Windows GUI needs a good font, Hack FTW! Else Consolas.
	if has('win32')
		silent! set guifont=Hack
		if &guifont != 'Hack'
			set guifont=Consolas
		endif
	endif

	" Auto and Smart Indenting on.
	set autoindent
	set smartindent
	filetype indent on
endif

