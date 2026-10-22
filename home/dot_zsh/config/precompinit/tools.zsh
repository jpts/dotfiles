if [[ $commands[chezmoi] ]]; then
  ensure-completion-cache "chezmoi"
fi

if [[ $commands[zellij] ]]; then
  ensure-completion-cache zellij "setup --generate-completion zsh"
fi

if [[ $commands[fly] ]]; then
  ensure-completion-cache fly
fi

if [[ $commands[yq] ]]; then
  ensure-completion-cache yq
fi
