for f in glob('~/.config/nvim/config.d/*.vim', 0, 1)
    exe 'source' fnameescape(f)
endfor

" theme
let g:codedark_modern=1
let g:codedark_transparent=1
colorscheme codedark

inoremap <silent><expr> <c-space> coc#refresh()

" nvim jump to the last position when reopening a file
au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" nvim undo config
set undodir=$HOME/.local/share/nvim/undodir
set undofile
