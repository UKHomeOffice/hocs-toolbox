FROM postgres:9.6-alpine

ENV USER hocs
ENV USER_ID 1000
ENV GROUP hocs
ENV NAME hocs-toolbox
ENV PGDATA /app/data

WORKDIR /app

RUN addgroup ${GROUP} && \
    adduser -u ${USER_ID} -G ${GROUP} -h /app -D ${USER} 
RUN mkdir -p /app && \
    chown -R ${USER}:${GROUP} /app
RUN mkdir -p /app/scripts && \
    chown -R ${USER}:${GROUP} /app/scripts

COPY run.sh /app/
RUN chmod a+x /app/run.sh

COPY scripts/*.sh /app/scripts/
RUN chmod a+x /app/scripts/*.sh

USER ${USER_ID}

CMD /app/run.sh
