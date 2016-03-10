FROM debian:jessie

RUN apt-get update && apt-get install -y \
      cron \
      curl \
      git \
      inotify-tools \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
      /tmp/* \
      /var/tmp/* \
 && git clone https://github.com/Neilpang/le.git \
 && cd le \
 && ./le.sh install

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
