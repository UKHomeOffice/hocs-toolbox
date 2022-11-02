FROM quay.io/ukhomeofficedigital/hocs-base-image

USER 0

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y awscli ca-certificates postgresql-client && \
    apt-get clean

USER 10000

WORKDIR /app

COPY --chown=user_hocs:group_hocs ./scripts ./

ENTRYPOINT tail -f /dev/null
