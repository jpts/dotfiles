function git-amend-name() {
    git rebase -i "$1" -x "git commit --amend --reset-author -CHEAD --no-edit"
}

function github-checkout-pr() {
    set -uo pipefail
    if (( $# > 2 )); then
        >&2 echo "usage: $0 ID PR-NAME"
        return
    fi
    ID=${1}
    REFNAME=$(gh pr view "$ID" --json headRefName --jq '.headRefName')
    NAME=${2-$REFNAME}
    REMOTE=$(git config --get branch.master.remote || git config --get branch.main.remote)
    git fetch "$REMOTE" "pull/$ID/head:$NAME"
    git checkout "$NAME"
}
alias ghi='git hist'
alias gpl='git pull'
alias gpr='git pull --rebase'
alias gpp='git pull --rebase && git push'
alias ga='git add'
alias gpff='git pull --ff-only'

alias gf='git fetch'
alias gb='git branch'
alias gc='git commit'
alias gca='git commit --amend'
alias gd='git diff --color-words'
alias gst='git status'
alias gl='git log --oneline --decorate'
alias gsl='git stash list'
alias gss='git stash save'

alias glog='git log --pretty=format:"%h - %cn - %s" -10'
alias glg='git log --graph --oneline --all'

alias git-current-branch="git branch | awk '/*/ {print \$2}'"
