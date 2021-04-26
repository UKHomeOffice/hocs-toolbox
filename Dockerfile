FROM postgres:9.6-alpine

ENV USER hocs
ENV USER_ID 1000
ENV GROUP hocs
ENV NAME hocs-toolbox
ENV PGDATA /app/data
ENV AWS_CLI_VERSION 1.16.207

WORKDIR /app

RUN addgroup ${GROUP} && \
    adduser -u ${USER_ID} -G ${GROUP} -h /app -D ${USER} 
RUN mkdir -p /app && \
    chown -R ${USER}:${GROUP} /app
RUN mkdir -p /app/scripts

COPY run.sh /app/
RUN chmod a+x /app/run.sh

COPY scripts/*.sh /app/scripts/
RUN chmod a+x /app/scripts/*.sh
RUN chown -R ${USER}:${GROUP} /app/scripts

# Installation of AWS CLI
RUN apk --no-cache update && \
    apk add --update --no-cache curl py-pip && \
    apk --no-cache add py-setuptools ca-certificates groff less && \
    pip --no-cache-dir install awscli==${AWS_CLI_VERSION} && \
    rm -rf /var/cache/apk/*
    
RUN mkdir /data && chown ${USER_ID} /data

# Installation of kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl \
    -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin

USER ${USER_ID}
CMD /app/run.sh
