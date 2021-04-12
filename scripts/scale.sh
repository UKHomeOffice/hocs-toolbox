#!/bin/bash

export VALID_NAMESPACES=("hocs-gamma" "hocs-delta" "hocs-qax")

current=$(kubectl config current-context)
if [[ ${VALID_NAMESPACES[*]} =~ $current ]] ; then
  echo "Current context is $current"
else
  echo "Unauthorised Namespace" >&2
  exit 1
fi

if [ "$#" -ne 1 ]; then
  echo "Usage: scale.sh down/up" >&2
  exit 1
fi
if [ "$1" != "down" -a "$1" != "up" ]; then
  echo "Usage: scale.sh down/up" >&2
  exit 1
fi

echo "Please be patient as some of these steps take up to a minute to complete."

if [ "$1" = "down" ]; then
  kubectl scale --replicas=0 deployment/hocs-management-ui
  kubectl scale --replicas=0 deployment/hocs-frontend
  kubectl scale --replicas=0 deployment/hocs-notify
  kubectl scale --replicas=0 deployment/hocs-search
  kubectl scale --replicas=0 deployment/hocs-templates
  sleep 5
  kubectl scale --replicas=0 deployment/hocs-docs
  kubectl scale --replicas=0 deployment/hocs-docs-converter
  sleep 5
  kubectl scale --replicas=0 deployment/hocs-audit
  kubectl scale --replicas=0 deployment/hocs-workflow
  kubectl scale --replicas=0 deployment/hocs-casework
  sleep 20
  kubectl scale --replicas=0 deployment/hocs-info-service
else
  kubectl scale --replicas=1 deployment/hocs-info-service
  sleep 60
  kubectl scale --replicas=1 deployment/hocs-casework
  kubectl scale --replicas=1 deployment/hocs-workflow
  kubectl scale --replicas=1 deployment/hocs-audit
  sleep 20
  kubectl scale --replicas=1 deployment/hocs-docs-converter
  kubectl scale --replicas=1 deployment/hocs-docs
  kubectl scale --replicas=1 deployment/hocs-notify
  kubectl scale --replicas=1 deployment/hocs-search
  kubectl scale --replicas=1 deployment/hocs-templates
  sleep 30
  kubectl scale --replicas=1 deployment/hocs-frontend
  kubectl scale --replicas=1 deployment/hocs-management-ui
fi

