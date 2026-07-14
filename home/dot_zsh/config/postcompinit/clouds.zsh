# detect if gcloud installed
if [[ $commands[gcloud] ]]; then
    source "$ZSH/gcloud.zsh"
fi

# configure completion as per docs
# https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-completion.html
if [[ $commands[aws] ]]; then
    if [[ $commands[aws_completer] ]]; then
      complete -C aws_completer aws
    elif [[ -f /usr/libexec/aws_completer ]]; then
      complete -C /usr/libexec/aws_completer aws
    fi
fi

## azure, use included bash completion
if [[ -f /usr/share/bash-completion/completions/az ]]; then
    source /usr/share/bash-completion/completions/az
fi

if [[ $commands[kubectl] ]]; then
  compdef k=kubectl
fi

if [[ $commands[terraform] ]]; then
  TF=$(builtin command -v terraform)
  complete -o nospace -C "$TF" terraform

  compdef tf=terraform
fi
