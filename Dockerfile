FROM quay.io/letsencrypt/letsencrypt

RUN apt-get update && apt-get install -y \
      inotify-tools \
      wget \
      dnsutils \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
      /tmp/* \
      /var/tmp/*

COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
