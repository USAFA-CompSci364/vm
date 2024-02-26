#!/bin/bash

set -e
set -o pipefail
set -u


# change to script's directory to support relative paths
cd "$(dirname "$0")"


# echo commands to terminal
set -x


# select services to uninstall
services=$@
if [ -z "$services" ]; then
  services=$(cd files/packages/ && ls)
fi


# remove packages and their configuration
for service in $services; do
  sudo apt purge --yes $(cat "files/packages/$service")

  # perform additional configuration (if it exists)
  if [ -e "files/uninstall/$service.sh" ]; then
    files/uninstall/"$service.sh"
  fi
done

# remove packages' dependencies that were automatically installed
sudo apt autoremove --purge --yes
