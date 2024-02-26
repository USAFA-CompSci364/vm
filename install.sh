#!/bin/bash

set -e
set -o pipefail
set -u


# change to script's directory to support relative paths
cd "$(dirname "$0")"


# echo commands to terminal
set -x


services=$@
if [ -z "$services" ]; then
  services=$(cd files/packages/ && ls)
fi


# update package repository
sudo --preserve-env=DEBIAN_FRONTEND apt update --quiet

# install and configure packages
for service in $services; do
  sudo --preserve-env=DEBIAN_FRONTEND \
      apt install --quiet --yes $(cat "files/packages/$service")

  # patch configuration (if patches exist)
  if [ -e "files/install/patches/$service.patch" ]; then
    sudo patch --dry-run -d / -p0 -ruN < "files/install/patches/$service.patch"
    sudo patch           -d / -p0 -ruN < "files/install/patches/$service.patch"
  fi

  # perform additional configuration (if it exists)
  if [ -e "files/install/$service.sh" ]; then
    files/install/"$service.sh"
  fi
done
