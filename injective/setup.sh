# Setting up a node

## Prerequisites

mkdir -p ~/Downloads
cd ~/Downloads
sudo apt-get install -y unzip

## Using a snapshot for mainnet.

### Check out https://docs.injective.network/docs/staking/mainnet/validate-on-mainnet/sync-from-snapshot/

### Install awscli
mkdir -p ~/Downloads
cd ~/Downloads
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

### Download the snapshot without using any credentials.
aws s3 sync --delete s3://injective-snapshots/mainnet/injectived/data  /mnt/injective/data/ --no-sign-request

### Download the latest binaries.
export INJ_VER=v1.1.1-1636733798 ## Check for the latest at https://github.com/InjectiveLabs/injective-chain-releases/releases
mkdir ~/Downloads/$INJ_VER
cd ~/Downloads/$INJ_VER
wget https://github.com/InjectiveLabs/injective-chain-releases/releases/download/$INJ_VER/linux-amd64.zip

### Unzip and add the binaries to the path.
unzip linux-amd64.zip
sudo mv -i injectived peggo injective-exchange /usr/bin

### Check the version.
injectived version #Version dev (096cbe5)

### Initialize a new chain node.
./mainnet.sh
injectived init $MONIKER --chain-id $CHAIN_ID

### Complete preparations.
cd ~/Downloads
git clone https://github.com/InjectiveLabs/mainnet-config
cp mainnet-config/10001/genesis.json ~/.injectived/config/genesis.json
cp mainnet-config/10001/app.toml  ~/.injectived/config/app.toml
sha256sum ~/.injectived/config/genesis.json # 573b89727e42b41d43156cd6605c0c8ad4a1ce16d9aad1e1604b02864015d528

### Update `persistent_peers` with the seeds value and `timeout_commit = 2500ms`.
cat mainnet-config/10001/seeds.txt
vi ~/.injectived/config/config.toml

### Start syncing the node
injectived start

## For testnet.

### Download the binaries.
export INJ_VER=v0.4.17-1635998233
mkdir ~/Downloads/$INJ_VER
cd ~/Downloads/$INJ_VER
wget https://github.com/InjectiveLabs/injective-chain-releases/releases/download/$INJ_VER/linux-amd64.zip

### Unzip and add the binaries to the path.
unzip linux-amd64.zip
sudo mv -i injectived peggo injective-exchange /usr/bin

### Check the version.
injectived version # Version dev (639589c)
peggo version # Version dev (5c7638b)
injective-exchange version # Version dev (102daa7)

### Initialize a new chain node.
./testnet.sh
injectived init $MONIKER --chain-id $CHAIN_ID

### Complete the preparations.
git clone https://github.com/InjectiveLabs/testnet-config/
cp testnet-config/staking/40017/genesis.json ~/.injectived/config/genesis.json
cp testnet-config/staking/40017/app.toml  ~/.injectived/config/app.toml

### Update `persistent_peers` with the seeds value and `timeout_commit = 1500ms`.
cat testnet-config/staking/40017/seeds.txt
vi ~/.injectived/config/config.toml

### Start syncing the node.
injectived start

### Create the validator account.
export VALIDATOR_KEY_NAME=validator-inj
injectived keys add $VALIDATOR_KEY_NAME
export VALIDATOR_ADDR=<>
export VALIDATOR_PUBKEY=$(injectived tendermint show-validator)

### Copy the secret phase.

### Transfer KINJ token to the validator account

### Check for balance.
injectived q bank balances $VALIDATOR_ADDR

# Create validator.
AMOUNT=3000000000000000000inj # 3inj
MAX_CHANGE_RATE=0.1
MAX_RATE=0.4
RATE=0.05
MIN_SELF_DELEGATION=1000000000000000000 # 1inj
injectived tx staking create-validator \
--moniker=$MONIKER \
--amount=$AMOUNT \
--pubkey=$VALIDATOR_PUBKEY \
--from=$VALIDATOR_KEY_NAME \
--keyring-backend=file \
--node=tcp://localhost:26657 \
---chain-id=$CHAIN_ID \
--commission-max-change-rate=$MAX_CHANGE_RATE \
--commission-max-rate=$MAX_RATE \
--commission-rate=$RATE \
--min-self-delegation=$MIN_SELF_DELEGATION
--identity=
--security-contact=
--website=
