#!/bin/bash
set -euo pipefail

export VALID_NAMESPACES=("hocs-gamma" "hocs-delta" "hocs-qax")

current=$(kubectl config current-context)
if [[ ${VALID_NAMESPACES[*]} =~ ${current} ]] ; then
  echo "Current context is ${current}"
else
  echo "Unauthorised Namespace" >&2
  exit 1
fi

echo 'Warning: this action will completely remove all the contents of'
echo 'the elastic search indexes of '${current}'. It cannot be undone!'

read -p 'Are you sure you want to remove all the contents (y/n)? ' yes_no

if [ $yes_no = 'y' -o $yes_no = 'Y' ];
then
    aws-es-curl --profile not-prod-es --region=eu-west-2 -X DELETE https://${ELASTICSEARCH_ENDPOINT}/${current}-case
    aws-es-curl --profile not-prod-es --region=eu-west-2 -X DELETE https://${ELASTICSEARCH_ENDPOINT}/${current}-lastest-case

    aws-es-curl --profile not-prod-es --region=eu-west-2 -X PUT https://${ELASTICSEARCH_ENDPOINT}/${current}-case \
     -H "Content-Type: application/json" -d @elastic_mapping

    if [ $current = 'hocs-qax' ];
    then
        aws-es-curl --profile not-prod-es --region=eu-west-2 -X POST https://${ELASTICSEARCH_ENDPOINT}/_aliases \
        -d '{"actions":[{"add":{"alias":"hocs-qax-latest-case","index":"$hocs-qax-case"}}]}'
    fi
    if [ $current = 'hocs-delta' ];
    then
        aws-es-curl --profile not-prod-es --region=eu-west-2 -X POST https://${ELASTICSEARCH_ENDPOINT}/_aliases \
        -d '{"actions":[{"add":{"alias":"hocs-delta-latest-case","index":"$hocs-delta-case"}}]}'
    fi
    if [ $current = 'hocs-gamma' ];
    then
        aws-es-curl --profile not-prod-es --region=eu-west-2 -X POST https://${ELASTICSEARCH_ENDPOINT}/_aliases \
        -d '{"actions":[{"add":{"alias":"hocs-gamma-latest-case","index":"$hocs-gamma-case"}}]}'
    fi
else
    echo 'Aborted. No action was performed.' >&2
fi
