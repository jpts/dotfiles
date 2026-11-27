# dot


## Install

```
curl https://raw.githubusercontent.com/jpts/dotfiles/refs/heads/main/install_chezmoi.sh -o ./install_chezmoi.sh
chmod +x ./install_chezmoi.sh
./install_chezmoi.sh
~/.local/bin/chezmoi --source ~/git/github/dotfiles-public init https://github.com/jpts/dotfiles.git --apply
```
or
```
curl https://raw.githubusercontent.com/jpts/dotfiles/refs/heads/main/install_chezmoi.sh | bash && ~/.local/bin/chezmoi --source ~/git/github/dotfiles-public init https://github.com/jpts/dotfiles.git --apply
```
