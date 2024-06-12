FROM quay.io/ukhomeofficedigital/hocs-base-image:4.1.5

USER 0

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y awscli ca-certificates postgresql-client python3-pip && \
    apt-get clean

# Version-lock SQLAlchemy due to current pandas(==1.5.3) incompatibility with sqlalchemy>=2.0
RUN pip3 install \
    pandas \
    matplotlib \
    sqlalchemy==1.4.46 \
    psycopg2-binary \
    scikit-learn \
    seaborn[stats]

USER 10000

WORKDIR /app

COPY --chown=user_hocs:group_hocs ./scripts ./

ENTRYPOINT tail -f /dev/null
