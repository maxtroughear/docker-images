FROM debian:bullseye AS BUILDER

ENV DEBFULLNAME GitHubActions
ENV DEBEMAIL githubactions@localhost
ENV SOGO_VERSION 5.6.0

WORKDIR /sogobuild

COPY build.sh ./

RUN touch .env \
  && echo DEBFULLNAME="${DEBFULLNAME}" >> .env \
  && echo DEBEMAIL="${DEBEMAIL}" >> .env \
  && echo VERSION_TO_BUILD="${SOGO_VERSION}" >> .env \
  && mkdir vendor

RUN chmod +x ./build.sh \
  && ./build.sh

FROM debian:bullseye-slim
LABEL maintainer "Andre Peters <andre.peters@servercow.de>"

ARG DEBIAN_FRONTEND=noninteractive
ENV LC_ALL C
ENV GOSU_VERSION 1.14

# Prerequisites
COPY --from=BUILDER /sogobuild/vendor/output/*.deb /sogodebs/

RUN echo "Building from repository" \
  && apt-get update && apt-get install -y --no-install-recommends \
  apt-transport-https \
  ca-certificates \
  gettext \
  gnupg \
  mariadb-client \
  rsync \
  supervisor \
  syslog-ng \
  syslog-ng-core \
  syslog-ng-mod-redis \
  dirmngr \
  netcat-openbsd \
  psmisc \
  wget \
  patch \
  gnustep-base-runtime \
  libcrypt1 \
  libcurl4 \
  libsbjson2.3 \
  libsodium23 \
  gnustep-make \
  libcurl4 \
  libcurl3-gnutls \
  liblasso3 \
  libmemcached11 \
  liboath0 \
  libytnef0 \
  libzip4 \
  && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
  && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true \
  && mkdir /usr/share/doc/sogo \
  && touch /usr/share/doc/sogo/empty.sh \
  && dpkg -i /sogodebs/libwbxml*.deb \
  && dpkg -i /sogodebs/libsope*.deb \
  && dpkg -i /sogodebs/sope*.deb \
  && dpkg -i /sogodebs/libsope*.deb \
  && dpkg -i /sogodebs/sogo_*.deb \
  && dpkg --ignore-depends=libwbxml2-0 -i /sogodebs/sogo-activesync*.deb \
  && rm /sogodebs/*.deb \
  && apt-get autoclean \
  && rm -rf /var/lib/apt/lists/* \
  && touch /etc/default/locale

COPY ./bootstrap-sogo.sh /bootstrap-sogo.sh
COPY syslog-ng.conf /etc/syslog-ng/syslog-ng.conf
COPY syslog-ng-redis_slave.conf /etc/syslog-ng/syslog-ng-redis_slave.conf
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY acl.diff /acl.diff
COPY stop-supervisor.sh /usr/local/sbin/stop-supervisor.sh
COPY docker-entrypoint.sh /

RUN chmod +x /bootstrap-sogo.sh \
  /usr/local/sbin/stop-supervisor.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
