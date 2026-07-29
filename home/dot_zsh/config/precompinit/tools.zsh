if [[ $commands[chezmoi] ]]; then
  ensure-completion-cache "chezmoi"
fi

if [[ $commands[zellij] ]]; then
  ensure-completion-cache zellij "setup --generate-completion zsh"
fi
