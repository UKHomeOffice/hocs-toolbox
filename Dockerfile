FROM alpine:3.16.0 as builder

USER root

RUN addgroup -S group_hocs && adduser -S -u 10000 user_hocs -G group_hocs -h /app

RUN apk add --no-cache postgresql-client kubectl aws-cli ca-certificates curl less


FROM builder AS safe

COPY --chown=user_hocs:group_hocs scripts/safe/ ./scripts/

USER 10000

WORKDIR /app

FROM builder AS dangerous

COPY --chown=user_hocs:group_hocs scripts/safe/ ./scripts/
COPY --chown=user_hocs:group_hocs scripts/dangerous/ ./scripts/

USER 10000

WORKDIR /app
