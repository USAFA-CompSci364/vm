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
sudo --preserve-env=DEBIAN_FRONTEND apt update

# install and configure packages
for service in $services; do
  sudo --preserve-env=DEBIAN_FRONTEND \
      apt install --yes $(cat "files/packages/$service")

  # patch configuration (if patches exist)
  if [ -e "files/configuration/patches/$service.patch" ]; then
    sudo patch --dry-run -d / -p0 -ruN < "files/configuration/patches/$service.patch"
    sudo patch           -d / -p0 -ruN < "files/configuration/patches/$service.patch"
  fi

  # perform additional configuration (if it exists)
  if [ -e "files/configuration/$service.sh" ]; then
    files/configuration/"$service.sh"
  fi
done
