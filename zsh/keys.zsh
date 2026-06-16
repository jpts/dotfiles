# zsh keybindings
bindkey -v

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^R'   history-incremental-search-backward

bindkey '^ ' autosuggest-accept
#bindkey 'autosuggest-execute

bindkey '^[[H' beginning-of-line  # Home
bindkey '^[[F' end-of-line        # End
bindkey '^[[3~' delete-char       # Del

bindkey "^[[1;5D" backward-word    # Ctl-Left
bindkey "^[[1;5C" forward-word     # Ctl-Right
bindkey "^[[5D" backward-word    # Ctl-Left mac
bindkey "^[[5C" forward-word     # Ctl-Right mac

bindkey '^[[Z' reverse-menu-complete  # Shift-Tab
# commands
#bindkey -s "^[[17~" "^usudo !!^M"
