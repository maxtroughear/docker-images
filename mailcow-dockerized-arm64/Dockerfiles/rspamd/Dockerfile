FROM alpine:3.16

RUN apk add --no-cache \
  bash \
  tzdata \
  ca-certificates \
  netcat-openbsd \
  redis \
  procps \
  nano \
  bind-tools \
  rspamd \
  rspamd-client \
  rspamd-controller \
  rspamd-fuzzy \
  rspamd-proxy \
  rspamd-utils

RUN adduser \
  --quiet \
  --system \
  --group \
  --home /var/lib/rspamd \
  --no-create-home \
  --disabled-login \
  --gecos "rspamd spam filtering system" \
  --force-badname \
  _rspamd \
  && mkdir -p /var/lib/rspamd /var/log/rspamd || true \
  && chown _rspamd: /var/lib/rspamd /var/log/rspamd

RUN mkdir -p /run/rspamd \
  && chown _rspamd:_rspamd /run/rspamd \
  && echo 'alias ll="ls -la --color"' >> ~/.bashrc \
  && sed -i 's/#analysis_keyword_table > 0/analysis_cat_table.macro_exist == "M"/g' /usr/share/rspamd/lualib/lua_scanners/oletools.lua

COPY settings.conf /etc/rspamd/settings.conf
COPY metadata_exporter.lua /usr/share/rspamd/plugins/metadata_exporter.lua
COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

STOPSIGNAL SIGTERM

CMD ["/usr/sbin/rspamd", "-f", "-u", "_rspamd", "-g", "_rspamd"]
