
install_granted_completion() {
    local sha="7d9d3b796c381f59e21316135b773b8589a4a130"
    local tool="$1"
    local tmpl=${tool/#d/}

    if [[ ! -f ~/.cache/zsh/fns/_$tool ]]; then
	curl -sSfL https://raw.githubusercontent.com/fwdcloudsec/granted/$sha/pkg/granted/templates/zsh_autocomplete_$tmpl.tmpl | sed -e "s/{{ .Program }}/$tool/" > ~/.cache/zsh/fns/_$tool
	zcompile-many ~/.cache/zsh/fns/_$tool
    fi
}

if [[ $commands[granted] ]]; then
    alias assume="source $(whence -p assume)"
    export GRANTED_ALIAS_CONFIGURED="true"

    install_granted_completion granted
    install_granted_completion assume
fi

if [[ $commands[dgranted] ]]; then
    alias dassume="source $(whence -p dassume)"
    export GRANTED_ALIAS_CONFIGURED="true"

    install_granted_completion dgranted
    install_granted_completion dassume
fi
unset -f install_granted_completion
