#!/bin/bash
set -euox pipefail

echo 'Warning: this action will completely remove all the documents in'
echo 'both the trusted and untrusted S3 buckets of '${KUBE_NAMESPACE^^}'. It cannot be undone!'

read -p 'Are you sure you want to remove all the documents (y/n)? ' yes_no

if [[ $yes_no = 'y' || $yes_no = 'Y' ]]
then
    export HTTP_PROXY=http://hocs-outbound-proxy.${KUBE_NAMESPACE}.svc.cluster.local:31290
    export HTTPS_PROXY=http://hocs-outbound-proxy.${KUBE_NAMESPACE}.svc.cluster.local:31290
    export AWS_ACCESS_KEY_ID=${S3_TRUSTED_ACCESS_KEY}
    export AWS_KMS_KEY_ID=${S3_TRUSTED_KMS_KEY}
    export AWS_SECRET_ACCESS_KEY=${S3_TRUSTED_SECRET_ACCESS_KEY}
    export AWS_DEFAULT_REGION=eu-west-2

    aws s3 rm s3://${S3_TRUSTED_BUCKET} --recursive

    export AWS_ACCESS_KEY_ID=${S3_UNTRUSTED_ACCESS_KEY}
    export AWS_KMS_KEY_ID=${S3_UNTRUSTED_KMS_KEY}
    export AWS_SECRET_ACCESS_KEY=${S3_UNTRUSTED_SECRET_ACCESS_KEY}

    aws s3 rm s3://${S3_UNTRUSTED_BUCKET} --recursive
else
    echo 'Aborted. No action was performed.' >&2
fi
