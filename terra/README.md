# Introduction

This folder contains the scripts that streamline the setting up of a validator in the Terra blockchain.

# Prerequisites

Before running any of the scripts, if you are starting from a new server as root, the first thing to do is to create a non-root user.

```
USER=terrau
useradd -m -s /bin/bash $USER
usermod -aG sudo $USER
# Set the password for the user.
passwd $USER
```

Then copy the SSH keys that the root user accepts (if any).

```
cp -r .ssh  /home/$USER
chown -R $USER:$USER /home/$USER/.ssh
chmod 644 /home/$USER/.ssh/authorized_keys
```

Enable the user to use sudo without entering a password.

```
echo "$USER ALL=NOPASSWD: ALL" >> /etc/sudoers
```

Recommended - change the default port and remove root SSH.

```
# Port 8888
# PermitRootLogin no
# PasswordAuthentication no
```

Then restart the server: `systemctl restart sshd `

Recommended - change the name of the machine to easily identify it.

sudo hostname {SERVER-NAME}

# start.sh

This script is to be run as a user in server. It downloads and sets up the software that is needed to get the validator running.

At a high-level, this script downloads and installs the following

- Go 1.16.3
- Terra 0.4.6
- Node.js 14.16.1
- Oracle Feeder - Price Server 1.10
- Oracle Feeder - Feeder 1.10

# Post setup

After the Terra application is installed, the next step is to configure it.

## Download a snapshot

Download the snapshot from https://terra.quicksync.io/

    aria2c -x5 https://get.quicksync.io/columbus-4-pruned.20210515.0310.tar.lz4

# After downloading, verify the integrity of the file by using the checksum.sh file provided.
wget {SNAPSHOT_FILE_URL}.checksum
curl -s https://lcd.terra.dev/txs/`curl -s https://get.quicksync.io/$FILENAME.hash`|jq -r '.tx.value.memo'|sha512sum -c
wget https://raw.githubusercontent.com/chainlayer/quicksync-playbooks/master/roles/quicksync/files/checksum.sh
bash checksum.sh {SNAPSHOT_FILE} check


## Initialize the node

terrad start

## Configure the client

terracli config chain-id columbus-4
terracli config node tcp://localhost:26657
terracli config trust-node true

## Set the minimum gas prices

// .terrad/config/app.toml
minimum-gas-prices = "0.01133uluna,0.15uusd,0.104938usdr,169.77ukrw,428.571umnt,0.125ueur,0.98ucny,16.37ujpy,0.11ugbp,10.88uinr,0.19ucad,0.14uchf,0.19uaud,0.2usgd,4.62uthb,1.25usek"
// https://discord.com/channels/566086600560214026/566126728578072586/842861299012468756

## Create the validator

