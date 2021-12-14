#!/bin/bash

set -e
set -o pipefail
set -u


# echo commands to terminal
set -x


# enable per-user web directories (i.e., ~/public_html)
sudo a2enmod userdir
sudo service apache2 restart
