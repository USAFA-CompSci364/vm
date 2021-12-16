#!/bin/bash

set -e
set -o pipefail
set -u


# ensure that shell is interactive (i.e., user can respond to prompt)
if [ -z "${PS1:-}" ]; then
  echo "Non-interactive shell, skipping Git configuration"
  exit
fi

# global configuration
for key in name email; do
  echo -n "Please enter your $key for your Git configuration: "
  read value

  git config --global "user.$key" "$value"
done
