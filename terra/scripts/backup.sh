#!/bin/bash

# TERRA #
USER_TERRA=
SERVER_TERRA=
SSH_PORT=22

BU_TERRA_FOLDER=./backup/terra-validator4/
BU_TERRA_CONFIG=${BU_TERRA_FOLDER}config/
BU_TERRA_PRICE=${BU_TERRA_FOLDER}price-server/
BU_TERRA_FEEDER=${BU_TERRA_FOLDER}feeder/

mkdir -p $BU_TERRA_CONFIG
mkdir -p $BU_TERRA_PRICE
mkdir -p $BU_TERRA_FEEDER

#Backup .terra folder.
rsync $USER_TERRA@$SERVER_TERRA:.terra/config/ $BU_TERRA_CONFIG -e "ssh -p $SSH_PORT" --delete --exclude-from=../excludes.txt -vzrc
#Copy the validator key separately.
rsync $USER_TERRA@$SERVER_TERRA:.terra/config/priv_validator_key.json $BU_TERRA_FOLDER -e "ssh -p $SSH_PORT" -vzc

#Backup price server
rsync $USER_TERRA@$SERVER_TERRA:oracle-feeder/price-server/config/default.js $BU_TERRA_PRICE -e "ssh -p $SSH_PORT" -vzrc

#Backup oracle feeder
rsync $USER_TERRA@$SERVER_TERRA:oracle-feeder/feeder/voter.json $BU_TERRA_FEEDER -e "ssh -p $SSH_PORT" -vzrc

#Backup the system configuration files.
rsync $USER_TERRA@$SERVER_TERRA:/etc/systemd/system/price-server.service $BU_TERRA_FOLDER -e "ssh -p $SSH_PORT" -vzc
rsync $USER_TERRA@$SERVER_TERRA:/etc/systemd/system/feeder.service $BU_TERRA_FOLDER -e "ssh -p $SSH_PORT" -vzc
rsync $USER_TERRA@$SERVER_TERRA:/etc/systemd/system/terrad.service $BU_TERRA_FOLDER -e "ssh -p $SSH_PORT" -vzc
