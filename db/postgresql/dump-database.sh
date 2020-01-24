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
    pg_dump --column-inserts --inserts --jobs=$(nproc --all) "$database" "$@"
