#!/bin/bash
cd /home/$USER/oracle-feeder/feeder
/usr/local/bin/npm startjs vote --\
  --source http://localhost:8532/latest \
  --lcd http://localhost:1317 \
  --lcd https://lcd.terra.dev \
  --chain-id "${CHAIN_ID}" \
  --validator "${VALIDATOR_KEY}" \
  --password "${ORACLE_PASS}"
