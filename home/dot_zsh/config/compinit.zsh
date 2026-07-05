## https://github.com/sorin-ionescu/prezto/blob/master/runcoms/zlogin
## https://gist.github.com/ctechols/ca1035271ad134841284
setopt extendedglob local_options
autoload -Uz compinit
local zcd=${ZDOTDIR:-$HOME}/.zcompdump
local zcdc="$zcd.zwc"

# Compile the completion dump to increase startup speed, if dump is newer or doesn't exist,
# in the background as this is doesn't affect the current session
if [[ (! -e "$zcd" || -f "$zcd"(#qN.m+1) || $(echo $HOME/.cache/zsh/fns/_*(om[1])) -nt "$zcd") ]]; then
      compinit -d "$zcd"
      { rm -f "$zcdc" && zcompile "$zcd" } &!
else
      compinit -C -d "$zcd"
      { [[ ! -f "$zcdc" || "$zcd" -nt "$zcdc" ]] && rm -f "$zcdc" && zcompile "$zcd" } &!
fi

## bashcompinit once here
autoload -Uz bashcompinit
bashcompinit -i
