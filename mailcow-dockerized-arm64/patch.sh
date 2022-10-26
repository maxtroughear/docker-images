#!/bin/bash

MAILCOW_INSTALL_DIR="/opt/mailcow-dockerized"

# Download and overwrite docker-compose.override.yml if it exists

wget -O ${MAILCOW_INSTALL_DIR}/docker-compose.override.yml https://raw.githubusercontent.com/maxtroughear/docker-images/main/mailcow-dockerized-arm64/docker-compose.override.yml

# Set the DEBIAN_DOCKER_IMAGE variable in ./helper-scripts/backup_and_restore.sh to multi-arch image

cp ${MAILCOW_INSTALL_DIR}/helper-scripts/backup_and_restore.sh ${MAILCOW_INSTALL_DIR}/helper-scripts/backup_and_restore.original.sh
awk '{sub("mailcow/backup","ghcr.io/maxtroughear/mailcow-backup"); print}' ${MAILCOW_INSTALL_DIR}/helper-scripts/backup_and_restore.original.sh > ${MAILCOW_INSTALL_DIR}/helper-scripts/backup_and_restore.sh
