function shrinkpdf() {
    gs -q -dNOPAUSE -dBATCH -dSAFER -sDEVICE=pdfwrite -dEmbedAllFonts=false -dSubsetFonts=true -dDetectDuplicateImages=true -dPDFSETTINGS=/screen -dCompressFonts=true -sOutputFile="${1%.*}_small.pdf" "$1"
}
