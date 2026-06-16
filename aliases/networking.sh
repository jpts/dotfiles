function isup() {
    ping "$1" -c 1 -W 1 | awk '/packet/ { if($6!="100%") print "Server Up"; else print "Not up" }'
}

function geoip() {
    curl -fsSL -H 'Referer: https://ipinfo.io/' "https://ipinfo.io/widget/demo/$1"
}

function icanhazinternet() {
  DNS=$(grep '^nameserver' /etc/resolv.conf 2>&1 >/dev/null)
  if [ "$?" -ne 0 ]; then
    print "No NS set in resolv.conf"
    return
  fi
  RESOLV=$(nslookup -timeout=1 google.com 2>&1 >/dev/null)
  if [ "$?" -ne 0 ]; then
    print "NS does not work"
    return
  fi
  CODE=$(curl --connect-timeout 1 -sL --head -o /tmp/curl_out -w "%{http_code}" http://clients3.google.com/generate_204)
  if [ "$CODE" -eq 204 ]; then
    print "Success"
  elif [ "$CODE" == "30*" ]; then
    GREP=$(awk '/Location/ {print $2}' /tmp/curl_out)
    print "Redirected to $GREP"
  else
    print "Nope. Try DNS tunnel."
  fi
}

function vpnexec() {
    if [ "z$XDG_SESSION_TYPE" = "zx11" ]; then
        P='XDG_RUNTIME_DIR,SSH_AUTH_SOCK'
    else
        P="DBUS_SESSION_BUS_ADDRESS,XDG_RUNTIME_DIR,SSH_AUTH_SOCK"
    fi
    # fix a goddam firefox bug
    if [[ "$1" == "firefox" || "$1" == "thunderbird" || "$1" == "thunderbird-wayland" ]]; then
        echo "Pulseaudio XDG broken for FF/TB"
        P=''
    elif [[ "$1" == "chromium-browser" ]]; then
        P='XDG_RUNTIME_DIR'
    fi

    sudo --preserve-env=$P ip netns exec vpn sudo --preserve-env=$P -u "$USER" "$*"
}

function humbledl() {
    awk -F'"' '/dl.humble.+pdf/ {print $4}' "$1" | sed 's/amp;//g' | parallel curl -JOL
}


curlws() {
    setopt local_options BASH_REMATCH;
    local uri="${1}"
    [[ "${uri}" =~ ^((http|https)[:]//)?([^/]+)(.*)$ ]] || return
    local protocol=${BASH_REMATCH[2]:-http://}
    curl -N \
    -H "Connection: upgrade" \
    -H "Upgrade: websocket" \
    -H "Host: ${BASH_REMATCH[4]}" \
    -H "Origin: $protocol${BASH_REMATCH[4]}" \
    -H "Sec-WebSocket-Key: $(head -c 16 /dev/urandom | base64)" \
    -H "Sec-WebSocket-Version: 13" \
    --http1.1 \
    "$@" --output - ;
}

curlh() {
    curl -sSv "$@" 2> >(grep --line-buffer -Ev '^[{}*]' >&2) | grep --line-buffer -v 'yzxzz'
}
alias ip-default-mtu="ip link show \$(ip route show default | sed -n 's/^default via .* \(dev [a-z0-9]\+\).*/\1/p' || true) | sed -n 's/.*mtu \([0-9]\+\).*/\1/p'"

alias wtfip='curl https://wtfismyip.com/json'
