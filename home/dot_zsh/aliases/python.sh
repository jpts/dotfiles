alias requirements2poetry="stat pyproject.toml &>/dev/null && grep -a -E '^[^# ]' requirements.txt | sed 's/==/@^/' | sed 's/~=/@~/' | xargs -n 1 poetry add || echo 'poetry not init-ed'"

venv-path() {
  if [ -f .venv ]; then
    echo "$HOME/.virtualenvs/$(cat .venv | tr -d '\r\n')"
  elif [ -f poetry.lock ]; then
    #echo "~/.cache/pypoetry/virtualenvs/..."
    echo "$(poetry env list --full-path | cut -d' ' -f1)"
  elif [ -f Pipfile ]; then
    #echo "~/.local/share/virtualenvs/$(basename "$PWD")-zzzzzzzz"
    echo "$(PIPENV_IGNORE_VIRTUALENVS=1 pipenv --venv)"
  else
    echo "Can't find venv"
    exit 1
  fi
}
