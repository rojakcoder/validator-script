#!/bin/bash

# TERRA #
USER_TERRA=terrau
SERVER_TERRA=terra-validator
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

# LUM #
USER_LUM=defif
SERVER_LUM=lum-a
SSH_PORT=9560

BU_LUM_FOLDER=./backup/lum-validator1/
BU_LUM_CONFIG=${BU_LUM_FOLDER}config/

mkdir -p $BU_LUM_CONFIG

#Backup .lum folder.
rsync $USER_LUM@$SERVER_LUM:.lumd/config/ $BU_LUM_CONFIG -e "ssh -p $SSH_PORT" --delete --exclude-from=../excludes.txt -vzrc
#Copy the validator key separately.
rsync $USER_LUM@$SERVER_LUM:.lumd/config/priv_validator_key.json $BU_LUM_FOLDER -e "ssh -p $SSH_PORT" -vzc

#Backup the system configuration files.
rsync $USER_LUM@$SERVER_LUM:/etc/systemd/system/lumd.service $BU_LUM_FOLDER -e "ssh -p $SSH_PORT" -vzc

# DESMOS #
USER_DESMOS=defif
SERVER_DESMOS=lum-a
SSH_PORT=9560

BU_DESMOS_FOLDER=./backup/desmos-validator1/
BU_DESMOS_CONFIG=${BU_DESMOS_FOLDER}config/

mkdir -p $BU_DESMOS_CONFIG

#Backup .lum folder.
rsync $USER_DESMOS@$SERVER_DESMOS:.desmos/config/ $BU_DESMOS_CONFIG -e "ssh -p $SSH_PORT" --delete --exclude-from=../excludes.txt -vzrc
#Copy the validator key separately.
rsync $USER_DESMOS@$SERVER_DESMOS:.desmos/config/priv_validator_key.json $BU_DESMOS_FOLDER -e "ssh -p $SSH_PORT" -vzc

#Backup the system configuration files.
rsync $USER_DESMOS@$SERVER_DESMOS:/etc/systemd/system/desmos.service $BU_DESMOS_FOLDER -e "ssh -p $SSH_PORT" -vzc
# rsync $USER_LUM@$SERVER_LUM:/etc/systemd/system/lumd.service $BU_LUM_FOLDER -e "ssh -p $SSH_PORT" -vzc

# KNSTL #
USER_KNSTL=konu
SERVER_KNSTL=lum-a
SSH_PORT=9560

BU_KNSTL_FOLDER=./backup/konstellation-validator1/
BU_KNSTL_CONFIG=${BU_KNSTL_FOLDER}config/

mkdir -p $BU_KNSTL_CONFIG

#Backup .lum folder.
rsync $USER_KNSTL@$SERVER_KNSTL:.knstld/config/ $BU_KNSTL_CONFIG -e "ssh -p $SSH_PORT" --delete --exclude-from=../excludes.txt -vzrc
#Copy the validator key separately.
rsync $USER_KNSTL@$SERVER_KNSTL:.knstld/config/priv_validator_key.json $BU_KNSTL_FOLDER -e "ssh -p $SSH_PORT" -vzc

#Backup the system configuration files.
rsync $USER_KNSTL@$SERVER_KNSTL:/etc/systemd/system/knstl.service $BU_KNSTL_FOLDER -e "ssh -p $SSH_PORT" -vzc
