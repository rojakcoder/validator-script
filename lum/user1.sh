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
VERSION_GO=1.17.6
echo "Installing Go"
echo "-------------"
cd $HOME/Downloads
wget https://golang.org/dl/go${VERSION_GO}.linux-amd64.tar.gz
sudo tar -C /usr/local -zxvf go${VERSION_GO}.linux-amd64.tar.gz
source ~/.profile
echo -n "Installed "
go version

# Need to download version 1.0.4 if starting from block 0.
VERSION_LUM=v1.0.4
cd $HOME/Downloads
git clone https://github.com/lum-network/chain.git
cd $HOME/Downloads/chain
git checkout $VERSION_LUM
go mod tidy
make install
echo -n "Installed lumd "
lumd version

cd $HOME/Downloads
echo -n "Adding autocompletion for lumd commands..."
# Add autocompletion.
lumd completion > lumd_completion
cat lumd_completion >> ~/.bash_aliases
source ~/.profile
echo "  done."

# 1.0.4 will run until block 90300 and then it will stop by itself.
VERSION_LUM=v1.0.5
cd $HOME/Downloads/chain
git checkout $VERSION_LUM
go mod tidy
make install
