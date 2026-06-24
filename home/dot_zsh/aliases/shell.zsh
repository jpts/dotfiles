function gopass() {
    if [[ "$(uname)" != "Linux" ]]; then
        command gopass "$@"
        return
    fi
    disable which
    local BIN=$(which --skip-functions --skip-alias -- gopass)
    if [[ ${commands[gpaste-client]} ]]; then
        gpaste-client stop
        "$BIN" "$@"
        gpaste-client start
    else
        "$BIN" "$@"
    fi
    enable which
}

function joinzoom () {
    echo "Opening https://zoom.us/wc/join/$1?pwd=$2"
    chromium-browser "https://zoom.us/wc/join/$1?pwd=$2" 2>/dev/null
}

function kexec-latest() {
    local INITRAMFS=$(find /boot -maxdepth 1 -name "initramfs*" ! -name "*fallback*" -printf "%T@ %p\n" | sort -rn | awk 'NR==1 {print $2}')
    local VMLINUZ=$(find /boot -maxdepth 1 -name "vmlinuz*" -printf "%T@ %p\n" | sort -rn | awk 'NR==1 {print $2}')
    local BOOTDEV=$(awk '/ \/ / {print $1}' /etc/mtab)
    sudo kexec -l "$VMLINUZ" --append "root=$BOOTDEV" --initrd "$INITRAMFS" || return
    sudo kexec -e
}

function strip-comments() {
     grep -v '^#' "$1" | grep -v '^$'
}

function source-completion-cache() {
    local cmd="$1"
    local args="${@:2}"
    local cdir="$HOME/.cache/zsh/fns/"
    local ccache="$cdir/_$cmd"

    # remove failed fn cache files
    if [[ -e "$ccache" && ! -s "$ccache" ]]; then
        echo "removing failed fn cache file: $ccache" >&2
        rm "$ccache"
    fi

    # Only run if older than 48h
    if [[ (! -e "$ccache" || -f "$ccache"(#qN.mh+48)) ]]; then
        CMD=$(builtin whence "$cmd")
        mkdir -p "$cdir"

        # use default arguments if not specified
        if [[ "$#" -eq 1 ]]; then
            builtin eval "$CMD completion zsh" > "$ccache"
        else
            #builtin eval "$*" > "$ccache"
            builtin eval "$CMD $args" > "$ccache"
        fi

        ## fix unnecessary bashcompinit calls
        ## matches: autoload -U +X bashcompinit && bashcompinit
        sed -i.bak -e 's/autoload .* bashcompinit//g' "${ccache}"
        rm -f "${ccache}.bak"

        ## remove unsued debug statements
        perl -0777 -i -pe "s/__${cmd}_debug\(\).*?}\n//smg" "$ccache"
        perl -0777 -i -pe "s/.*__${cmd}_debug.*//g" "$ccache"

        ## remove comments & empty lines
        sed -i.bak -e '2,${ /^[[:space:]]*#.*$/d; }' -e '2,${ /^[[:space:]]*$/d; }' "${ccache}"
        rm -f "${ccache}.bak"
    fi

    zcompile-many "$ccache"

    source "$ccache"
}

alias dotenv-load="set -o allexport; source .env; set +o allexport"
