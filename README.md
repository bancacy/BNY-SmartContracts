# Bancacy

[![Build Status](https://travis-ci.com/bancacy/uEquilibriums.svg?token=xxNsLhLrTiyG3pc78i5v&branch=master)](https://travis-ci.com/bancacy/uEquilibriums)&nbsp;&nbsp;[![Coverage Status](https://coveralls.io/repos/github/equprotocol/uEquilibriums/badge.svg?branch=master&t=GiWi8p)](https://coveralls.io/github/equprotocol/uEquilibriums?branch=master)

Bancacy (code name uEquilibriums) is a decentralized Stablecoin protocol. It maintains a stable unit price by adjusting supply directly to and from wallet holders. You can read (https://www.bancacy.com) for the motivation and a complete description of the protocol.

This repository is a collection of smart contracts that implement the Bancacy protocol on the Ethereum blockchain.

The official contract addresses are:
- ERC-20 Token: 
- Supply Policy: 

## Table of Contents

- [Install](#install)
- [Testing](#testing)
- [Contribute](#contribute)
- [License](#license)


## Install

```bash
# Install project dependencies
npm install

# Install ethereum local blockchain(s) and associated dependencies
npx setup-local-chains
```

## Testing

``` bash
# You can use the following command to start a local blockchain instance
npx start-chain [ganacheUnitTest|gethUnitTest]

# Run all unit tests
npm test

# Run unit tests in isolation
npx truffle --network ganacheUnitTest test test/unit/uEquilibriums.js
```

## Contribute

To report bugs within this package, please create an issue in this repository.
When submitting code ensure that it is free of lint errors and has 100% test coverage.

``` bash
# Lint code
npm run lint

# View code coverage
npm run coverage
```

## License
[GNU General Public License v3.0 (c) 2018 Fregments, Inc.](./LICENSE)
[GNU General Public License v3.0 (c) 2020 Equilibriums, Inc.](./LICENSE)
