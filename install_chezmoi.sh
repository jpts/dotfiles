#!/usr/bin/env bash

set -euo pipefail

VERSION="2.70.5"

if command -v chezmoi &>/dev/null; then
  echo "Chezmoi already installed" >&2
  exit 0
fi

for cmd in mktemp curl tar sha256sum install awk; do
  if ! command -v $cmd &>/dev/null; then
    echo "Command not found: $cmd"
    exit 1
  fi
done

DISTRO="$(awk -F= '/^ID=/ {print $2}' /etc/os-release)"
OS_VERSION="$(awk -F= '/^VERSION=/ {print $2}' /etc/os-release)"

install_cosign_from_github() {
  curl -sSfL https://github.com/sigstore/cosign/releases/download/v3.1.1/cosign-linux-amd64 -o ./cosign
  echo -n "ae1ecd212663f3693ad9edf8b1a183900c9a52d3155ba6e354237f9a0f6463fc cosign" | sha256sum --check -
  install ./cosign ~/.local/bin
}

TMP=$(mktemp -d)
pushd "$TMP"

mkdir -p ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"

if ! command -v cosign &>/dev/null; then
  case $DISTRO in
    ubuntu)
      if [[ $OS_VERSION == "25."* || $OS_VERSION == "26."* ]]; then
        sudo apt install cosign -y --no-install-recommends
      else
        install_cosign_from_github
      fi
      ;;
    debian)
      sudo apt install cosign -y --no-install-recommends
      ;;
    alpine)
      sudo apk add cosign -y --no-cache
      ;;
    *)
      echo "Distro $DISTRO unsuported" >&2
      install_cosign_from_github
      ;;
  esac
fi


cat > ./chezmoi.pub << EOF
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEJDy2Dn3u5hqjQkTrcAukXwJty9Ke
oquP+qONwiD4r+cjO8yrhoELoUk1ogXzvpM7f9bOS/YS5pdx2snCmMudDg==
-----END PUBLIC KEY-----
EOF

curl -sS --location --remote-name-all \
  https://github.com/twpayne/chezmoi/releases/download/v${VERSION}/chezmoi_${VERSION}_linux_amd64.tar.gz \
  https://github.com/twpayne/chezmoi/releases/download/v${VERSION}/chezmoi_${VERSION}_checksums.txt \
  https://github.com/twpayne/chezmoi/releases/download/v${VERSION}/chezmoi_${VERSION}_checksums.txt.sig

cosign verify-blob --key=chezmoi.pub \
  --signature=chezmoi_${VERSION}_checksums.txt.sig \
  chezmoi_${VERSION}_checksums.txt

sha256sum --check chezmoi_${VERSION}_checksums.txt --ignore-missing

tar xf chezmoi_${VERSION}_linux_amd64.tar.gz chezmoi

mkdir -p ~/.local/bin
install ./chezmoi ~/.local/bin

popd
if [ -d "$TMP" ]; then
  rm -rf "$TMP"
fi

chezmoi --version
