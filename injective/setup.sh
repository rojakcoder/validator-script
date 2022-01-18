# Setting up a node

## Prerequisites

mkdir -p ~/Downloads
cd ~/Downloads
sudo apt-get install -y unzip

### Install Go Ethereum

#;https://geth.ethereum.org/docs/install-and-build/installing-geth
sudo add-apt-repository -y ppa:ethereum/ethereum
sudo apt-get update
sudo apt-get install ethereum

### Get an account with Infura

#;infura.io

## Using a snapshot for mainnet.

### Check out https://docs.injective.network/docs/staking/mainnet/validate-on-mainnet/sync-from-snapshot/

### 1A. Install awscli
mkdir -p ~/Downloads
cd ~/Downloads
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

### Download the snapshot without using any credentials.
aws s3 sync --delete s3://injective-snapshots/mainnet/injectived/data  /mnt/injective/data/ --no-sign-request

./mainnet.sh

### Download the latest binaries.
mkdir ~/Downloads/$INJ_VER
cd ~/Downloads/$INJ_VER
wget https://github.com/InjectiveLabs/injective-chain-releases/releases/download/$INJ_VER/linux-amd64.zip

### Unzip and add the binaries to the path.
unzip linux-amd64.zip
sudo mv -i injectived peggo injective-exchange /usr/bin

### Check the version.
injectived version #Version dev (096cbe5)
peggo version # Version dev (5c7638b)
injective-exchange version # Version dev (102daa7)

### Initialize a new chain node.
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

### Configure as validator

See section "Create the validator account".

## 1B. For testnet.
./testnet.sh

### Download the binaries.
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
injectived init $MONIKER --chain-id $CHAIN_ID

### Complete the preparations.

git clone https://github.com/InjectiveLabs/testnet-config/
cp testnet-config/staking/$TESTNET_VER/genesis.json ~/.injectived/config/genesis.json
cp testnet-config/staking/$TESTNET_VER/app.toml  ~/.injectived/config/app.toml
sha256sum ~/.injectived/config/genesis.json # e45b7c97d2afb37b9529e7dc234a410ff5cc8961adef2d39a3ef6923c0acfb22

### Update `persistent_peers` with the seeds value and `timeout_commit = 1500ms`.
cat testnet-config/staking/$TESTNET_VER/seeds.txt
vi ~/.injectived/config/config.toml

### Start syncing the node.
injectived start

### Configure as validator

See section "Create the validator account" below.

## 2. Create the validator account.
injectived keys add $VALIDATOR_KEY_NAME
export VALIDATOR_ADDR=$(injectived keys show $VALIDATOR_KEY_NAME | grep address | cut -d' ' -f4)
export VALIDATOR_PUBKEY=$(injectived tendermint show-validator)

### Store the secret phase!

### Transfer KINJ token to the validator account

#;For testnet tokens: https://faucet.injective.network
#;For mainnet tokens: obtain some real INJ on Mainnet Ethereum (ERC-20 token address 0xe28b3b32b6c345a34ff64674606124dd5aceca30). https://chain.injective.network/guides/mainnet/becoming-a-validator.html#step-3-transfer-inj-to-your-validator-account-on-the-injective-chain

### Check for balance.
injectived q bank balances $VALIDATOR_ADDR

#;Create validator.
AMOUNT=3000000000000000000inj # 3inj
MAX_CHANGE_RATE=0.5
MAX_RATE=0.5
RATE=0.01
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

#After setting up the validator, the next step is to set up the Ethereum Bridge Relayer. https://chain.injective.network/guides/testnet/peggo.html

## 3A. Configure Peggo (mainnet)

mkdir ~/.peggo
cp mainnet-config/10001/peggo-config.env ~/.peggo/.env
cd ~/.peggo

#;Update PEGGO_ETH_RPC in .env with a valid Ethereum EVM RPC endpoint.

injectived keys add $ORCHESTRATOR_KEY_NAME
export ORCHESTRATOR_ADDR=$(injectived keys show $ORCHESTRATOR_KEY_NAME | grep address | cut -d' ' -f4)

#;Update the passphrase for the key.
PEGGO_COSMOS_FROM=$ORCHESTRATOR_KEY_NAME
PEGGO_COSMOS_FROM_PASSPHRASE=<>

### Manage Ethereum keys for peggo

geth account new --datadir=$HOME/.peggo/data

#;Update the environment file with these keys.

PEGGO_ETH_KEYSTORE_DIR=$HOME/.peggo/data/keystore
PEGGO_ETH_FROM=0x<>
PEGGO_ETH_PASSPHRASE=<>
#;export ETHEREUM_ADDR=PEGGO_ETH_FROM

### Transfer some tokens to the Ethereum wallet



### Register Ethereum address

injectived tx peggy set-orchestrator-address $VALIDATOR_ADDR $ORCHESTRATOR_ADDR $ETHEREUM_ADDR --from $VALIDATOR_KEY_NAME --chain-id=$CHAIN_ID --yes --gas-prices=500000000inj

### Start the relayer

peggo orchestrator

## 3B. Configure Peggo (testnet)

mkdir ~/.peggo
cp testnet-config/staking/$TESTNET_VER/peggo-config.env ~/.peggo/.env
cd ~/.peggo

#;Update PEGGO_ETH_RPC in .env with a Kovan EVM RPC endpoint.

injectived keys add $ORCHESTRATOR_KEY_NAME
export ORCHESTRATOR_ADDR=$(injectived keys show $ORCHESTRATOR_KEY_NAME | grep address | cut -d' ' -f4)

#;Update the passphrase for the key.
PEGGO_COSMOS_FROM=$ORCHESTRATOR_KEY_NAME
PEGGO_COSMOS_FROM_PASSPHRASE=<>

### Manage Ethereum keys for peggo

geth account new --datadir=$HOME/.peggo/data/

#;Update the environment file with these keys.

PEGGO_ETH_KEYSTORE_DIR=$HOME/.peggo/data/keystore
PEGGO_ETH_FROM=0x<>
PEGGO_ETH_PASSPHRASE=<>
#;export ETHEREUM_ADDR=PEGGO_ETH_FROM

### Get some tokens

#;For testnet: https://gitter.im/kovan-testnet/faucet

### Register Ethereum address

peggo tx register-eth-key

#;Verify registration by checking for validator's mapped ethereum address at https://staking-lcd-testnet.injective.network/peggy/v1/valset/current

### Start the relayer

peggo orchestrator

#;Verify by checking at https://staking-lcd-testnet.injective.network/peggy/v1/valset/current
