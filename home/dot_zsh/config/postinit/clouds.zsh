## needs to be run after compinit, because bashcompinit??

# detect if gcloud installed
if [[ $commands[gcloud] ]]; then
    source "$ZSH/gcloud.zsh"
    alias gcloud='TERM=xterm-256color gcloud'
fi

# configure completion as per docs
# https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-completion.html
if [[ $commands[aws] ]]; then
    complete -C aws_completer aws
fi

## azure, use included bash completion
if [[ -f /usr/share/bash-completion/completions/az ]]; then
    source /usr/share/bash-completion/completions/az
fi

if [[ $commands[kubectl] ]]; then
  # needs a manual load for some reason
  source-completion-cache "kubectl"

  compdef k=kubectl
fi

if [[ $commands[terraform] ]]; then
  TF=$(builtin command -v terraform)
  complete -o nospace -C "$TF" terraform

  compdef tf=terraform
fi

if [[ $commands[helm] ]]; then
    source-completion-cache "helm"
fi
