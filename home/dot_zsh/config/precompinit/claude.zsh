install_claude_completion() {
    local sha="1ae44eee6ca1e7b4f5998617346d44a4aac62b96"
    local tool="$1"
    local tmpl=${tool/#d/}

    if [[ ! -f ~/.cache/zsh/fns/_$tool ]]; then
    	curl -sSfL https://raw.githubusercontent.com/wbingli/zsh-claudecode-completion/$sha/_claude > ~/.cache/zsh/fns/_$tool
    	zcompile-many ~/.cache/zsh/fns/_$tool
    fi
}

if [[ $commands[claude] ]]; then
    install_claude_completion claude
fi

unset -f install_claude_completion
