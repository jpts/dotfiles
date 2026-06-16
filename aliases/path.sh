function pathmunge() {
    dir="${1%/}"
    case ":${PATH}:" in
    *:"$dir":*)
        ;;
    *)
        if [ "$2" = "after" ]; then
            PATH=$PATH:$dir
        else
            PATH=$dir:$PATH
        fi
    esac
}

function pathdedupe() {
    local NEWPATH
    if [ -n "$ZSH_VERSION" ]; then
        # only valid in zsh
        DIRS=("${(s/:/)PATH}")
    else
        IFS=':' read -ra DIRS <<< "$PATH"
    fi
    for dir in "${DIRS[@]}"; do
        dir="${dir%/}"
        if [[ "$NEWPATH" == "" ]]; then
            NEWPATH="$dir"
        elif [[ ! ":${NEWPATH}:" =~ .*:"$dir":.* ]]; then
            NEWPATH="$NEWPATH:$dir"
        fi
    done
    export PATH="$NEWPATH"
}
