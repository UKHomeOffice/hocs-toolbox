#!/bin/bash
set -euo pipefail # make bash quit if something weird happens

export KUBE_NAMESPACE=${ENVIRONMENT}
export VERSION=${VERSION:-latest}
export CA_URL="https://raw.githubusercontent.com/UKHomeOffice/acp-ca/master/acp-notprod.crt"

export KUBE_CERTIFICATE_AUTHORITY=/tmp/cert.crt
if ! wget --quiet $CA_URL -O $KUBE_CERTIFICATE_AUTHORITY; then
    echo "[error] failed to download certificate authority"
    exit 1
fi

kd --timeout 5m0s --file deployment.yaml
