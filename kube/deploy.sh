export KUBE_NAMESPACE=${KUBE_NAMESPACE}
export KUBE_SERVER=${KUBE_SERVER}

if [[ -z ${VERSION} ]] ; then
    export VERSION=${IMAGE_VERSION}
fi

if [[ ${ENVIRONMENT} == "prod" ]] ; then
    echo "deploy ${VERSION} to prod namespace, using HOCS_POSTGRES_PR drone secret"
    export CA_URL="https://raw.githubusercontent.com/UKHomeOffice/acp-ca/master/acp-prod.crt"
    export KUBE_TOKEN=${HOCS_POSTGRES_PROD}
else
    export CA_URL="https://raw.githubusercontent.com/UKHomeOffice/acp-ca/master/acp-notprod.crt"
    if [[ ${ENVIRONMENT} == "qa" ]] ; then
        echo "deploying ${VERSION} to test namespace, using HOCS_POSTGRES_QA drone secret"
        export KUBE_TOKEN=${HOCS_POSTGRES_QA}
    elif [[ ${ENVIRONMENT} == "demo" ]] ; then
        echo "deploy ${VERSION} to DEMO namespace, HOCS_POSTGRES_DEMO drone secret"
        export KUBE_TOKEN=${HOCS_POSTGRES_DEMO}
        export REPLICAS="1"
    elif [[ ${ENVIRONMENT} == "dev" ]] ; then
        echo "deploy ${VERSION} to DEV namespace, HOCS_POSTGRES_DEV drone secret"
        export KUBE_TOKEN=${HOCS_POSTGRES_DEV}
        export REPLICAS="1"
    else
        echo "Unable to find environment: ${ENVIRONMENT}"
    fi
    
fi

export KUBE_CERTIFICATE_AUTHORITY=/tmp/cert.crt
if ! wget --quiet $CA_URL -O $KUBE_CERTIFICATE_AUTHORITY; then
    echo "[error] faled to download certificate authority!"
    exit 1
fi

if [[ -z ${KUBE_TOKEN} ]] ; then
    echo "Failed to find a value for KUBE_TOKEN - exiting"
    exit 1
fi

kd --timeout 5m0s --file deployment.yaml
