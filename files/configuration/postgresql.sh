#!/bin/bash

set -e
set -o pipefail
set -u


# change to script's directory to support relative paths
cd "$(dirname "$0")"


# parse options
destination=""
while getopts ":d:h" opt; do
  case $opt in
    d )
      destination="$OPTARG"
      ;;
    h )
      cat <<- Usage
		Usage: $(basename "$0") [options]
		where options include the following:
		  -d destination    The base directory for configuration and data
		  -h                Print this help message
		Usage
      exit
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      ;;
    \?)
      echo "Invalid option: $OPTARG" 1>&2
      ;;
  esac
done
shift $((OPTIND - 1))


# echo commands to terminal
set -x


# move configuration and data files to another location (e.g., separate disk)
if [ -n "$destination" ]; then
  # stop the PostgreSQL server
  sudo systemctl stop postgresql

  # move configuration files and replace with symbolic link
  sudo mkdir --parents "$destination/etc/"
  if ! [ -d "$destination/etc/postgresql/" ]; then
    sudo mv /etc/postgresql "$destination/etc/."
  else
    sudo rm -rf /etc/postgresql
  fi
  sudo ln --symbolic "$destination/etc/postgresql/" /etc/.

  # move data files and replace with symbolic link
  sudo mkdir --parents "$destination/var/lib/"
  if ! [ -d "$destination/var/lib/postgresql/" ]; then
    sudo mv /var/lib/postgresql "$destination/var/lib/."
  else
    sudo rm -rf /var/lib/postgresql
  fi
  sudo ln --symbolic "$destination/var/lib/postgresql/" /var/lib/.

  # restart the PostgreSQL server
  sudo systemctl start postgresql
fi

# ensure that the server is running
pg_isready


# add adminpack extension (used by pgAdmin) to template database so it is
# available in all databases (which are created from the template)
sudo -H -u postgres psql --dbname=template1 <<-SQL
	CREATE EXTENSION adminpack;
SQL


# create database users
while read -r line; do
  read -r username password <<<$(echo "$line" | sed 's/:/ /')

  sudo -H -u postgres psql <<-SQL
	-- create user
	CREATE USER $username WITH LOGIN PASSWORD '$password';

	-- create database owned by user
	CREATE DATABASE $username WITH OWNER $username;
	SQL
done < ../../db/users.yaml
