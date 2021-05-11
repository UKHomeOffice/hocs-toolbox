#! /bin/bash
set -euo pipefail

# This script fires Drone builds to copy one environment to another
# Usage: ./copy-ns.sh source_namespace target_namespace

SOURCE=$1
TARGET=$2

echo "Copying $1 to $2."

case $SOURCE in
  "hocs-gamma")
    BRANCH=epic/foi-mvp
    ;;
  "hocs-delta")
    BRANCH=epic/HOCS-COMP
    ;;
  *)
    BRANCH=main
esac


echo -n "Fetching deployments on $SOURCE. This may take a moment..."

DEPLOYMENTS=( $(
  kubectl get deployments \
    -n "${SOURCE}" \
    -o jsonpath="{.items[*].spec.template.spec.containers[*].image}" \
  | tr ' ' '\n' \
  | grep hocs
) )

for DEPLOYMENT in "${DEPLOYMENTS[@]}"; do
  APP_PAIR=${DEPLOYMENT##*/} # everything after the last slash
  APP_VERSION=${APP_PAIR#*:} # everything after the colon
  APP_NAME=${APP_PAIR%:*} # everything before the colon
  echo "Discovered $APP_NAME is version $APP_VERSION"

  if [[ $APP_NAME == "hocs-psql-exec" ]] ; then
    echo "Skipping $APP_NAME"
    continue
  fi

  DRONE_REPO="UKHomeOffice/${APP_NAME}"
  DRONE_BUILD=$(drone build last "${DRONE_REPO}" --format "{{ .Number }}" --branch "${BRANCH}")

  echo drone build promote \
    -p HOCS_DATA_REPO=hocs-data \
    -p "VERSION=${APP_VERSION}" \
    "${DRONE_REPO}" \
    "${DRONE_BUILD}" \
    "$TARGET"
done

