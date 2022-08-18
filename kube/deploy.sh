#!/bin/bash
set -euo pipefail # make bash quit if something weird happens

export KUBE_NAMESPACE=${DRONE_STEP_NAME}
#export KUBE_TOKEN=${KUBE_TOKEN}
export VERSION=${VERSION}

if [[ ${KUBE_NAMESPACE} == *prod* ]]
then
    export DOWNSCALE_PERIOD="Mon-Sun 23:00-05:00 Europe/London"

    export CLUSTER_NAME="acp-prod"
    export KUBE_SERVER=https://kube-api-prod.prod.acp.homeoffice.gov.uk
else
    export DOWNSCALE_PERIOD="Mon-Fri 18:00-08:00 Europe/London"

    export CLUSTER_NAME="acp-notprod"
    export KUBE_SERVER=https://kube-api-notprod.notprod.acp.homeoffice.gov.uk
fi

export KUBE_CERTIFICATE_AUTHORITY="https://raw.githubusercontent.com/UKHomeOffice/acp-ca/master/${CLUSTER_NAME}.crt"

echo
echo "Deploying to ${KUBE_NAMESPACE}"
echo "Version: ${VERSION}"
echo

cd kd || exit 1

kd --timeout 5m0s -f deployment.yaml
