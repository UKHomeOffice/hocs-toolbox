FROM alpine:3.16

USER 0

ENV USER hocs
ENV USER_ID 1000
ENV GROUP hocs
ENV NAME hocs-migration-toolbox

WORKDIR /app

RUN addgroup ${GROUP} &&\
    adduser -u ${USER_ID} -G ${GROUP} -h /app -D ${USER} &&\
    mkdir -p /app/scripts &&\
    chown -R ${USER}:${GROUP} /app &&\
    mkdir -p /app/scripts

RUN apk add --no-cache aws-cli bash ca-certificates curl gnupg
RUN curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.6.1.1-1_amd64.apk &&\
    curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_17.6.1.1-1_amd64.apk &&\
    curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.6.1.1-1_amd64.sig &&\
    curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_17.6.1.1-1_amd64.sig &&\
    curl https://packages.microsoft.com/keys/microsoft.asc  | gpg --import - &&\
    gpg --verify msodbcsql17_17.6.1.1-1_amd64.sig msodbcsql17_17.6.1.1-1_amd64.apk &&\
    gpg --verify mssql-tools_17.6.1.1-1_amd64.sig mssql-tools_17.6.1.1-1_amd64.apk &&\
    apk add --allow-untrusted msodbcsql17_17.6.1.1-1_amd64.apk mssql-tools_17.6.1.1-1_amd64.apk &&\
    rm -f msodbcsql*.sig msodbcsql*.apk mssql-tools*.sig mssql-tools*.apk

USER hocs

# Adding SQL Server tools to $PATH
ENV PATH=$PATH:/opt/mssql-tools/bin

COPY --chown=hocs:hocs ./scripts ./
COPY --chown=hocs:hocs run.sh ./

CMD ["sh", "/app/run.sh"]
