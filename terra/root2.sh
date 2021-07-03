#!/bin/bash

if [[ -z "${TERRA_USER}" ]]; then
  echo "ERROR: Environment variable 'TERRA_USER' must be defined first. E.g."
  echo "    export TERRA_USER=terrau"
  exit
fi

echo "> Copying SSH keys to new user account..."

cp -r .ssh  /home/$TERRA_USER
chown -R $TERRA_USER:$TERRA_USER /home/$TERRA_USER/.ssh
chmod 644 /home/$TERRA_USER/.ssh/authorized_keys

echo "  Done."

echo "> Enabling sudo without password..."

echo "$TERRA_USER ALL=NOPASSWD: ALL" >> /etc/sudoers

echo "  Done."

echo "> Extending resource limits..."

echo "*                soft    nofile          65535" >> /etc/security/limits.conf
echo "*                hard    nofile          65535" >> /etc/security/limits.conf

echo "  Done."

