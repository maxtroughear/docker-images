FROM alpine:3.17

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

RUN addgroup \
  --system \
  _rspamd \
  && adduser \
  --system \
  --home /var/lib/rspamd \
  --no-create-home \
  --disabled-password \
  --gecos "rspamd spam filtering system" \
  _rspamd \
  _rspamd \
  && mkdir -p /var/lib/rspamd /var/log/rspamd || true \
  && chown _rspamd: /var/lib/rspamd /var/log/rspamd

RUN mkdir -p /run/rspamd \
  && chown _rspamd:_rspamd /run/rspamd \
  && echo 'alias ll="ls -la --color"' >> ~/.bashrc \
  && sed -i 's/#analysis_keyword_table > 0/analysis_cat_table.macro_exist == "M"/g' /usr/share/rspamd/lualib/lua_scanners/oletools.lua

COPY settings.conf /etc/rspamd/settings.conf
COPY metadata_exporter.lua /usr/share/rspamd/plugins/metadata_exporter.lua
COPY set_worker_password.sh /set_worker_password.sh
COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

STOPSIGNAL SIGTERM

CMD ["/usr/sbin/rspamd", "-f", "-u", "_rspamd", "-g", "_rspamd"]
