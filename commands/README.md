## Monitoring

### glances

`glances` is a tool to help with monitoring resource consumption.

```bash
sudo apt-get install python3-pip
pip install --user glances
```

## Logging

### Gets the log output of a service.

`journalctl -u price-server.service -f`

Note that if the service is running at a "system" level, there may be a need to use `sudo` with the command.

### Lists the logs since a specific time.

`journalctl -u feeder.service --since "2021-12-09 20:00:00"`

`journalctl -S "4 hour ago"`

## Service Management

### Auto-start

System services need to be made explicitly auto-started. They can run but may not be configured for auto-start upon reboot.

To see if the service has been configured for auto-start:

```bash
systemctl list-unit-files --type=service --state=enabled
```

> Change `enabled` to `disabled` to see the services that do not auto-start.

To make a service start on boot, use the following command:

```bash
sudo systemctl enable cosmos.service
```

## Cosmos

### Node information

- `curl -Ss localhost:1317/node_info`

### Consensus information

- `curl -Ss localhost:26657/dump_consensus_state`
- `curl -Ss localhost:26657/consensus_state`

## Miscellaneous

### Check disk performance

`sudo hdparm -tT /dev/disk/by-id/scsi-0DO_Volume_columbus5a`

### Disk interaction

`sudo blkid /dev/sdb`
