# Setting up a Desmos validator

A custom seed may be used to create the node.

```bash
# Get a random seed phrase.
desmos keys add node --dry-run
desmos init AuraStake --recover
```

### Getting the genesis file

```bash
curl https://raw.githubusercontent.com/desmos-labs/mainnet/main/genesis.json > ~/.desmos/config/genesis.json

jq -S -c -M '' /root/.desmos/config/genesis.json | shasum -a 256
# 619c9462ccd9045522300c5ce9e7f4662cac096eed02ef0535cca2a6826074c4  -
```

[Reference](https://docs.desmos.network/mainnet/genesis-file)

### Get the seed nodes

```
seeds = "9bde6ab4e0e00f721cc3f5b4b35f3a0e8979fab5@seed-1.mainnet.desmos.network:26656,5c86915026093f9a2f81e5910107cf14676b48fc@seed-2.mainnet.desmos.network:26656,45105c7241068904bdf5a32c86ee45979794637f@seed-3.mainnet.desmos.network:26656"
```

[Reference](https://docs.desmos.network/mainnet/seeds)

### State sync

This is Tendermint's _state sync_ feature. Desmos 0.15.0 onwards has support for this.

[Reference](https://docs.desmos.network/mainnet/state-sync)