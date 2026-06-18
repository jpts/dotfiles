#!/usr/bin/env bash

set -euo pipefail

VERSION="2.70.5"

for cmd in mktemp curl cosign tar sha256sum install strip; do
  if ! command -v $cmd &>/dev/null; then
    echo "Command not found: $cmd"
    exit 1
  fi
done

TMP=$(mktemp -d)
pushd "$TMP"

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
install -s ./chezmoi ~/.local/bin

popd
if [ -d "$TMP" ]; then
  rm -rf "$TMP"
fi

~/.local/bin/chezmoi --version
