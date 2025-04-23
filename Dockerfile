FROM quay.io/ukhomeofficedigital/hocs-base-image:4.1.6

USER 0

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y awscli ca-certificates postgresql-client zip jq && \
    apt-get clean


USER 10000

WORKDIR /app

COPY --chown=user_hocs:group_hocs ./scripts ./

ADD --chown=user_hocs:group_hocs https://raw.githubusercontent.com/UKHomeOffice/hocs-audit/refs/heads/main/config/materializedviews/Audit-Schema-DataUpdates.sql sql/

ENTRYPOINT tail -f /dev/null
