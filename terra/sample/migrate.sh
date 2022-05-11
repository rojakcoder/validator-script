#!/bin/bash

# ./migrate.sh -n
# Performs a dry run.

# ./migrate.sh -t
# Peforms the actual migration.

HOST=
USER=
SSH_PORT=22

KEY_FILE=.terra/config/priv_validator_key.json
STATE_FILE=.terra/data/priv_validator_state.json

while getopts tn var
do
  if test $var = "t"
  then
    mkdir -p ~/backup
    mv -i ~/"$KEY_FILE" ~/backup/
    echo "Moved ~/"$KEY_FILE" to ~/backup"
    mv -i ~/"$STATE_FILE" ~/backup/
    echo "Moved ~/"$STATE_FILE" to ~/backup"
    rsync $USER@$HOST:"$KEY_FILE" ~/.terra/config/ -e "ssh -p $SSH_PORT" -vzrc
    rsync $USER@$HOST:"$STATE_FILE" ~/.terra/data/ -e "ssh -p $SSH_PORT" -vzrc
  else
    echo "Moving ~/"$KEY_FILE" to ~/backup"
    echo "Moving ~/"$STATE_FILE" to ~/backup"
    rsync $USER@$HOST:"$KEY_FILE" ~/.terra/config/ -e "ssh -p $SSH_PORT" -vzrcn
    rsync $USER@$HOST:"$STATE_FILE" ~/.terra/data/ -e "ssh -p $SSH_PORT" -vzrcn
  fi
done

if [[ -f ~/"$KEY_FILE" ]]; then
  key=`md5sum ~/"$KEY_FILE"`
  echo "Key: $key"
else
  echo "~/$KEY_FILE does not exist."
fi

if [[ -f ~/"$STATE_FILE" ]]; then
  state=`md5sum ~/"$STATE_FILE"`
  echo "State: $state"
else
  echo "~/$STATE_FILE does not exist."
fi
