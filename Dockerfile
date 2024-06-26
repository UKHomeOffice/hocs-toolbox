FROM quay.io/ukhomeofficedigital/hocs-base-image:4.1.6

USER 0

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y awscli ca-certificates postgresql-client zip jq && \
    apt-get clean


USER 10000

WORKDIR /app

COPY --chown=user_hocs:group_hocs ./scripts ./

ENTRYPOINT tail -f /dev/null
