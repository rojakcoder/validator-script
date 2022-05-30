## Monitoring

### glances

`glances` is a tool to help with monitoring resource consumption.

```bash
sudo apt-get install python3-pip
pip install --user glances
```

## Logging

### Gets the log output of a service

`journalctl -u price-server.service -f`

Note that if the service is running at a "system" level, there may be a need to use `sudo` with the command.

### List the logs since a specific time

`journalctl -u feeder.service --since "2021-12-09 20:00:00"`

`journalctl -S "4 hour ago"`

### List the logs until a specific time

`journalctl --until "2022-02-24 01:23:00`

### List the logs only from the current boot

`journalctl -u service-name.service -b`

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

### Get the SHA256 hash of a file

```bash
jq -S -c -M '' genesis.json | shasum -a 256
```

### Snippet to view consensus state

```bash
while true; do curl http://localhost:26657/consensus_state | jq '.result.round_state.height_vote_set[0].prevotes_bit_array'; curl http://localhost:26657/dump_consensus_state | jq '.result.round_state.votes[0].prevotes' | grep $(curl -s http://localhost:26657/status | jq -r '.result.validator_info.address[:12]'); sleep 3; echo ----; done
```

### Generate the operator address from the wallet key.

```bash
terrad keys show KEY_NAME --bech val --home ~/.terra --output json | jq -r .address
```

### List the validators in order of voting power

terrad --node http://localhost:26657 query staking validators --limit 1000 -o json | jq -r '.validators[] | [.operator_address, .status, (.tokens|tonumber / pow(10; 6)), .description.moniker] | @csv' | column -t -s"," | sort -k3 -n -r | nl

(Reference: https://discord.com/channels/976127574252060703/976143280800661524/979992980091969546)
