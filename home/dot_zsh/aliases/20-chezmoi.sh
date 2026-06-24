alias chezmoi-public='chezmoi --source ~/git/github/dotfiles-public --config ~/.config/chezmoi/chezmoi-public.yaml'

function chezmoi-all() {
  chezmoi-public "$@"
  if alias chezmoi-private; then
    chezmoi-private "$@"
  fi
}
