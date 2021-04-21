#!/usr/bin/env bash

kubectl config use-context ${KUBE_NAMESPACE}

export PGPASSWORD=${HOCS_PASSWORD}

psql -h${HOCS_DB_HOSTNAME} -U${HOCS_USERNAME} -d${HOCS_DB_NAME}

tail -f /dev/null
