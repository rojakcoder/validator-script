#!/bin/bash

if [[ -z "${LUM_USER}" ]]; then
  echo "ERROR: Environment variable 'LUM_USER' must be defined first. E.g."
  echo "    export LUM_USER=defif"
  exit
fi

echo "> Creating new user '${LUM_USER}'"

useradd -m -s /bin/bash $LUM_USER
usermod -aG sudo $LUM_USER
# Set the password for the user.
passwd $LUM_USER
