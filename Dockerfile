FROM quay.io/ukhomeofficedigital/hocs-base-image

USER root

RUN apk add --no-cache postgresql-client kubectl aws-cli ca-certificates curl less

USER 10000

COPY --chown=user_hocs:group_hocs ./scripts ./
