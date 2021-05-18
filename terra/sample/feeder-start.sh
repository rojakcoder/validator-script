#!/bin/bash
cd /home/terrau/oracle-feeder/feeder
/usr/local/bin/npm start vote --\
  --source http://localhost:8532/latest \
  --lcd https://lcd.terra.dev \
  --chain-id "${CHAIN_ID}" \
  --denoms sdr,krw,usd,mnt,eur,cny,jpy,gbp,inr,cad,chf,hkd,aud,sgd,thb \
  --validator "${VALIDATOR_KEY}" \
  --password "${ORACLE_PASS}" \
  --gas-prices 169.77ukrw
