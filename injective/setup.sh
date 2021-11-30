mkdir -p ~/Downloads
cd ~/Downloads

# Download the binaries.
wget https://github.com/InjectiveLabs/injective-chain-releases/releases/download/v0.4.17-1635998233/linux-amd64.zip

# Unzip and add the binaries to the path.
unzip linux-amd64.zip
sudo mv -i injectived peggo injective-exchange /usr/bin

# Check the version.
injectived version
# Version dev (639589c)

peggo version
# Version dev (5c7638b)

injective-exchange version
# Version dev (102daa7)

# Initialize a new chain node.
export MONIKER=CloverStake
injectived init $MONIKER --chain-id injective-888

# Complete the preparations.
git clone https://github.com/InjectiveLabs/testnet-config/

# copy genesis file to config directory
cp testnet-config/staking/40017/genesis.json ~/.injectived/config/genesis.json

# copy config file to config directory
cp testnet-config/staking/40017/app.toml  ~/.injectived/config/app.toml

# Add seeds to `persistent_peers`.
cat testnet-config/staking/40017/seeds.txt
vi ~/.injectived/config/config.toml

# Change timeout_commit = 1500ms
vi ~/.injectived/config/config.toml

# Start the node.
injectived start

# Create the validator account.
export VALIDATOR_KEY_NAME=validator-inj
injectived keys add $VALIDATOR_KEY_NAME
export VALIDATOR_ADDR=<>
export VALIDATOR_PUBKEY=$(injectived tendermint show-validator)

# Copy the secret phase.

# Transfer KINJ token to the validator account

# Check for balance.
injectived q bank balances $VALIDATOR_ADDR

# Create validator.
AMOUNT=30000000000000000000inj # 10inj
MAX_CHANGE_RATE=0.1
MAX_RATE=0.4
RATE=0.05
MIN_SELF_DELEGATION=1000000000000000000inj
injectived tx staking create-validator \
--moniker=$MONIKER \
--amount=$AMOUNT \
--pubkey=$VALIDATOR_PUBKEY \
--from=$VALIDATOR_KEY_NAME \
--keyring-backend=file
--node=tcp://localhost:26657 \
--chain-id=injective-888 \
--commission-max-change-rate=$MAX_CHANGE_RATE \
--commission-max-rate=$MAX_RATE \
--commission-rate=$RATE \
--min-self-delegation=$MIN_SELF_DELEGATION

#####
# Sync the node
##  Install awscli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
