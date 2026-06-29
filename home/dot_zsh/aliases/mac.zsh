{{- if eq .chezmoi.os "darwin" }}
#!/usr/bin/env zsh

mac-flush-dns() {
  sudo dscacheutil -flushcache
  sudo killall -HUP mDNSResponder
}

scutil_show() {
read -r -d '' CMDS <<EOF
    show ${1}
    quit
EOF
  RESULT=$(sudo scutil <<< "$CMDS")
  if [[ "$RESULT" != "  No such key" ]]; then
    echo "Key: ${1}"
    echo "$RESULT"
  fi
}

# echo "list State:/Network/Service/.+" | sudo scutil
scutil_dump_svc() {
    SVC="$1"
    # Setup
    for PROP in IPv4 IPv6 Interface Proxies; do
        scutil_show "Setup:/Network/${SVC}/${PROP}"
    done

    # State
    for PROP in IPv4 IPv6 DNS DHCP; do
        scutil_show "State:/Network/${SVC}/${PROP}"
    done
}

mac-net-state() {
    set -uo pipefail

    TUNNEL_NAME="wg_tunnel"
    #LOCAL_ADDR="$(ip a s utun4 | awk '/inet6/ {print $2}' | grep -v 'fe80')"
    DNS_ADDR="fdaa:0:3c54::3"
    DOMAIN="internal"
    INTERFACE="utun4"

    #PSID="$(echo 'show State:/Network/Global/IPv4' | sudo scutil | grep -F PrimaryService | sed -e 's/.*PrimaryService : //')"

    # broken
    SVCS="$(echo 'list State:/Network/Service/[^/]+/DNS' | sudo scutil | awk '{print $4}' | perl -0777 -pe 's|State:/Network/Service/(.+)/DNS|\1|mg')"
    IFS=$'\n' SVC_ARR=($(SVCS))

    echo "# Global"
    scutil_dump_svc "Global"

    echo
    echo "# Services"
    for SVC in ${SVC_ARR[@]}; do
      scutil_dump_svc "Service/$SVC"
    done
}

mac-wg-fix-dns() {
  set -uo pipefail

    TUNNEL_NAME="wg_tunnel"
    #TUNNEL_NAME="utun4"
    LOCAL_ADDR="$(ip a s utun4 | awk '/inet6/ {print $2}' | grep -v 'fe80')"
    DNS_ADDR="fdaa:0:3c54::3"
    DOMAIN="internal"
    INTERFACE="utun4"

    PSID="$(echo 'show State:/Network/Global/IPv4' | sudo scutil | grep -F PrimaryService | sed -e 's/.*PrimaryService : //')"

    echo "Setting config for ${INTERFACE} @ ${LOCAL_ADDR}"

    sudo scutil <<-CMDS
        d.init
        d.add Addresses * ${LOCAL_ADDR}
        d.add DestAddresses * ::ffff:ffff:ffff:ffff:0:0 ::
        d.add InterfaceName ${INTERFACE}
        set State:/Network/Service/${TUNNEL_NAME}/IPv6
        set Setup:/Network/Service/${TUNNEL_NAME}/IPv6
        d.init
        d.add ServerAddresses * ${DNS_ADDR}
        d.add SupplementalMatchDomains * ${DOMAIN}
        set State:/Network/Service/${TUNNEL_NAME}/DNS
        set Setup:/Network/Service/${TUNNEL_NAME}/DNS
        quit
CMDS
}

mac-wg-clean-dns() {
    set -uo pipefail

    TUNNEL_NAME="wg_tunnel"
    #TUNNEL_NAME="utun4"
    #LOCAL_ADDR="$(ip a s utun4 | awk '/inet6/ {print $2}' | grep -v 'fe80')"
    DNS_ADDR="fdaa:0:3c54::3"
    DOMAIN="internal"
    INTERFACE="utun4"

    for TUNNEL_NAME in utun4 wg_tunnel my_ipv6_tunnel_service; do
        echo "removing config for $TUNNEL_NAME"
    sudo scutil <<-CMDS
      remove State:/Network/Service/${TUNNEL_NAME}/IPv6
      remove Setup:/Network/Service/${TUNNEL_NAME}/IPv6
      remove State:/Network/Service/${TUNNEL_NAME}/DNS
      remove Setup:/Network/Service/${TUNNEL_NAME}/DNS
      quit
CMDS
    done
}
{{- end }}
