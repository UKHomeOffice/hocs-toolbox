#!/bin/bash
set -euo pipefail

export KUBE_SERVER="https://kube-api-notprod.notprod.acp.homeoffice.gov.uk"
export KUBE_CERTIFICATE_AUTHORITY="https://raw.githubusercontent.com/UKHomeOffice/acp-ca/master/acp-notprod.crt"
export KUBE_NAMESPACE=${ENVIRONMENT}

JOB_NAME="destroy-info-schema"
kd -f $JOB_NAME.yaml
kd run wait --for=condition=complete "job/$JOB_NAME"
kd --delete -f $JOB_NAME.yaml
kd run rollout restart "deployment/hocs-info-service"
