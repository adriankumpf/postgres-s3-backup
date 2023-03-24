ARG POSTGRES_VERSION=15
FROM postgres:${POSTGRES_VERSION}

RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y -q gnupg xz-utils awscli

COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

CMD ["/app/run.sh"]
