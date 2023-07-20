#!/bin/bash

set -e
set -o pipefail
set -u


os="$(lsb_release --id --short) $(lsb_release --release --short)"
echo "Checking operating system... ${os}"
if [ "${os}" != "Ubuntu 22.04" ]; then
  {
    echo "$(lsb_release --description --short) is not supported"
  } >&2  # echo to stderr
  exit 1
fi

echo -n "Checking for database configuration... "
if [ -e "databases.yaml" ]; then
  echo "found"
else
  echo "missing"
  {
    echo
    echo -n "Download the database configuration (databases.yaml) "
    echo    "and place it in the current directory ($PWD)"
  } >&2  # echo to stderr
  exit 1
fi

echo
echo "Starting setup..."
echo


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

# enable PHP error reporting
cat - > ~/public_html/.htaccess <<- .htaccess
php_flag display_errors on
php_flag html_errors on
.htaccess


# stop echoing commands to terminal
set +x


echo
echo "Setup completed successfully!"
