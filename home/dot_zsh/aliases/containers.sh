skopeo-unpack() {
    set -uo pipefail
    TMP=$(mktemp -d)
    cd $TMP
    mkdir -p {unpack,rootfs}
    if ! podman inspect "$1" &>/dev/null; then
        podman pull "$1"
    fi
    skopeo --insecure-policy copy containers-storage:"$1" dir:"$TMP/unpack"
    file unpack/* | awk -F: '/tar/ {print $1}' | xargs -I{} tar -xf {} -C "$TMP/rootfs"
    local SHA=$(jq -r .config.digest "$TMP/unpack/manifest.json")
    jq . "$TMP/unpack/${SHA[8,-1]}" > "$TMP/config.json"
    #find . -name layer.tar -exec echo tar xf {} -C root \;
}

skopeo-unpack-oci() {
    set -uo pipefail
    TMP=$(mktemp -d)
    cd $TMP
    mkdir -p {unpack,rootfs}
    if ! podman inspect "$1" &>/dev/null; then
        podman pull "$1"
    fi
    skopeo copy containers-storage:"$1" oci:"$TMP/unpack"
    file unpack/blobs/sha256/* | awk -F: '/gzip/ {print $1}' | xargs -i tar -xf {} -C "$TMP/rootfs"
    local SHA=$(jq -r '.manifests[0].digest' "$TMP/unpack/index.json" )
    jq . "$TMP/unpack/blobs/sha256/${SHA[8,-1]}" > "$TMP/manifest.json"
    local SHA=$(jq -r '.config.digest' "$TMP/manifest.json" )
    jq . "$TMP/unpack/blobs/sha256/${SHA[8,-1]}" > "$TMP/config.json"
}

# this doesn't apply order correcly I think
skopeo-repack-oci() {
    set -uo pipefail
    TMP="$1"
    cd $TMP
    rm -rf repack/
    mkdir -p repack/blobs/sha256
    cat config.json | jq -c '{"architecture":.architecture,"os":"linux","config":.config,"rootfs":.rootfs}' > config.json.min
    local CONFIG_SHA=$(sha256sum config.json.min | cut -d ' ' -f1 | tr -d '\n')
    local CONFIG_SIZE=$(stat config.json.min | awk '/Size/ {print $2}' | tr -d '\n')
    cp config.json.min "repack/blobs/sha256/${CONFIG_SHA}"
    tar -c -I 'pigz -9' -f rootfs.tar.gz -C rootfs .
    local ROOTFS_SHA=$(sha256sum rootfs.tar.gz | cut -d ' ' -f1 | tr -d '\n')
    local ROOTFS_SIZE=$(stat rootfs.tar.gz | awk '/Size/ {print $2}' | tr -d '\n')
    cp rootfs.tar.gz "repack/blobs/sha256/${ROOTFS_SHA}"
    echo "{\"schemaVersion\":2,\"mediaType\":\"application/vnd.oci.image.manifest.v1+json\",\"config\":{\"mediaType\":\"application/vnd.oci.image.config.v1+json\",\"digest\":\"sha256:$CONFIG_SHA\",\"size\":$CONFIG_SIZE},\"layers\":[{\"mediaType\":\"application/vnd.oci.image.layer.v1.tar+gzip\",\"digest\":\"sha256:$ROOTFS_SHA\",\"size\":$ROOTFS_SIZE}]}" | jq -c . > manifest.json.min
    local MAN_SHA=$(sha256sum manifest.json.min | cut -d ' ' -f1 | tr -d '\n')
    local MAN_SIZE=$(stat manifest.json.min | awk '/Size/ {print $2}' | tr -d '\n')
    cp manifest.json.min "repack/blobs/sha256/${MAN_SHA}"
    cp unpack/oci-layout repack/oci-layout
    echo "{\"schemaVersion\":2,\"manifests\":[{\"mediaType\":\"application/vnd.oci.image.manifest.v1+json\",\"digest\":\"sha256:$MAN_SHA\",\"size\":$MAN_SIZE}]}" | jq -c . > repack/index.json
    skopeo copy "oci:$TMP/repack" "containers-storage:$2"
}

aws-ecr-login-podman() {
    local AccID=$(aws sts get-caller-identity --output json | jq -r .Account)
    local ID=${1:-$AccID}
    local TOKEN=$(aws ecr get-login --region "$AWS_REGION" --no-include-email --registry-ids="$ID" | awk '/login/ {print $6}')
    podman login -u AWS -p "$TOKEN" "${ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
}

gcr-get-tag-digest() {
    set -Eeuo pipefail
    gcloud container images list-tags "$1" --format json | jq ".[] | select(any(.tags[] == \"$2\"; .)) | .digest" -r
}

crane-ls-arch() {
  MANIFEST="$(crane manifest "$1")"
  TYPE="$(jq .mediaType -r <<< "$MANIFEST")"
  OCI_CONFIGTYPE="$(jq .config.mediaType -r <<< "$MANIFEST")"
  if [[ "$TYPE" == "application/vnd.docker.distribution.manifest.list.v2+json" || "$TYPE" == "application/vnd.oci.image.index.v1+json" ]]; then
    echo "$MANIFEST" | jq '.manifests[].platform | "\(.os)-\(.architecture)"' -r
  elif [[ "$TYPE" == "application/vnd.docker.distribution.manifest.v2+json" || "$TYPE" == "application/vnd.oci.image.manifest.v1+json" || "$OCI_CONFIGTYPE" == "application/vnd.oci.image.config.v1+json" ]]; then
    crane config "$1" | jq '. | "\(.os)-\(.architecture)"' -r
  else
    echo "Manifest type '$TYPE' unsupported"
  fi
}

alias limactl='limactl --log-level=warn'
