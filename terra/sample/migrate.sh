#!/bin/bash

# ./migrate.sh -n
# Performs a dry run.

# ./migrate.sh -t
# Peforms the actual migration.

KEY_FILE=.terra/config/priv_validator_key.json
STATE_FILE=.terra/data/priv_validator_state.json

while getopts tn var
do
  if test $var = "t"
  then
    mkdir -p ~/backup1
    mv -i "~/$KEY_FILE" ~/backup1/
    mv -i "~/$STATE_FILE" ~/backup1/
    rsync terrau@validator2-terra:"$KEY_FILE" ~/.terra/config/ -e 'ssh -p 9560' -vzrc
    rsync terrau@validator2-terra:"$STATE_FILE" ~/.terra/data/ -e 'ssh -p 9560' -vzrc
  else
    echo "Copying "~/$KEY_FILE" to ~/backup"
    echo "Copying "~/$STATE_FILE" to ~/backup"
    rsync terrau@validator2-terra:"$KEY_FILE" ~/.terra/config/  -e 'ssh -p 9560' -vzrcn
    rsync terrau@validator2-terra:"$STATE_FILE" ~/.terra/data/  -e 'ssh -p 9560' -vzrcn
  fi
done

if [[ -f ~/"$KEY_FILE" ]]; then
  key=`md5sum ~/"$KEY_FILE"`
  echo "Key: $key"
else
  echo "~/$KEY_FILE does not exist."
fi

if [[ -f ~/"$STATE_FILE" ]]; then
  state=`md5sum "~/$STATE_FILE"`
  echo "State: $state"
else
  echo "~/$STATE_FILE does not exist."
fi
