FROM alpine:3.14

ENV USER hocs
ENV USER_ID 1000
ENV GROUP hocs
ENV NAME hocs-migration-toolbox
ENV AWS_CLI_VERSION 1.16.207

WORKDIR /app

RUN apk update && apk add bash

RUN addgroup ${GROUP} &&\
    adduser -u ${USER_ID} -G ${GROUP} -h /app -D ${USER} &&\
    mkdir -p /app/scripts &&\
    chown -R ${USER}:${GROUP} /app &&\
    mkdir -p /app/scripts

COPY run.sh /app/
RUN chmod a+x /app/run.sh

RUN apk --no-cache update &&\
    apk add --update --no-cache curl py-pip &&\
    apk --no-cache add py-setuptools ca-certificates groff less &&\
    apk --no-cache add curl gnupg &&\
    pip --no-cache-dir install awscli==${AWS_CLI_VERSION} &&\
    rm -rf /var/cache/apk/*

# Installation of kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl \
    -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl &&\
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin && \

# Download the desired package(s)
    curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.6.1.1-1_amd64.apk &&\
    curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_17.6.1.1-1_amd64.apk &&\

# (Optional) Verify signature, if 'gpg' is missing install it using 'apk add gnupg':
    curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.6.1.1-1_amd64.sig &&\
    curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_17.6.1.1-1_amd64.sig &&\
    curl https://packages.microsoft.com/keys/microsoft.asc  | gpg --import - &&\
    gpg --verify msodbcsql17_17.6.1.1-1_amd64.sig msodbcsql17_17.6.1.1-1_amd64.apk &&\
    gpg --verify mssql-tools_17.6.1.1-1_amd64.sig mssql-tools_17.6.1.1-1_amd64.apk &&\

# Install the package(s)
    apk add --allow-untrusted msodbcsql17_17.6.1.1-1_amd64.apk mssql-tools_17.6.1.1-1_amd64.apk &&\

# Remove installation files
    rm -f msodbcsql*.sig msodbcsql*.apk mssql-tools*.sig mssql-tools*.apk

# Adding SQL Server tools to $PATH
ENV PATH=$PATH:/opt/mssql-tools/bin
USER ${USER_ID}
COPY scripts/safe/*.sh /app/scripts/
COPY scripts/safe/db/migration /app/scripts/
CMD /app/run.sh
