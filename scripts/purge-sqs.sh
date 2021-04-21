#!/bin/bash
set -euo pipefail

echo 'Warning: this action will completely remove all the messages in'
echo 'all of the queues in '${KUBE_NAMESPACE^^}'. It cannot be undone!'

read -p 'Are you sure you want to remove all messages (y/n)? ' yes_no

if [[ $yes_no = 'y' || $yes_no = 'Y' ]]
then
    export HTTP_PROXY=http://hocs-outbound-proxy.${KUBE_NAMESPACE}.svc.cluster.local:31290
    export HTTPS_PROXY=http://hocs-outbound-proxy.${KUBE_NAMESPACE}.svc.cluster.local:31290
    export AWS_DEFAULT_REGION=eu-west-2

    export AWS_ACCESS_KEY_ID=${AWS_AUDIT_SQS_ACCESS_KEY}
    export AWS_SECRET_ACCESS_KEY=${AWS_AUDIT_SQS_SECRET_KEY}

    aws sqs purge-queue --queue-url https://sqs.eu-west-2.amazonaws.com/${AWS_ACCOUNT_ID}/${AUDIT_QUEUE_NAME}
    aws sqs purge-queue --queue-url https://sqs.eu-west-2.amazonaws.com/${AWS_ACCOUNT_ID}/${AUDIT_QUEUE_DLQ_NAME}

    export AWS_ACCESS_KEY_ID=${AWS_DOCUMENT_SQS_ACCESS_KEY}
    export AWS_SECRET_ACCESS_KEY=${AWS_DOCUMENT_SQS_SECRET_KEY}

    aws sqs purge-queue --queue-url https://sqs.eu-west-2.amazonaws.com/${AWS_ACCOUNT_ID}/${DOCUMENT_QUEUE_NAME}
    aws sqs purge-queue --queue-url https://sqs.eu-west-2.amazonaws.com/${AWS_ACCOUNT_ID}/${DOCUMENT_QUEUE_DLQ_NAME}

    export AWS_ACCESS_KEY_ID=${AWS_SEARCH_SQS_ACCESS_KEY}
    export AWS_SECRET_ACCESS_KEY=${AWS_SEARCH_SQS_SECRET_KEY}

    aws sqs purge-queue --queue-url https://sqs.eu-west-2.amazonaws.com/${AWS_ACCOUNT_ID}/${SEARCH_QUEUE_NAME}
    aws sqs purge-queue --queue-url https://sqs.eu-west-2.amazonaws.com/${AWS_ACCOUNT_ID}/${SEARCH_QUEUE_DLQ_NAME}
else
    echo 'Aborted. No action was performed.' >&2
fi
