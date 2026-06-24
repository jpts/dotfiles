# Use colors in coreutils utilities output
#alias ls='ls --color=auto --hyperlink=auto'
alias ls='ls --color=auto'
alias grep='grep --color'
alias egrep='grep -E --color'
alias fgrep='grep -F --color'

# ls
alias ll='ls -Ahl'
alias la='ls -A'

# cd
alias ..='cd ..'
alias ...='..; ..'
alias ....='...; ..'

# vim
alias vimrc='vim ~/.vimrc'

# zsh
alias zshrc='vim ~/.zshrc'
alias zsh-clean='compaudit | xargs chmod g-w -- & echo "Restart zsh to complete"'
alias zsh-profile='ZPROF=1 zsh -i -c exit'

alias diff='diff -Naur --color=auto'
alias parallel='parallel --will-cite'
alias time="command time -f '%Us user %Ss system %P cpu %E total'"

alias ssh='TERM=xterm-256color ssh' #fix most remote systems

# kitty
alias icat='kitty +kitten icat'

alias sign-kmod='/usr/src/kernels/`uname -r`/scripts/sign-file'
