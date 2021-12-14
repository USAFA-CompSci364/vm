#!/bin/bash

set -e
set -o pipefail
set -u


if ! [ -e "databases.yaml" ]; then
  {
    echo -n "Please download the database configuration (databases.yaml) "
    echo    "and place it in the current directory ($PWD)"
  } >&2  # echo to stderr
  exit 1
fi


# echo commands to terminal
set -x


cd "$(dirname "$0")"

# install dependencies
./install.sh

# restore databases
db/restore.sh "$OLDPWD/databases.yaml"

# create public_html directory
if ! [ -d ~/public_html ]; then
  mkdir ~/public_html
fi


# stop echoing commands to terminal
set +x


echo
echo "Setup completed successfully!"
