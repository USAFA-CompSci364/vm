#!/bin/bash

set -e
set -o pipefail
set -u


# echo commands to terminal
set -x


#
# pgAdmin 4 documentation: https://www.pgadmin.org/download/pgadmin-4-apt/
#

# install the public key for the repository
curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub \
    | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg --yes

# create apt configuration file
sudo sh -c \
'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] \
     https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) \
     pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'
