#!/bin/bash

## Update the repos.
read -p "Perform system update? (y|N) " update_system
if [[ update_system = "y" ]]; then
  echo "Updating the system"
  echo "==================="
  sudo apt-get update && sudo apt-get upgrade -y
fi

read -p "Install build tools? (y|N) " install_tools
if [[ install_tools ]]; then
  # Installation of build tools.
  echo "Installing build tools"
  echo "======================"
  sudo apt-get install -y build-essential
  sudo apt-get install -y jq
fi

# System configuration
GOPATH=$HOME/go
GOROOT=/usr/local/go
read -p "Update environment variables? (y|N) " update_env
if [[ update_env = "y" ]]; then
  echo "Configuration"
  echo "============="
  echo -n "> Updating bash profile..."
  echo "export GOROOT=$GOROOT" >> ~/.profile
  echo "export GOPATH=$GOPATH" >> ~/.profile
  echo "export PATH=$GOPATH/bin:$GOROOT/bin:$PATH" >> ~/.profile
  echo "  done."
fi

echo "Software installation"
echo "====================="
mkdir -p $HOME/Downloads

# Installation of Go
read -p "Please enter the version of Go to install (e.g. 1.17.8). Press enter to skip: " version_go

if [[ -n $version_go ]]; then
  echo "Installing Go"
  echo "-------------"
  cd $HOME/Downloads
  wget https://golang.org/dl/go${version_go}.linux-amd64.tar.gz
  sudo tar -C /usr/local -zxvf go${version_go}.linux-amd64.tar.gz
  source ~/.profile
  echo -n "> Installed Go "
  go version
fi

# Installation of terrad
read -p "Please enter the version of Terra core to install (e.g. v0.5.17). Press enter to skip: " version_core
if [[ -n $version_core ]]; then
  echo "Installing terrad"
  echo "-----------------"
  mkdir -p $HOME/go
  cd $HOME/Downloads
  git clone https://github.com/terra-money/core
  cd $HOME/Downloads/core
  git checkout ${version_core}
  make install
  echo -n "> Installed terrad "
  terrad version
fi

read -p "Proceed with enabling autocomplete with terrad commands? (y|N) " autocomp
if [[ -n $autocomp ]]; then
  cd $HOME/Downloads
  echo -n "> Adding autocompletion for terrad commands..."
  # Add autocompletion.
  terrad completion > terrad_completion
  cat terrad_completion >> ~/.bash_aliases
  source ~/.profile
  echo "  done."
fi

# Install the Price Server
read -p "Please enter the version of Node.js to install (e.g. v16.14.2). Press enter to skip: " version_node
if [[ -n $version_node ]]; then
  echo "Installing Node.js"
  echo "------------------"
  cd $HOME/Downloads
  wget https://nodejs.org/dist/${version_node}/node-${version_node}-linux-x64.tar.xz
  tar -xvf node-${version_node}-linux-x64.tar.xz
  cd node-${version_node}-linux-x64/
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
  rmdir node-${version_node}-linux-x64
  echo -n "> Installed Node.js "
  node --version
fi

read -p "Please enter the version of Oracle Feeder/Price Server to install (e.g. v2.0.2). Press enter to skip: " version_feeder

if [[ -n $version_feeder ]]; then
  # Install the Oracle Feeder and Price Server
  echo "Downloading Oracle Feeder"
  echo "-------------------------"
  cd $HOME
  git clone https://github.com/terra-project/oracle-feeder.git

  cd $HOME/oracle-feeder
  git checkout $version_feeder

  echo "> Installing Feeder."
  cd $HOME/oracle-feeder/feeder
  /usr/local/bin/npm install

  echo "> Installing Price Server."
  cd $HOME/oracle-feeder/price-server
  /usr/local/bin/npm install
  echo "> Making a default configuration file. REMEMBER TO CHANGE config/default.js"
  cp config/default-sample.js config/default.js
fi
