#!/bin/bash

set -e
set -o pipefail
set -u


if [ $# -lt 1 ]; then
  cat <<- Usage
	Usage: $(basename "$0") path
	where <path> is the path to a file specifying the databases to create
	Usage
  exit 1
fi

path="$1"
shift


# echo commands to terminal
set -x


while read -r line; do
  read -r database url <<<$(echo "$line" | sed 's/:/ /')

  # download database dump
  filename="$(mktemp)"
  curl --cookie-jar $(mktemp) --fail --location --output "$filename" "$url"

  # drop and (re)create database
  sudo -H -u postgres dropdb --if-exists "$database"
  sudo -H -u postgres createdb "$database"

  # load database dump
  $(dirname "$0")/postgresql/load-database.sh "$database" < "$filename"

  # grant privileges to database users
  sudo -H -u postgres psql --dbname="$database" --echo-queries <<-SQL
	-- grant read access to all tables
	GRANT SELECT ON ALL TABLES IN SCHEMA public TO PUBLIC;
	SQL

  while read -r line; do
    read -r username password <<<$(echo "$line" | sed 's/:/ /')

    sudo -H -u postgres psql --dbname="$database" --echo-queries <<-SQL
	-- grant access to create tables (with foreign keys)
	GRANT CREATE ON SCHEMA public TO $username;
	GRANT REFERENCES ON ALL TABLES IN SCHEMA public TO $username;
	SQL
  done < $(dirname "$0")/users.yaml
done < "$path"
