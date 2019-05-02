# TODO pass in postgres version via build-arg & add makefile

FROM postgres:11.2

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y -q curl gnupg xz-utils ca-certificates python3-pip cron

RUN pip3 install awscli

COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

RUN touch /var/log/cron.log && \
    (crontab -l ; echo "15 2 * * * /app/run.sh > /proc/1/fd/1 2>/proc/1/fd/2") | crontab

CMD ["cron", "-f"]
