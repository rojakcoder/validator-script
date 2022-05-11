# Fresh new setup

### Initialize the node

A new node needs to be initialized with a moniker. E.g.

    terrad init "Validator A"

This will create a ".terrad" directory in the home folder. It comes with a file that needs to be replaced by one from Mainnet.

    mv -i ~/.terrad/config/genesis.json
    curl {GENESIS_FILE} > ~/.terrad/config/genesis.json
    curl {ADDRBOOK} > ~/.terrad/config/addrbook.json

For the Mainnet (columbus-4), the genesis file can be downloaded from https://columbus-genesis.s3-ap-northeast-1.amazonaws.com/columbus-4-genesis.json (reference [docs.terra.money](https://docs.terra.money/node/join-network.html#download-the-genesis-file)).

~~The address book can be found at https://network.terra.dev/addrbook.json (reference [docs.terra.money](https://docs.terra.money/node/join-network.html#picking-a-network)).~~ The address book is not actually required.

For the Testnet (tequila-0004), the genesis file can be downloaded from https://raw.githubusercontent.com/terra-project/testnet/master/tequila-0004/genesis.json (reference [github.com](https://github.com/terra-project/testnet)).

For Bombay testnet, the genesis file is at https://raw.githubusercontent.com/terra-project/testnet/master/bombay-0007/genesis.json

Update the seeds (~/.terrad/config/config.toml) to begin running the blockchain. The seeds for Mainnet are (reference: [docs.terra.money](https://docs.terra.money/node/join-network.html#define-seed-nodes)):

```
seeds = "87048bf71526fb92d73733ba3ddb79b7a83ca11e@public-seed.terra.dev:26656,b5205baf1d52b6f91afb0da7d7b33dcebc71755f@public-seed2.terra.dev:26656,5fa582d7c9931e5be8c02069d7b7b243c79d25bf@seed.terra.de-light.io:26656"
```

Update the minimum gas prices to prevent spamming (~/.terrad/config/app.toml).

```
minimum-gas-prices = "0.01133uluna,0.15uusd,0.104938usdr,169.77ukrw,428.571umnt,0.125ueur,0.98ucny,16.37ujpy,0.11ugbp,10.88uinr,0.19ucad,0.14uchf,0.19uaud,0.2usgd,4.62uthb,1.25usek"
```

Reference: https://discord.com/channels/566086600560214026/566126728578072586/842861299012468756

Make sure that the data folder points to the actual files by creating a symbolic link to the folder.

    ln -s /mnt/columbus-a/data ~/.terrad/data

The daemon can now be started to run through the blocks.

    terrad start

# Client

## Create the keys

This usually just needs to be done the first time the validator is being set up.

    terracli keys add <keyName>

## Configure the client

```
terracli config node tcp://localhost:26657
terracli config trust-node true
```

Run just one of the following commands:

```
terracli config chain-id columbus-4 # Mainnet
terracli config chain-id tequila-0004 # Testnet
```

## Create the validator

```
terracli tx oracle set-feeder terra139ycju27xcek7n2ulew308p28pdh6a6mdqac5a --from=terra1rjmzlljxwu2qh6g2sm9uldmtg0kj4qgyy27m6x --fees 33954000ukrw
```

## Configure the oracle feeder

    terracli tx oracle set-feeder terra139ycju27xcek7n2ulew308p28pdh6a6mdqac5a --from=terra1rjmzlljxwu2qh6g2sm9uldmtg0kj4qgyy27m6x --fees 33954000ukrw

```
cd $FEEDER_PATH
npm start update-key
```

Requires the mnemonic.

This creates a file voter.json

cd /home/terrau/oracle-feeder/feeder
/usr/local/bin/npm start vote --\
 --source http://localhost:8532/latest \
 --lcd https://lcd.terra.dev \
 --chain-id "${CHAIN_ID}" \
  --denoms sdr,krw,usd,mnt,eur,cny,jpy,gbp,inr,cad,chf,hkd,aud,sgd,thb \
  --validator "${VALIDATOR_KEY}" \
 --password "${ORACLE_PASS}" \
 --gas-prices 169.77ukrw
