#!/usr/bin/env bash

# Original build script https://github.com/lbausch/sogo-debian-packaging
# Adapted to build on arm64 as well

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

REPOSITORY_SOGO="https://github.com/inverse-inc/sogo.git"
REPOSITORY_SOPE="https://github.com/inverse-inc/sope.git"
SOGO_GIT_TAG="SOGo-${VERSION_TO_BUILD}"
SOPE_GIT_TAG="SOPE-${VERSION_TO_BUILD}"

PACKAGES_DIR="${BASE_DIR}/vendor"
PACKAGES_TO_INSTALL="git zip wget make cmake debhelper gnustep-make libssl-dev libgnustep-base-dev libldap2-dev libytnef0-dev zlib1g-dev libpq-dev libmariadbclient-dev-compat libmemcached-dev liblasso3-dev libcurl4-gnutls-dev devscripts libexpat1-dev libpopt-dev libsbjson-dev libsbjson2.3 libcurl4 liboath-dev libsodium-dev libzip-dev"

export DEBIAN_FRONTEND=noninteractive

cd "$PACKAGES_DIR"

# Do not install recommended or suggested packages
echo 'APT::Get::Install-Recommends "false";' >> /etc/apt/apt.conf
echo 'APT::Get::Install-Suggests "false";' >> /etc/apt/apt.conf

# Install required packages
# shellcheck disable=SC2086
apt-get update && apt-get install -y $PACKAGES_TO_INSTALL

# Checkout libwbxml
git clone --depth 1 --branch libwbxml-0.11.8 https://github.com/libwbxml/libwbxml.git
cd libwbxml

# Build libwbxml
mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX=$prefix ..
make
make test
make install

cd "$PACKAGES_DIR"

# Install any missing packages
apt-get -f install -y

# Install Python
apt-get install -y python2

# Checkout the SOPE repository with the given tag
git clone --depth 1 --branch "${SOPE_GIT_TAG}" $REPOSITORY_SOPE
cd sope

cp -a packaging/debian debian

./debian/rules

dpkg-checkbuilddeps && dpkg-buildpackage

cd "$PACKAGES_DIR"

# Install the built packages
dpkg -i libsope*.deb

# Checkout the SOGo repository with the given tag
git clone --depth 1 --branch "${SOGO_GIT_TAG}" $REPOSITORY_SOGO
cd sogo

cp -a packaging/debian debian

dch --newversion "$VERSION_TO_BUILD" "Automated build for version $VERSION_TO_BUILD"

# cp packaging/debian-multiarch/control-no-openchange debian

./debian/rules

dpkg-checkbuilddeps && dpkg-buildpackage -b

cd "$PACKAGES_DIR"

# Install the built packages
dpkg -i sope4.9-gdl1-mysql_4.9.r1664_*.deb
dpkg -i sope4.9-libxmlsaxdriver_4.9.r1664_*.deb
dpkg -i "sogo_${VERSION_TO_BUILD}_*.deb"
