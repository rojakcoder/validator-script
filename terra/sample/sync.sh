#!/bin/bash
USER=
SERVER=
SSH_PORT=22

rsync $USER@$SERVER:.terra/config/ ~/.terra/config/ -e "ssh -p $SSH_PORT" --delete --exclude-from=$HOME/validator-script/terra/excludes.txt -vzrc
# Validator key is not synchronized here as it might be for a new server.
rsync $USER@$SERVER:oracle-feeder/price-server/config/default.js ~/oracle-feeder/price-server/config/ -e "ssh -p $SSH_PORT" -vzrc
rsync $USER@$SERVER:oracle-feeder/feeder/voter.json ~/oracle-feeder/feeder/ -e "ssh -p $SSH_PORT" -vzrc
rsync $USER@$SERVER:/etc/systemd/system/price-server.service ~/ -e "ssh -p $SSH_PORT" -vzrc
rsync $USER@$SERVER:/etc/systemd/system/feeder.service ~/ -e "ssh -p $SSH_PORT" -vzrc
rsync $USER@$SERVER:/etc/systemd/system/terrad.service ~/ -e "ssh -p $SSH_PORT" -vzrc
