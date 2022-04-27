#!/bin/bash
set -euo pipefail # make bash quit if something weird happens

export KUBE_NAMESPACE=${DRONE_STEP_NAME}
export VERSION=${VERSION:-latest}
export KUBE_SERVER=https://kube-api-notprod.notprod.acp.homeoffice.gov.uk
export KUBE_CERTIFICATE_AUTHORITY="https://raw.githubusercontent.com/UKHomeOffice/acp-ca/master/acp-notprod.crt"

echo
echo "Deploying to ${KUBE_NAMESPACE}"
echo "Version: ${VERSION}"
echo

cd kd

kd --timeout 5m0s -f deployment.yaml
