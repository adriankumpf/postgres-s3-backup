FROM postgres:12

RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y -q gnupg xz-utils awscli

COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

CMD ["/app/run.sh"]
