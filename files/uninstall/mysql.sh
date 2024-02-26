#!/bin/bash

set -e
set -o pipefail
set -u


# change to script's directory to support relative paths
cd "$(dirname "$0")"


# echo commands to terminal
set -x


# stop MySQL
sudo service mysql stop


# remove MySQL configuration and data
sudo rm -rf /etc/mysql /var/lib/mysql
