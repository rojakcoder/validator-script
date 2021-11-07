# System services & migration

## Services

### terrad

```bash
sudo cp -i terrad.service /etc/systemd/system/
```

Modify the service file by replacing `$USER` with the correct user.

```bash
sudo vi /etc/systemd/system/terrad.service
sudo systemctl daemon-reload
sudo systemctl start terrad.service
```

### Price Server

```bash
cp -i price-server-start.sh ~/oracle-feeder/price-server/
sudo cp -i price-server.service /etc/systemd/system/
```

Modify the service file by replacing `$USER` with the correct user.

```bash
sudo vi /etc/systemd/system/price-server.service
sudo systemctl daemon-reload
sudo systemctl start price-server.service
```

### Oracle Feeder

```bash
cp -i feeder-start.sh ~/oracle-feeder/feeder/
sudo cp -i feeder.service /etc/system/system/
```

Modify the service file by replacing `$USER` with the correct user.

IMPORTANT: Adjust the environment variables.

```bash
sudo vi /etc/systemd/system/feeder.service
sudo systemctl daemon-reload
sudo systemctl start feeder.service
```

## Migration

### Preparation at the new server

> This section describes the scenario where the data directory resides on an externally mounted volume.

Copy the configuration files over:

```bash
scp ~/.terra/config/priv_validator_key.json terra2.aurastake.com:.terra/config/
scp ~/.terra/config/config.toml terra2.aurastake.com:.terra/config/
scp ~/.terra/config/app.toml terra2.aurastake.com:.terra/config/
scp ~/.terra/config/addrbook.json terra2.aurastake.com:.terra/config/
scp ~/oracle-feeder/price-server/config/default.js terra2.aurastake.com:oracle-feeder/price-server/config/
scp ~/oracle-feeder/feeder/voter.json terra2.aurastake.com:oracle-feeder/feeder/
```

Make the mount directory.

```bash
sudo mkdir /mnt/bombay10a
```

### Deprovisioning at the old server

Check that no other services are accessing the mounted folder.

```bash
lsof | grep /mnt/columbusa
```

```bash
sudo systemctl stop terrad.service
sudo umount /mnt/columbusa
```

### Dashboard

Then unmount the volume from the old server, and mount the volume onto the new server.

### Activation at the new server

```bash
sudo mount -o discard,defaults,noatime /dev/disk/by-id/scsi-columbusa /mnt/columbusa
sudo chown -R ${TERRA_USER}:${TERRA_USER} /mnt/columbusa
sudo systemctl start terrad.service
```

After confirming that the service is running, update the _fstab_ file at **both** servers.

```bash
echo '/dev/disk/by-id/scsi-columbusa /mnt/columbusa ext4 defaults,noatime,nofail,discard 0 0' | sudo tee -a /etc/fstab
```
