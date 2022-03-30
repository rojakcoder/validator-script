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

Recommended - change the name of the machine to easily identify it if not already.

sudo hostname {SERVER-NAME}

# user1.sh

This script is to be run as a user in server. It downloads and sets up the software that is needed to get the validator running.

At a high-level, this script downloads and installs the following

- Go 1.17.5
- Terra 0.5.13-oracle
- Node.js 16.13.1
- Oracle Feeder - Price Server (latest in main)
- Oracle Feeder - Feeder (latest in main)

> As the script isn't very robust, it is preferable to copy each command and run it line by line.

## Post setup

After the script has completed running and the applications are downloaded, be sure to update the following:

> /home/$TERRA_USER/oracle-feeder/price-server/config/default.js

### Performance improvement

As it is, running the feeder on `ts-node` consumes over 100 MB of memory. Use the patch file _sample/feeder.patch_ to transpile the TS code into JS.

```bash
cd ~/oracle-feeder/feeder
git apply ~/Downloads/validator-script/terra/sample/feeder.patch
npm run build
```

Then copy _sample/feeder-startjs.sh_ into the _feeder_ directory.

Modify _/etc/systemd/system/feeder.service_ to change `feeder-start.sh` to `feeder-startjs.sh` and reload the daemon.

# Migration

To migrate the validator, the main consideration is whether the blockchain data is available or not. In other words, whether the blockchain data is available on an external storage volume or does it need to be rebuilt. The latter scenario typically happens when moving to a different provider.

Regardless of the scenarios, the steps described in Phase 1 and Phase 3 should be followed. It is Phase 2 where the steps differ depending on the scenario.

## Phase 1

## SSH keys

Regardless of whether the data is migrated or is generated from a snapshot, the replacement server (Server B) should be able to access the origin server (Server A) via SSH.

```bash
# Server B
SERVER_A=server-a
SERVER_B=server-b
SSH_PORT=22
vi /etc/hosts # Create a hosts file entry for the origin server.
ssh-keygen -t ed25519 -C $SERVER_B
ssh-copy-id -i ~/.ssh/id_ed25519.pub -p $SSH_PORT $SERVER_A
```

OPTIONAL: Before running either of the options described next, it is prudent to keep the SSH key in memory because the commands need to be executed quickly.

```bash
eval `ssh-agent`
ssh-add ~/.ssh/id_ed25519.pub
```

## Sync script

Create the following sync script (sync.sh) in Server B:

```bash
#!/bin/bash
rsync $SERVER_A:.terra/config/ ~/.terra/config/ -e 'ssh -p '$SSH_PORT --delete --include-from=$HOME/validator-script/terra/includes.txt -vzrc
# Validator key is not synchronized here as it might be for a new server.
rsync $SERVER_A:oracle-feeder/price-server/config/default.js ~/oracle-feeder/price-server/config/ -e 'ssh -p $SSH_PORT' -vzrc
rsync $SERVER_A:oracle-feeder/feeder/voter.json ~/oracle-feeder/feeder/ -e 'ssh -p $SSH_PORT' -vzrc
rsync $SERVER_A:/etc/systemd/system/price-server.service ~/ -e 'ssh -p $SSH_PORT' -vzrc
rsync $SERVER_A:/etc/systemd/system/feeder.service ~/ -e 'ssh -p $SSH_PORT' -vzrc
rsync $SERVER_A:/etc/systemd/system/terrad.service ~/ -e 'ssh -p $SSH_PORT' -vzrc
```

(No need to move .terra/config/node_key.json - [https://discord.com/channels/566086600560214026/566126867686621185/842673595117207573])

The following commands can be run prior to the stopping of the old server.

```bash
sudo mkdir /mnt/columbus-a
sudo chown $TERRA_USER:$TERRA_USER -R /mnt/columbus-a
bash sync.sh
ln -s /mnt/columbus-a/data ~/.terrad/data
```

Running the sync script will create three systemd service files in the home directory. They are to be moved to _/etc/systemd/system_ after checking for correctness (i.e. ensure that path and user account are correct).

The ownership of these files also need to be set to `root:root`

```bash
sudo chown root:root price-server.service
sudo chown root:root feeder.service
sudo chown root:root terrad.service
sudo mv -i *service /etc/systemd/system/
```

After doing so, the first service that can be started on server-b with no dependencies is the price server.

```bash
sudo systemctl daemon-reload
sudo systemctl start price-server.service
```

The service can be confirmed to be running by executing

```bash
journalctl -u price-server.service -f
```

## Phase 2A: Migration with no pre-existing blockchain data

For a new server, a snapshot of the blockchain needs to be downloaded for quick sync.

### Download a snapshot

DO THIS FIRST AS THIS CAN TAKE A LONG TIME.

Download the snapshot from https://terra.quicksync.io/

```bash
sudo apt-get install -y liblz4-tool aria2
aria2c -x5 https://get.quicksync.io/$SNAPSHOT_FILENAME

# E.g.
# aria2c -x5 https://getsin.quicksync.io/columbus-5-pruned.20211217.0210.tar.lz4
```

After downloading, verify the integrity of the file by using the checksum.sh file provided by the service.

```bash
wget https://get.quicksync.io/${SNAPSHOT_FILENAME}.checksum
# E.g.
# wget https://getsin.quicksync.io/columbus-5-pruned.20211217.0210.tar.lz4.checksum

# Read the transaction hash from the page https://quicksync.io/networks/terra.html according to the mirror the hash is downloaded from.

curl -s https://lcd.terra.dev/txs/$HASH | jq -r '.tx.value.memo' | sha512sum -c

wget https://raw.githubusercontent.com/chainlayer/quicksync-playbooks/master/roles/quicksync/files/checksum.sh

bash checksum.sh $SNAPSHOT_FILENAME check
```

If the checksum passes, it means the file was downloaded properly. The next step is to extract it.

```bash
lz4 -d {SNAPSHOT_FILE} | tar xf - -C /mnt/columbus-a
```

This command extracts the files into /mnt/columbus-a/data (assuming /mnt/columbus-a is a separate storage disk). This can also take a long while (hours) to complete depending on the size and the speed of the disk.

Once the extraction is complete, run `sudo systemctl start terrad` and wait for it to catch up.

Once it is caught up:

1. Stop the old server.
2. Stop the new server.
3. Copy the _priv_validator_key.json_ file to the new node.
4. Copy the _priv_validator_state.json_ file to the new node.
5. Start the new server.

(Reference: https://discord.com/channels/566086600560214026/566126867686621185/806929605629968396)

### Actual migration

The sequence of commands below needs to be **excuted in quick succession**.

```bash
# 1. server-a
sudo systemctl stop terrad
# 2. server-b
sudo systemctl stop terrad
# 3. server-b
rsync $SERVER_A:.terra/config/priv_validator_key.json ~/.terra/config/ -e 'ssh -p $SSH_PORT' -vzc
# 4. server-b
rsync $SERVER_A:.terra/data/priv_validator_state.json ~/.terra/data/ -e 'ssh -p $SSH_PORT' -vzc
# 5. server-b
sudo systemctl start terrad
```

## Phase 2B: Migration with blockchain data available

Prepare the server by making sure that the software components are in place. There is no need to download the blockchain snapshot since the data is already available for migration.

What _needs_ to be done is to re-attach the block storage when doing the migration.

At a high-level, the steps for the migration are:

1. Stop the old server.
2. Unmount the storage volume.
3. Sync the terrad folders over.
4. Mount the storage volume to the new server.
5. Start the new server.

Before following the next steps, it is prudent to reboot the machine and re-run the SSH agent.

```bash
sudo reboot
# After rebooting,
eval `ssh-agent`
ssh-add ~/.ssh/id_ed25519.pub
bash sync.sh
```

### Preparation at the old server

Check that only `terrad` is accessing the mounted folder so that there is no delay in unmounting the drive later.

```bash
lsof +f -- /mnt/columbus-a
```

### Actual migration

The sequence of commands below needs to be **executed in quick succession**.

```bash
# server-a
sudo systemctl stop terrad
umount /dev/sda

# Dashboard: Detach volume from Server A and attach to Server B.

# server-b
bash sync.sh
# Check that the symbolic link works.
sudo mount -o nodiscard,defaults,noatime /dev/disk/by-id/scsi-0DO_Volume_columbus5a /mnt/columbus-a && ls -l ~/.terra/
# Update ownership
sudo chown -R $TERRA_USER:$TERRA_USER /mnt/columbus-a
sudo systemctl start terrad
```

The command to automatically mount the volume needs to be added to /etc/fstab so that the volume is auto-mounted on reboot.

```
/dev/disk/by-id/scsi-0DO_Volume_columbus5a /mnt/columbus-a ext4 defaults,nofail,noatime 0 0
```

## Phase 3

After `terrad` is running as a service, the next service to run is the feeder.

```bash
sudo systemctl start feeder.service
journalctl -u feeder.service -f
```

When the feeder is running smooth for a while, the monitoring script can be started to monitor the oracle feeder's performance.

```bash
bash oracle-monitor.sh terravaloper1rjmzlljxwu2qh6g2sm9uldmtg0kj4qgyy9jx24 http://localhost:1317
```

# Fresh new setup

### Initialize the node

A new node needs to be initialized with a moniker. E.g.

    terrad init "Validator A"

This will create a ".terrad" directory in the home folder. It comes with a file that needs to be replaced by one from Mainnet.

    mv -i ~/.terrad/config/genesis.json
    curl {GENESIS_FILE} > ~/.terrad/config/genesis.json
    curl {ADDRBOOK} > ~/.terrad/config/addrbook.json

For the Mainnet (columbus-4), the genesis file can be downloaded from https://columbus-genesis.s3-ap-northeast-1.amazonaws.com/columbus-4-genesis.json (reference [docs.terra.money](https://docs.terra.money/node/join-network.html#download-the-genesis-file)).

~~The address book can be found at https://network.terra.dev/addrbook.json (reference [docs.terra.money](https://docs.terra.money/node/join-network.html#picking-a-network)).~~ The address book is not actually required.

For the Testnet (tequila-0004), the genesis file can be downloaded from https://raw.githubusercontent.com/terra-project/testnet/master/tequila-0004/genesis.json (reference [github.com](https://github.com/terra-project/testnet)).

For Bombay testnet, the genesis file is at https://raw.githubusercontent.com/terra-project/testnet/master/bombay-0007/genesis.json

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

    ln -s /mnt/columbus-a/data ~/.terrad/data

The daemon can now be started to run through the blocks.

    terrad start

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
