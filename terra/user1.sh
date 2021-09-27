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
echo "export PATH=$GOPATH/bin:$GOROOT/bin:$PATH" >> ~/.profile
echo "  done."

echo "Software installation"
echo "====================="
mkdir -p $HOME/Downloads

# Installation of Go
VERSION_GO=1.16.8
echo "Installing Go"
echo "-------------"
cd $HOME/Downloads
wget https://golang.org/dl/go${VERSION_GO}.linux-amd64.tar.gz
sudo tar -C /usr/local -zxvf go${VERSION_GO}.linux-amd64.tar.gz
source ~/.profile
echo -n "Installed "
go version

# Installation of terrad
VERSION_CORE=v0.4.6
echo "Installing terrad"
echo "-----------------"
mkdir -p $HOME/go
cd $HOME/Downloads
git clone https://github.com/terra-project/core
cd $HOME/Downloads/core
git checkout ${VERSION_CORE}
make install
echo -n "Installed terrad "
terrad version

cd $HOME/Downloads
echo -n "Adding autocompletion for terrad & terracli commands..."
# Add autocompletion.
terrad completion > terrad_completion
terracli completion > terracli_completion
cat terrad_completion >> ~/.bash_aliases
cat terracli_completion >> ~/.bash_aliases
source ~/.profile
echo "  done."

# Install the Price Server
VERSION_NODE=v14.17.6
echo "Downloading Node.js"
echo "-------------------"
cd $HOME/Downloads
wget https://nodejs.org/dist/${VERSION_NODE}/node-${VERSION_NODE}-linux-x64.tar.xz
tar -xvf node-${VERSION_NODE}-linux-x64.tar.xz
cd node-${VERSION_NODE}-linux-x64/
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
rmdir node-${VERSION_NODE}-linux-x64

# Install the Oracle Feeder and Price Server
echo "Downloading Oracle Feeder"
echo "-------------------------"
cd $HOME
git clone https://github.com/terra-project/oracle-feeder.git

VERSION_FEEDER=v1.4.5
echo "Switching to version $VERSION_FEEDER"
cd $HOME/oracle-feeder
git checkout $VERSION_FEEDER

echo "- Installing Feeder."
cd $HOME/oracle-feeder/feeder
/usr/local/bin/npm install

echo "- Installing Price Server."
cd $HOME/oracle-feeder/price-server
/usr/local/bin/npm install
echo "Making a default configuration file. REMEMBER TO CHANGE config/default.js"
cp config/default-sample.js config/default.js
