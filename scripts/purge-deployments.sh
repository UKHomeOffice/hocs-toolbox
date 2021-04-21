#!/bin/bash
set -euox pipefail

export VALID_NAMESPACES=("hocs-gamma" "hocs-delta" "hocs-qax")

current=$(kubectl config current-context)
if [[ ${VALID_NAMESPACES[*]} =~ $current ]] ; then
  echo "Current context is $current"
else
  echo "Unauthorised Namespace" >&2
  exit 1
fi

echo "Warning: this action will completely remove all the kubernetes deployments of ${current^^}. It cannot be undone!"

read -p 'Are you sure you want to remove all the kubernetes deployments (y/N)? ' yes_no

if [[ $yes_no = 'y' || $yes_no = 'Y' ]]
then
    kubectl delete deployment hocs-info-service
    kubectl delete deployment hocs-casework
    kubectl delete deployment hocs-workflow
    kubectl delete deployment hocs-audit
    kubectl delete deployment hocs-docs
    kubectl delete deployment hocs-docs-converter
    kubectl delete deployment hocs-notify
    kubectl delete deployment hocs-search
    kubectl delete deployment hocs-templates
    kubectl delete deployment hocs-frontend
    kubectl delete deployment hocs-management-ui
    kubectl delete deployment hocs-case-creator
else
    echo 'Aborted. No action was performed.' >&2
fi
