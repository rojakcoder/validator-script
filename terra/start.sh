#!/bin/bash

# This script is meant to be run as a user.

# The following prerequisite steps are meant to be run as root.

## Create a non-root user. (Copy and run)
#> USER={USER}
#> useradd -m -s /bin/bash $USER
#> usermod -aG sudo $USER
#> passwd $USER
#> cp -r .ssh /home/$USER
#> chown -R $USER:$USER /home/$USER/.ssh
#> chmod 644 /home/$USER/.ssh/authorized_keys

## Enable sudo without password.
#> echo "$USER ALL=NOPASSWD: ALL" >> /etc/sudoers

## Change the default port and remove root SSH
#> vi /etc/ssh/sshd_config
## Port 8888
## PermitRootLogin no
## PasswordAuthentication no
## systemctl restart sshd

# Actual steps to run.

## Update the repos.
echo "Updating the system"
echo "==================="
sudo apt-get update && sudo apt-get upgrade -y

# Installation of build tools.
echo "Installing build tools"
echo "======================"
sudo apt-get install -y  build-essential
sudo apt-get install -y jq

# System configuration
echo "Configuration"
echo "============="
echo -n "Updating bash profile"
echo "export GOROOT=/usr/local/go" >> ~/.profile
echo "export GOPATH=$HOME/go" >> ~/.profile
source ~/.profile
echo "export PATH=$GOPATH/bin:$GOROOT/bin:$PATH" >> ~/.profile
source ~/.profile
echo " - done"

echo "Software installation"
echo "====================="
mkdir /home/$USER/downloads

# Installation of Go 
echo "Installing Go"
echo "-------------"
cd /home/$USER/downloads
curl -o go1.16.3.linux-amd64.tar.gz https://dl.google.com/go/go1.16.3.linux-amd64.tar.gz
sudo tar -C /usr/local -zxvf go1.16.3.linux-amd64.tar.gz
echo -n "Installed "
/usr/local/go/bin/go version

# Installation of terrad
echo "Installing terrad"
echo "-----------------"
mkdir /home/$USER/go
cd /home/$USER/downloads
git clone https://github.com/terra-project/core
cd /home/$USER/downloads/core
git checkout v0.4.6
make install
echo -n "Installed terrad "
terrad version

# Add alias `tc` and `td` for faster typing
cd /home/$USER/downloads
echo -n "Adding autocompletion for terrad & terracli commands"
# Add autocompletion.
terrad completion > terrad_completion
terracli completion > terracli_completion
cat terrad_completion >> ~/.bash_aliases
cat terracli_completion >> ~/.bash_aliases
source ~/.profile
echo " - done"

# Install the Price Server
echo "Downloading Node.js"
echo "-------------------"
cd /home/$USER/downloads
wget https://nodejs.org/dist/v14.16.1/node-v14.16.1-linux-x64.tar.xz
tar -xvf node-v14.16.1-linux-x64.tar.xz
cd node-v14.16.1-linux-x64/
sudo mv -i bin/* /usr/local/bin/
rmdir bin
sudo mv -i include/node /usr/local/include/
rmdir include/
sudo mv -i lib/node_modules /usr/local/lib/
rmdir lib
sudo mv -i share/doc /usr/local/share/
sudo mv -i share/man/man1 /usr/local/share/man/
rmdir share/man
sudo mv -i share/systemtap /usr/local/share/
rmdir share
rm CHANGELOG.md
rm LICENSE
rm README.md
cd ..
rmdir node-v14.16.1-linux-x64

# Install the Oracle Feeder and Price Server
echo "Downloading Oracle Feeder"
echo "-------------------------"
cd /home/$USER
git clone https://github.com/terra-project/oracle-feeder.git

echo "- Installing Feeder."
cd /home/$USER/oracle-feeder/feeder
/usr/local/bin/npm install

echo "- Installing Price Server."
cd /home/$USER/oracle-feeder/price-server
/usr/local/bin/npm install
echo "Making a default configuration file. REMEMBER TO CHANGE config/default.js"
cp config/default-sample.js config/default.js

