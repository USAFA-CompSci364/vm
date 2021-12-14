#!/bin/bash

set -e
set -o pipefail
set -u


# change to script's directory to support relative paths
cd "$(dirname "$0")"


# echo commands to terminal
set -x


# start MySQL
sudo service mysql start


# create database users
while read -r line; do
  read -r username password <<<$(echo "$line" | sed 's/:/ /')

  sudo -H mysql --password="$(echo $DB_PASSWORD)" <<-SQL
	-- create user
	CREATE USER '$username'@'localhost' IDENTIFIED BY '$password';

	-- create database for user
	CREATE DATABASE $username;
	GRANT ALL PRIVILEGES ON $username.* TO '$username'@'localhost';
	SQL
done < ../../db/users.yaml
