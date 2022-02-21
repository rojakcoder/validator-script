## Logging

### Gets the log output of a service.

`journalctl -u price-server.service -f`

Note that if the service is running at a "system" level, there may be a need to use `sudo` with the command.

### Lists the logs since a specific time.

`journalctl -u feeder.service --since "2021-12-09 20:00:00"`

`journalctl -S "4 hour ago"`

## Cosmos

### Consensus information

- `curl -Ss localhost:26657/dump_consensus_state`
- `curl -Ss localhost:26657/consensus_state`

## Miscellaneous

### Check disk performance

`sudo hdparm -tT /dev/disk/by-id/scsi-0DO_Volume_columbus5a`

### Disk interfaction

`sudo blkid /dev/sdb`
