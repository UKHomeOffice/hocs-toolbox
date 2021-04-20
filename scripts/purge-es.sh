#!/bin/bash
set -euox pipefail

export VALID_NAMESPACES=("hocs-gamma" "hocs-delta" "hocs-qax")

current=$(kubectl config current-context)
if [[ ${VALID_NAMESPACES[*]} =~ ${current} ]] ; then
  echo "Current context is ${current}"
else
  echo "Unauthorised Namespace" >&2
  exit 1
fi

echo 'Warning: this action will completely remove all the contents of'
echo 'the elastic search indexes of '${current^^}'. It cannot be undone!'

read -p 'Are you sure you want to remove all the contents (y/n)? ' yes_no

if [[ $yes_no = 'y' || $yes_no = 'Y' ]]
then
    aws-es-curl --profile not-prod-es --region=eu-west-2 -X DELETE https://search-cs-notprod-elasticsearch-eg6slvni45k55o2j3lmo6yupdy.eu-west-2.es.amazonaws.com/${current}-case
    aws-es-curl --profile not-prod-es --region=eu-west-2 -X DELETE https://search-cs-notprod-elasticsearch-eg6slvni45k55o2j3lmo6yupdy.eu-west-2.es.amazonaws.com/${current}-lastest-case

    aws-es-curl --profile not-prod-es --region=eu-west-2 -X PUT https://search-cs-notprod-elasticsearch-eg6slvni45k55o2j3lmo6yupdy.eu-west-2.es.amazonaws.com/${current}-case \
     -H "Content-Type: application/json" -d @elastic_mapping
    aws-es-curl --profile not-prod-es --region=eu-west-2 -X POST https://search-cs-notprod-elasticsearch-eg6slvni45k55o2j3lmo6yupdy.eu-west-2.es.amazonaws.com/_aliases \
     -d '{"actions":[{"add":{"alias":"${current}-latest-case","index":"${current}-case"}}]}'
else
    echo 'Aborted. No action was performed.' >&2
fi
