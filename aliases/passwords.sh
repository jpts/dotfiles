alias passgen='pwgen -s -c -y -n 64 && sleep 30 && clear'
alias passphrasegen="shuf -n 3 <(bzcat /data/dumps/dicts/compressed/english.txt.bz2) | tr '\n' '-'"
