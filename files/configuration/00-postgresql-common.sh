#!/bin/bash

set -e
set -o pipefail
set -u


# echo commands to terminal
set -x


# configure PostgreSQL backports
echo | sh /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
