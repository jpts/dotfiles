" Standard options
syntax on
filetype plugin indent on
set encoding=utf-8

" set autoindent
set indentexpr &
set nu
set mouse=

" allow modelines
set modeline
set modelines=2

" default indentation
set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4

" associate filetypes
au BufNewFile,BufRead *.md set filetype=markdown
au BufNewFile,BufRead *.nmap set filetype=nmap
au BufNewFile,BufRead *.md setlocal spell spelllang=en_gb
au BufNewFile,BufRead *.txt setlocal spell spelllang=en_gb
au BufNewFile,BufRead Dockerfile* set filetype=dockerfile
au BufNewFile,BufRead Containerfile* set filetype=dockerfile
au BufNewFile,BufRead *.gotmpl set filetype=gohtmltmpl
au BufNewFile,BufRead *.yaml.* set filetype=yaml
au BufNewFile,BufRead .yamllint set filetype=yaml

" read line 1
if getline(1) =~ '^#!.*bash.*'
  syntax on
  setfiletype bash
elseif getline(1) =~ '^#!.*zsh.*'
  syntax on
  setfiletype zsh
elseif getline(1) =~ '^Starting Nmap.*'
  syntax on
  setfiletype nmap
elseif getline(1) =~ '^FROM '
  syntax on
  setfiletype dockerfile
endif

" show whitespace for languages that care
highlight BadWhitespace ctermbg=red guibg=red
au ColorScheme * highlight BadWhitespace ctermbg=red guibg=red
" trailing whitespace
au BufNewFile,BufRead *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/
" trailing whitespace before a tab
au BufNewFile,BufRead *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$\| \+\ze\t/
" Switch off :match highlighting.
match
