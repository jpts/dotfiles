{{- if eq .chezmoi.os "linux" }}
usbguard-list-blocked() {
    local TMP=$(mktemp)
    usbguard list-devices -b > $TMP
    for id in $(awk '/block/ {print $4}' "$TMP"); do
        if [[ -z "$id" ]];then continue; fi
        USBGID=$(grep -F "$id" $TMP | sed -n -E 's/^(.{2,3}):.*name "(.*)" hash.*/\1:/p')
        INFO=$(grep -F "$id" $TMP | sed -n -E 's/^(.{2,3}):.*name "(.*)" hash.*/\2/p')
        PROD=$(lsusb -d "$id" -v 2>/dev/null| grep idProd | cut -c 29-)
        VEND=$(lsusb -d "$id" -v 2>/dev/null| grep idVend | cut -c 29-)
        echo "$USBGID $id - $VEND $PROD $INFO"
    done
    rm $TMP
}

usbguard-unblock-webcam() {
    local TMP=$(mktemp)
    sudo grep -v "Logitech Webcam C925e" /etc/usbguard/rules.conf >> $TMP
    sudo cp -f  "$TMP" /etc/usbguard/rules.conf

    sudo grep "Logitech Webcam C925e" /etc/usbguard/rules.d/webcam.conf | sed -e 's/ parent-hash "[a-zA-Z0-9=+]*"//' > $TMP
    sudo cp -f "$TMP" /etc/usbguard/rules.d/webcam.conf
    shred -u $TMP

    sudo chmod 600 /etc/usbguard/rules.d/webcam.conf
    sudo systemctl restart usbguard
}

function ouisearch() {
  local DB
  OUI="$(echo -n "$1" | tr -d ':')"
  if [ -f /usr/share/hwdata/oui.txt ]; then
    DB="/usr/share/hwdata/oui.txt"
  else
    echo "OUI DB not found"
    exit 1
  fi
  grep -i "$OUI" "$DB"
}
{{- end }}
