function html2pdf() {
    html-pdf "$1" "${1:r}.pdf"
}

function doc2pdf() {
    oowriter --convert-to pdf "$@" 2>/dev/null
}

function md2pdf() {
    markdown-pdf -b 2cm "$@" 2>/dev/null
}

function pdfcount() {
    pdftotext "$1" - | grep "^[A-Za-z]" | wc -w
}

function tex2plain() {
  pandoc "$HOME/git/vuln-writeups/gitlib-master/fs.tex" <(tail -n+4 "$1") -f latex -t plain
}

function tex2r2r() {
  pandoc "$HOME/git/vuln-writeups/gitlib-master/fs.tex" <(tail -n+4 "$1") -f latex -t textile
}
alias pdf2bw='convert -quality 100 -density 400 -fill white -fuzz 80% -auto-level -depth 4 -threshold 70% -colorspace Gray'
alias pdf2bw2='convert -quality 100 -density 400 -level 25% -auto-gamma -depth 4 -colorspace Gray'
