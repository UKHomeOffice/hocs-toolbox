#!/bin/bash
set -euo pipefail # make bash quit if something weird happens

export KUBE_NAMESPACE=${ENVIRONMENT}
export VERSION=${VERSION:-latest}
export KUBE_CERTIFICATE_AUTHORITY="https://raw.githubusercontent.com/UKHomeOffice/acp-ca/master/acp-notprod.crt"

cd kd

kd --timeout 5m0s \
  -f deployment.yaml
