#!/bin/bash

if [[ -z "${TERRA_USER}" ]]; then
  echo "ERROR: Environment variable 'TERRA_USER' must be defined first. E.g."
  echo "    export TERRA_USER=terra"
  exit
fi

echo "> Creating new user '${TERRA_USER}'"

useradd -m -s /bin/bash $TERRA_USER
usermod -aG sudo $TERRA_USER
# Set the password for the user.
passwd $TERRA_USER
