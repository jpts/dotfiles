{{- if eq .osid "linux-fedora" }}
function wl-type() {
    if [ -n "$1" ]; then
        sudo ydotool type --delay 10 --key-delay 2 "$1" 2>/dev/null
    else
        sudo ydotool type --delay 10 --key-delay 2 --file - 2>/dev/null
    fi
}

alias runXwithroot='xhost +local:root &&'
{{- end }}
