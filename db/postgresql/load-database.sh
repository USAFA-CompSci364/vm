#!/bin/bash

set -e
set -o pipefail
set -u


if [ $# -lt 1 ]; then
  cat <<- Usage
	Usage: $(basename "$0") database
	Usage
  exit 1
fi

database="$1"
shift


# echo commands to terminal
set -x


sudo -H -u postgres \
    psql --dbname="$database" --echo-errors --quiet --set=ON_ERROR_STOP=on "$@"
