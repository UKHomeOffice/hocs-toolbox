FROM postgres:14.2-alpine AS base

ENV USER hocs
ENV USER_ID 1000
ENV GROUP hocs
ENV NAME hocs-toolbox
ENV PGDATA /app/data
ENV AWS_CLI_VERSION 1.16.207

WORKDIR /app

RUN addgroup ${GROUP} && \
    adduser -u ${USER_ID} -G ${GROUP} -h /app -D ${USER}
RUN mkdir -p /app/scripts && \
    chown -R ${USER}:${GROUP} /app
RUN mkdir -p /app/scripts

COPY run.sh /app/
RUN chmod a+x /app/run.sh

# Installation of AWS CLI & libpq (latter needed for password auth on PG client)
RUN apk --no-cache update && \
    apk add --update --no-cache curl py-pip libpq && \
    apk --no-cache add py-setuptools ca-certificates groff less && \
    pip --no-cache-dir install awscli==${AWS_CLI_VERSION} && \
    rm -rf /var/cache/apk/*

RUN mkdir /data && chown ${USER_ID} /data

# Installation of kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl \
    -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin

USER ${USER_ID}
CMD /app/run.sh

FROM base AS safe
COPY scripts/safe/*.sh /app/scripts/
RUN echo "SET SESSION CHARACTERISTICS AS TRANSACTION READ ONLY;" >> ~/.pgsqlrc

FROM base AS dangerous
COPY scripts/safe/*.sh /app/scripts/
COPY scripts/dangerous/*.sh /app/scripts/
