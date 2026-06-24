#!/usr/bin/env bash

function kj() { kubectl "$@" -o json | jq; }
function ky() { kubectl "$@" -o yaml | yh; }

# doesnt work
function ksh() {
    kubectl exec -it "$@" -- "(bash || ash || sh)"
}

#function aws-static-kubeconfig() {
#   envs
#    CMD=$(kubectl config view -o json | jq '.users[] | select(.name=="aws") | .user.exec | .command, .args[]' -r | tr '\n' ' ')
#}

kubectl-sa-dir() {
    local DIR="${1:-}";
    local API_SERVER="${2:-kubernetes.default}";
    kubectl config set-cluster tmpk8s --server="https://${API_SERVER}" #--certificate-authority="${
    kubectl config set-context tmpk8s --cluster=tmpk8s;
    kubectl config set-credentials tmpk8s --token="$(<${DIR}/token)";
    kubectl config set-context tmpk8s --user=tmpk8s;
    kubectl config use-context tmpk8s;
    kubectl get secrets -n null 2>&1 | sed -E 's,.*r "([^"]+).*,\1,g'
}

kubectl-delete-grep() {
    kubectl get "$1" -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep -F "$2" | xargs -i kubectl delete "$1" {}
}

mitmproxy-kubectl() {
    TMP=$(mktemp)
    kubectl config view --minify --flatten -o=go-template='{{(index (index .users 0).user "client-key-data")}}' | base64 -d >> $TMP
    kubectl config view --minify --flatten -o=go-template='{{(index (index .users 0).user "client-certificate-data")}}' | base64 -d >> $TMP
    mitmproxy --ssl-insecure --set client_certs="$TMP" "$@"
    shred -u "$TMP"
}

alias kans="kubectl get ns -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | xargs -I{} kubectl -n {}"
kubectl-all-ns() {
  kubectl get ns -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | xargs -I{} sh -c "kubectl -n {} $@"
}

alias k-spawn-priv-pod="k run tools --image=alpine --restart=Never --overrides='{\"spec\":{\"hostPID\":true}}' --privileged -- sleep inf"

kubectl-set-token-ctx() {
    local NAME="$1"
    local API_SERVER="$2"
    local TOKEN="$3"
    kubectl config set-cluster "$NAME:work" --server="${API_SERVER}" --insecure-skip-tls-verify
    kubectl config set-credentials "${NAME}-token" --token="$TOKEN"
    kubectl config set-context "${NAME}" --cluster="$NAME";
    kubectl config set-context "$NAME" --user="${NAME}-token";
    kubectl config use-context "$NAME"
}
# kubectl
alias k=kubectl

alias kns='kubectl config set-context --current --namespace'
alias k-node-capacity="k get nodes -o custom-columns='NAME:.metadata.name,ALLOCATABLE:.status.allocatable.pods,CAPACITY:.status.capacity.pods"
alias koy='kubectl get -oyaml'
alias kpo='kubectl get pods'
alias wkg='watch kubectl get'
alias kallns="kubectl get ns -o jsonpath='{.items[*].metadata.name}'|tr ' ' '\n'|grep -v -E '(*-system|kube-*)' | xargs -i kubectl -n {}"

# tools
alias kubeaudit-format=$'jq \'[group_by(.AuditResultName)[]| {vuln:.[0].AuditResultName, level:.[0].level, msg:.[0].msg, resources:[.[]|.ResourceKind+":"+.ResourceNamespace+"/"+.ResourceName+"#"+.Container] }]\' -s'
alias kubeaudit-format-pretty=$'jq \'[group_by(.AuditResultName)[]| {vuln:.[0].AuditResultName, level:.[0].level, msg:.[0].msg, resources:[.[]|.ResourceNamespace+"/"+.ResourceName+"#"+.Container+" "+.ResourceKind] }]\' -s'

alias kubesec="podman run -i docker.io/kubesec/kubesec"

alias items2yamldocs="yq e '.items[]' /dev/stdin | sed -e 's/^apiVersion/---\napiVersion/g'"
