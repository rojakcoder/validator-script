# Introduction

This folder contains the scripts that streamline the setting up of a validator in the Terra blockchain.

# Prerequisites

Before running any of the scripts, if you are starting from a new server as root, the first thing to do is to create a non-root user.

```
export TERRA_USER=terrau
./root1.sh
```

Then copy the SSH keys that the root user accepts (if any) and enable the user to use `sudo` without entering a password.

```
./root2.sh
```

This script also makes changes to SSH default configurations and extends the resource limits.

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

## Post setup

After the script has completed running and the applications are downloaded, be sure to update the following:

- /home/$USER/oracle-feeder/price-server/config/default.js

# For a new server

For a new server, a snapshot of the blockchain needs to be downloaded for quick sync. The sections below describe the steps for setting up a new node. If running a replacement node, see section "For a replacement server".

## Download a snapshot

Download the snapshot from https://terra.quicksync.io/

    sudo apt-get install -y liblz4-tool aria2
    aria2c -x5 https://get.quicksync.io/{SNAPSHOT_FILE_URL}

E.g.

    aria2c -x5 https://get.quicksync.io/columbus-4-pruned.20210630.0310.tar.lz4

After downloading, verify the integrity of the file by using the checksum.sh file provided by the service.

```
wget {SNAPSHOT_FILE_URL}.checksum # E.g. https://get.quicksync.io/columbus-4-pruned.20210630.0310.tar.lz4.checksum
curl -s https://lcd.terra.dev/txs/`curl -s https://get.quicksync.io/$FILENAME.hash` | jq -r '.tx.value.memo' | sha512sum -c
# E.g. curl -s https://lcd.terra.dev/txs/7E4FEEEAD0BCF5FEA016BA2CAD2E8175F019C87324FAB5208D34E6EFD44EFEC3 | jq -r '.tx.value.memo' | sha512sum -c
wget https://raw.githubusercontent.com/chainlayer/quicksync-playbooks/master/roles/quicksync/files/checksum.sh
bash checksum.sh {SNAPSHOT_FILE} check
```

If the checksum passes, it means the file was downloaded properly. (This process can take several hours.) The next step is to extract it.

    lz4 -d {SNAPSHOT_FILE} | tar xf - -C /mnt/columbus4

This command extracts the files into /mnt/columbus4/data (assuming /mnt/columbus4 is a separate storage disk). This can also take hours to complete.

## Initialize the node

A new node needs to be initialized with a moniker. E.g.

    terrad init "Validator A"

This will create a ".terrad" directory in the home folder. It comes with a file that needs to be replaced by one from Mainnet.

    mv -i ~/.terrad/config/genesis.json
    curl {GENESIS_FILE} > ~/.terrad/config/genesis.json
    curl {ADDRBOOK} > ~/.terrad/config/addrbook.json

For the Mainnet (columbus-4), the genesis file can be downloaded from https://columbus-genesis.s3-ap-northeast-1.amazonaws.com/columbus-4-genesis.json (reference [docs.terra.money](https://docs.terra.money/node/join-network.html#download-the-genesis-file)).

The address book can be found at https://network.terra.dev/addrbook.json (reference [docs.terra.money](https://docs.terra.money/node/join-network.html#picking-a-network)).

For the Testnet (tequila-0004), the genesis file can be downloaded from https://raw.githubusercontent.com/terra-project/testnet/master/tequila-0004/genesis.json (reference [github.com](https://github.com/terra-project/testnet)).

The address book can be found at https://network.terra.dev/testnet/addrbook.json

Update the seeds (~/.terrad/config/config.toml) to begin running the blockchain. The seeds for Mainnet are (reference: [docs.terra.money](https://docs.terra.money/node/join-network.html#define-seed-nodes)):

```
seeds = "87048bf71526fb92d73733ba3ddb79b7a83ca11e@public-seed.terra.dev:26656,b5205baf1d52b6f91afb0da7d7b33dcebc71755f@public-seed2.terra.dev:26656,5fa582d7c9931e5be8c02069d7b7b243c79d25bf@seed.terra.de-light.io:26656"
```

Update the minimum gas prices to prevent spamming (~/.terrad/config/app.toml).

```
minimum-gas-prices = "0.01133uluna,0.15uusd,0.104938usdr,169.77ukrw,428.571umnt,0.125ueur,0.98ucny,16.37ujpy,0.11ugbp,10.88uinr,0.19ucad,0.14uchf,0.19uaud,0.2usgd,4.62uthb,1.25usek"
```

Reference: https://discord.com/channels/566086600560214026/566126728578072586/842861299012468756

Make sure that the data folder points to the actual files by creating a symbolic link to the folder.

    ln -s /mnt/columbus4/data ~/.terrad/data

The daemon can now be started to run through the blocks.

    terrad start

# For a replacement server

Do the same steps for initializing the server. This includes downloading the snapshot file and extracting it.

To do the migration:

1. Stop the old terrad server
2. Copy `.terrad/config/priv_validator_key.json` to the new node.
3. Copy `.terrad/data/priv_validator_state.json` to the new node.

(Reference: [https://discord.com/channels/566086600560214026/566126867686621185/842673595117207573])
(No need to move .terrad/config/node_key.json - [https://discord.com/channels/566086600560214026/566126867686621185/842673595117207573])

# Client

## Create the keys

This usually just needs to be done the first time the validator is being set up.

    terracli keys add <keyName>

## Configure the client

```
terracli config node tcp://localhost:26657
terracli config trust-node true
```

Run just one of the following commands:

```
terracli config chain-id columbus-4 # Mainnet
terracli config chain-id tequila-0004 # Testnet
```

## Create the validator

```
terracli tx oracle set-feeder terra139ycju27xcek7n2ulew308p28pdh6a6mdqac5a --from=terra1rjmzlljxwu2qh6g2sm9uldmtg0kj4qgyy27m6x --fees 33954000ukrw
```

The

## Configure the oracle feeder

    terracli tx oracle set-feeder terra139ycju27xcek7n2ulew308p28pdh6a6mdqac5a --from=terra1rjmzlljxwu2qh6g2sm9uldmtg0kj4qgyy27m6x --fees 33954000ukrw

```
cd $FEEDER_PATH
npm start update-key
```

Requires the mnemonic.

This creates a file voter.json

cd /home/terrau/oracle-feeder/feeder
/usr/local/bin/npm start vote --\
  --source http://localhost:8532/latest \
  --lcd https://lcd.terra.dev \
  --chain-id "${CHAIN_ID}" \
  --denoms sdr,krw,usd,mnt,eur,cny,jpy,gbp,inr,cad,chf,hkd,aud,sgd,thb \
  --validator "${VALIDATOR_KEY}" \
  --password "${ORACLE_PASS}" \
  --gas-prices 169.77ukrw

