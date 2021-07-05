#!/bin/bash

## Update the repos.
echo "Updating the system"
echo "==================="
sudo apt-get update && sudo apt-get upgrade -y

# Installation of build tools.
echo "Installing build tools"
echo "======================"
sudo apt-get install -y build-essential
sudo apt-get install -y jq

# System configuration
GOPATH=$HOME/go
GOROOT=/usr/local/go
echo "Configuration"
echo "============="
echo -n "Updating bash profile..."
echo "export GOROOT=$GOROOT" >> ~/.profile
echo "export GOPATH=$GOPATH" >> ~/.profile
source ~/.profile
echo "export PATH=$GOPATH/bin:$GOROOT/bin:$PATH" >> ~/.profile
source ~/.profile
echo "  done."

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
echo -n "Adding autocompletion for terrad & terracli commands..."
# Add autocompletion.
terrad completion > terrad_completion
terracli completion > terracli_completion
cat terrad_completion >> ~/.bash_aliases
cat terracli_completion >> ~/.bash_aliases
source ~/.profile
echo "  done."

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

