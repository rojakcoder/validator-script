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

## Post setup

After the script has completed running and the applications are downloaded, be sure to update the following:

> /home/$TERRA_USER/oracle-feeder/price-server/config/default.js

### Performance improvement

As it is, running the feeder on `ts-node` consumes over 100 MB of memory. Use the patch file _sample/feeder.patch_ to transpile the TS code into JS.

```bash
cd ~/oracle-feeder/feeder
patch package.json ~/validator-script/terra/scripts/feeder.patch
npm run build
```

Then copy _~/validator-script/terra/scripts/feeder-startjs.sh_ into the _feeder_ directory.

Modify _/etc/systemd/system/feeder.service_ to change `feeder-start.sh` to `feeder-startjs.sh` and reload the daemon.

# Migration

To migrate the validator, the main consideration is whether the blockchain data is available or not. In other words, whether the blockchain data is available on an external storage volume or does it need to be rebuilt. The latter scenario typically happens when moving to a different provider.

Regardless of the scenarios, the steps described in Phase 1 and Phase 3 should be followed. It is Phase 2 where the steps differ depending on the scenario.

## Phase 1

### SSH keys

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

### Sync script

Update _sample/sync.sh_ by specifying the user and the host, and use it in Server B to get the files over for the initial sync.

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
# Enable the service and start it immediately.
sudo systemctl enable price-server.service --now
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

Make sure to create a symbolic link to the data directory in the home folder.

```bash
cd ~/.terra
rmdir data
ln -s /mnt/col5/data
```

Once the extraction is complete, run `sudo systemctl start terrad` and wait for it to catch up.

Once it is caught up:

1. Stop the old server.
2. Stop the new server.
3. Copy the _priv_validator_key.json_ file to the new node.
4. Copy the _priv_validator_state.json_ file to the new node.
5. Start the new server.

(Reference: https://discord.com/channels/566086600560214026/566126867686621185/806929605629968396)

Modify _sample/migrate.sh_ by specifying the user and the host, and use it to copy the file from the old server to the new server **after stopping both servers**.

### Actual migration

The sequence of commands below needs to be **excuted in quick succession**.

```bash
# 1. server-a
sudo systemctl stop terrad
# 2. server-b
sudo systemctl stop terrad
# 3. server-b
bash $HOME/validator-script/terra/sample/migrate.sh -t
# 4. server-b
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
# The exact instructions depend on the service provider.

# server-b
bash sync.sh
# Check that the symbolic link works.
sudo mount -o nodiscard,defaults,noatime /dev/disk/by-id/scsi-0DO_Volume_columbus5a /mnt/columbus-a && ls -l ~/.terra/
# Update ownership if necessary.
sudo chown -R $TERRA_USER:$TERRA_USER /mnt/columbus-a
# Modify the migrate script to exclude the state JSON file and run it to get the key file.
bash $HOME/validator-script/terra/sample/migrate.sh -t
sudo systemctl start terrad
```

The command to automatically mount the volume needs to be added to /etc/fstab so that the volume is auto-mounted on reboot.

```
/dev/disk/by-id/scsi-0DO_Volume_columbus5a /mnt/columbus-a ext4 defaults,nofail,noatime 0 0
```

## Phase 3

After `terrad` is running as a service, the next service to run is the feeder.

```bash
sudo systemctl enable feeder.service
sudo systemctl start feeder.service
journalctl -u feeder.service -f
```

When the feeder is running smooth for a while, the monitoring script can be started to monitor the oracle feeder's performance.

```bash
bash oracle-monitor.sh terravaloper1rjmzlljxwu2qh6g2sm9uldmtg0kj4qgyy9jx24 http://localhost:1317
```

# Tips

## Continuous TRIM

One performance tip for SSD storage technologies is the removal of continuous [TRIM](https://www.digitalocean.com/community/tutorials/how-to-configure-periodic-trim-for-ssd-storage-on-linux-servers).

Drives that have continuous TRIM enabled are mounted with the `discard` option. They can be found by running:

`findmnt -O discard`

_If_ there are drives that have this option, they can be remounted in place with the `-o` option:

`sudo mount -o remount,nodiscard /mnt/col`

In the _/etc/fstab_ file, the `discard` property needs to be removed so that when the drives get mounted on boot, continuous TRIM will not be enabled.

## Auto-mounting

To prepare for the case that the server reboots, the external volume needs to be automatically mounted. This can be done by modifying the _/etc/fstab_ file.

Before doing so, check for the UUID of the drive that is mounted. The UUID is used instead of the path is because the mapping can be different.

First determine which is the drive that is mapped to the mount point:

```bash
mount
```

Then list the drives:

```bash
ls -l /dev/disk/by-uuid
```

The IDs are symbolic links to the disk paths. Locate the correct value then modify _/etc/fstab_ by adding the following line:

    UUID=<uuid> /mnt/col5 ext4 defaults,nofail,noatime 0 2

## Periodic TRIM

If continuous TRIM is disabled, periodic TRIM needs to be performed.

Create the cron script _/etc/cron.weekly/fstrim_:

```
#!/bin/sh
/usr/sbin/fstrim --all || true
```

Then make the script executable:

```bash
sudo chmod a+x /etc/cron.weekly/fstrim
```

## Hostname

Some distributions may not set the hostname to match the name set in the dashboard.

The name can be permanently changed using `hostnamectl`:

```bash
sudo hostnamectl set-hostname validator-terra
```
