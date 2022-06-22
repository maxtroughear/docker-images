FROM debian:bullseye AS BUILDER

ENV RSPAMD_VERSION 3.2

WORKDIR /build

COPY build.sh ./

RUN touch .env \
  && echo VERSION_TO_BUILD="${RSPAMD_VERSION}" >> .env \
  && mkdir vendor

RUN chmod +x ./build.sh \
  && ./build.sh

FROM debian:bullseye-slim
LABEL maintainer "Andre Peters <andre.peters@tinc.gmbh>"

ARG DEBIAN_FRONTEND=noninteractive
ARG CODENAME=bullseye
ENV LC_ALL C

# Prerequisites
COPY --from=BUILDER /build/vendor/output/*.deb /rspamddebs/
COPY install-rundeps.sh.sh /install-rundeps.sh.sh

RUN apt-get update && apt-get install -y \
  tzdata \
  ca-certificates \
  gnupg2 \
  apt-transport-https \
  dnsutils \
  netcat \
  && apt-get update \
  && apt-get --no-install-recommends -y install redis-tools procps nano libluajit-5.1-2 libglib2.0-0 libsodium23 libunwind8

RUN chmod +x ./install-rundeps.sh.sh \
  && ./install-rundeps.sh.sh

RUN dpkg -i /rspamddebs/rspamd_*.deb \
  && rm /rspamddebs/*.deb \
  && apt-get autoremove --purge \
  && apt-get clean \
  && mkdir -p /run/rspamd \
  && chown _rspamd:_rspamd /run/rspamd \
  && echo 'alias ll="ls -la --color"' >> ~/.bashrc \
  && sed -i 's/#analysis_keyword_table > 0/analysis_cat_table.macro_exist == "M"/g' /usr/share/rspamd/lualib/lua_scanners/oletools.lua

COPY settings.conf /etc/rspamd/settings.conf
COPY metadata_exporter.lua /usr/share/rspamd/plugins/metadata_exporter.lua
COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

STOPSIGNAL SIGTERM

CMD ["/usr/bin/rspamd", "-f", "-u", "_rspamd", "-g", "_rspamd"]
