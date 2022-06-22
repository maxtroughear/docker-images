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

PACKAGES_DIR="${BASE_DIR}/vendor"

export DEBIAN_FRONTEND=noninteractive

cd "$PACKAGES_DIR"

# Do not install recommended or suggested packages
echo 'APT::Get::Install-Recommends "false";' >> /etc/apt/apt.conf
echo 'APT::Get::Install-Suggests "false";' >> /etc/apt/apt.conf

# Install common packages
apt-get update && apt-get install -y tzdata ca-certificates gnupg2 apt-transport-https lsb-release git zip wget devscripts

# Install any missing packages
apt-get -f install -y

ARCH="$(dpkg --print-architecture)"
DISTRIBUTION="$(lsb_release -sc)"

apt-key adv --fetch-keys https://rspamd.com/apt-stable/gpg.key
echo "deb-src https://rspamd.com/apt-stable/ ${DISTRIBUTION} main" > /etc/apt/sources.list.d/rspamd.list

apt-get update
apt-get source rspamd=${VERSION_TO_BUILD}-1~${DISTRIBUTION}
apt build-dep rspamd=${VERSION_TO_BUILD}-1~${DISTRIBUTION}

cd rspamd-${VERSION_TO_BUILD}

debuild -uc -us

cd "$PACKAGES_DIR"

mkdir output
cp rspamd_${VERSION_TO_BUILD}-1~${DISTRIBUTION}_${ARCH}.deb ./output
