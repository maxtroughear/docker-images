#!/usr/bin/env bash

# Original build script https://github.com/lbausch/sogo-debian-packaging
# Adapted for rspamd and to build on arm64

set -e

# https://stackoverflow.com/a/246128
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Path to config file
CONFIG_FILE="${BASE_DIR}/.env"

# shellcheck disable=SC2086
if [ ! -f "$CONFIG_FILE" ] && [ -z ${CI+x} ]; then
  echo "Error: You need to create a .env file. See .env.example for reference."
  exit 1
fi

# When running in CI do not source configuration file
# shellcheck disable=SC2086
if [ -z ${CI+x} ]; then
  set -a
  # shellcheck source=.env disable=SC1091
  . "$CONFIG_FILE"
  set +a
fi


ARCH="$(dpkg --print-architecture)"
DISTRIBUTION="$(lsb_release -sc)"

PACKAGES_DIR="${BASE_DIR}/vendor"
PACKAGES_TO_INSTALL="tzdata ca-certificates gnupg2 apt-transport-https git zip wget devscripts make cmake debhelper libcurl4-openssl-dev libglib2.0-dev libicu-dev libjemalloc-dev libluajit-5.1-dev libmagic-dev libpcre2-dev libsodium-dev libsqlite3-dev libssl-dev libunwind-dev perl ragel zlib1g-dev"

export DEBIAN_FRONTEND=noninteractive

cd "$PACKAGES_DIR"

# Do not install recommended or suggested packages
echo 'APT::Get::Install-Recommends "false";' >> /etc/apt/apt.conf
echo 'APT::Get::Install-Suggests "false";' >> /etc/apt/apt.conf

# Install required packages
apt-get update && apt-get install -y $PACKAGES_TO_INSTALL

# Install any missing packages
apt-get -f install -y

if [ "$ARCH" = "amd64" ]; then
  apt-get install -y libhyperscan-dev
fi

apt-key adv --fetch-keys https://rspamd.com/apt-stable/gpg.key
echo "deb-src https://rspamd.com/apt-stable/ ${DISTRIBUTION} main" > /etc/apt/sources.list.d/rspamd.list

apt-get update && apt-get source rspamd=${VERSION_TO_BUILD}-1~${DISTRIBUTION}

cd rspamd-${VERSION_TO_BUILD}

debuild -b -uc -us

cd "$PACKAGES_DIR"

mkdir output

cp rspamd_${VERSION_TO_BUILD}-1~${DISTRIBUTION}_${ARCH}.deb
