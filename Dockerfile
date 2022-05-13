FROM alpine:3.14 AS base

ENV USER hocs
ENV USER_ID 1000
ENV GROUP hocs
ENV NAME hocs-migration-toolbox
ENV AWS_CLI_VERSION 1.16.207

WORKDIR /app

RUN apk update && apk add bash

RUN addgroup ${GROUP} && \
    adduser -u ${USER_ID} -G ${GROUP} -h /app -D ${USER} 
RUN mkdir -p /app/scripts && \
    chown -R ${USER}:${GROUP} /app
RUN mkdir -p /app/scripts

COPY run.sh /app/
RUN chmod a+x /app/run.sh

RUN apk --no-cache update && \
    apk add --update --no-cache curl py-pip && \
    apk --no-cache add py-setuptools ca-certificates groff less && \
    apk --no-cache add curl gnupg && \
    pip --no-cache-dir install awscli==${AWS_CLI_VERSION} && \
    rm -rf /var/cache/apk/*

# Installation of kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl \
    -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin

# Download the desired package(s)
RUN curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.6.1.1-1_amd64.apk
RUN curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_17.6.1.1-1_amd64.apk


# (Optional) Verify signature, if 'gpg' is missing install it using 'apk add gnupg':
RUN curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.6.1.1-1_amd64.sig
RUN curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_17.6.1.1-1_amd64.sig

RUN curl https://packages.microsoft.com/keys/microsoft.asc  | gpg --import -
RUN gpg --verify msodbcsql17_17.6.1.1-1_amd64.sig msodbcsql17_17.6.1.1-1_amd64.apk
RUN gpg --verify mssql-tools_17.6.1.1-1_amd64.sig mssql-tools_17.6.1.1-1_amd64.apk


# Install the package(s)
RUN apk add --allow-untrusted msodbcsql17_17.6.1.1-1_amd64.apk
RUN apk add --allow-untrusted mssql-tools_17.6.1.1-1_amd64.apk

# Adding SQL Server tools to $PATH
ENV PATH=$PATH:/opt/mssql-tools/bin

RUN rm -f msodbcsql*.sig mssql-tools*.apk

USER ${USER_ID}

FROM base AS safe
COPY scripts/safe/*.sh /app/scripts/
ENTRYPOINT ["tail", "-f", "/dev/null"]