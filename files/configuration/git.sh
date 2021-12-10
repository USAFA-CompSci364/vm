#!/bin/bash

set -e
set -o pipefail
set -u


# global configuration
for key in name email; do
  echo -n "Please enter your $key for your Git configuration: "
  read value

  git config --global "user.$key" "$value"
done
