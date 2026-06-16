#!/usr/bin/env bash

aws-regions-static() {
if [[ ! -s ~/.aws/regions.txt ]] || find ~/.aws/regions.txt -mtime +31 &>/dev/null ; then
        curl -sL 'https://raw.githubusercontent.com/jsonmaur/aws-regions/master/regions.json' | \
            jq '.[] | select(.public==true) | .code' -r | sort > ~/.aws/regions.txt
    fi
    cat ~/.aws/regions.txt
}

aws-regions-live() {
    aws ec2 describe-regions --region us-east-1 --query 'Regions[*].RegionName[]' --output text | tr '\t' '\n' | sort
}

aws-all-regions() {
    (
    for r in $(aws-regions-live); do
        aws "$@" --region "$r" --output json | jq "{\"region\":\"$r\", result:.}" &
    done
    ) | jq -s 'map(select(.result!=[]))'
}

aws-all-regions-static() {
    (
    for r in $(aws-regions-static); do
        aws "$@" --region "$r" --output json | jq "{\"region\":\"$r\", result:.}" &
    done
    ) | jq -s 'map(select(.result!=[]))'
}

aws-all-gov-regions() {
    (
    for r in us-gov-west-1 us-gov-east-1; do
        aws "$@" --region "$r" --output json | jq "{\"region\":\"$r\", result:.}" &
    done
    ) | jq -s 'map(select(.result!=[]))'
}

aws-assume-role() {
    set -uo pipefail
    local TMP=$(mktemp)
    aws sts assume-role "$@" > $TMP
    aws configure set --profile sts aws_access_key_id $(jq .Credentials.AccessKeyId -r $TMP) || return
    aws configure set --profile sts aws_secret_access_key $(jq .Credentials.SecretAccessKey -r $TMP) || return
    aws configure set --profile sts aws_session_token $(jq .Credentials.SessionToken -r $TMP) || return
    echo "Token expires at $(jq .Credentials.Expiration -r $TMP)"
    shred -u $TMP
}

aws-refresh-sts-token() {
    set -uo pipefail
    local TMP=$(mktemp)
    aws --profile sts sts get-caller-identity > $TMP
    local ARN=$(jq .Arn -r $TMP)
    local ROLE=$( echo ${ARN%/*} | sed -e 's/sts/iam/' | sed -e 's/assumed-role/role/' )
    local NAME=${ARN##*/}
    shred -u $TMP
    unset TMP

    aws-assume-role --profile sts --role-arn "$ROLE" --role-session-name "$NAME"
}

aws-refresh-sts-token-loop() {
    set -uo pipefail
    while :; do aws-refresh-token; sleep 30m; done
}

aws-temp-session-creds() {
    set -uo pipefail
    local TMP=$(mktemp)
    aws sts get-session-token "$@" > $TMP
    aws configure set --profile sts aws_access_key_id $(jq .Credentials.AccessKeyId -r $TMP) || return
    aws configure set --profile sts aws_secret_access_key $(jq .Credentials.SecretAccessKey -r $TMP) || return
    aws configure set --profile sts aws_session_token $(jq .Credentials.SessionToken -r $TMP) || return
    echo "Token expires at $(jq .Credentials.Expiration -r $TMP)"
    shred -u $TMP
}


aws-sso-get-temp-creds() {
    #AWS_PROFILE=${AWS_PROFILE:-"sso"}
    PROFILE=${1:-"$AWS_PROFILE"}
    set -uo pipefail
    TMPCONF=$(mktemp)
    grep -F -A6 "[profile $PROFILE]" ~/.aws/config > $TMPCONF
    local SSOACC=$(awk -F= '/sso_account_id/ {print $2}' $TMPCONF | tr -d ' ')
    local SSOROLE=$(awk -F= '/sso_role_name/ {print $2}' $TMPCONF | tr -d ' ')
    local SSOSTART=$(awk -F= '/sso_start_url/ {print $2}' $TMPCONF | tr -d ' ')
    local SSOTOKEN=$(jq -r -s ".[] | select(.startUrl == \"$SSOSTART\") | .accessToken" ~/.aws/sso/cache/*.json)
    local SSOREGION=$(jq -r -s ".[] | select(.startUrl == \"$SSOSTART\") | .region" ~/.aws/sso/cache/*.json)
    shred -u $TMPCONF
    local TMP=$(mktemp)
    #echo "get-role-credentials --profile "$PROFILE" --role-name "$SSOROLE" --account-id "$SSOACC" --access-token "$SSOTOKEN" --region "$SSOREGION""
    aws sso get-role-credentials --profile "$PROFILE" --role-name "$SSOROLE" --account-id "$SSOACC" --access-token "$SSOTOKEN" --region "$SSOREGION" > "$TMP" || return
    aws configure set --profile sts aws_access_key_id "$(jq .roleCredentials.accessKeyId -r $TMP)" || return
    aws configure set --profile sts aws_secret_access_key "$(jq .roleCredentials.secretAccessKey -r $TMP)" || return
    aws configure set --profile sts aws_session_token "$(jq .roleCredentials.sessionToken -r $TMP)" || return
    NS=$(jq .roleCredentials.expiration -r "$TMP")
    DATETIME=$(date -d "@${NS%"000"}")
    echo "Token expires at $DATETIME"
    shred -u $TMP
}

aws-sso-get-temp-creds-loop() {
    set -uo pipefail
    while :; do aws-sso-get-temp-creds "$1"; sleep 45m; done
}

aws-guardduty-get-all-findings() {
(
  for r in $(aws-regions-live); do
      aws --region "$r" guardduty list-findings --output json \
          --finding-criteria "Criterion={type={Eq=[$1]}}" \
          --detector-id "$(aws guardduty list-detectors --output json --region "$r"| jq -r '.DetectorIds[0]')" | jq "{\"region\":\"$r\", result:.FindingIds}" &
  done
) | jq -s 'map(select(.result!=[]))'
}

aws-guardduty-get-all-filters() {
(
  for r in $(cat ~/.aws/regions.txt); do
      aws --region "$r" guardduty list-filters --output json \
          --detector-id "$(aws guardduty list-detectors --output json --region "$r"| jq -r '.DetectorIds[0]')" | jq "{\"region\":\"$r\", result:.FilterNames}" &
  done
) | jq -s 'map(select(.result!=[]))'
}

aws-get-all-natgw() {
(
  for r in $(aws-regions-live); do
      aws --region "$r" ec2 describe-nat-gateways --output json \
          | jq ".NatGateways[] | .NatGatewayAddresses[0].PublicIp as \$ip | .Tags[] | select(.Key==\"Name\") | {region:\"$r\", ip:\$ip, name:.Value}" &
  done
  ) | jq -s '. | group_by(.name)[] | .[0].name as $n | [.[].ip] | {name:$n,ips:.}'

  #) | tee /tmp/out.json | jq -s .
      #jq -s '.[] | select(.result!=[]) | .region as $r | .result[] | .NatGatewayAddresses[0].PublicIp as $ip | .Tags[] | select(.Key=="Name") | {region:$r, ip:$ip, name:.Value}'
}

aws-get-eks-cluster-region() {
(
  for r in $(aws-regions-live); do
        aws --region "$r" eks list-clusters --output json \
          | jq ".clusters[] | {region:\"$r\", cluster:.}" &
  done
  ) | jq -s ".[] | select(.cluster==\"$1\") | .region" -r
}

aws-eks-update-kubeconfig-cluster() {
    REGION="$(aws-get-eks-cluster-region "$1" 2>/dev/null)"
    if [ -z "$REGION" ]; then
        echo "could not find cluster" >&2
        return
    fi
    aws eks update-kubeconfig --name "$1" --region "$REGION"
}

aws-source-cognito-identity-credentials() {
    IDENT="$1"
    TMP=$(mktemp)
    aws cognito-identity get-credentials-for-identity --identity-id "$IDENT" > "$TMP"
    aws configure set --profile cognito-identity aws_access_key_id "$(jq .Credentials.AccessKeyId -r "$TMP")" || return
    aws configure set --profile cognito-identity aws_secret_access_key "$(jq .Credentials.SecretKey -r "$TMP")" || return
    aws configure set --profile cognito-identity aws_session_token "$(jq .Credentials.SessionToken -r "$TMP")" || return
    NS=$(jq .Credentials.Expiration -r "$TMP")
    DATETIME=$(date -d "${NS}")
    echo "Token expires at $DATETIME"
    shred -u "$TMP"
    export AWS_PROFILE="cognito-identity"
}
