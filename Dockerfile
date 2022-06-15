FROM quay.io/ukhomeofficedigital/hocs-base-image

USER 0

RUN apk add --no-cache postgresql-client aws-cli ca-certificates curl bash

USER 10000

COPY --chown=user_hocs:group_hocs ./scripts ./
COPY --chown=user_hocs:group_hocs run.sh ./

CMD ["sh", "/app/run.sh"]
