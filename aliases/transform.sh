hex2ascii() {
   for c in $(echo -n "$1" | sed "s/\(..\)/\1 /g"); do echo -n "\x$c"; done
   echo
}

dec2ascii() {
   for c in $(echo -n "$1" | sed "s/\(..\)/\1 /g"); do printf \\$(printf "%o" $c); done
   echo
}

alias jwtdecode="jq -R 'split(\".\") | .[0,1] | gsub(\"-\";\"+\") | gsub(\"_\";\"/\") | @base64d | fromjson'"

urldecode() {
  python3 -c 'import sys, urllib.parse as ul; u = sys.argv[1] if sys.argv[1] != "" else sys.stdin.readline(); print(ul.unquote_plus(u))' "$1"
}
alias rot13="tr '[A-Za-z]' '[N-ZA-Mn-za-m]'"
alias atbash="tr '[a-zA-Z]' 'zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA'"
alias toupper="tr '[a-z]' '[A-Z]'"
alias tolower="tr '[A-Z]' '[a-z]'"

alias jsoncommafix=$'perl -0777 -pe \'s/",\n([ \t\b]*)\]/"\\n\\1]/msg\' '
alias escapedoublequotes=$'perl -0777 -pe \'s|"|\\"|msg\' '
