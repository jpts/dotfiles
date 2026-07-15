if [[ $commands[helm] ]]; then
    ensure-completion-cache "helm"
fi

if [[ $commands[crane] ]]; then
    ensure-completion-cache "crane"
fi

if [[ $commands[opa] ]]; then
    ensure-completion-cache "opa"
fi
