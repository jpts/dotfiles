if [[ $commands[granted] ]]; then
    alias assume="source $(builtin command -v assume)"
    export GRANTED_ALIAS_CONFIGURED='true'
fi

if [[ $commands[dgranted] ]]; then
    alias dassume="source $(builtin command -v dassume)"
    export GRANTED_ALIAS_CONFIGURED='true'
fi
