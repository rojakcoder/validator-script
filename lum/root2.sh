#!/bin/bash

if [[ -z "${LUM_USER}" ]]
then
  echo "ERROR: Environment variable 'LUM_USER' must be defined first. E.g."
  echo "    export LUM_USER=terrau"
  exit
fi

if [[ -d /root/.ssh ]]
then
  echo -n "> Copying SSH keys to new user account..."

  cp -r /root/.ssh  /home/$LUM_USER
  chown -R $LUM_USER:$LUM_USER /home/$LUM_USER/.ssh
  chmod 644 /home/$LUM_USER/.ssh/authorized_keys

  echo "  done."
fi

echo -n "> Enabling sudo without password..."

echo "$LUM_USER ALL=NOPASSWD: ALL" >> /etc/sudoers

echo "  done."

echo -n "> Changing default SSH port, password login, and root configurations..."

sed -i'.bak1' -e 's/^PasswordAuthentication /#PasswordAuthentication /' /etc/ssh/sshd_config
sed -i'.bak2' -e 's/^PermitRootLogin /#PermitRootLogin /' /etc/ssh/sshd_config
echo "Port 9560" >> /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
echo "PermitRootLogin no" >> /etc/ssh/sshd_config
systemctl restart sshd

echo "  done."
