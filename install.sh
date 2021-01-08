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
sudo apt update

# install and configure packages
for service in $services; do
  sudo apt install --yes $(cat "files/packages/$service")

  # patch configuration (if patches exist)
  for patch in $(ls "files/configuration/patches/$service" | sort); do
    path=${patch:3}  # strip patch number
    path=${path//--/\/}  # replace `--` with `/`
    sudo patch --dry-run -ruN $path < "$patch"
    sudo patch           -ruN $path < "$patch"
  done

  # perform additional configuration (if it exists)
  if [ -e "files/configuration/$service.sh" ]; then
    files/configuration/"$service.sh"
  fi
done
