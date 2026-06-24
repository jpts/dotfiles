function pip(){
    local PIP=$(command which --skip-functions --skip-alias -- pip)
    if [ $1 = "search" ]; then
        pip_search "$2"
    else
        "$PIP" "$@"
    fi
}
alias requirements2poetry="stat pyproject.toml &>/dev/null && grep -a -E '^[^# ]' requirements.txt | sed 's/==/@^/' | sed 's/~=/@~/' | xargs -n 1 poetry add || echo 'poetry not init-ed'"
