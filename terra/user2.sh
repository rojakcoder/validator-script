#!/bin/bash

# This script performs the checks on a downloaded snapshot from terra.quicksync.io

if [[ -z "${SNAPSHOT_FILE}" ]]; then
  echo "ERROR: Environment variable 'SNAPSHOT_FILE' must be defined first. E.g."
  echo "    export SNAPSHOT_FILE=columbus-5-pruned.20211106.0210.tar.lz4"
  echo "This file can be obtained by running the command below (URL from terra.quicksync.io)"
  echo "    wget https://get.quicksync.io/${SNAPSHOT_FILE}"
  echo "(Use aria2c for faster download but more disk space required.)"
  echo "    aria2c -x5 https://get.quicksync.io/${SNAPSHOT_FILE}"
  exit
fi

if [[ -z "${TERRA_DIR}" ]]; then
  echo "ERROR: Environment variable 'TERRA_DIR' must be defined first. E.g."
  echo "    export TERRA_DIR=/mnt/col5b"
  echo "This specifies the directory to extract the snapshot contents to. This directory must exist."
  exit
fi

# Ensures the tools are installed.
sudo apt-get install liblz4-tool -y

# Get the script that validates the checksum.
wget https://raw.githubusercontent.com/chainlayer/quicksync-playbooks/master/roles/quicksync/files/checksum.sh

# Gets the checksum file.
wget https://getsin.quicksync.io/${SNAPSHOT_FILE}.checksum

# Checks the checksum.
curl -s https://lcd.terra.dev/txs/`curl -s https://getsin.quicksync.io/${SNAPSHOT_FILE}.hash` | jq -r '.tx.value.memo' | sha512sum -c

# Checks the file.
bash checksum.sh ${SNAPSHOT_FILE}

# Unpack the file
lz4 -d ${SNAPSHOT_FILE} | tar -C ${TERRA_DIR} xf -
